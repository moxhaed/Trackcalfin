import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/price_book.dart';
import 'clock.dart';

/// Store prices from the ledger, read for one receipt at a time.
class PriceService {
  PriceService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  /// Items on transaction [txId] another store sold clearly cheaper lately (PriceBook.tipsFor).
  Future<List<PriceTip>> tipsFor(int txId) async {
    final tx = await isar.transactions.get(txId);
    if (tx == null) return const [];
    final t = now();
    final history = await isar.transactions
        .where()
        .occurredAtGreaterThan(DayClock.addDays(t, -PriceBook.tipDays))
        .findAll();
    final units = {for (final i in await isar.ingredients.where().findAll()) i.key: i.baseUnit};
    return PriceBook.tipsFor(tx, history, now: t, units: units);
  }
}
