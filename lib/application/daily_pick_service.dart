import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/recipe_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/json_reader.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/daily_fallback.dart';
import '../domain/feasibility.dart';
import '../domain/ingredient_matcher.dart';
import '../domain/stock_index.dart';
import '../domain/validation/recipe_validator.dart';
import 'ai_gateway.dart';
import 'clock.dart';
import 'profile_service.dart';

class PickOutcome {
  PickOutcome({this.recipe, this.fromAi = false, this.isFallback = false, this.error, this.shopping = const []});
  final Recipe? recipe;
  final bool fromAi;
  final bool isFallback;
  final String? error;

  /// Filled when the pantry can't support a meal ("insufficient_stock").
  final List<ShoppingDto> shopping;
}

/// Prompt B: one stock-only recipe per day, with an offline fallback.
class DailyPickService {
  DailyPickService({required this.isar, required this.ai, Now? now}) : now = now ?? DateTime.now;

  final Isar isar;
  final AiGateway ai;
  final Now now;

  static const maxSwaps = 2;

  /// After a failed pick, [ensure] shows the saved-recipe fallback instead of asking again, for
  /// this long after a quota or network error...
  static const retryAfterTransient = Duration(minutes: 15);

  /// ...and, after an answer that didn't work out, until the pantry changes or this has passed.
  static const retryAfterFailure = Duration(hours: 4);

  final _generating = <int, Future<PickOutcome>>{};
  final _failed = <int, ({DateTime at, int pantry, bool transient, PickOutcome outcome})>{};

  Future<DayClock> _clock() async => ProfileService.clockFor((await isar.userProfiles.get(1))!);

  /// Changes when anything is bought, used or counted.
  static int _pantryStamp(Iterable<Ingredient> all) =>
      Object.hashAllUnordered(all.map((i) => Object.hash(i.key, i.qtyOnHand.round())));

  Future<Recipe?> pickFor(int dateKey) async {
    final list = await isar.recipes.where().suggestedForDateKeyEqualTo(dateKey).findAll();
    final active = list.where((r) => r.status != RecipeStatus.dismissed).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.firstOrNull;
  }

  Future<int> swapsUsed(int dateKey) async => (await isar.recipes.where().suggestedForDateKeyEqualTo(dateKey).findAll())
      .where((r) => r.status == RecipeStatus.dismissed)
      .length;

  /// Existing pick if still cookable, otherwise a fresh one (AI or fallback). Without [force],
  /// a pick that failed a moment ago isn't asked for again until [retryAfterTransient] or, for
  /// an answer that didn't work out, until the pantry changes ([retryAfterFailure] at most).
  Future<PickOutcome> ensure({
    DateTime? forDate,
    bool force = false,
    List<String> rejected = const [],
    AiPriority priority = AiPriority.background,
  }) async {
    final clock = await _clock();
    final target = forDate ?? now();
    final key = clock.dateKey(target);
    final ingredients = await isar.ingredients.where().findAll();
    final stock = StockIndex(ingredients);
    final existing = await pickFor(key);
    if (existing != null && !force) {
      final cookedToday = existing.lastCookedAt != null && clock.dateKey(existing.lastCookedAt!) == key;
      final f = FeasibilityChecker.check(existing.ingredients, existing.defaultPortions, stock);
      if (cookedToday || f.maxPortionsNow >= 1) return PickOutcome(recipe: existing, fromAi: true);
    }
    final runner = await ai.runner();
    if (runner == null) return _fallback(stock, error: 'No API key: showing a saved recipe.');
    final failed = _failed[key];
    if (failed != null && !force) {
      final age = now().difference(failed.at);
      final recent = failed.transient
          ? age < retryAfterTransient
          : age < retryAfterFailure && failed.pantry == _pantryStamp(ingredients);
      if (recent) {
        return failed.outcome.shopping.isNotEmpty ? failed.outcome : _fallback(stock, error: failed.outcome.error);
      }
    }
    final outcome = await generate(key, rejected: rejected, priority: priority);
    if (outcome.recipe != null || outcome.shopping.isNotEmpty) {
      if (existing != null && outcome.recipe != null && existing.timesCooked == 0) {
        await isar.writeTxn(() => isar.recipes.put(existing..status = RecipeStatus.dismissed));
      }
      return outcome;
    }
    return _fallback(stock, error: outcome.error);
  }

  Future<PickOutcome> _fallback(StockIndex stock, {String? error}) async {
    final profile = (await isar.userProfiles.get(1))!;
    final saved = await isar.recipes
        .filter()
        .group((q) => q.statusEqualTo(RecipeStatus.saved).or().favoriteEqualTo(true).or().timesCookedGreaterThan(0))
        .findAll();
    final ranked = DailyFallback.rank(
      saved.where((r) => r.status != RecipeStatus.archived),
      stock,
      now(),
      proteinTarget: profile.dailyProteinTargetG / (profile.mealsPerDay < 1 ? 1 : profile.mealsPerDay),
      targetCostMinor: profile.targetCostPerPortionMinor,
    );
    return PickOutcome(recipe: ranked.firstOrNull?.recipe, isFallback: true, error: error);
  }

  Future<List<String>> _recentTitles(DateTime t) async {
    final since = t.subtract(const Duration(days: 14));
    final recent = await isar.recipes
        .filter()
        .createdAtGreaterThan(since)
        .or()
        .lastCookedAtGreaterThan(since)
        .findAll();
    recent.sort((a, b) => (b.lastCookedAt ?? b.createdAt).compareTo(a.lastCookedAt ?? a.createdAt));
    return recent.map((r) => r.title).toSet().take(20).toList();
  }

  /// Calls Prompt B for [dateKey] and stores the validated recipe. Callers asking for the same
  /// day at once (a new key rebuilds the pick and refreshes it) share one request.
  Future<PickOutcome> generate(
    int dateKey, {
    List<String> rejected = const [],
    AiPriority priority = AiPriority.background,
  }) async {
    final shared = rejected.isEmpty;
    final running = shared ? _generating[dateKey] : null;
    if (running != null) return running;
    final run = _generate(dateKey, rejected, priority);
    if (shared) _generating[dateKey] = run;
    try {
      return await run;
    } finally {
      _generating.removeWhere((_, f) => identical(f, run));
    }
  }

  Future<PickOutcome> _generate(int dateKey, List<String> rejected, AiPriority priority) async {
    final runner = await ai.runner();
    if (runner == null) return PickOutcome(error: 'No API key');
    final profile = (await isar.userProfiles.get(1))!;
    final ingredients = await isar.ingredients.where().findAll();
    final stock = StockIndex(ingredients);
    final matcher = IngredientMatcher(ingredients);
    final t = now();
    final ctx = ContextBuilders.daily(
      profile: profile,
      ingredients: ingredients,
      now: t,
      forDate: DayClock.dateOfKey(dateKey),
      recentTitles: await _recentTitles(t),
      rejectedToday: rejected,
    );
    RecipeValidation? validation;
    final prompt = await ai.prompts.load(PromptRepository.daily);
    final outcome = await runner.run<DailyRecipeOutput>(
      task: AiTask.dailyRecipe,
      promptVersion: PromptRepository.daily,
      request: GeminiRequest(
        systemPrompt: prompt,
        turns: [Turn.user(jsonEncode(ctx))],
        thinkingLevel: 'medium',
        responseSchema: AiSchemas.daily,
        maxOutputTokens: 8192,
        priority: priority,
      ),
      parse: (json) {
        final parsed = DailyRecipeOutput.parse(json);
        if (!parsed.ok || parsed.value!.recipe == null) return parsed;
        final v = RecipeValidator.validate(
          parsed.value!.recipe!,
          stock: stock,
          matcher: matcher,
          profile: profile,
          allowMissing: false,
          origin: RecipeOrigin.dailyAuto,
        );
        if (!v.ok) return ParseResult(null, v.hardErrors);
        validation = v;
        return parsed;
      },
    );
    PickOutcome failed(PickOutcome o, {bool transient = false}) {
      _failed[dateKey] = (at: now(), pantry: _pantryStamp(ingredients), transient: transient, outcome: o);
      return o;
    }

    if (!outcome.ok) {
      return failed(PickOutcome(error: outcome.errors.firstOrNull ?? 'AI error'), transient: outcome.transient);
    }
    final out = outcome.value!;
    if (out.status == 'insufficient_stock' || validation == null) {
      return failed(
        PickOutcome(shopping: out.shoppingSuggestions, error: 'Not enough in the pantry for a proper meal.'),
      );
    }
    _failed.remove(dateKey);
    final recipe = validation!.recipe!
      ..suggestedForDateKey = dateKey
      ..promptVersion = PromptRepository.daily
      ..createdAt = t;
    await isar.writeTxn(() => isar.recipes.put(recipe));
    return PickOutcome(recipe: recipe, fromAi: true);
  }

  /// Dismisses today's pick and asks for a different one (max 2 per day).
  Future<PickOutcome> swap() async {
    final clock = await _clock();
    final key = clock.dateKey(now());
    final used = await swapsUsed(key);
    if (used >= maxSwaps) return PickOutcome(recipe: await pickFor(key), error: 'Swap limit reached for today.');
    final current = await pickFor(key);
    if (current != null) {
      await isar.writeTxn(() => isar.recipes.put(current..status = RecipeStatus.dismissed));
    }
    final rejected = (await isar.recipes.where().suggestedForDateKeyEqualTo(key).findAll())
        .where((r) => r.status == RecipeStatus.dismissed)
        .map((r) => r.title)
        .toList();
    final res = await generate(key, rejected: rejected, priority: AiPriority.user);
    if (res.recipe == null && current != null) {
      // Put the old one back rather than leaving the card empty.
      await isar.writeTxn(() => isar.recipes.put(current..status = RecipeStatus.suggested));
      return PickOutcome(recipe: current, fromAi: true, error: res.error);
    }
    return res;
  }
}
