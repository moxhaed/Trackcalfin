import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/cook_session.dart';
import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/nutrition.dart';
import '../data/isar/collections/recipe.dart';
import 'costing.dart';
import 'nutrition.dart';
import 'stock_index.dart';
import 'units.dart';

class CookPlan {
  CookPlan({
    required this.portions,
    required this.deltas,
    required this.perPortion,
    required this.costPerPortionMinor,
    required this.flags,
  });

  final int portions;
  final List<StockDelta> deltas;
  final Nutrition perPortion;
  final int costPerPortionMinor;
  final List<String> flags;

  bool get hasShortfall => deltas.any((d) => d.shortfall > 1e-9);
}

/// Turns "I cooked this xN" into exact stock deductions.
class DepletionEngine {
  const DepletionEngine._();

  /// Snapshots cost and nutrition BEFORE anything is deducted.
  static CookPlan plan(List<RecipeIngredient> items, int portions, StockIndex stock) {
    final numbers = NutritionEngine.compute(items, stock);
    final deltas = <StockDelta>[];
    final flags = [...numbers.flags];
    for (final ri in items) {
      if (ri.role != IngredientRole.stock) continue;
      final ing = stock.resolve(ri);
      if (ing == null) continue;
      final perPortion = UnitConverter.toBase(ri.qtyPerPortion, ri.unit, ing);
      if (perPortion == null) continue;
      final requested = perPortion * portions;
      final deducted = requested < ing.qtyOnHand ? requested : ing.qtyOnHand;
      final existing = deltas.where((d) => d.ingredientId == ing.id).firstOrNull;
      if (existing != null) {
        // The same ingredient twice in one recipe: merge.
        existing.requested += requested;
        final total = existing.requested < ing.qtyOnHand ? existing.requested : ing.qtyOnHand;
        existing.deducted = total;
        existing.shortfall = existing.requested - total;
        continue;
      }
      deltas.add(
        StockDelta()
          ..ingredientId = ing.id
          ..key = ing.key
          ..requested = requested
          ..deducted = deducted
          ..shortfall = requested - deducted,
      );
    }
    return CookPlan(
      portions: portions,
      deltas: deltas,
      perPortion: numbers.perPortion,
      costPerPortionMinor: numbers.costPerPortionMinor,
      flags: flags,
    );
  }

  /// Applies [plan] to the ingredients in [stock]; returns the touched ones.
  static List<Ingredient> apply(CookPlan plan, StockIndex stock, DateTime at) {
    final touched = <Ingredient>[];
    for (final d in plan.deltas) {
      final ing = stock.byId[d.ingredientId];
      if (ing == null) continue;
      ing.qtyOnHand = (ing.qtyOnHand - d.deducted).clamp(0, double.infinity).toDouble();
      if (d.shortfall > 1e-9) {
        // You physically had more than the app thought: a purchase was missed.
        ing.lastVerifiedAt = null;
      }
      ing.updatedAt = at;
      ExpiryEstimator.onDeplete(ing);
      touched.add(ing);
    }
    return touched;
  }

  /// Puts back exactly what [deltas] removed.
  static List<Ingredient> revert(List<StockDelta> deltas, StockIndex stock, DateTime at) {
    final touched = <Ingredient>[];
    for (final d in deltas) {
      final ing = stock.byId[d.ingredientId];
      if (ing == null) continue;
      final before = ing.qtyOnHand;
      ing.qtyOnHand = before + d.deducted;
      if (before <= 0 && ing.lastPurchasedAt != null) {
        ing.expiresAt = DayClock.addDays(ing.lastPurchasedAt!, ing.shelfLifeDays);
      }
      ing.updatedAt = at;
      touched.add(ing);
    }
    return touched;
  }
}
