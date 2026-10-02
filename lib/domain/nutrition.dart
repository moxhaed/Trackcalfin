import '../core/enums.dart';
import '../data/ai/dto/nutrition_dto.dart';
import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/nutrition.dart';
import '../data/isar/collections/recipe.dart';
import 'stock_index.dart';
import 'units.dart';

/// A nutrition label converted to an ingredient's per-100 basis, with what looked off.
class LabelNumbers {
  LabelNumbers(this.per100, this.flags);
  final Nutrition per100;

  /// "energy_mismatch": kcal disagree with the macros. "too_dense": more than any food per gram.
  final List<String> flags;
}

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

  /// [per100g] (food-table basis) as the ingredient stores it: per 100 ml for ml items.
  static Nutrition per100For(Nutrition per100g, BaseUnit unit, double? densityGPerMl) =>
      (unit == BaseUnit.ml ? per100g.scale(densityGPerMl ?? 1) : per100g).rounded();

  /// Converts a label to [ing]'s basis (per 100 g, or per 100 ml for ml items).
  /// Null when the label has no energy value or no usable basis.
  static LabelNumbers? fromLabel(LabelReading r, Ingredient ing) {
    final kcal = r.energyKcal ?? (r.energyKj == null ? null : r.energyKj! / 4.184);
    if (!r.readable || kcal == null) return null;
    double? grams, ml;
    switch (r.basis) {
      case LabelBasis.per100g:
        grams = 100;
      case LabelBasis.per100ml:
        ml = 100;
      case LabelBasis.perServing:
        grams = r.servingSizeG;
        ml = grams == null ? r.servingSizeMl : null;
      case null:
        return null;
    }
    if ((grams ?? ml ?? 0) <= 0) return null;
    final density = ing.densityGPerMl ?? 1;
    // Grams the label column describes, and the factor to the ingredient's basis.
    final labelGrams = grams ?? ml! * density;
    final factor = ing.baseUnit == BaseUnit.ml ? 100 * density / labelGrams : 100 / labelGrams;
    final fiber = r.fiberG ?? 0;
    final carbs = r.carbsIncludeFiber ? (r.carbsG ?? 0) - fiber : (r.carbsG ?? 0);
    final raw = Nutrition(
      kcal: kcal,
      proteinG: r.proteinG ?? 0,
      carbsG: carbs < 0 ? 0 : carbs,
      fatG: r.fatG ?? 0,
      fiberG: fiber,
    );
    final flags = <String>[];
    final perGram = raw.scale(1 / labelGrams);
    if (perGram.kcal > 9.1 || perGram.proteinG + perGram.carbsG + perGram.fatG + perGram.fiberG > 1.05) {
      flags.add('too_dense');
    }
    if (!atwaterPlausible(raw.scale(100 / labelGrams))) flags.add('energy_mismatch');
    return LabelNumbers(raw.scale(factor).rounded(), flags);
  }

  /// Atwater check: kcal should be close to 4p + 4c + 9f.
  static bool atwaterPlausible(Nutrition per100) {
    final est = 4 * per100.proteinG + 4 * per100.carbsG + 9 * per100.fatG;
    final diff = (per100.kcal - est).abs();
    if (diff <= 15) return true;
    return diff / (per100.kcal <= 0 ? 1 : per100.kcal) <= 0.20;
  }
}
