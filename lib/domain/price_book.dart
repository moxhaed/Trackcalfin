import '../core/day_clock.dart';
import '../core/enums.dart';
import '../core/money.dart';
import '../data/isar/collections/transaction.dart';

/// What one store charged for an item, the last time it was bought there.
class StorePrice {
  StorePrice({
    required this.store,
    required this.storeKey,
    required this.qty,
    required this.totalMinor,
    required this.at,
    this.product,
    this.unit,
  });

  /// The store's name as receipts print it (the shortest seen: "Lidl", not "Lidl Berlin").
  final String store;

  /// The store with branch and case ignored: "lidl".
  final String storeKey;

  /// How much was bought, in the item's base unit, and what it cost.
  final double qty;
  final int totalMinor;
  final DateTime at;

  /// The exact product, when the receipt said ("Barilla Spaghetti n.5, 500 g").
  final String? product;

  /// The unit of [qty]; null on lines from before units were kept.
  final BaseUnit? unit;

  /// Price per base unit (per g, ml or piece), in minor units.
  double get unitMinor => totalMinor / qty;
}

/// An item just bought that another store sold for less.
class PriceTip {
  PriceTip({required this.key, required this.name, required this.paid, required this.cheaper});
  final String key;
  final String name;

  /// What this receipt paid.
  final StorePrice paid;

  /// The cheapest other store, from the last [PriceBook.tipDays].
  final StorePrice cheaper;

  /// How much less the amount just bought would have cost there.
  int get savingMinor => ((paid.unitMinor - cheaper.unitMinor) * paid.qty).round();

  /// How much cheaper per unit, 0..1.
  double get share => 1 - cheaper.unitMinor / paid.unitMinor;
}

/// Store prices from the ledger: the latest price per store for each item, from grocery lines
/// that know their item and quantity (receipts, buys with a price paid). Pure Dart, no AI.
class PriceBook {
  PriceBook._(this._prices);

  /// Prices older than this are history, not a price.
  static const maxDays = 120;

  /// A tip compares with prices from this many days back.
  static const tipDays = 90;

  /// A tip needs the other store to be at least this much cheaper per unit...
  static const tipShare = 0.10;

  /// ...and to save at least this much on what was bought (0.30 in the home currency).
  static const tipMinMinor = 30;

  final Map<String, List<StorePrice>> _prices;

  /// No prices at all.
  static final empty = PriceBook._(const {});

  /// Every store's latest price for [key], cheapest first.
  List<StorePrice> pricesFor(String key) => _prices[key] ?? const [];

  /// Items bought at two stores or more.
  Iterable<String> get compared => _prices.keys.where((k) => _prices[k]!.length > 1);

  /// The cheapest store for [key], when two or more stores have a price for it.
  StorePrice? cheapest(String key) {
    final p = pricesFor(key);
    return p.length > 1 ? p.first : null;
  }

  /// The book from [txs]. [units] are the items' base units now: a price in another unit (an
  /// item switched from ml to cans since) is left out.
  static PriceBook from(
    Iterable<Transaction> txs, {
    required DateTime now,
    Map<String, BaseUnit> units = const {},
    int days = maxDays,
  }) {
    final from = DayClock.addDays(now, -days);
    final names = <String, String>{};
    final latest = <String, Map<String, StorePrice>>{};
    for (final t in txs) {
      if (t.occurredAt.isBefore(from) || t.occurredAt.isAfter(now)) continue;
      final store = storeKey(t.merchant);
      if (store == null) continue;
      final name = t.merchant!.trim();
      if (names[store] == null || name.length < names[store]!.length) names[store] = name;
      for (final MapEntry(:key, value: line) in _lines(t, units).entries) {
        final byStore = latest.putIfAbsent(key, () => {});
        final old = byStore[store];
        if (old != null && !t.occurredAt.isAfter(old.at)) continue;
        byStore[store] = StorePrice(
          store: name,
          storeKey: store,
          qty: line.qty,
          totalMinor: line.totalMinor,
          at: t.occurredAt,
          product: line.product,
          unit: line.unit,
        );
      }
    }
    return PriceBook._({
      for (final e in latest.entries)
        e.key: [
          for (final p in e.value.values)
            StorePrice(
              store: names[p.storeKey]!,
              storeKey: p.storeKey,
              qty: p.qty,
              totalMinor: p.totalMinor,
              at: p.at,
              product: p.product,
              unit: p.unit,
            ),
        ]..sort((a, b) => a.unitMinor.compareTo(b.unitMinor)),
    });
  }

  /// Items on [tx] another store sold for at least [tipShare] less per unit in the last
  /// [tipDays], saving at least [tipMinMinor] on what was bought. Biggest saving first.
  /// [history] may include [tx]; it is left out of the comparison.
  static List<PriceTip> tipsFor(
    Transaction tx,
    Iterable<Transaction> history, {
    required DateTime now,
    Map<String, BaseUnit> units = const {},
  }) {
    final here = storeKey(tx.merchant);
    if (here == null) return const [];
    final book = PriceBook.from(history.where((t) => t.id != tx.id), now: now, units: units, days: tipDays);
    final tips = <PriceTip>[];
    for (final MapEntry(:key, value: line) in _lines(tx, units).entries) {
      final other = book
          .pricesFor(key)
          .where((p) => p.storeKey != here && (p.unit == null || line.unit == null || p.unit == line.unit))
          .firstOrNull;
      if (other == null) continue;
      final tip = PriceTip(
        key: key,
        name: line.name,
        paid: StorePrice(
          store: tx.merchant!.trim(),
          storeKey: here,
          qty: line.qty,
          totalMinor: line.totalMinor,
          at: tx.occurredAt,
          product: line.product,
          unit: line.unit,
        ),
        cheaper: other,
      );
      if (tip.share >= tipShare && tip.savingMinor >= tipMinMinor) tips.add(tip);
    }
    tips.sort((a, b) => b.savingMinor.compareTo(a.savingMinor));
    return tips;
  }

  /// "Migros Zürich", "MIGROS" and "Migros-Genossenschaft" are one store: the first word of the
  /// name, lowercased, after an article ("The Co-op" is "co").
  static String? storeKey(String? merchant) {
    final words = (merchant ?? '')
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((w) => w.isNotEmpty && !_articles.contains(w));
    return words.firstOrNull;
  }

  static const _articles = {'the', 'le', 'la', 'les', 'l', 'der', 'die', 'das', 'el', 'il', 'de'};

  /// A transaction's priced grocery lines by item, two lines of one item added together.
  /// Lines in another unit than the item's ([units]) are skipped.
  static Map<String, _Line> _lines(Transaction t, Map<String, BaseUnit> units) {
    final out = <String, _Line>{};
    for (final l in t.lines) {
      final key = l.ingredientKey;
      final qty = l.qtyBought;
      if (key == null || qty == null || qty <= 0 || l.totalMinor <= 0 || !l.category.isFood) continue;
      final now = units[key];
      if (now != null && l.unit != null && l.unit != now) continue;
      final old = out[key];
      if (old != null && old.unit != l.unit) continue;
      out[key] = old == null
          ? _Line(l.name, qty, l.totalMinor, l.product, l.unit)
          : _Line(old.name, old.qty + qty, old.totalMinor + l.totalMinor, old.product ?? l.product, old.unit);
    }
    return out;
  }

  /// [unitMinor] as a shelf label reads: per kg, per litre or per piece.
  static String perUnit(MoneyFormat money, double unitMinor, BaseUnit unit) => switch (unit) {
    BaseUnit.g => '${money.format((unitMinor * 1000).round())}/kg',
    BaseUnit.ml => '${money.format((unitMinor * 1000).round())}/l',
    BaseUnit.pc => '${money.format(unitMinor.round())} each',
  };
}

class _Line {
  _Line(this.name, this.qty, this.totalMinor, this.product, this.unit);
  final String name;
  final double qty;
  final int totalMinor;
  final String? product;
  final BaseUnit? unit;
}
