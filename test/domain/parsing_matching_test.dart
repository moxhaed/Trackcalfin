import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/scan_job.dart';
import 'package:trackcalfin/data/isar/collections/user_profile.dart';
import 'package:trackcalfin/domain/ingredient_matcher.dart';
import 'package:trackcalfin/domain/quick_check.dart';
import 'package:trackcalfin/domain/quick_text_parser.dart';
import 'package:trackcalfin/domain/receipt_math.dart';

import 'fixtures.dart';

void main() {
  group('QuickTextParser', () {
    test('amount first or last, comma decimals', () {
      final a = QuickTextParser.parse('12,50 lunch')!;
      expect(a.amountMinor, 1250);
      expect(a.category, SpendCategory.eatingOut);
      final b = QuickTextParser.parse('cinema 11')!;
      expect(b.amountMinor, 1100);
      expect(b.category, SpendCategory.entertainment);
      expect(QuickTextParser.parse('zara 39,99 jeans')!.category, SpendCategory.clothes);
      expect(QuickTextParser.parse('no amount here'), isNull);
    });
    test('learned keyword beats built-in; unknown keyword has no category', () {
      final learned = QuickTextParser.learn(const [], 'lunch', SpendCategory.other);
      expect(QuickTextParser.parse('9 lunch', learned: learned)!.category, SpendCategory.other);
      final u = QuickTextParser.parse('5 thingamajig')!;
      expect(u.category, isNull);
      expect(u.keyword, 'thingamajig');
    });
    test('learn replaces an existing keyword', () {
      var l = <KeywordCategory>[];
      l = QuickTextParser.learn(l, 'Gym', SpendCategory.entertainment);
      l = QuickTextParser.learn(l, 'gym', SpendCategory.other);
      expect(l.length, 1);
      expect(l.single.category, SpendCategory.other);
    });
  });

  group('IngredientMatcher', () {
    test('normalization strips prices, weights, digits and punctuation', () {
      expect(IngredientMatcher.normalize('HOCHL.BRUSTFILET 500G 4,99 A'), 'HOCHL BRUSTFILET');
      expect(IngredientMatcher.normalize('H-MILCH 3,5% 1L 1,09'), 'H MILCH');
      expect(IngredientMatcher.normalize('2 x Joghurt 150g'), 'JOGHURT');
    });
    test('alias beats AI key; fuzzy proposes; unknown is none', () {
      final breast = ingredient('chicken_breast')..aliases = ['HOCHL BRUSTFILET'];
      final thigh = ingredient('chicken_thigh');
      final m = IngredientMatcher([breast, thigh]);
      final a = m.resolve(rawText: 'HOCHL.BRUSTFILET 4,99', key: 'chicken_thigh');
      expect(a.kind, MatchKind.alias);
      expect(a.ingredient, breast);
      expect(m.resolve(key: 'chicken_thigh').kind, MatchKind.key);
      final f = m.resolve(key: 'chicken_breasts', name: 'Chicken breasts');
      expect(f.kind, MatchKind.fuzzy);
      expect(f.ingredient, breast);
      expect(m.resolve(key: 'salmon_fillet', name: 'Salmon fillet').kind, MatchKind.none);
    });
    test('learnAlias dedupes and caps', () {
      final i = ingredient('milk');
      for (var n = 0; n < 25; n++) {
        IngredientMatcher.learnAlias(i, 'MILK BRAND $n');
        IngredientMatcher.learnAlias(i, 'MILK BRAND${String.fromCharCode(65 + n)}');
      }
      expect(i.aliases.length, IngredientMatcher.maxAliases);
    });
  });

  group('ReceiptMath', () {
    DraftLine line(int minor, {LineType type = LineType.product, SpendCategory cat = SpendCategory.groceries}) =>
        DraftLine()
          ..totalMinor = minor
          ..lineType = type
          ..category = cat;

    test('basket adjustment is spread proportionally with no rounding drift', () {
      final lines = [line(333), line(333), line(334), line(-100, type: LineType.adjustment), line(25, type: LineType.deposit)];
      final out = ReceiptMath.allocateAdjustments(lines);
      expect(out.length, 4);
      expect(out.fold(0, (a, l) => a + l.totalMinor), 925);
      expect(out.where((l) => l.lineType == LineType.adjustment), isEmpty);
    });
    test('primary category by amount', () {
      expect(
        ReceiptMath.primaryCategory([
          (category: SpendCategory.groceries, totalMinor: 800),
          (category: SpendCategory.household, totalMinor: 900),
        ]),
        SpendCategory.household,
      );
    });
  });

  group('QuickCheck', () {
    final now = DateTime(2026, 10, 1);
    test('selects unverified, stale and expired items; shortfall first', () {
      final unverified = ingredient('rice', qty: 800, shelf: 365, cost: 0.2);
      final stalePerishable = ingredient('milk', qty: 500, shelf: 7, verified: now.subtract(const Duration(days: 8)), cost: 0.1);
      final fresh = ingredient('pasta', qty: 500, shelf: 365, verified: now.subtract(const Duration(days: 3)));
      final expired = ingredient('yogurt', qty: 200, shelf: 14, verified: now.subtract(const Duration(days: 2)), expiresAt: now.subtract(const Duration(days: 1)));
      final empty = ingredient('salt', qty: 0);
      final c = QuickCheck.candidates([fresh, stalePerishable, unverified, expired, empty], now);
      expect(c.first, unverified);
      expect(c.toSet(), {unverified, stalePerishable, expired});
    });
  });
}
