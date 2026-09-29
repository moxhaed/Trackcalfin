import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/dto/receipt_dto.dart';
import 'package:trackcalfin/data/ai/dto/recipe_dto.dart';
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

    ReceiptExtraction example([void Function(Map<String, dynamic>)? edit]) {
      final json = jsonDecode(promptExample('receipt_extraction.v2.md')) as Map<String, dynamic>;
      edit?.call(json);
      return ReceiptExtraction.parse(json).value!;
    }

    test('clean receipt with known chicken is auto-commit eligible', () {
      final chicken = ingredient('chicken_breast');
      final d = ReceiptValidator.validate(
        example(),
        matcher: IngredientMatcher([chicken]),
        homeCurrency: 'EUR',
        capturedAt: capturedAt,
      );
      expect(d.flags, isEmpty);
      expect(d.lines[0].matchedIngredientId, chicken.id);
      expect(d.lines[1].isNewIngredient, isTrue);
      expect(d.lines[1].profile!.per100.kcal, 124);
      expect(d.lines[2].ingredientKey, isNull);
      expect(d.autoCommitEligible, isTrue);
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
      ingredient('olive_oil', unit: BaseUnit.ml, staple: true, kcal: 814, fat: 92),
      ingredient('garlic_powder', staple: true, kcal: 331, protein: 17, carbs: 73),
      ingredient('salt', staple: true),
    ];
    final idx = StockIndex(stock);
    final matcher = IngredientMatcher(stock);
    final staples = {'olive_oil', 'garlic_powder', 'salt'};

    RecipeDto daily([void Function(Map<String, dynamic>)? edit]) {
      final json = jsonDecode(promptExample('daily_recipe.v1.md')) as Map<String, dynamic>;
      edit?.call(json['recipe'] as Map<String, dynamic>);
      return DailyRecipeOutput.parse(json).value!.recipe!;
    }

    test('prompt B example validates; Dart numbers match the estimate', () {
      final v = RecipeValidator.validate(
        daily(),
        stock: idx,
        matcher: matcher,
        stapleKeys: staples,
        profile: profile,
        allowMissing: false,
        origin: RecipeOrigin.dailyAuto,
      );
      expect(v.ok, isTrue, reason: v.hardErrors.join('\n'));
      expect(v.recipe!.perPortion.kcal, closeTo(633, 25));
      expect(v.recipe!.costPerPortionMinor, closeTo(255, 2));
      expect(v.flags.where((f) => f.startsWith('estimate_divergence')), isEmpty);
    });

    test('allergen is a hard error for the repair loop', () {
      final allergic = UserProfile()..allergies = ['garlic'];
      final v = RecipeValidator.validate(
        daily(),
        stock: idx,
        matcher: matcher,
        stapleKeys: staples,
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
        stapleKeys: staples,
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
        stapleKeys: staples,
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
        stapleKeys: staples,
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
