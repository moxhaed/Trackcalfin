import '../../../core/enums.dart';
import '../../isar/collections/nutrition.dart';
import '../json_reader.dart';
import 'enum_codec.dart';

class RecipeIngredientDto {
  RecipeIngredientDto({
    this.key,
    required this.name,
    required this.qtyPerPortion,
    required this.unit,
    required this.role,
    this.prepNote,
    this.substitutesFor,
    this.missingCostMinor,
    this.missingNutrition,
  });
  final String? key;
  final String name;
  final double qtyPerPortion;
  final BaseUnit unit;
  final IngredientRole role;
  final String? prepNote;
  final String? substitutesFor;
  final int? missingCostMinor;
  final Nutrition? missingNutrition;
}

class ExtraItemDto {
  ExtraItemDto(this.name, this.why, this.estCostMinor);
  final String name;
  final String why;
  final int estCostMinor;
}

class RecipeDto {
  RecipeDto({
    required this.title,
    required this.hook,
    required this.why,
    required this.cuisine,
    required this.portions,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.activeMinutes,
    required this.fridgeLifeDays,
    required this.ingredients,
    required this.optionalAdditions,
    required this.steps,
    required this.tags,
    required this.estimate,
    required this.estimateCostMinor,
    this.tradeoffs,
  });
  final String title;
  final String hook;
  final String why;
  final String cuisine;
  final int portions;
  final int prepMinutes;
  final int cookMinutes;
  final int activeMinutes;
  final int fridgeLifeDays;
  final List<RecipeIngredientDto> ingredients;
  final List<ExtraItemDto> optionalAdditions;
  final List<String> steps;
  final List<String> tags;
  final Nutrition estimate;
  final int estimateCostMinor;
  final String? tradeoffs;

  static RecipeDto? read(JsonReader j, Map<String, dynamic> m, String path) {
    final ingredients = <RecipeIngredientDto>[];
    final raw = j.list(m, 'ingredients', path);
    if (raw.isEmpty) j.error('$path.ingredients', 'must not be empty');
    for (var i = 0; i < raw.length; i++) {
      final p = '$path.ingredients[$i]';
      final it = raw[i];
      if (it is! Map) {
        j.error(p, 'must be an object');
        continue;
      }
      final role = j.enumOf(it, 'role', p, EnumCodec.role) ?? IngredientRole.stock;
      final key = j.str(it, 'key', p, nullable: true);
      if (role != IngredientRole.missing && (key == null || key.isEmpty)) {
        j.error('$p.key', 'is required unless role is "missing"');
      }
      int? mCost;
      Nutrition? mNut;
      if (role == IngredientRole.missing) {
        final est = j.object(it, 'missing_est', p, nullable: true);
        if (est == null) {
          j.error('$p.missing_est', 'is required when role is "missing"');
        } else {
          mCost = j.integer(est, 'cost_minor_per_portion', '$p.missing_est') ?? 0;
          mNut = Nutrition(
            kcal: j.number(est, 'kcal_per_portion', '$p.missing_est') ?? 0,
            proteinG: j.number(est, 'protein_g_per_portion', '$p.missing_est') ?? 0,
            carbsG: j.number(est, 'carbs_g_per_portion', '$p.missing_est', nullable: true) ?? 0,
            fatG: j.number(est, 'fat_g_per_portion', '$p.missing_est', nullable: true) ?? 0,
          );
        }
      }
      final qty = j.number(it, 'qty_per_portion', p) ?? 0;
      if (qty < 0) j.error('$p.qty_per_portion', 'must be >= 0');
      ingredients.add(
        RecipeIngredientDto(
          key: key,
          name: j.str(it, 'name', p) ?? key ?? '',
          qtyPerPortion: qty,
          unit: j.enumOf(it, 'unit', p, EnumCodec.unit) ?? BaseUnit.g,
          role: role,
          prepNote: j.str(it, 'prep_note', p, nullable: true),
          substitutesFor: j.str(it, 'substitutes_for', p, nullable: true),
          missingCostMinor: mCost,
          missingNutrition: mNut,
        ),
      );
    }
    final extras = <ExtraItemDto>[];
    for (final e in j.list(m, 'optional_additions', path, required: false)) {
      if (e is Map) {
        extras.add(
          ExtraItemDto(
            e['name']?.toString() ?? '',
            e['why']?.toString() ?? '',
            (e['est_cost_minor'] as num?)?.round() ?? 0,
          ),
        );
      }
    }
    final est = j.object(m, 'estimate_per_portion', path);
    final portions = j.integer(m, 'portions', path) ?? 1;
    if (portions < 1) j.error('$path.portions', 'must be >= 1');
    final steps = j.strings(m, 'steps', path);
    if (steps.isEmpty) j.error('$path.steps', 'must contain at least one step');
    return RecipeDto(
      title: j.str(m, 'title', path) ?? '',
      hook: j.str(m, 'hook', path, nullable: true) ?? '',
      why: j.str(m, 'why', path, nullable: true) ?? '',
      cuisine: j.str(m, 'cuisine', path, nullable: true) ?? '',
      portions: portions < 1 ? 1 : portions,
      prepMinutes: j.integer(m, 'prep_minutes', path, nullable: true) ?? 0,
      cookMinutes: j.integer(m, 'cook_minutes', path, nullable: true) ?? 0,
      activeMinutes: j.integer(m, 'active_minutes', path, nullable: true) ?? 0,
      fridgeLifeDays: j.integer(m, 'fridge_life_days', path, nullable: true) ?? 3,
      ingredients: ingredients,
      optionalAdditions: extras,
      steps: steps,
      tags: j.strings(m, 'tags', path),
      estimate: est == null
          ? Nutrition()
          : Nutrition(
              kcal: (est['kcal'] as num?)?.toDouble() ?? 0,
              proteinG: (est['protein_g'] as num?)?.toDouble() ?? 0,
              carbsG: (est['carbs_g'] as num?)?.toDouble() ?? 0,
              fatG: (est['fat_g'] as num?)?.toDouble() ?? 0,
              fiberG: (est['fiber_g'] as num?)?.toDouble() ?? 0,
            ),
      estimateCostMinor: (est?['cost_minor'] as num?)?.round() ?? 0,
      tradeoffs: j.str(m, 'tradeoffs', path, nullable: true),
    );
  }
}

class ShoppingDto {
  ShoppingDto(this.name, this.packageDesc, this.estCostMinor, this.reason);
  final String name;
  final String packageDesc;
  final int estCostMinor;
  final String reason;
}

class DailyRecipeOutput {
  DailyRecipeOutput(this.status, this.recipe, this.shoppingSuggestions);
  final String status;
  final RecipeDto? recipe;
  final List<ShoppingDto> shoppingSuggestions;

  static ParseResult<DailyRecipeOutput> parse(Map<String, dynamic> m) {
    final j = JsonReader();
    final status = j.enumOf(m, 'status', r'$', const {'ok': 'ok', 'insufficient_stock': 'insufficient_stock'});
    RecipeDto? recipe;
    final r = j.object(m, 'recipe', r'$', nullable: true);
    if (status == 'ok') {
      if (r == null) {
        j.error(r'$.recipe', 'is required when status is "ok"');
      } else {
        recipe = RecipeDto.read(j, r, r'$.recipe');
        for (final (i, ing) in (recipe?.ingredients ?? const <RecipeIngredientDto>[]).indexed) {
          if (ing.role == IngredientRole.missing) {
            j.error('\$.recipe.ingredients[$i].role', 'must be "stock" or "staple" in the daily recipe');
          }
        }
      }
    }
    final shopping = [
      for (final s in j.list(m, 'shopping_suggestions', r'$', required: false))
        if (s is Map)
          ShoppingDto(
            s['name']?.toString() ?? '',
            s['why']?.toString() ?? '',
            (s['est_cost_minor'] as num?)?.round() ?? 0,
            'suggestion',
          ),
    ];
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(DailyRecipeOutput(status!, recipe, shopping), const []);
  }
}

class SpontaneousOutput {
  SpontaneousOutput({
    required this.status,
    required this.requestType,
    required this.interpretedRequest,
    required this.summary,
    required this.maxPortionsNow,
    this.recipe,
    required this.omitted,
    required this.shoppingList,
  });
  final String status;
  final String requestType;
  final String interpretedRequest;
  final String summary;
  final int maxPortionsNow;
  final RecipeDto? recipe;
  final List<String> omitted;
  final List<ShoppingDto> shoppingList;

  static const statuses = {
    'ready': 'ready',
    'ready_with_swaps': 'ready_with_swaps',
    'missing_items': 'missing_items',
    'not_a_recipe': 'not_a_recipe',
  };

  static ParseResult<SpontaneousOutput> parse(Map<String, dynamic> m) {
    final j = JsonReader();
    final status = j.enumOf(m, 'status', r'$', statuses);
    final type = j.enumOf(m, 'request_type', r'$', const {
      'dish': 'dish',
      'ingredient_led': 'ingredient_led',
      'not_a_recipe': 'not_a_recipe',
    });
    RecipeDto? recipe;
    final r = j.object(m, 'recipe', r'$', nullable: true);
    if (status != null && status != 'not_a_recipe') {
      if (r == null) {
        j.error(r'$.recipe', 'is required unless status is "not_a_recipe"');
      } else {
        recipe = RecipeDto.read(j, r, r'$.recipe');
      }
    }
    final shopping = [
      for (final s in j.list(m, 'shopping_list', r'$', required: false))
        if (s is Map)
          ShoppingDto(
            s['name']?.toString() ?? '',
            s['package_desc']?.toString() ?? '',
            (s['est_package_cost_minor'] as num?)?.round() ?? 0,
            s['reason']?.toString() ?? 'missing',
          ),
    ];
    final out = SpontaneousOutput(
      status: status ?? 'not_a_recipe',
      requestType: type ?? 'dish',
      interpretedRequest: j.str(m, 'interpreted_request', r'$', nullable: true) ?? '',
      summary: j.str(m, 'summary', r'$', nullable: true) ?? '',
      maxPortionsNow: j.integer(m, 'max_portions_now', r'$', nullable: true) ?? 0,
      recipe: recipe,
      omitted: j.strings(m, 'omitted', r'$'),
      shoppingList: shopping,
    );
    if (j.errors.isNotEmpty) return ParseResult(null, j.errors);
    return ParseResult(out, const []);
  }
}
