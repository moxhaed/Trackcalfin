import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/quick_log_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/price_book.dart';
import '../domain/quick_log.dart';
import 'ai_gateway.dart';
import 'clock.dart';
import 'profile_service.dart';
import 'recipe_service.dart';

/// What the user said, as Prompt G read it: the actions and the card's steps, or why not.
class QuickLogDraft {
  QuickLogDraft({required this.said, this.log, this.steps = const [], this.error});
  final String said;
  final QuickLog? log;
  final List<QuickStep> steps;
  final String? error;

  String? get question => log?.question;
}

/// What a saved quick log changed, so Undo can put it all back.
class QuickLogReceipt {
  QuickLogReceipt({
    required this.steps,
    required this.transactions,
    required this.ingredients,
    required this.sessions,
    required this.logs,
    required this.uses,
    required this.ingredientsBefore,
    required this.sessionsBefore,
    required this.logsBefore,
    required this.recipesBefore,
  });
  final List<QuickStep> steps;

  // Created, so Undo deletes them.
  final List<int> transactions;
  final List<int> ingredients;
  final List<int> sessions;
  final List<int> logs;
  final List<int> uses;

  // Changed, as they were before, so Undo puts them back.
  final List<Ingredient> ingredientsBefore;
  final List<CookSession> sessionsBefore;
  final List<DailyLog> logsBefore;
  final List<Recipe> recipesBefore;
}

/// "Say it": the user tells the app what they did, Prompt G turns it into actions, Dart
/// checks and computes them, the user confirms, and it is all saved in one transaction.
class QuickLogService {
  QuickLogService({required this.isar, required this.ai, Now? now}) : now = now ?? DateTime.now;

  final Isar isar;
  final AiGateway ai;
  final Now now;

  Future<QuickLogDraft> interpret(String said) async {
    final text = said.trim();
    if (text.isEmpty) return QuickLogDraft(said: said, error: 'Say or type what you did.');
    final runner = await ai.runner();
    if (runner == null) return QuickLogDraft(said: text, error: 'Add a Gemini API key in Settings to use Say it.');
    final t = now();
    final profile = await isar.userProfiles.get(1) ?? ProfileService.defaults();
    final ingredients = await isar.ingredients.where().findAll();
    final fridge = await _fridge();
    final recipes = await isar.recipes.filter().not().statusEqualTo(RecipeStatus.archived).findAll();
    final ctx = QuickLogContext(
      now: t,
      pantry: {for (final i in ingredients) i.key: i.baseUnit},
      fridge: {for (final s in fridge) s.id: s.portionsRemaining},
      recipes: {for (final r in recipes) r.id},
    );
    final input = ContextBuilders.quickLog(
      profile: profile,
      now: t,
      ingredients: ingredients,
      fridge: fridge,
      recipes: recipes,
      said: text,
    );
    final outcome = await runner.run<QuickLog>(
      task: AiTask.quickLog,
      promptVersion: PromptRepository.quickLog,
      request: GeminiRequest(
        systemPrompt: await ai.prompts.load(PromptRepository.quickLog),
        turns: [Turn.user(jsonEncode(input))],
        thinkingLevel: 'low',
        responseSchema: AiSchemas.quickLog,
        maxOutputTokens: 4096,
        timeout: const Duration(seconds: 30),
      ),
      parse: (m) => QuickLog.parse(m, ctx: ctx),
    );
    if (!outcome.ok) return QuickLogDraft(said: text, error: outcome.errors.firstOrNull ?? 'Unknown error');
    final log = outcome.value!;
    return QuickLogDraft(said: text, log: log, steps: await preview(log));
  }

  /// What [log] would do now, without saving anything: the card.
  Future<List<QuickStep>> preview(QuickLog log, {Set<int> skip = const {}, Map<int, int> paid = const {}}) async =>
      _plan(log, await _world(log), skip, paid);

  /// Saves [log] in one transaction, planned again on what is in the database right now.
  Future<QuickLogReceipt> apply(QuickLog log, {Set<int> skip = const {}, Map<int, int> paid = const {}}) {
    return isar.writeTxn(() async {
      final w = await _world(log);
      final steps = _plan(log, w, skip, paid);
      // Nothing is written yet, so these reads are the state before.
      final created = w.created.toSet();
      final ingredientsBefore = (await isar.ingredients.getAll([
        for (final i in w.changedIngredients)
          if (!created.contains(i)) i.id,
      ])).whereType<Ingredient>().toList();
      final sessionsBefore = (await isar.cookSessions.getAll([
        for (final s in w.changedSessions) s.id,
      ])).whereType<CookSession>().toList();
      final logsBefore = (await isar.dailyLogs.getAll([
        for (final l in w.changedLogs)
          if (l.id != Isar.autoIncrement) l.id,
      ])).whereType<DailyLog>().toList();
      final recipesBefore = (await isar.recipes.getAll([
        for (final r in w.changedRecipes) r.id,
      ])).whereType<Recipe>().toList();

      // New ingredients first: purchases and cook sessions point at their ids.
      final ingredientIds = <int, int>{};
      for (final ing in w.created) {
        final standIn = ing.id;
        ing.id = Isar.autoIncrement;
        ingredientIds[standIn] = await isar.ingredients.put(ing);
      }
      for (final tx in w.transactions) {
        for (final l in tx.lines) {
          if (ingredientIds.containsKey(l.ingredientId)) l.ingredientId = ingredientIds[l.ingredientId];
        }
      }
      final sessionIds = <int, int>{};
      for (final s in w.sessions) {
        for (final d in s.deltas) {
          if (ingredientIds.containsKey(d.ingredientId)) d.ingredientId = ingredientIds[d.ingredientId]!;
        }
        final standIn = s.id;
        s.id = Isar.autoIncrement;
        sessionIds[standIn] = await isar.cookSessions.put(s);
      }
      for (final l in w.changedLogs) {
        for (final m in l.meals) {
          if (sessionIds.containsKey(m.cookSessionId)) m.cookSessionId = sessionIds[m.cookSessionId];
        }
      }
      final newLogs = [
        for (final l in w.changedLogs)
          if (l.id == Isar.autoIncrement) l,
      ];
      final txIds = await isar.transactions.putAll(w.transactions);
      final useIds = await isar.foodUses.putAll(w.uses);
      await isar.ingredients.putAll(w.changedIngredients.where((i) => !created.contains(i)).toList());
      await isar.cookSessions.putAll(w.changedSessions.toList());
      await isar.dailyLogs.putAll(w.changedLogs.toList());
      await isar.recipes.putAll(w.changedRecipes.toList());
      // Prices and stock changed: recipes using these items are costed again.
      await RecipeService.refreshUsing(isar, {for (final i in w.changedIngredients) i.id});
      return QuickLogReceipt(
        steps: steps,
        transactions: txIds,
        ingredients: ingredientIds.values.toList(),
        sessions: sessionIds.values.toList(),
        logs: [for (final l in newLogs) l.id],
        uses: useIds,
        ingredientsBefore: ingredientsBefore,
        sessionsBefore: sessionsBefore,
        logsBefore: logsBefore,
        recipesBefore: recipesBefore,
      );
    });
  }

  /// Puts everything [r] changed back, in one transaction.
  Future<void> undo(QuickLogReceipt r) {
    return isar.writeTxn(() async {
      await isar.transactions.deleteAll(r.transactions);
      await isar.cookSessions.deleteAll(r.sessions);
      await isar.dailyLogs.deleteAll(r.logs);
      await isar.foodUses.deleteAll(r.uses);
      await isar.ingredients.deleteAll(r.ingredients);
      await isar.ingredients.putAll(r.ingredientsBefore);
      await isar.cookSessions.putAll(r.sessionsBefore);
      await isar.dailyLogs.putAll(r.logsBefore);
      await isar.recipes.putAll(r.recipesBefore);
      await RecipeService.refreshUsing(isar, {for (final i in r.ingredientsBefore) i.id});
    });
  }

  List<QuickStep> _plan(QuickLog log, QuickLogWorld w, Set<int> skip, Map<int, int> paid) => QuickLogPlanner.plan(
    log,
    w,
    now: now(),
    clock: ProfileService.clockFor(w.profile),
    money: ProfileService.moneyFor(w.profile),
    skip: skip,
    paid: paid,
  );

  Future<List<CookSession>> _fridge() =>
      isar.cookSessions.where().statusEqualTo(CookStatus.active).sortByCookedAt().findAll();

  /// What [log] may change, fresh from the database.
  Future<QuickLogWorld> _world(QuickLog log) async {
    final t = now();
    final profile = await isar.userProfiles.get(1) ?? ProfileService.defaults();
    final clock = ProfileService.clockFor(profile);
    final days = {
      for (final a in log.actions)
        if (a.type == QuickActionType.eat || a.type == QuickActionType.cook) clock.dateKey(a.when ?? t),
    };
    final ingredients = await isar.ingredients.where().findAll();
    return QuickLogWorld(
      ingredients: ingredients,
      fridge: await _fridge(),
      recipes: (await isar.recipes.getAll([
        for (final a in log.actions)
          if (a.recipeId != null) a.recipeId!,
      ])).whereType<Recipe>().toList(),
      logs: (await isar.dailyLogs.getAllByDateKey(days.toList())).whereType<DailyLog>().toList(),
      profile: profile,
      prices: log.actions.any((a) => a.type == QuickActionType.priceCheck)
          ? PriceBook.from(
              await isar.transactions.where().occurredAtGreaterThan(DayClock.addDays(t, -PriceBook.maxDays)).findAll(),
              now: t,
              units: {for (final i in ingredients) i.key: i.baseUnit},
            )
          : null,
    );
  }
}
