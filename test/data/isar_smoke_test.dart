import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

import '../support/test_db.dart';

void main() {
  test('Isar opens and round-trips an ingredient by key and alias', () async {
    final isar = await openTestDb();
    final ing = Ingredient()
      ..key = 'chicken_breast'
      ..name = 'Chicken breast'
      ..aliases = ['HOCHL BRUSTFILET']
      ..qtyOnHand = 500;
    await isar.writeTxn(() => isar.ingredients.put(ing));
    expect((await isar.ingredients.getByKey('chicken_breast'))!.qtyOnHand, 500);
    final byAlias = await isar.ingredients.where().aliasesElementEqualTo('HOCHL BRUSTFILET').findFirst();
    expect(byAlias!.key, 'chicken_breast');
    await closeTestDb(isar);
  });
}
