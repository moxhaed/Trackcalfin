import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/feasibility.dart';
import 'package:trackcalfin/domain/price_book.dart';
import 'package:trackcalfin/domain/shopping.dart';
import 'package:trackcalfin/domain/stock_index.dart';

import 'fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 2, 18);

  ShoppingListItem line(String name, {String? key, bool done = false, int minutes = 0}) => ShoppingListItem()
    ..name = name
    ..ingredientKey = key
    ..addedAt = now.add(Duration(minutes: minutes))
    ..doneAt = done ? now : null;

  test('suggests what is running low or ran out lately, unless it is on the list already', () {
    final milk = ingredient('whole_milk', qty: 150)..lowStockThreshold = 250;
    final eggs = ingredient('egg', qty: 0)..lastPurchasedAt = now.subtract(const Duration(days: 9));
    final saffron = ingredient('saffron', qty: 0)..lastPurchasedAt = now.subtract(const Duration(days: 200));
    final rice = ingredient('white_rice', qty: 900)..lowStockThreshold = 250;
    final oil = ingredient('olive_oil', qty: 50)..lowStockThreshold = 100;
    final list = [line('Olive oil', key: 'olive_oil'), line('egg', key: 'egg', done: true)];
    final s = Shopping.suggestions([milk, eggs, saffron, rice, oil], list, now: now);
    expect([for (final x in s) (x.key, x.reason)], [('egg', 'out'), ('whole_milk', 'running low')]);
  });

  test("a recipe's missing items: short ones, missing ones and its own To buy list, once each", () {
    final pasta = ingredient('dry_pasta', qty: 100);
    final r = Recipe()
      ..ingredients = [ri('dry_pasta', 160), ri('guanciale', 80, role: IngredientRole.missing)..name = 'Guanciale']
      ..shoppingList = [ShoppingItem()..name = 'Guanciale', ShoppingItem()..name = 'Pecorino'];
    final f = FeasibilityChecker.check(r.ingredients, 2, StockIndex([pasta]));
    expect(
      [for (final x in Shopping.forRecipe(r, f)) (x.name, x.key)],
      [('dry pasta', 'dry_pasta'), ('Guanciale', null), ('Pecorino', null)],
    );
  });

  test('the list by the store each item is cheapest at, "anywhere" last, ready to send', () {
    Transaction shop(String store, String key, double qty, int minor) => Transaction()
      ..merchant = store
      ..occurredAt = now.subtract(const Duration(days: 3))
      ..lines = [
        LineItem()
          ..ingredientKey = key
          ..qtyBought = qty
          ..totalMinor = minor,
      ];
    final book = PriceBook.from([
      shop('Rewe', 'whole_milk', 1000, 119),
      shop('Lidl', 'whole_milk', 1000, 99),
      shop('Aldi', 'egg', 10, 259),
    ], now: now);
    final open = [
      line('Whole milk', key: 'whole_milk'),
      line('Birthday candles', minutes: 1),
      line('Eggs', key: 'egg', minutes: 2)..amount = '10',
    ];
    expect(
      [for (final (store, items) in Shopping.byStore(open, book)) '$store: ${items.map((l) => l.name).join(', ')}'],
      ['Aldi: Eggs', 'Lidl: Whole milk', 'null: Birthday candles'],
    );
    expect(
      Shopping.asText(open, book),
      'Shopping list\n\nAldi\n- Eggs (10)\n\nLidl\n- Whole milk\n\nAnywhere\n- Birthday candles',
    );
  });
}
