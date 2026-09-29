import 'dart:math' as math;

import '../core/enums.dart';
import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/recipe.dart';
import 'stock_index.dart';
import 'units.dart';

class Shortfall {
  Shortfall(this.item, this.ingredient, this.need, this.have);
  final RecipeIngredient item;
  final Ingredient? ingredient;

  /// In the ingredient's base unit (or the recipe unit if unresolved).
  final double need;
  final double have;
  double get missing => need - have;
  BaseUnit get unit => ingredient?.baseUnit ?? item.unit;
}

class FeasibilityResult {
  FeasibilityResult({
    required this.portions,
    required this.maxPortionsNow,
    required this.shortfalls,
    required this.missing,
    required this.readiness,
  });

  final int portions;
  final int maxPortionsNow;
  final List<Shortfall> shortfalls;

  /// Names of role=missing ingredients (and stock rows that don't resolve).
  final List<String> missing;

  /// 0..1: share of the needed stock that is on hand.
  final double readiness;

  bool get ready => shortfalls.isEmpty && missing.isEmpty;
}

/// Checks a recipe against stock without AI.
class FeasibilityChecker {
  const FeasibilityChecker._();

  static const unbounded = 99;

  static FeasibilityResult check(List<RecipeIngredient> items, int portions, StockIndex stock) {
    var maxPortions = unbounded;
    final shortfalls = <Shortfall>[];
    final missing = <String>[];
    final ratios = <double>[];

    for (final ri in items) {
      if (ri.role == IngredientRole.staple) continue;
      if (ri.role == IngredientRole.missing) {
        missing.add(ri.name);
        ratios.add(0);
        maxPortions = 0;
        continue;
      }
      if (ri.qtyPerPortion <= 0) continue;
      final ing = stock.resolve(ri);
      if (ing == null) {
        missing.add(ri.name);
        ratios.add(0);
        maxPortions = 0;
        continue;
      }
      if (ing.isStaple) continue;
      final perPortion = UnitConverter.toBase(ri.qtyPerPortion, ri.unit, ing);
      if (perPortion == null || perPortion <= 0) continue;
      final need = perPortion * portions;
      final have = ing.qtyOnHand;
      final possible = (have / perPortion + 1e-9).floor();
      maxPortions = math.min(maxPortions, possible);
      ratios.add(math.min(have / need, 1.0));
      if (have + 1e-9 < need) shortfalls.add(Shortfall(ri, ing, need, have));
    }

    final readiness = ratios.isEmpty ? 1.0 : ratios.reduce((a, b) => a + b) / ratios.length;
    return FeasibilityResult(
      portions: portions,
      maxPortionsNow: maxPortions,
      shortfalls: shortfalls,
      missing: missing,
      readiness: readiness,
    );
  }
}
