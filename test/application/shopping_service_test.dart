import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/shopping_service.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

import '../support/test_db.dart';

void main() {
  late Isar isar;
  setUp(() async => isar = await openTestDb());
  tearDown(() => closeTestDb(isar));

  test('add once, tick off, remove and clear with Undo', () async {
    final s = ShoppingService(isar, now: () => DateTime(2026, 10, 2, 18));
    final milk = (await s.add('Whole milk', key: 'whole_milk', amount: '2 l'))!;
    expect(await s.add('whole milk'), isNull, reason: 'already on the list, by name');
    expect(await s.addAll([('Milk', 'whole_milk'), ('Eggs', 'egg'), ('  ', null)]), hasLength(1), reason: 'by key');
    expect((await isar.shoppingListItems.get(milk))!.amount, '2 l');

    await s.toggle(milk);
    expect((await isar.shoppingListItems.get(milk))!.doneAt, DateTime(2026, 10, 2, 18));
    expect(await s.add('Whole milk', key: 'whole_milk'), isNotNull, reason: 'ticked off: it can go on again');

    final cleared = await s.clearDone();
    expect([for (final l in cleared) l.id], [milk]);
    await s.restore(cleared);
    expect(await isar.shoppingListItems.count(), 3);

    await s.rename(milk, 'Oat milk', amount: '');
    final renamed = (await isar.shoppingListItems.get(milk))!;
    expect((renamed.name, renamed.amount), ('Oat milk', null));
    final gone = await s.removeAll([milk]);
    expect(await isar.shoppingListItems.get(milk), isNull);
    await s.restore(gone);
    expect((await isar.shoppingListItems.get(milk))!.name, 'Oat milk');
  });
}
