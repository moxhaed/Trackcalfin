import '../core/enums.dart';
import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/nutrition.dart';
import '../data/isar/collections/recipe.dart';
import 'stock_index.dart';
import 'units.dart';

class RecipeNumbers {
  RecipeNumbers(this.perPortion, this.costPerPortionMinor, this.flags);
  final Nutrition perPortion;
  final int costPerPortionMinor;
  final List<String> flags;
}

/// Macro and cost math for ingredients and recipes.
class NutritionEngine {
  const NutritionEngine._();

  /// Nutrients in [qtyBase] of [ing]; null when a pc item has no piece weight.
  static Nutrition? nutrientsFor(Ingredient ing, double qtyBase) {
    final double? basis = ing.baseUnit == BaseUnit.ml
        ? qtyBase
        : UnitConverter.ingredientGrams(qtyBase, ing.baseUnit, ing);
    if (basis == null) return null;
    return ing.per100.scale(basis / 100);
  }

  /// Per-portion nutrition and cost, computed from stock data only.
  static RecipeNumbers compute(List<RecipeIngredient> items, StockIndex stock) {
    var n = Nutrition();
    var cost = 0.0;
    final flags = <String>[];
    for (final ri in items) {
      if (ri.role == IngredientRole.missing) {
        if (ri.estNutritionPerPortion != null) n = n + ri.estNutritionPerPortion!;
        cost += ri.estCostMinor ?? 0;
        continue;
      }
      final ing = stock.resolve(ri);
      if (ing == null) {
        if (ri.role == IngredientRole.stock) flags.add('unresolved:${ri.key}');
        continue;
      }
      final qty = UnitConverter.toBase(ri.qtyPerPortion, ri.unit, ing);
      if (qty == null) {
        flags.add('unit_mismatch:${ri.key}');
        continue;
      }
      final part = nutrientsFor(ing, qty);
      if (part == null) {
        flags.add('no_piece_weight:${ri.key}');
      } else {
        n = n + part;
      }
      cost += qty * ing.avgCostPerUnitMinor;
    }
    return RecipeNumbers(n, cost.round(), flags);
  }

  /// Atwater check: kcal should be close to 4p + 4c + 9f.
  static bool atwaterPlausible(Nutrition per100) {
    final est = 4 * per100.proteinG + 4 * per100.carbsG + 9 * per100.fatG;
    final diff = (per100.kcal - est).abs();
    if (diff <= 15) return true;
    return diff / (per100.kcal <= 0 ? 1 : per100.kcal) <= 0.20;
  }
}
