import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/nutrition_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/nutrition.dart';
import 'ai_gateway.dart';
import 'clock.dart';
import 'recipe_service.dart';

/// A nutrition label read and converted, not saved yet: the user checks it first.
class LabelDraft {
  LabelDraft({this.numbers, this.productName, this.error});
  final LabelNumbers? numbers;
  final String? productName;
  final String? error;
  bool get ok => numbers != null;
}

/// Macros per pantry item: AI estimates for the missing ones, label scans and user confirmation.
class NutritionService {
  NutritionService({required this.isar, required this.ai, Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final AiGateway ai;
  final Now now;

  static const batchSize = 40;

  /// After an item's estimate failed n times, it is left out of background runs this long.
  static const backoff = [Duration(minutes: 30), Duration(hours: 2), Duration(hours: 12), Duration(hours: 24)];

  /// After a rate limit or a network error, background runs wait this long.
  static const pauseAfterTransient = Duration(minutes: 10);

  Future<({int filled, String? error})>? _running;
  final _failed = <String, ({int times, DateTime retryAt})>{};
  DateTime? _pausedUntil;

  /// Asks the AI for every ingredient whose macros are unknown (onboarding staples, items added
  /// without numbers). Safe to call often: a call while one runs shares its result, items whose
  /// estimate failed wait out a growing [backoff], and a rate limit pauses background runs. With
  /// nothing new to ask it sends nothing. A [AiPriority.user] call (Fill with AI) asks for every
  /// item now. [error] is set when something could not be asked or answered.
  Future<({int filled, String? error})> fillMissing({AiPriority priority = AiPriority.background}) async {
    final running = _running;
    if (running != null) return running;
    final run = _fill(priority);
    _running = run;
    try {
      return await run;
    } finally {
      _running = null;
    }
  }

  /// Fill with AI: the user asked, so every unknown item is asked for now, ahead of background work.
  Future<({int filled, String? error})> fillMissingNow() => fillMissing(priority: AiPriority.user);

  Future<({int filled, String? error})> _fill(AiPriority priority) async {
    final user = priority == AiPriority.user;
    final t = now();
    if (!user && _pausedUntil != null && t.isBefore(_pausedUntil!)) return (filled: 0, error: null);
    final unknown = await isar.ingredients.filter().nutritionSourceEqualTo(DataSource.none).findAll();
    final todo = [
      for (final i in unknown)
        if (user || !(_failed[i.key]?.retryAt.isAfter(t) ?? false)) i,
    ];
    if (todo.isEmpty) return (filled: 0, error: null);
    final runner = await ai.runner();
    if (runner == null) return (filled: 0, error: 'Add a Gemini API key in Settings first.');
    final profile = (await isar.userProfiles.get(1))!;
    final prompt = await ai.prompts.load(PromptRepository.nutritionEstimate);
    var filled = 0;
    String? error;
    for (var i = 0; i < todo.length; i += batchSize) {
      final batch = todo.sublist(i, math.min(i + batchSize, todo.length));
      final units = {for (final ing in batch) ing.key: ing.baseUnit};
      final outcome = await runner.run<NutritionEstimates>(
        task: AiTask.nutritionEstimate,
        promptVersion: PromptRepository.nutritionEstimate,
        request: GeminiRequest(
          systemPrompt: prompt,
          turns: [Turn.user(jsonEncode(ContextBuilders.nutritionEstimate(profile: profile, items: batch)))],
          thinkingLevel: 'low',
          responseSchema: AiSchemas.nutritionEstimate,
          priority: priority,
        ),
        parse: (m) => NutritionEstimates.parse(m, units: units),
      );
      if (outcome.transient) {
        // Quota or network: the next batches would fail the same way.
        _pausedUntil = now().add(pauseAfterTransient);
        return (filled: filled, error: outcome.errors.firstOrNull ?? 'Unknown error');
      }
      // A batch that still fails after the repair round keeps the items that checked out.
      final items = outcome.ok ? outcome.value!.items : _salvage(outcome.raw, units);
      filled += await _applyEstimates(items);
      final answered = {for (final e in items) e.key};
      for (final key in units.keys) {
        if (answered.contains(key)) {
          _failed.remove(key);
        } else {
          final times = (_failed[key]?.times ?? 0) + 1;
          _failed[key] = (times: times, retryAt: now().add(backoff[math.min(times, backoff.length) - 1]));
        }
      }
      if (!outcome.ok) error ??= outcome.errors.firstOrNull ?? 'Unknown error';
    }
    _pausedUntil = null;
    return (filled: filled, error: error);
  }

  /// The estimates in a rejected answer that pass the checks on their own.
  static List<NutritionEstimateDto> _salvage(String raw, Map<String, BaseUnit> units) {
    if (raw.trim().isEmpty) return const [];
    try {
      final m = jsonDecode(GeminiClient.stripFences(raw));
      if (m is! Map) return const [];
      return NutritionEstimates.parse(m.cast<String, dynamic>(), units: units, lenient: true).value?.items ?? const [];
    } on FormatException {
      return const [];
    }
  }

  Future<int> _applyEstimates(List<NutritionEstimateDto> items) async {
    final t = now();
    return isar.writeTxn(() async {
      final changed = <Ingredient>[];
      for (final e in items) {
        final ing = await isar.ingredients.getByKey(e.key);
        // The user may have typed numbers while the AI was answering.
        if (ing == null || !ing.needsNutrition) continue;
        if (ing.baseUnit == BaseUnit.ml) ing.densityGPerMl ??= e.densityGPerMl;
        if (ing.baseUnit == BaseUnit.pc) ing.gramsPerPiece ??= e.gramsPerPiece;
        ing
          ..per100 = NutritionEngine.per100For(e.per100g, ing.baseUnit, ing.densityGPerMl)
          ..nutritionSource = DataSource.aiEstimate
          ..nutritionConfirmedAt = null
          ..updatedAt = t;
        changed.add(ing);
      }
      await isar.ingredients.putAll(changed);
      await RecipeService.refreshUsing(isar, {for (final i in changed) i.id});
      return changed.length;
    });
  }

  /// Reads a nutrition label photo and converts it to the ingredient's basis. Saves nothing.
  Future<LabelDraft> readLabel(int ingredientId, List<Uint8List> images) async {
    final ing = await isar.ingredients.get(ingredientId);
    if (ing == null) return LabelDraft(error: 'This item no longer exists.');
    final runner = await ai.runner();
    if (runner == null) return LabelDraft(error: 'Add a Gemini API key in Settings to read labels.');
    final prompt = await ai.prompts.load(PromptRepository.nutritionLabel);
    final outcome = await runner.run<LabelReading>(
      task: AiTask.nutritionLabel,
      promptVersion: PromptRepository.nutritionLabel,
      request: GeminiRequest(
        systemPrompt: prompt,
        turns: [Turn.user(jsonEncode(ContextBuilders.nutritionLabel(ing)), images)],
        thinkingLevel: 'low',
        highMediaResolution: true,
        responseSchema: AiSchemas.nutritionLabel,
        maxOutputTokens: 4096,
        timeout: const Duration(seconds: 60),
      ),
      parse: LabelReading.parse,
    );
    if (!outcome.ok) return LabelDraft(error: outcome.errors.firstOrNull ?? 'Unknown error');
    final r = outcome.value!;
    final numbers = NutritionEngine.fromLabel(r, ing);
    if (numbers == null) {
      final why = r.warnings.isEmpty ? '' : ' (${r.warnings.join(', ')})';
      return LabelDraft(
        productName: r.productName,
        error: r.readable ? 'The label shows no energy value$why.' : "Couldn't find a readable nutrition table$why.",
      );
    }
    return LabelDraft(numbers: numbers, productName: r.productName);
  }

  /// Saves macros the user checked (typed, or read from a label) as confirmed.
  Future<void> setNutrition(int ingredientId, Nutrition per100, DataSource source) async {
    final t = now();
    await isar.writeTxn(() async {
      final ing = await isar.ingredients.get(ingredientId);
      if (ing == null) return;
      ing
        ..per100 = per100
        ..nutritionSource = source
        ..nutritionConfirmedAt = t
        ..updatedAt = t;
      await isar.ingredients.put(ing);
      await RecipeService.refreshUsing(isar, {ingredientId});
    });
  }
}
