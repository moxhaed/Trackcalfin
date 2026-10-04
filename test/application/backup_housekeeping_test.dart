import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/backup_service.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/application/housekeeping.dart';
import 'package:trackcalfin/application/migrations.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

import '../support/test_db.dart';

void main() {
  late Isar isar;
  setUp(() async => isar = await openTestDb());
  tearDown(() => closeTestDb(isar));

  test('backup round-trips every collection, embedded objects included', () async {
    await DemoSeed.run(isar, now: DateTime(2026, 9, 29, 10));
    final json = await BackupService(isar).exportJson();
    final before = (
      await isar.ingredients.count(),
      await isar.transactions.count(),
      await isar.recipes.count(),
      await isar.dailyLogs.count(),
      await isar.cookSessions.count(),
    );
    await isar.writeTxn(() => isar.clear());
    expect(await isar.ingredients.count(), 0);

    final counts = await BackupService(isar).importJson(json);
    expect(counts['ingredients'], before.$1);
    expect((
      await isar.ingredients.count(),
      await isar.transactions.count(),
      await isar.recipes.count(),
      await isar.dailyLogs.count(),
      await isar.cookSessions.count(),
    ), before);
    final carbonara = await isar.recipes.filter().titleContains('carbonara').findFirst();
    expect(carbonara!.ingredients.where((i) => i.substitutesFor == 'guanciale').length, 1);
    expect((await isar.userProfiles.get(1))!.onboardingDone, isTrue);
  });

  test(
    'the price lookup after every pantry photo is off after an upgrade to schema 6, and stays on once turned on',
    () async {
      await isar.writeTxn(() => isar.userProfiles.put(UserProfile()));
      final data = jsonDecode(await BackupService(isar).exportJson()) as Map<String, dynamic>;
      final old = (data['userProfiles'] as List)[0] as Map;
      old
        ..['lookUpPrices'] = true
        ..['schemaVersion'] = 5;
      await BackupService(isar).importJson(jsonEncode(data));
      expect((await isar.userProfiles.get(1))!.lookUpPrices, isFalse);

      // Schema 4 switched it on for everybody; schema 6 makes a photo one request again.
      final p = (await isar.userProfiles.get(1))!
        ..lookUpPrices = true
        ..schemaVersion = 3;
      await isar.writeTxn(() => isar.userProfiles.put(p));
      await Migrations.run(isar);
      expect((await isar.userProfiles.get(1))!.lookUpPrices, isFalse);
      await isar.writeTxn(
        () => isar.userProfiles.put(
          p
            ..lookUpPrices = true
            ..schemaVersion = Migrations.current,
        ),
      );
      await Migrations.run(isar);
      expect((await isar.userProfiles.get(1))!.lookUpPrices, isTrue, reason: "the user's choice");
    },
  );

  test('schema 5: receipt lines learn how much was bought; Say it buys are left out', () async {
    LineItem stocked(int minor) => LineItem()
      ..name = 'Rice'
      ..ingredientKey = 'white_rice'
      ..ingredientId = 1
      ..qtyBase = 1000
      ..totalMinor = minor;
    await isar.writeTxn(() async {
      await isar.userProfiles.put(UserProfile()..schemaVersion = 4);
      await isar.transactions.putAll([
        Transaction()
          ..source = TxSource.receiptScan
          ..merchant = 'Lidl'
          ..lines = [stocked(149), LineItem()..name = 'Dish soap'],
        Transaction()
          ..source = TxSource.quickText
          ..lines = [stocked(199)],
      ]);
    });
    await Migrations.run(isar);
    final txs = await isar.transactions.where().findAll();
    expect(txs[0].lines.map((l) => l.qtyBought), [1000, null]);
    expect(txs[1].lines.single.qtyBought, isNull, reason: 'its price may be an estimate');
    expect((await isar.userProfiles.get(1))!.schemaVersion, Migrations.current);
  });

  test('a backup from before schema 3 turns its staples into regular items', () async {
    final verified = DateTime(2026, 9, 20);
    await isar.writeTxn(() async {
      await isar.userProfiles.put(UserProfile());
      await isar.ingredients.putAll([
        Ingredient()
          ..key = 'olive_oil'
          ..name = 'Olive oil'
          ..baseUnit = BaseUnit.ml
          ..qtyOnHand = 1500
          ..lastVerifiedAt = verified,
        Ingredient()
          ..key = 'salt'
          ..name = 'Salt'
          ..lastVerifiedAt = verified,
        Ingredient()
          ..key = 'chicken_breast'
          ..name = 'Chicken breast'
          ..qtyOnHand = 500
          ..lastVerifiedAt = verified,
      ]);
      await isar.recipes.put(
        Recipe()
          ..title = 'Salted chicken'
          ..ingredients = [
            RecipeIngredient()
              ..key = 'chicken_breast'
              ..qtyPerPortion = 150,
            RecipeIngredient()
              ..key = 'salt'
              ..qtyPerPortion = 2,
          ],
      );
    });
    // What an export from the old version looked like.
    final data = jsonDecode(await BackupService(isar).exportJson()) as Map<String, dynamic>;
    for (final i in (data['ingredients'] as List).cast<Map>()) {
      i['trackingMode'] = i['key'] == 'chicken_breast' ? 'exact' : 'staple';
    }
    ((((data['recipes'] as List)[0] as Map)['ingredients'] as List)[1] as Map)['role'] = 'staple';
    ((data['userProfiles'] as List)[0] as Map)['schemaVersion'] = 2;

    await BackupService(isar).importJson(jsonEncode(data));
    final oil = (await isar.ingredients.getByKey('olive_oil'))!;
    expect(oil.legacyTrackingMode, isNull);
    expect(oil.qtyOnHand, 1500);
    expect(oil.lastVerifiedAt, isNull, reason: 'it was never deducted, so Quick Check asks about it');
    expect((await isar.ingredients.getByKey('salt'))!.lastVerifiedAt, verified, reason: 'none on hand');
    expect((await isar.ingredients.getByKey('chicken_breast'))!.lastVerifiedAt, verified);
    expect((await isar.userProfiles.get(1))!.schemaVersion, Migrations.current);
    final again = jsonDecode(await BackupService(isar).exportJson()) as Map<String, dynamic>;
    final rows = (((again['recipes'] as List)[0] as Map)['ingredients'] as List).cast<Map>();
    expect(rows.map((r) => r['role']), ['stock', 'stock'], reason: 'stored the new way');
  });

  test('import rejects files that are not backups', () async {
    expect(() => BackupService(isar).importJson('{"hello": 1}'), throwsFormatException);
  });

  test('housekeeping prunes stale suggestions and caps AI logs but keeps saved recipes', () async {
    final now = DateTime(2026, 9, 29);
    await isar.writeTxn(() async {
      await isar.recipes.putAll([
        Recipe()
          ..title = 'old suggestion'
          ..status = RecipeStatus.suggested
          ..createdAt = now.subtract(const Duration(days: 40)),
        Recipe()
          ..title = 'old but cooked'
          ..status = RecipeStatus.suggested
          ..timesCooked = 1
          ..createdAt = now.subtract(const Duration(days: 40)),
        Recipe()
          ..title = 'recent suggestion'
          ..status = RecipeStatus.suggested
          ..createdAt = now.subtract(const Duration(days: 3)),
        Recipe()
          ..title = 'saved'
          ..status = RecipeStatus.saved
          ..createdAt = now.subtract(const Duration(days: 400)),
      ]);
      await isar.aiCallLogs.putAll([
        for (var i = 0; i < 230; i++) AiCallLog()..at = now.subtract(Duration(minutes: i)),
      ]);
    });
    final out = await Housekeeping(isar, now: () => now).run();
    expect(out['recipes'], 1);
    expect(await isar.aiCallLogs.count(), Housekeeping.aiLogCap);
    final titles = (await isar.recipes.where().findAll()).map((r) => r.title).toSet();
    expect(titles, {'old but cooked', 'recent suggestion', 'saved'});
  });
}
