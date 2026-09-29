import 'dart:math' as math;

import '../data/isar/collections/recipe.dart';
import 'costing.dart';
import 'feasibility.dart';
import 'nutrition.dart';
import 'stock_index.dart';
import 'units.dart';

class RankedRecipe {
  RankedRecipe(this.recipe, this.score, this.feasibility);
  final Recipe recipe;
  final double score;
  final FeasibilityResult feasibility;
}

/// Offline daily pick: the best "ready" saved recipe.
class DailyFallback {
  const DailyFallback._();

  static List<RankedRecipe> rank(
    Iterable<Recipe> recipes,
    StockIndex stock,
    DateTime now, {
    required double proteinTarget,
    required int targetCostMinor,
    int? portions,
  }) {
    final out = <RankedRecipe>[];
    for (final r in recipes) {
      if (r.lastCookedAt != null && now.difference(r.lastCookedAt!).inDays < 3) continue;
      final n = portions ?? math.max(1, r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions);
      final f = FeasibilityChecker.check(r.ingredients, n, stock);
      if (!f.ready) continue;
      final numbers = NutritionEngine.compute(r.ingredients, stock);
      var soonGrams = 0.0;
      var allGrams = 0.0;
      for (final ri in r.ingredients) {
        final ing = stock.resolve(ri);
        if (ing == null || ing.isStaple) continue;
        final g = UnitConverter.toBase(ri.qtyPerPortion, ri.unit, ing) ?? 0;
        allGrams += g;
        if (ExpiryEstimator.useSoon(ing, now)) soonGrams += g;
      }
      final expiryUse = allGrams == 0 ? 0.0 : soonGrams / allGrams;
      final proteinFit = proteinTarget <= 0 ? 1.0 : math.min(numbers.perPortion.proteinG / proteinTarget, 1.0);
      final cost = numbers.costPerPortionMinor;
      final costFit = cost <= 0 ? 1.0 : math.min(targetCostMinor / cost, 1.0);
      out.add(RankedRecipe(r, 0.5 * expiryUse + 0.3 * proteinFit + 0.2 * costFit, f));
    }
    out.sort((a, b) => b.score.compareTo(a.score));
    return out;
  }

}
