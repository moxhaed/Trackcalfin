import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/recipe_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/json_reader.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/feasibility.dart';
import '../domain/ingredient_matcher.dart';
import '../domain/stock_index.dart';
import '../domain/units.dart';
import '../domain/validation/recipe_validator.dart';
import 'ai_gateway.dart';
import 'clock.dart';

class AskOutcome {
  AskOutcome({this.recipe, this.summary, this.error, this.notARecipe = false});
  final Recipe? recipe;
  final String? summary;
  final String? error;
  final bool notARecipe;
}

/// Prompt C: "Can I cook this?" with a Dart-computed verdict.
class AskService {
  AskService({required this.isar, required this.ai, Now? now}) : now = now ?? DateTime.now;

  final Isar isar;
  final AiGateway ai;
  final Now now;

  Future<AskOutcome> ask(String request) async {
    final text = request.trim();
    if (text.isEmpty) return AskOutcome(error: 'Say or type what you want to cook.');
    final runner = await ai.runner();
    if (runner == null) return AskOutcome(error: 'Add a Gemini API key in Settings to ask for recipes.');
    final profile = (await isar.userProfiles.get(1))!;
    final ingredients = await isar.ingredients.where().findAll();
    final stock = StockIndex(ingredients);
    final matcher = IngredientMatcher(ingredients);
    final staples = ingredients.where((i) => i.isStaple).map((i) => i.key).toSet();
    final ctx = ContextBuilders.spontaneous(profile: profile, ingredients: ingredients, now: now(), request: text);
    RecipeValidation? validation;
    final prompt = await ai.prompts.load(PromptRepository.spontaneous);
    final outcome = await runner.run<SpontaneousOutput>(
      task: AiTask.spontaneousRecipe,
      promptVersion: PromptRepository.spontaneous,
      request: GeminiRequest(
        systemPrompt: prompt,
        turns: [Turn.user(jsonEncode(ctx))],
        thinkingLevel: 'medium',
        responseSchema: AiSchemas.spontaneous,
        maxOutputTokens: 8192,
      ),
      parse: (json) {
        final parsed = SpontaneousOutput.parse(json);
        if (!parsed.ok || parsed.value!.recipe == null) return parsed;
        final v = RecipeValidator.validate(
          parsed.value!.recipe!,
          stock: stock,
          matcher: matcher,
          stapleKeys: staples,
          profile: profile,
          allowMissing: true,
          origin: RecipeOrigin.spontaneous,
        );
        if (!v.ok) return ParseResult(null, v.hardErrors);
        validation = v;
        return parsed;
      },
    );
    if (!outcome.ok) return AskOutcome(error: outcome.errors.firstOrNull ?? 'AI error');
    final out = outcome.value!;
    if (out.status == 'not_a_recipe' || validation == null) {
      return AskOutcome(
        notARecipe: true,
        summary: out.summary.isEmpty ? "That doesn't sound like a dish." : out.summary,
      );
    }

    final recipe = validation!.recipe!;
    final f = FeasibilityChecker.check(recipe.ingredients, recipe.defaultPortions, stock);
    final verdict = RecipeValidator.verdict(recipe, f, out.omitted);
    var summary = out.summary;
    if (verdict != out.status) summary = _dartSummary(verdict, f);

    final shopping = [
      for (final s in out.shoppingList)
        ShoppingItem()
          ..name = s.name
          ..packageDesc = s.packageDesc
          ..estCostMinor = s.estCostMinor
          ..reason = s.reason,
    ];
    for (final s in f.shortfalls) {
      final name = s.ingredient?.name ?? s.item.name;
      if (shopping.any((x) => x.name.toLowerCase().contains(name.toLowerCase()))) continue;
      shopping.add(
        ShoppingItem()
          ..name = name
          ..packageDesc = 'short by ${UnitConverter.format(s.missing, s.unit)}'
          ..estCostMinor = ((s.ingredient?.avgCostPerUnitMinor ?? 0) * s.missing).round()
          ..reason = 'short',
      );
    }

    recipe
      ..sourceQuery = text
      ..feasibilityStatus = verdict
      ..summary = summary
      ..omitted = out.omitted
      ..shoppingList = shopping
      ..promptVersion = PromptRepository.spontaneous
      ..createdAt = now();
    await isar.writeTxn(() => isar.recipes.put(recipe));
    return AskOutcome(recipe: recipe, summary: summary);
  }

  static String _dartSummary(String verdict, FeasibilityResult f) {
    switch (verdict) {
      case 'ready':
        return 'Ready now with what you have.';
      case 'ready_with_swaps':
        return 'Ready now, with a few swaps.';
      default:
        final parts = <String>[
          ...f.missing.map((m) => 'need $m'),
          ...f.shortfalls.map((s) => 'short on ${s.ingredient?.name ?? s.item.name}'),
        ];
        return parts.isEmpty ? 'Needs a quick shop first.' : 'Not yet: ${parts.take(3).join(', ')}.';
    }
  }
}
