import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/application/ledger_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

import '../support/test_db.dart';

/// "I'm out" by mistake, found days later: the item's sheet takes the count back.
void main() {
  late Isar isar;
  late PantryService pantry;
  var clockNow = DateTime(2026, 9, 26, 19);
  DateTime now() => clockNow;

  final bought = DateTime(2026, 9, 26, 19);
  final markedOut = DateTime(2026, 10, 2, 19); // Friday
  final found = DateTime(2026, 10, 3, 12); // Saturday, long past the 2-minute undo window

  setUp(() async {
    isar = await openTestDb();
    await ProfileService(isar).load();
    pantry = PantryService(isar, now: now);
    clockNow = bought;
  });
  tearDown(() => closeTestDb(isar));

  /// 455 g of rice at €2.615/kg (€1.19), counted when it was bought on 26 Sep, keeps 30 days.
  Future<int> rice() => pantry.upsert(
    Ingredient()
      ..name = 'Rice'
      ..key = 'rice'
      ..qtyOnHand = 455
      ..avgCostPerUnitMinor = 0.2615
      ..shelfLifeDays = 30,
  );

  Future<({int week, int month, int history})> eaten() async {
    final d = await loadDashboard(isar, clockNow);
    final h = await loadFoodHistory(isar, clockNow);
    return (week: d.state.eaten.week, month: d.state.eaten.month, history: h.months.last.eatenMinor);
  }

  test('marked out by mistake, days later: Undo puts it back as it was and nothing counts as eaten', () async {
    final id = await rice();
    clockNow = markedOut;
    final useId = (await pantry.markOut(id))!;
    final use = (await isar.foodUses.get(useId))!;
    expect((use.qtyBase, use.costMinor, use.countLeft), (455.0, 119, 0.0));
    expect((use.expiresBefore, use.countedBefore), (DayClock.addDays(bought, 30), bought), reason: 'the snapshot');

    clockNow = found;
    // 119 spread over 26 Sep to 2 Oct (7 days, 17 a day): 5 days in the week, 2 in October.
    expect(await eaten(), (week: 85, month: 34, history: 34));

    final last = (await pantry.lastCount(id))!;
    expect((last.use.id, last.putsBack, last.markedOut), (useId, true, true));

    final undone = (await pantry.undoCount(useId))!;
    var r = (await isar.ingredients.get(id))!;
    expect(r.qtyOnHand, 455);
    expect(r.expiresAt, DayClock.addDays(bought, 30), reason: 'its old expiry, not a fresh one');
    expect(r.lastCountedAt, bought, reason: 'as if the count never happened');
    expect(await isar.foodUses.get(useId), isNull);
    expect(await pantry.lastCount(id), isNull, reason: 'nothing left to take back');
    expect(await eaten(), (week: 0, month: 0, history: 0), reason: 'the dashboard and Food by month');

    // Undo of the undo: marked out again, with the same use.
    await pantry.redoCount(undone);
    r = (await isar.ingredients.get(id))!;
    expect((r.qtyOnHand, r.expiresAt, r.lastCountedAt), (0.0, null, markedOut));
    expect((await isar.foodUses.get(useId))!.costMinor, 119);
    expect(await eaten(), (week: 85, month: 34, history: 34));
  });

  test('bought since the mistaken "I\'m out": Undo adds it to the purchase, which stays spent', () async {
    final id = await rice();
    clockNow = markedOut;
    final useId = (await pantry.markOut(id))!;
    clockNow = found;
    final txId = await LedgerService(isar, now: now).applyManualPurchase(ingredientId: id, qty: 500, totalMinor: 130);
    expect((await isar.ingredients.get(id))!.expiresAt, DayClock.addDays(found, 30));

    final last = (await pantry.lastCount(id))!;
    expect((last.putsBack, last.markedOut), (true, true), reason: 'a purchase is not a count');
    await pantry.undoCount(useId);
    final r = (await isar.ingredients.get(id))!;
    expect(r.qtyOnHand, 955);
    expect(r.expiresAt, DayClock.addDays(bought, 30), reason: 'the soonest expiry of what is on hand');
    final d = await loadDashboard(isar, clockNow);
    expect((d.state.spent.month, d.state.eaten.month), (130, 0));
    expect(await isar.transactions.get(txId), isNotNull);
  });

  test('set back up by hand after the undo window: the use stays until "Not eaten" takes it back', () async {
    final id = await rice();
    clockNow = markedOut;
    final useId = (await pantry.markOut(id))!;
    clockNow = found;
    expect(await pantry.setQuantity(id, 455), isNull);
    expect(await isar.foodUses.get(useId), isNotNull, reason: 'after 2 minutes more is just more');

    final last = (await pantry.lastCount(id))!;
    expect((last.use.id, last.putsBack), (useId, false), reason: 'the later count holds the amount');
    final undone = (await pantry.undoCount(useId))!;
    expect((await isar.ingredients.get(id))!.qtyOnHand, 455, reason: 'not 910');
    expect(await isar.foodUses.get(useId), isNull);
    expect(await eaten(), (week: 0, month: 0, history: 0));

    await pantry.redoCount(undone);
    expect((await isar.ingredients.get(id))!.qtyOnHand, 455);
    expect(await isar.foodUses.get(useId), isNotNull);
  });

  test('a partial count, thrown away: Undo puts back what it found gone', () async {
    final id = await rice();
    clockNow = markedOut;
    final useId = (await pantry.setQuantity(id, 155, kind: UseKind.thrownAway))!;
    clockNow = found;
    final last = (await pantry.lastCount(id))!;
    expect((last.putsBack, last.markedOut, last.use.qtyBase), (true, false, 300.0));
    await pantry.undoCount(useId);
    expect((await isar.ingredients.get(id))!.qtyOnHand, 455);
  });

  test('what can be taken back: the newest count use, not a receipt one, for 30 days', () async {
    final id = await rice();
    clockNow = markedOut;
    final first = (await pantry.setQuantity(id, 255))!;
    clockNow = markedOut.add(const Duration(hours: 1));
    final second = (await pantry.markOut(id))!;
    expect((await pantry.lastCount(id))!.use.id, second);

    // A receipt's "none left" is taken back by deleting the receipt, not here.
    clockNow = found;
    final receiptUse = await isar.writeTxn(
      () => isar.foodUses.put(
        FoodUse()
          ..ingredientKey = 'rice'
          ..name = 'Rice'
          ..qtyBase = 100
          ..costMinor = 26
          ..from = bought
          ..to = found
          ..createdAt = found
          ..transactionId = 7,
      ),
    );
    expect((await pantry.lastCount(id))!.use.id, second);
    expect(await pantry.undoCount(receiptUse), isNull);
    expect(await isar.foodUses.get(receiptUse), isNotNull);

    // Thrown away, then counted again: it was never eaten, so there's nothing to fix.
    await pantry.setUseKind(second, UseKind.thrownAway);
    await pantry.verify(id);
    expect((await pantry.lastCount(id)), isNull);
    await pantry.setUseKind(second, UseKind.eaten);
    expect((await pantry.lastCount(id))!.putsBack, isFalse);

    clockNow = DayClock.addDays(markedOut, 31);
    expect(await pantry.lastCount(id), isNull, reason: 'a month on, it stays as it is');
    expect(await isar.foodUses.get(first), isNotNull);
  });
}
