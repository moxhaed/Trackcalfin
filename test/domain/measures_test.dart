import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/domain/measures.dart';
import 'package:trackcalfin/domain/nutrition.dart';
import 'package:trackcalfin/domain/units.dart';

import 'fixtures.dart';

void main() {
  group('Measures', () {
    test("a measure comes off in the item's own unit", () {
      final soy = ingredient('soy_sauce', unit: BaseUnit.ml)..densityGPerMl = 1.2;
      final salt = ingredient('salt')..densityGPerMl = 1.2;
      final rice = ingredient('white_rice')..densityGPerMl = 0.85;
      final cola = ingredient('cola_zero', unit: BaseUnit.pc, gpp: 330);
      expect(Measures.toBase(1, Measure.tbsp, soy), 15);
      expect(Measures.toBase(3, Measure.tbsp, soy), 45);
      expect(Measures.toBase(1, Measure.tsp, salt), closeTo(6, 1e-9));
      expect(Measures.toBase(1, Measure.pinch, salt), closeTo(0.4, 1e-9));
      expect(Measures.toBase(0.5, Measure.cup, rice), closeTo(102, 1e-9));
      expect(Measures.toBase(1, Measure.handful, ingredient('almonds')), 30);
      expect(Measures.toBase(1, Measure.glass, cola), closeTo(250 / 330, 1e-9), reason: 'a glass from 330 ml cans');
      expect(Measures.toBase(1, Measure.tbsp, ingredient('flour')), 15, reason: 'no density counts 1 g per ml');
      expect(
        Measures.toBase(1, Measure.glass, ingredient('juice_box', unit: BaseUnit.pc)),
        isNull,
        reason: 'pieces without a weight',
      );
    });

    test('measures are read as people write them', () {
      expect(
        [
          for (final s in ['tbsp', 'Tbsp.', 'tablespoons', 'tsp', 'teaspoon', 'cups', 'glass', 'pinch', 'handfuls'])
            Measures.parse(s),
        ],
        [
          Measure.tbsp,
          Measure.tbsp,
          Measure.tbsp,
          Measure.tsp,
          Measure.tsp,
          Measure.cup,
          Measure.glass,
          Measure.pinch,
          Measure.handful,
        ],
      );
      expect(Measures.parse('spoon'), isNull);
      expect(Measures.parse('g'), isNull);
    });

    test('the Ate dialog offers spoons, a glass, cups or a handful by what the item is', () {
      List<String> labels(Iterable<MeasurePreset> p) => [for (final x in p) x.label];
      final soy = ingredient('soy_sauce', unit: BaseUnit.ml)..category = IngredientCategory.spicesCondiments;
      expect(labels(Measures.presetsFor(soy)), ['1 tsp', '1 tbsp', '2 tbsp', '50 ml', '100 ml']);
      expect(Measures.presetsFor(soy)[1].qty, 15);
      final sugar = ingredient('sugar')
        ..category = IngredientCategory.spicesCondiments
        ..densityGPerMl = 0.85;
      expect(labels(Measures.presetsFor(sugar)), ['1 pinch', '1 tsp', '1 tbsp', '2 tbsp', '50 g']);
      expect(Measures.presetsFor(sugar)[2].qty, closeTo(12.75, 1e-9));
      final milk = ingredient('whole_milk', unit: BaseUnit.ml)..category = IngredientCategory.dairyEggs;
      expect(Measures.presetsFor(milk).first.label, '1 glass');
      final rice = ingredient('white_rice')
        ..category = IngredientCategory.grainsPasta
        ..densityGPerMl = 0.85;
      expect(labels(Measures.presetsFor(rice)), ['0.5 cup', '1 cup', '50 g', '100 g']);
      final nuts = ingredient('almonds')..category = IngredientCategory.legumesNuts;
      expect(Measures.presetsFor(nuts).first.label, '1 handful');
      final chicken = ingredient('chicken_breast')..category = IngredientCategory.meatFish;
      expect(labels(Measures.presetsFor(chicken)), ['30 g', '50 g', '100 g', '150 g', '200 g']);
      expect(Measures.presetsFor(ingredient('egg', unit: BaseUnit.pc, gpp: 60)), isEmpty, reason: 'eaten whole');
    });
  });

  group('Pieces', () {
    test('amounts in pieces say what they are', () {
      expect(UnitConverter.format(1, BaseUnit.pc, piece: 'can'), '1 can');
      expect(UnitConverter.format(6, BaseUnit.pc, piece: 'can'), '6 cans');
      expect(UnitConverter.format(4.545, BaseUnit.pc, piece: 'can'), '4.5 cans');
      expect(UnitConverter.format(6, BaseUnit.pc), '6 pc');
      expect(UnitConverter.format(250, BaseUnit.ml, piece: 'can'), '250 ml', reason: 'only pieces have a name');
      expect(
        [
          for (final n in ['tortilla', 'box', 'patty', 'loaf', 'glass', 'sausages', 'bun', 'tomato'])
            UnitConverter.plural(n),
        ],
        ['tortillas', 'boxes', 'patties', 'loaves', 'glasses', 'sausages', 'buns', 'tomatoes'],
      );
    });

    test('a converted count within 3% of a whole number is that number', () {
      expect(UnitConverter.snapPieces(1980 / 340), 6, reason: 'a 340 g can against 1980 ml');
      expect(UnitConverter.snapPieces(1500 / 330), closeTo(4.545, 1e-3));
      expect(UnitConverter.snapPieces(0.02), 0.02);
    });

    test('a cola kept in ml switches to cans: stock, cost, low-stock line and macros move along', () {
      final cola = ingredient('cola', unit: BaseUnit.ml, qty: 660, cost: 0.227, kcal: 42)
        ..densityGPerMl = 1.04
        ..lowStockThreshold = 330
        ..lastPurchaseQty = 1980;
      final kcalPerCan = NutritionEngine.nutrientsFor(cola, 330)!.kcal;
      expect(UnitConverter.switchToPieces(cola, gramsPerPiece: 330 * 1.04, pieceName: 'can'), isTrue);
      expect(
        (cola.baseUnit, cola.qtyOnHand, cola.lowStockThreshold, cola.lastPurchaseQty, cola.pieceName),
        (BaseUnit.pc, 2.0, 1.0, 6.0, 'can'),
      );
      expect(cola.avgCostPerUnitMinor, closeTo(0.227 * 330, 1e-6));
      expect(NutritionEngine.nutrientsFor(cola, 1)!.kcal, closeTo(kcalPerCan, 1e-6), reason: 'a can is still a can');
      expect(UnitConverter.switchToPieces(cola, gramsPerPiece: 330), isFalse, reason: 'already in pieces');
      final wraps = ingredient('wheat_tortilla', qty: 185, cost: 0.54);
      UnitConverter.switchToPieces(wraps, gramsPerPiece: 370 / 6, pieceName: 'wrap');
      expect((wraps.qtyOnHand, wraps.pieceName), (3.0, 'wrap'));
    });
  });
}
