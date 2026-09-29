import 'package:isar_community/isar.dart';

import '../data/fx/fx_rate_client.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/fx.dart';
import 'clock.dart';

/// Exchange rates for foreign receipts: ECB rate for the purchase day, else the
/// last rate you used for that currency, else null (the review screen asks).
class FxService {
  FxService(this.isar, {this.client, Now? now}) : now = now ?? DateTime.now;

  final Isar isar;
  final FxRateClient? client;
  final Now now;

  Future<FxQuote?> quote(String from, String to, DateTime date) async {
    final f = from.toUpperCase();
    final t = to.toUpperCase();
    if (f == t) return FxQuote(from: f, to: t, rate: 1, date: date, source: FxSource.ecb);
    final fetched = await client?.fetch(f, t, date, now: now());
    if (fetched != null) {
      await remember(fetched);
      return fetched;
    }
    return remembered(f, t);
  }

  Future<FxQuote?> remembered(String from, String to) async {
    final p = await isar.userProfiles.get(1);
    final memo = p?.fxMemory.where((m) => m.from == from.toUpperCase() && m.to == to.toUpperCase()).firstOrNull;
    if (memo == null) return null;
    return FxQuote(from: memo.from, to: memo.to, rate: memo.rate, date: memo.updatedAt, source: FxSource.remembered);
  }

  Future<void> remember(FxQuote q) async {
    if (!FxMath.plausible(q.rate)) return;
    await isar.writeTxn(() async {
      final p = await isar.userProfiles.get(1);
      if (p == null) return;
      p.fxMemory = [
        ...p.fxMemory.where((m) => !(m.from == q.from && m.to == q.to)),
        FxMemo()
          ..from = q.from
          ..to = q.to
          ..rate = q.rate
          ..updatedAt = now(),
      ];
      await isar.userProfiles.put(p);
    });
  }
}
