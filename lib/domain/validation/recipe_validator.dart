import '../../core/enums.dart';
import '../../data/ai/dto/recipe_dto.dart';
import '../../data/isar/collections/recipe.dart';
import '../../data/isar/collections/user_profile.dart';
import '../feasibility.dart';
import '../ingredient_matcher.dart';
import '../nutrition.dart';
import '../stock_index.dart';
import '../units.dart';
import 'allergens.dart';

class RecipeValidation {
  RecipeValidation({this.recipe, required this.hardErrors, required this.flags, this.feasibility});
  final Recipe? recipe;

  /// Errors that trigger the repair retry (never shown as-is).
  final List<String> hardErrors;
  final List<String> flags;
  final FeasibilityResult? feasibility;
  bool get ok => hardErrors.isEmpty && recipe != null;
}

/// Validates a model recipe against stock and profile and computes Dart numbers.
class RecipeValidator {
  const RecipeValidator._();

  static const allowedTags = {
    'high_protein',
    'meal_prep',
    'one_pot',
    'quick',
    'vegetarian',
    'vegan',
    'low_carb',
    'budget',
    'freezer_friendly',
  };

  static String _truncate(String s, int max) => s.length <= max ? s : '${s.substring(0, max - 1).trimRight()}…';

  static RecipeValidation validate(
    RecipeDto dto, {
    required StockIndex stock,
    required IngredientMatcher matcher,
    required Set<String> stapleKeys,
    required UserProfile profile,
    required bool allowMissing,
    required RecipeOrigin origin,
  }) {
    final hard = <String>[];
    final flags = <String>{};
    final items = <RecipeIngredient>[];

    for (final (i, d) in dto.ingredients.indexed) {
      final path = 'recipe.ingredients[$i]';
      // V2: allergens (key and name)
      final allergen =
          AllergenScreen.hit(d.key ?? '', profile.allergies) ?? AllergenScreen.hit(d.name, profile.allergies);
      if (allergen != null) {
        hard.add(
          "$path '${d.name}' conflicts with the user's allergy '$allergen'. Remove it or use a safe substitute.",
        );
        continue;
      }
      if (profile.dislikes.any((x) => x.isNotEmpty && d.name.toLowerCase().contains(x.toLowerCase()))) {
        flags.add('disliked:${d.name}');
      }

      final ri = RecipeIngredient()
        ..name = d.name
        ..qtyPerPortion = d.qtyPerPortion
        ..unit = d.unit
        ..role = d.role
        ..prepNote = d.prepNote
        ..substitutesFor = d.substitutesFor;

      if (d.role == IngredientRole.missing) {
        if (!allowMissing) {
          hard.add('$path must use only inventory or staples in this task');
          continue;
        }
        ri
          ..key = ''
          ..estCostMinor = d.missingCostMinor
          ..estNutritionPerPortion = d.missingNutrition;
        items.add(ri);
        continue;
      }

      final key = d.key ?? '';
      if (d.role == IngredientRole.staple) {
        if (stapleKeys.contains(key)) {
          ri.key = key;
          ri.ingredientId = stock.byKey[key]?.id;
          items.add(ri);
          continue;
        }
        // V4: not a staple -> maybe it's in stock
        final m = matcher.resolve(key: key, name: d.name);
        if (m.ingredient != null) {
          ri
            ..key = m.ingredient!.key
            ..ingredientId = m.ingredient!.id
            ..role = m.ingredient!.isStaple ? IngredientRole.staple : IngredientRole.stock;
          flags.add('staple_remapped:$key');
          items.add(ri);
        } else if (d.qtyPerPortion < 5 && d.unit != BaseUnit.pc) {
          flags.add('staple_dropped:$key');
        } else if (allowMissing) {
          ri
            ..role = IngredientRole.missing
            ..key = '';
          items.add(ri);
          flags.add('converted_to_missing:$key');
        } else {
          hard.add("$path key '$key' is not in staples or inventory");
        }
        continue;
      }

      // Stock role (V3)
      var ing = stock.byKey[key];
      if (ing == null) {
        final m = matcher.resolve(key: key, name: d.name);
        if (m.ingredient != null && m.kind != MatchKind.none) {
          ing = m.ingredient;
          flags.add('remapped_key:$key->${ing!.key}');
        }
      }
      if (ing == null) {
        if (allowMissing) {
          ri
            ..role = IngredientRole.missing
            ..key = '';
          items.add(ri);
          flags.add('converted_to_missing:$key');
        } else {
          hard.add("$path key '$key' is not in inventory; use only keys from inventory or staples");
        }
        continue;
      }
      ri
        ..key = ing.key
        ..ingredientId = ing.id;
      if (ing.isStaple) ri.role = IngredientRole.staple;
      // V5: units
      if (UnitConverter.toBase(d.qtyPerPortion, d.unit, ing) == null) {
        flags.add('unit_mismatch:${ing.key}');
      }
      // V7: bounds per ingredient
      final grams = UnitConverter.ingredientGrams(d.qtyPerPortion, d.unit, ing) ?? d.qtyPerPortion;
      if (grams > 1000) {
        hard.add('$path qty_per_portion ${d.qtyPerPortion} ${d.unit.label} is not a realistic single portion');
        continue;
      }
      items.add(ri);
    }

    if (items.isEmpty && hard.isEmpty) hard.add('recipe.ingredients must contain at least one usable ingredient');
    if (dto.steps.isEmpty) hard.add('recipe.steps must not be empty');

    var portions = dto.portions.clamp(1, 12);
    FeasibilityResult? feas;
    if (hard.isEmpty) {
      feas = FeasibilityChecker.check(items, portions, stock);
      if (!allowMissing && !feas.ready) {
        // V6: daily pick must be cookable now
        if (feas.maxPortionsNow >= 1 && feas.missing.isEmpty) {
          portions = feas.maxPortionsNow.clamp(1, portions);
          flags.add('portions_clamped');
          feas = FeasibilityChecker.check(items, portions, stock);
        } else {
          for (final s in feas.shortfalls) {
            hard.add(
              "'${s.item.name}' needs ${s.need.toStringAsFixed(0)} ${s.unit.label} for $portions portions "
              'but only ${s.have.toStringAsFixed(0)} is available',
            );
          }
          for (final m in feas.missing) {
            hard.add("'$m' is not available");
          }
        }
      }
    }

    if (hard.isNotEmpty) return RecipeValidation(hardErrors: hard, flags: flags.toList());

    final recipe = Recipe()
      ..title = _truncate(dto.title.trim().isEmpty ? 'Untitled recipe' : dto.title.trim(), 45)
      ..hook = _truncate(dto.hook.trim(), 70)
      ..why = _truncate(dto.why.trim(), 140)
      ..cuisine = dto.cuisine.toLowerCase()
      ..origin = origin
      ..status = RecipeStatus.suggested
      ..defaultPortions = portions
      ..prepMinutes = dto.prepMinutes.clamp(0, 600)
      ..cookMinutes = dto.cookMinutes.clamp(0, 1440)
      ..activeMinutes = dto.activeMinutes.clamp(0, 600)
      ..fridgeLifeDays = dto.fridgeLifeDays.clamp(0, 7)
      ..ingredients = items
      ..steps = dto.steps.take(12).map((s) => _truncate(s.trim(), 220)).toList()
      ..tags = dto.tags.where(allowedTags.contains).toList()
      ..aiPerPortion = dto.estimate
      ..aiCostPerPortionMinor = dto.estimateCostMinor;

    // V8: Dart numbers are the truth; divergence flags a likely unit error.
    final numbers = NutritionEngine.compute(items, stock);
    recipe
      ..perPortion = numbers.perPortion
      ..costPerPortionMinor = numbers.costPerPortionMinor;
    flags.addAll(numbers.flags);
    final kcalA = dto.estimate.kcal;
    final kcalD = numbers.perPortion.kcal;
    if (kcalA > 0 && kcalD > 0 && ((kcalA - kcalD).abs() / kcalD) > 0.25) flags.add('estimate_divergence_kcal');
    final costA = dto.estimateCostMinor;
    final costD = numbers.costPerPortionMinor;
    if (costA > 0 && costD > 0 && ((costA - costD).abs() / costD) > 0.25) flags.add('estimate_divergence_cost');
    // V7: bounds per portion
    if (kcalD > 2000 || (kcalD > 0 && kcalD < 150)) flags.add('kcal_out_of_bounds');
    if (numbers.perPortion.proteinG > 150) flags.add('protein_out_of_bounds');

    recipe.validationFlags = flags.toList();
    return RecipeValidation(recipe: recipe, hardErrors: const [], flags: flags.toList(), feasibility: feas);
  }

  /// Dart verdict for Prompt C (overrides the model's status).
  static String verdict(Recipe r, FeasibilityResult f, List<String> omitted) {
    if (!f.ready || f.maxPortionsNow < r.defaultPortions) return 'missing_items';
    final swaps =
        r.ingredients.any((i) => i.substitutesFor != null && i.substitutesFor!.isNotEmpty) || omitted.isNotEmpty;
    return swaps ? 'ready_with_swaps' : 'ready';
  }
}
