import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/backup_service.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/application/housekeeping.dart';
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
