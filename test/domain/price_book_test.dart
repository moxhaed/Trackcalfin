import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/price_book.dart';

var _id = 1;

Transaction shop(String? merchant, DateTime at, List<LineItem> lines) => Transaction()
  ..id = _id++
  ..merchant = merchant
  ..occurredAt = at
  ..lines = lines
  ..totalMinor = lines.fold(0, (a, l) => a + l.totalMinor);

LineItem line(String key, double qty, int minor, {String? product, bool stocked = true, BaseUnit? unit}) => LineItem()
  ..name = key.replaceAll('_', ' ')
  ..ingredientKey = key
  ..qtyBought = stocked ? qty : null
  ..unit = unit
  ..totalMinor = minor
  ..product = product;

void main() {
  final now = DateTime(2026, 10, 1, 20);
  DateTime ago(int days) => now.subtract(Duration(days: days));

  test('one store, whatever the branch: the brand, lowercased', () {
    expect(PriceBook.storeKey('Migros Zürich'), 'migros');
    expect(PriceBook.storeKey('MIGROS'), 'migros');
    expect(PriceBook.storeKey('Migros-Genossenschaft'), 'migros');
    expect(PriceBook.storeKey('The Co-op'), 'co');
    expect(PriceBook.storeKey("L'Épicerie"), 'épicerie');
    expect(PriceBook.storeKey('  '), isNull);
    expect(PriceBook.storeKey(null), isNull);
  });

  test("each store's latest price per item, cheapest first", () {
    final book = PriceBook.from([
      shop('Lidl Berlin', ago(20), [line('chicken_breast', 500, 549)]),
      shop('Lidl', ago(6), [line('chicken_breast', 500, 499, product: 'Store-brand fillet, 500 g')]),
      shop('Rewe', ago(3), [line('chicken_breast', 400, 549), line('chicken_breast', 400, 549)]),
      shop('Aldi', ago(150), [line('chicken_breast', 500, 399)]), // too old to be a price
      shop(null, ago(2), [line('chicken_breast', 500, 299)]), // no store
      shop('Edeka', ago(2), [line('chicken_breast', 500, 299, stocked: false)]), // no quantity
    ], now: now);
    final prices = book.pricesFor('chicken_breast');
    expect([for (final p in prices) (p.store, p.totalMinor, p.qty)], [('Lidl', 499, 500.0), ('Rewe', 1098, 800.0)]);
    expect(prices.first.product, 'Store-brand fillet, 500 g');
    expect(prices.first.unitMinor, closeTo(0.998, 1e-9));
    expect(book.cheapest('chicken_breast')!.store, 'Lidl');
    expect(book.compared, ['chicken_breast']);
    expect(book.cheapest('rice'), isNull);

    const money = MoneyFormat();
    expect(PriceBook.perUnit(money, 0.998, BaseUnit.g), '€9.98/kg');
    expect(PriceBook.perUnit(money, 0.099, BaseUnit.ml), '€0.99/l');
    expect(PriceBook.perUnit(money, 27.9, BaseUnit.pc), '€0.28 each');
  });

  test('a price in a unit the item no longer uses is left out', () {
    final txs = [
      shop('Lidl', ago(40), [line('cola_zero', 1980, 299, unit: BaseUnit.ml)]),
      shop('Rewe', ago(5), [line('cola_zero', 6, 389, unit: BaseUnit.pc)]),
    ];
    final book = PriceBook.from(txs, now: now, units: {'cola_zero': BaseUnit.pc});
    expect([for (final p in book.pricesFor('cola_zero')) (p.store, p.unit)], [('Rewe', BaseUnit.pc)]);
    final receipt = shop('Rewe', now, [line('cola_zero', 6, 389, unit: BaseUnit.pc)]);
    expect(PriceBook.tipsFor(receipt, txs, now: now), isEmpty, reason: 'ml and cans are not compared');
  });

  test('after a receipt: items another store sold clearly cheaper, biggest saving first', () {
    final history = [
      shop('Lidl', ago(10), [
        line('chicken_breast', 500, 499),
        line('greek_yogurt', 500, 179),
        line('egg', 10, 279),
        line('dry_pasta', 500, 95),
        line('oat_flakes', 500, 99),
      ]),
      shop('Rewe', ago(30), [line('greek_yogurt', 500, 150)]), // the same store is never a tip
      shop('Aldi', ago(100), [line('chicken_breast', 500, 299)]), // older than the tip window
    ];
    final receipt = shop('REWE City', ago(0), [
      line('chicken_breast', 400, 549), // Lidl: 27% less, saves 1.50
      line('greek_yogurt', 500, 229), // Lidl: 22% less, saves 0.50
      line('egg', 6, 219), // Lidl: 24% less, saves 0.52
      line('dry_pasta', 500, 99), // Lidl: 4% less: not worth a word
      line('oat_flakes', 100, 25), // Lidl: 20% less, but saves 0.05
    ]);
    final tips = PriceBook.tipsFor(receipt, [...history, receipt], now: now);
    expect(
      [for (final t in tips) (t.key, t.cheaper.store, t.savingMinor)],
      [('chicken_breast', 'Lidl', 150), ('egg', 'Lidl', 52), ('greek_yogurt', 'Lidl', 50)],
    );
    expect(tips.first.share, closeTo(0.273, 0.001));
    expect(tips.first.paid.store, 'REWE City');
    expect(PriceBook.tipsFor(shop(null, now, receipt.lines), history, now: now), isEmpty, reason: 'no store, no tip');
  });
}
