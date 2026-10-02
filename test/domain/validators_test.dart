import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/dto/receipt_dto.dart';
import 'package:trackcalfin/data/ai/dto/recipe_dto.dart';
import 'package:trackcalfin/data/isar/collections/ingredient.dart';
import 'package:trackcalfin/data/isar/collections/scan_job.dart';
import 'package:trackcalfin/data/isar/collections/user_profile.dart';
import 'package:trackcalfin/domain/ingredient_matcher.dart';
import 'package:trackcalfin/domain/stock_index.dart';
import 'package:trackcalfin/domain/validation/allergens.dart';
import 'package:trackcalfin/domain/validation/receipt_validator.dart';
import 'package:trackcalfin/domain/validation/recipe_validator.dart';

import '../support/fake_gemini.dart';
import 'fixtures.dart';

void main() {
  group('AllergenScreen', () {
    test('synonyms, aliases and exceptions', () {
      expect(AllergenScreen.hit('peanut_butter', ['peanuts']), 'peanuts');
      expect(AllergenScreen.hit('Grana Padano', ['lactose']), 'lactose');
      expect(AllergenScreen.hit('coconut_milk', ['dairy']), isNull);
      expect(AllergenScreen.hit('eggplant', ['egg']), isNull);
      expect(AllergenScreen.hit('Eggs', ['egg']), 'egg');
      expect(AllergenScreen.hit('dry_pasta', ['gluten']), 'gluten');
      expect(AllergenScreen.hit('gluten_free_pasta', ['gluten']), isNull);
      expect(AllergenScreen.hit('butternut_squash', ['nuts']), isNull);
      expect(AllergenScreen.hit('soy_sauce', ['gluten']), 'gluten');
      expect(AllergenScreen.hit('chicken_breast', ['peanut', 'fish']), isNull);
    });
  });

  group('ReceiptValidator', () {
    final capturedAt = DateTime(2026, 9, 27, 19);

    ReceiptExtraction example([void Function(Map<String, dynamic>)? edit, int index = 0]) {
      final json = jsonDecode(promptExamples('receipt_extraction.v3.md')[index]) as Map<String, dynamic>;
      edit?.call(json);
      return ReceiptExtraction.parse(json).value!;
    }

    ScanDraft validate(ReceiptExtraction x, List<Ingredient> pantry, {DateTime? at}) => ReceiptValidator.validate(
      x,
      matcher: IngredientMatcher(pantry),
      homeCurrency: 'EUR',
      capturedAt: at ?? capturedAt,
    );

    test('clean receipt with known chicken is auto-commit eligible', () {
      final chicken = ingredient('chicken_breast');
      final d = validate(example(), [chicken]);
      expect(d.flags, isEmpty);
      expect(d.purchasedAt, DateTime(2026, 9, 27, 18, 42));
      expect(d.lines[0].matchedIngredientId, chicken.id);
      expect(d.lines[0].product, 'Store-brand chicken breast fillet, 500 g');
      expect(d.lines[0].stockCheck, isNull);
      expect(d.lines[1].isNewIngredient, isTrue);
      expect(d.lines[1].profile!.per100.kcal, 124);
      expect(d.lines[2].ingredientKey, isNull);
      expect(d.lines.every((l) => l.effectFor(ScanKind.receipt) == StockEffect.add), isTrue);
      expect(d.autoCommitEligible, isTrue);
    });

    test('an old receipt keeps its printed date; what keeps less long than that is probably used up', () {
      final chicken = ingredient('chicken_breast', shelf: 2);
      final d = validate(example(), [chicken], at: DateTime(2026, 10, 2, 9));
      expect(d.purchasedAt, DateTime(2026, 9, 27, 18, 42), reason: 'five days ago, as printed');
      expect(d.flags, isEmpty);
      expect(d.clean, isTrue);
      expect(d.lines[0].stockCheck, StockCheck.usedUp);
      expect(d.lines[0].effectFor(ScanKind.receipt), StockEffect.none);
      expect(d.lines[1].stockCheck, isNull, reason: 'the yogurt keeps 14 days');
      expect(d.autoCommitEligible, isFalse);
    });

    test('dates: none printed or in the future means the photo date; over a year back is kept', () {
      final pantry = [ingredient('chicken_breast')];
      final missing = validate(example((j) => j['purchased_at'] = null), pantry);
      expect(missing.purchasedAt, capturedAt);
      expect(missing.flags, ['date_missing']);
      expect(missing.clean, isFalse);
      final future = validate(example((j) => j['purchased_at'] = '2026-10-04'), pantry);
      expect(future.purchasedAt, capturedAt);
      expect(future.flags, ['date_adjusted']);
      final old = validate(example((j) => j['purchased_at'] = '2025-03-03'), pantry);
      expect(old.purchasedAt, DateTime(2025, 3, 3, 18, 42));
      expect(old.flags, ['date_old']);
      expect(old.autoCommitEligible, isFalse);
    });

    test('an item counted after the purchase asks whether the count already has it', () {
      final countedAfter = ingredient('chicken_breast', qty: 500, counted: DateTime(2026, 9, 27, 18, 55));
      final d = validate(example(), [countedAfter]);
      expect(d.lines[0].stockCheck, StockCheck.counted);
      expect(d.lines[0].effectFor(ScanKind.receipt), StockEffect.none);
      expect(d.clean, isTrue);
      expect(d.autoCommitEligible, isFalse);
      final countedBefore = ingredient('chicken_breast', qty: 500, counted: DateTime(2026, 9, 27, 9));
      expect(validate(example(), [countedBefore]).lines[0].stockCheck, isNull);
    });

    test('pantry photo: exact product, shelf price, and "already in your pantry?"', () {
      final pasta = ingredient('dry_pasta', qty: 900);
      final d = validate(example(null, 1), [pasta]);
      expect(d.kind, ScanKind.pantry);
      expect(d.purchasedAt, isNull);
      final spaghetti = d.lines[0];
      expect(spaghetti.product, 'Barilla Spaghetti n.5, 500 g');
      expect(spaghetti.estUnitCostMinor, closeTo(199 / 500, 1e-9));
      expect(spaghetti.stockCheck, StockCheck.onHand);
      expect(spaghetti.effectFor(ScanKind.pantry), StockEffect.replace, reason: 'by default the photo counts it');
      final oil = d.lines[1];
      expect(oil.isNewIngredient, isTrue);
      expect(oil.stockCheck, isNull);
      expect(oil.packageQty, 750);
      expect(oil.packagePriceMinor, 899);
      final none = validate(example(null, 1), [ingredient('dry_pasta')]);
      expect(none.lines[0].stockCheck, isNull, reason: 'nothing on hand to mix it up with');
    });

    test('a receipt line never takes a shelf price', () {
      final d = validate(
        example((j) => (j['items'] as List)[0]['shelf_price'] = {'package_qty': 500, 'price_minor': 450}),
        [ingredient('chicken_breast')],
      );
      expect(d.lines[0].packagePriceMinor, isNull);
    });

    test('alignUnit converts the quantity and the pack size together', () {
      final l = DraftLine()
        ..qty = 6
        ..unit = BaseUnit.pc
        ..packageQty = 10
        ..packagePriceMinor = 299;
      ReceiptValidator.alignUnit(l, BaseUnit.g, 55);
      expect(l.qty, 330);
      expect(l.packageQty, 550);
      expect(l.estUnitCostMinor, closeTo(299 / 550, 1e-9));
      final m = DraftLine()
        ..qty = 1
        ..unit = BaseUnit.pc
        ..packageQty = 1
        ..packagePriceMinor = 99;
      ReceiptValidator.alignUnit(m, BaseUnit.ml, null);
      expect(m.qty, isNull);
      expect(m.qtySource, QtySource.unknown);
      expect(m.packagePriceMinor, isNull);
    });

    test('sameReceipt: same day, total and store; store names may differ in detail', () {
      final day = DateTime(2026, 9, 26, 18, 42);
      bool same(String? merchant, DateTime other, int total) => ReceiptValidator.sameReceipt(
        merchant: 'Lidl',
        day: day,
        totalMinor: 822,
        otherMerchant: merchant,
        otherDay: other,
        otherTotalMinor: total,
      );
      expect(same('LIDL', DateTime(2026, 9, 26, 9), 822), isTrue);
      expect(same(null, day, 822), isTrue);
      expect(same('Lidl', day, 823), isFalse);
      expect(same('Lidl', DateTime(2026, 9, 27, 9), 822), isFalse);
      expect(same('Rewe', day, 822), isFalse);
      expect(
        ReceiptValidator.sameReceipt(
          merchant: 'Migros Zürich',
          day: day,
          totalMinor: 2310,
          otherMerchant: 'Migros',
          otherDay: day,
          otherTotalMinor: 2310,
        ),
        isTrue,
      );
    });

    test('total mismatch, foreign currency and fuzzy merge block auto-commit', () {
      final breast = ingredient('chicken_breasts')..name = 'Chicken breasts';
      final d = ReceiptValidator.validate(
        example((j) {
          j['receipt_total_minor'] = 900;
          j['currency'] = 'CHF';
          (j['items'] as List)[0]['ingredient_key'] = 'chicken_breast_fillet';
          (j['items'] as List)[0]['name'] = 'Chicken breasts';
          (j['items'] as List)[0]['is_new_ingredient'] = true;
          (j['items'] as List)[0]['new_ingredient'] = (j['items'] as List)[1]['new_ingredient'];
        }),
        matcher: IngredientMatcher([breast]),
        homeCurrency: 'EUR',
        capturedAt: capturedAt,
      );
      expect(d.flags, containsAll(['total_mismatch', 'foreign_currency', 'merge_proposed']));
      expect(d.lines[0].mergeCandidateId, breast.id);
      expect(d.autoCommitEligible, isFalse);
    });

    test('an uncertain currency blocks auto-commit', () {
      final d = ReceiptValidator.validate(
        example((j) => j['warnings'] = ['currency_uncertain']),
        matcher: IngredientMatcher([ingredient('chicken_breast')]),
        homeCurrency: 'EUR',
        capturedAt: capturedAt,
      );
      expect(d.flags, contains('currency_uncertain'));
      expect(d.autoCommitEligible, isFalse);
    });

    test('alias learned from an earlier receipt beats the AI key', () {
      final thigh = ingredient('chicken_thigh')..aliases = ['HOCHL BRUSTFILET'];
      final d = ReceiptValidator.validate(
        example(),
        matcher: IngredientMatcher([thigh]),
        homeCurrency: 'EUR',
        capturedAt: capturedAt,
      );
      expect(d.lines[0].ingredientKey, 'chicken_thigh');
    });

    test('pc quantity converts to a g ingredient via piece weight', () {
      final egg = ingredient('egg', gpp: 55);
      final d = ReceiptValidator.validate(
        example((j) {
          final it = (j['items'] as List)[0] as Map;
          it['ingredient_key'] = 'egg';
          it['qty'] = 10;
          it['unit'] = 'pc';
        }),
        matcher: IngredientMatcher([egg]),
        homeCurrency: 'EUR',
        capturedAt: capturedAt,
      );
      expect(d.lines[0].qty, 550);
      expect(d.lines[0].unit, BaseUnit.g);
    });
  });

  group('RecipeValidator', () {
    final profile = UserProfile();
    final stock = [
      ingredient('chicken_breast', qty: 650, cost: 0.998, kcal: 110, protein: 23.1, fat: 1.9),
      ingredient('white_rice', qty: 1000, cost: 0.2, kcal: 360, protein: 7.1, carbs: 79, fat: 0.7),
      ingredient('spinach', qty: 210, cost: 0.796, kcal: 23, protein: 2.9, carbs: 3.6, fat: 0.4),
      ingredient('olive_oil', qty: 450, unit: BaseUnit.ml, cost: 0.9, kcal: 814, fat: 92),
      ingredient('garlic_powder', qty: 55, cost: 2.48, kcal: 331, protein: 17, carbs: 73),
      ingredient('salt', qty: 450, cost: 0.098),
    ];
    final idx = StockIndex(stock);
    final matcher = IngredientMatcher(stock);

    RecipeDto daily([void Function(Map<String, dynamic>)? edit]) {
      final json = jsonDecode(promptExample('daily_recipe.v2.md')) as Map<String, dynamic>;
      edit?.call(json['recipe'] as Map<String, dynamic>);
      return DailyRecipeOutput.parse(json).value!.recipe!;
    }

    test('prompt B example validates; Dart numbers match the estimate, seasonings costed', () {
      final v = RecipeValidator.validate(
        daily(),
        stock: idx,
        matcher: matcher,
        profile: profile,
        allowMissing: false,
        origin: RecipeOrigin.dailyAuto,
      );
      expect(v.ok, isTrue, reason: v.hardErrors.join('\n'));
      expect(v.recipe!.perPortion.kcal, closeTo(634, 25));
      // 179.6 chicken + 20 rice + 55.7 spinach + 6.3 oil + 2.5 garlic + 0.2 salt
      expect(v.recipe!.costPerPortionMinor, 264);
      expect(v.recipe!.ingredients.every((i) => i.role == IngredientRole.stock), isTrue);
      expect(v.flags.where((f) => f.startsWith('estimate_divergence')), isEmpty);
    });

    test('salt is stock like anything else: none on hand and the pick goes back for repair', () {
      final noSalt = [for (final i in stock) i.key == 'salt' ? ingredient('salt') : i];
      final v = RecipeValidator.validate(
        daily(),
        stock: StockIndex(noSalt),
        matcher: IngredientMatcher(noSalt),
        profile: profile,
        allowMissing: false,
        origin: RecipeOrigin.dailyAuto,
      );
      expect(v.ok, isFalse);
      expect(v.hardErrors.single, contains("'Salt' needs 6 g for 3 portions but only 0 is available"));
    });

    test('allergen is a hard error for the repair loop', () {
      final allergic = UserProfile()..allergies = ['garlic'];
      final v = RecipeValidator.validate(
        daily(),
        stock: idx,
        matcher: matcher,
        profile: allergic,
        allowMissing: false,
        origin: RecipeOrigin.dailyAuto,
      );
      expect(v.ok, isFalse);
      expect(v.hardErrors.single, contains("allergy 'garlic'"));
    });

    test('over-quantity clamps portions; unknown key is remapped by name', () {
      final v = RecipeValidator.validate(
        daily((r) {
          r['portions'] = 4;
          (r['ingredients'] as List)[0]['key'] = 'chicken_breasts';
        }),
        stock: idx,
        matcher: matcher,
        profile: profile,
        allowMissing: false,
        origin: RecipeOrigin.dailyAuto,
      );
      expect(v.ok, isTrue, reason: v.hardErrors.join('\n'));
      expect(v.recipe!.defaultPortions, 3);
      expect(v.flags, contains('portions_clamped'));
      expect(v.flags.any((f) => f.startsWith('remapped_key:chicken_breasts')), isTrue);
    });

    test('unknown key: hard error for B, missing for C', () {
      void edit(Map<String, dynamic> r) {
        (r['ingredients'] as List)[2]['key'] = 'kale';
        (r['ingredients'] as List)[2]['name'] = 'Kale';
      }

      final b = RecipeValidator.validate(
        daily(edit),
        stock: idx,
        matcher: matcher,
        profile: profile,
        allowMissing: false,
        origin: RecipeOrigin.dailyAuto,
      );
      expect(b.ok, isFalse);
      final kale = daily(edit);
      final c = RecipeValidator.validate(
        kale,
        stock: idx,
        matcher: matcher,
        profile: profile,
        allowMissing: true,
        origin: RecipeOrigin.spontaneous,
      );
      expect(c.ok, isTrue);
      expect(c.recipe!.ingredients[2].role, IngredientRole.missing);
      expect(RecipeValidator.verdict(c.recipe!, c.feasibility!, const []), 'missing_items');
    });
  });
}
