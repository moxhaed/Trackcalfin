import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/cookbook.dart';
import 'package:trackcalfin/domain/feasibility.dart';
import 'package:trackcalfin/domain/shopping.dart';
import 'package:trackcalfin/domain/stock_index.dart';

import 'fixtures.dart';

Uint8List pdf(String body) => Uint8List.fromList(latin1.encode('%PDF-1.7\n$body\n%%EOF'));

void main() {
  test('page count: a linearized /N, the page tree /Count, the pages counted, or unknown', () {
    expect(CookbookPdf.pageCount(pdf('1 0 obj << /Linearized 1 /L 9000 /N 212 /T 800 >> endobj')), 212);
    expect(
      CookbookPdf.pageCount(
        pdf(
          '2 0 obj << /Type /Pages /Kids [3 0 R 9 0 R] /Count 140 >> endobj\n'
          '9 0 obj << /Type /Pages /Parent 2 0 R /Count 40 >> endobj\n'
          '7 0 obj << /Type /Outlines /Count 900 >> endobj',
        ),
      ),
      140,
      reason: 'the root node, not a branch or the bookmarks',
    );
    expect(CookbookPdf.pageCount(pdf('3 0 obj << /Type /Page >> endobj 4 0 obj << /Type /Page >> endobj')), 2);
    expect(CookbookPdf.pageCount(pdf('5 0 obj << /Type /ObjStm /N 40 /Filter /FlateDecode >> stream')), isNull);
    expect(CookbookPdf.looksLikePdf(pdf('')), isTrue);
    expect(CookbookPdf.looksLikePdf(Uint8List.fromList(utf8.encode('<html>'))), isFalse);
  });

  test('index entries are kept once; batches go in book order and halve after a failure', () {
    final entries = <CookbookEntry>[];
    expect(CookbookPlanner.addToIndex(entries, const [('Sumac onions', 35), ('Hummus', 34), ('HUMMUS!', 90)]), 2);
    expect(CookbookPlanner.addToIndex(entries, const [('Flatbread', null)]), 1);
    expect(CookbookPlanner.nextBatch(entries, size: 2), [1, 0], reason: 'page 34 first, no page last');
    expect(CookbookPlanner.pagesLabel(entries, [1, 0]), 'pages 34–35');
    entries[1].attempts = 1;
    expect(CookbookPlanner.nextBatch(entries, size: 4), [1, 0]);
    entries[1].state = CookbookEntryState.done;
    expect(CookbookPlanner.nextBatch(entries, size: 4), [0, 2]);
    expect(CookbookPlanner.pagesLabel(entries, [2]), '1 recipe');
  });

  test('a draft becomes a recipe per portion: pantry matches, one row per item, optional lines left out', () {
    final oil = ingredient('olive_oil', qty: 500, unit: BaseUnit.ml, cost: 0.9);
    final flour = ingredient('flour', qty: 1000, cost: 0.1)..name = 'Flour';
    final d = CookbookDraft()
      ..title = 'Flatbread'
      ..page = 12
      ..servings = 4
      ..ingredients = [
        CookbookLine()
          ..name = 'Plain flour'
          ..key = 'flour'
          ..qty = 400,
        CookbookLine()
          ..name = 'Olive oil'
          ..key = 'olive_oil'
          ..qty = 40
          ..unit = BaseUnit.ml,
        CookbookLine()
          ..name = 'Olive oil'
          ..key = 'olive_oil'
          ..qty = 20
          ..unit = BaseUnit.ml,
        CookbookLine()
          ..name = "Za'atar"
          ..key = 'zaatar'
          ..qty = 8,
        CookbookLine()
          ..name = 'Flaky salt'
          ..key = 'flaky_salt'
          ..qty = 2
          ..optional = true,
      ];
    final stock = StockIndex([oil, flour]);
    final r = CookbookReview.toRecipe(d, book: 'Breads', matcher: CookbookMatcher([oil, flour]), stock: stock);
    expect(
      [for (final i in r.ingredients) (i.key, i.qtyPerPortion, i.ingredientId != null)],
      [('flour', 100, true), ('olive_oil', 15, true), ('zaatar', 2, false)],
    );
    expect(r.omitted, ['Flaky salt']);
    expect((r.sourceBook, r.sourcePage, r.defaultPortions), ('Breads', 12, 4));
    expect(r.costPerPortionMinor, (100 * 0.1 + 15 * 0.9).round(), reason: "the pantry's prices; za'atar adds nothing");
    final fit = CookbookReview.fit(r, stock);
    expect(fit.summary, "You have 2 of 3 · missing za'atar");

    // A row the pantry doesn't have goes on the shopping list too.
    final f = FeasibilityChecker.check(r.ingredients, 4, stock);
    expect([for (final s in Shopping.forRecipe(r, f)) (s.name, s.key)], [("Za'atar", null)]);
  });
}
