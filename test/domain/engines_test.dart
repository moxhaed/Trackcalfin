import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/dto/nutrition_dto.dart';
import 'package:trackcalfin/domain/costing.dart';
import 'package:trackcalfin/domain/depletion.dart';
import 'package:trackcalfin/domain/feasibility.dart';
import 'package:trackcalfin/domain/nutrition.dart';
import 'package:trackcalfin/domain/stock_index.dart';
import 'package:trackcalfin/data/isar/collections/nutrition.dart';

import 'fixtures.dart';

void main() {
  final t0 = DateTime(2026, 9, 20, 18);

  group('CostingEngine (WAC)', () {
    test('first purchase sets unit cost', () {
      final i = ingredient('rice');
      CostingEngine.applyPurchase(i, qtyAdded: 1000, lineTotalMinor: 200, at: t0);
      expect(i.qtyOnHand, 1000);
      expect(i.avgCostPerUnitMinor, closeTo(0.2, 1e-9));
      expect(i.lastVerifiedAt, t0);
    });
    test('purchase onto existing stock averages', () {
      final i = ingredient('rice', qty: 1000, cost: 0.2);
      CostingEngine.applyPurchase(i, qtyAdded: 1000, lineTotalMinor: 400, at: t0);
      expect(i.avgCostPerUnitMinor, closeTo(0.3, 1e-9));
      expect(i.qtyOnHand, 2000);
    });
    test('purchase after stock hit 0 resets the average', () {
      final i = ingredient('rice', qty: 0, cost: 0.2);
      CostingEngine.applyPurchase(i, qtyAdded: 500, lineTotalMinor: 250, at: t0);
      expect(i.avgCostPerUnitMinor, closeTo(0.5, 1e-9));
    });
    test('zero quantity and unknown price guards', () {
      final i = ingredient('rice', qty: 100, cost: 0.2);
      CostingEngine.applyPurchase(i, qtyAdded: 0, lineTotalMinor: 100, at: t0);
      expect(i.qtyOnHand, 100);
      CostingEngine.applyPurchase(i, qtyAdded: 100, lineTotalMinor: 0, at: t0);
      expect(i.qtyOnHand, 200);
      expect(i.avgCostPerUnitMinor, closeTo(0.2, 1e-9));
    });
  });

  group('ExpiryEstimator', () {
    test('purchase onto non-empty stock keeps the earlier expiry', () {
      final i = ingredient('milk', shelf: 7);
      CostingEngine.applyPurchase(i, qtyAdded: 1000, lineTotalMinor: 100, at: t0);
      final first = i.expiresAt!;
      CostingEngine.applyPurchase(i, qtyAdded: 1000, lineTotalMinor: 100, at: t0.add(const Duration(days: 3)));
      expect(i.expiresAt, first);
    });
    test('older lot consumed moves expiry to the latest purchase', () {
      final i = ingredient('milk', shelf: 7);
      CostingEngine.applyPurchase(i, qtyAdded: 1000, lineTotalMinor: 100, at: t0);
      final later = t0.add(const Duration(days: 3));
      CostingEngine.applyPurchase(i, qtyAdded: 1000, lineTotalMinor: 100, at: later);
      i.qtyOnHand = 800;
      ExpiryEstimator.onDeplete(i);
      expect(i.expiresAt, DateTime(2026, 9, 30, 18));
      i.qtyOnHand = 0;
      ExpiryEstimator.onDeplete(i);
      expect(i.expiresAt, isNull);
    });
    test('daysLeft and shelf-stable', () {
      final i = ingredient('spinach', qty: 200, shelf: 5, expiresAt: DateTime(2026, 9, 22, 18));
      expect(ExpiryEstimator.daysLeft(i, t0), 2);
      expect(ExpiryEstimator.useSoon(i, t0), isTrue);
      final pasta = ingredient('pasta', qty: 500, shelf: 365, expiresAt: DateTime(2027, 9, 1));
      expect(ExpiryEstimator.daysLeft(pasta, t0), isNull);
    });
  });

  group('NutritionEngine', () {
    test('ml item uses per-100 ml, pc item uses grams, missing adds estimate', () {
      final milk = ingredient('milk', unit: BaseUnit.ml, kcal: 64, protein: 3.4, cost: 0.1);
      final egg = ingredient('egg', unit: BaseUnit.pc, gpp: 55, kcal: 143, protein: 12.6, cost: 30);
      final stock = StockIndex([milk, egg]);
      final missing = ri('pecorino', 15, role: IngredientRole.missing)
        ..estCostMinor = 40
        ..estNutritionPerPortion = Nutrition(kcal: 58, proteinG: 4);
      final r = NutritionEngine.compute([
        ri('milk', 200, unit: BaseUnit.ml),
        ri('egg', 2, unit: BaseUnit.pc),
        missing,
      ], stock);
      expect(r.perPortion.kcal, closeTo(128 + 157.3 + 58, 0.01));
      expect(r.perPortion.proteinG, closeTo(6.8 + 13.86 + 4, 0.01));
      expect(r.costPerPortionMinor, 20 + 60 + 40);
      expect(r.flags, isEmpty);
    });
    test('Atwater check', () {
      expect(NutritionEngine.atwaterPlausible(Nutrition(kcal: 124, proteinG: 4.5, carbsG: 4, fatG: 10)), isTrue);
      expect(NutritionEngine.atwaterPlausible(Nutrition(kcal: 500, proteinG: 4.5, carbsG: 4, fatG: 10)), isFalse);
      expect(NutritionEngine.atwaterPlausible(Nutrition(kcal: 23, proteinG: 2.9, carbsG: 3.6, fatG: 0.4)), isTrue);
    });
    test('food-table values per 100 g become per 100 ml for ml items', () {
      final oil = Nutrition(kcal: 884, fatG: 100);
      expect(NutritionEngine.per100For(oil, BaseUnit.ml, 0.91).kcal, 804.4);
      expect(NutritionEngine.per100For(oil, BaseUnit.ml, 0.91).fatG, 91);
      expect(NutritionEngine.per100For(oil, BaseUnit.g, 0.91).kcal, 884);
    });
  });

  group('NutritionEngine.fromLabel', () {
    LabelReading label({
      LabelBasis basis = LabelBasis.per100g,
      double? servingG,
      double? servingMl,
      double? kcal,
      double? kj,
      double protein = 0,
      double carbs = 0,
      double fat = 0,
      double fiber = 0,
      bool carbsIncludeFiber = false,
    }) => LabelReading(
      readable: true,
      basis: basis,
      servingSizeG: servingG,
      servingSizeMl: servingMl,
      energyKcal: kcal,
      energyKj: kj,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      fiberG: fiber,
      carbsIncludeFiber: carbsIncludeFiber,
    );

    test('per 100 g label on a g item is taken as printed', () {
      final flour = ingredient('flour');
      final r = NutritionEngine.fromLabel(label(kcal: 348, protein: 10, carbs: 72, fat: 1, fiber: 4), flour)!;
      expect(r.per100.sameAs(Nutrition(kcal: 348, proteinG: 10, carbsG: 72, fatG: 1, fiberG: 4)), isTrue);
      expect(r.flags, isEmpty);
    });
    test('converts between g and ml with the density', () {
      final oil = ingredient('olive_oil', unit: BaseUnit.ml)..densityGPerMl = 0.91;
      final r = NutritionEngine.fromLabel(label(kcal: 884, fat: 100), oil)!;
      expect(r.per100.kcal, 804.4);
      expect(r.per100.fatG, 91);
      final milk = ingredient('milk')..densityGPerMl = 1.03;
      final m = NutritionEngine.fromLabel(label(basis: LabelBasis.per100ml, kcal: 64, protein: 3.4, fat: 3.5), milk)!;
      expect(m.per100.kcal, 62.1);
    });
    test('per-serving US label: scaled to 100 g, fiber taken out of carbs', () {
      final oats = ingredient('oats');
      final r = NutritionEngine.fromLabel(
        label(
          basis: LabelBasis.perServing,
          servingG: 30,
          kcal: 110,
          protein: 3,
          carbs: 23,
          fat: 1,
          fiber: 3,
          carbsIncludeFiber: true,
        ),
        oats,
      )!;
      expect(r.per100.kcal, 366.7);
      expect(r.per100.proteinG, 10);
      expect(r.per100.carbsG, 66.7);
      expect(r.per100.fiberG, 10);
    });
    test('kJ-only energy is converted; missing energy or unreadable gives null', () {
      final flour = ingredient('flour');
      expect(NutritionEngine.fromLabel(label(kj: 1475, protein: 10, carbs: 72, fat: 1), flour)!.per100.kcal, 352.5);
      expect(NutritionEngine.fromLabel(label(protein: 10), flour), isNull);
      expect(NutritionEngine.fromLabel(LabelReading(readable: false), flour), isNull);
    });
    test('flags numbers that disagree or exceed what food can hold', () {
      final x = ingredient('x');
      expect(NutritionEngine.fromLabel(label(kcal: 500, protein: 10, carbs: 10, fat: 1), x)!.flags, [
        'energy_mismatch',
      ]);
      expect(
        NutritionEngine.fromLabel(label(basis: LabelBasis.perServing, servingG: 10, kcal: 150, fat: 15), x)!.flags,
        contains('too_dense'),
      );
    });
  });

  group('FeasibilityChecker', () {
    final chicken = ingredient('chicken', qty: 650);
    final rice = ingredient('rice', qty: 1000);
    final egg = ingredient('egg', qty: 3, unit: BaseUnit.pc, gpp: 55);
    final oil = ingredient('oil', staple: true);
    final stock = StockIndex([chicken, rice, egg, oil]);

    test('exact fit and max portions', () {
      final f = FeasibilityChecker.check(
        [ri('chicken', 180), ri('rice', 100), ri('oil', 7, role: IngredientRole.staple)],
        3,
        stock,
      );
      expect(f.ready, isTrue);
      expect(f.maxPortionsNow, 3);
    });
    test('shortfall', () {
      final f = FeasibilityChecker.check([ri('chicken', 180)], 4, stock);
      expect(f.ready, isFalse);
      expect(f.shortfalls.single.missing, closeTo(70, 1e-9));
      expect(f.maxPortionsNow, 3);
    });
    test('pc half units and missing -> 0 portions', () {
      final f = FeasibilityChecker.check([ri('egg', 1.5, unit: BaseUnit.pc)], 2, stock);
      expect(f.ready, isTrue);
      expect(f.maxPortionsNow, 2);
      final g = FeasibilityChecker.check(
        [ri('egg', 1, unit: BaseUnit.pc), ri('salmon', 150, role: IngredientRole.missing)],
        1,
        stock,
      );
      expect(g.maxPortionsNow, 0);
      expect(g.missing, ['salmon']);
    });
  });

  group('DepletionEngine', () {
    test('shortfall clamps at 0 and flags; undo restores exactly; snapshot before deduction', () {
      final chicken = ingredient('chicken', qty: 300, cost: 1.0, kcal: 110, protein: 23, verified: t0);
      final rice = ingredient('rice', qty: 1000, cost: 0.2, kcal: 360, protein: 7, verified: t0);
      final stock = StockIndex([chicken, rice]);
      final items = [ri('chicken', 180), ri('rice', 100)];
      final plan = DepletionEngine.plan(items, 2, stock);
      expect(plan.costPerPortionMinor, 180 + 20);
      expect(plan.perPortion.proteinG, closeTo(41.4 + 7, 1e-9));
      expect(plan.hasShortfall, isTrue);

      DepletionEngine.apply(plan, stock, t0);
      expect(chicken.qtyOnHand, 0);
      expect(chicken.lastVerifiedAt, isNull);
      expect(rice.qtyOnHand, 800);
      expect(rice.lastVerifiedAt, t0);

      DepletionEngine.revert(plan.deltas, stock, t0);
      expect(chicken.qtyOnHand, 300);
      expect(rice.qtyOnHand, 1000);
    });
    test('staples are never deducted and duplicate rows merge', () {
      final oil = ingredient('oil', qty: 500, unit: BaseUnit.ml, staple: true);
      final onion = ingredient('onion', qty: 400);
      final stock = StockIndex([oil, onion]);
      final plan = DepletionEngine.plan(
        [ri('oil', 10, unit: BaseUnit.ml, role: IngredientRole.staple), ri('onion', 50), ri('onion', 30)],
        2,
        stock,
      );
      expect(plan.deltas.length, 1);
      expect(plan.deltas.single.requested, 160);
      DepletionEngine.apply(plan, stock, t0);
      expect(oil.qtyOnHand, 500);
      expect(onion.qtyOnHand, 240);
    });
  });
}
