import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';

/// One-off data upgrades at startup. [UserProfile.schemaVersion] is the last one applied.
class Migrations {
  const Migrations._();

  static const current = 3;

  static Future<void> run(Isar isar) async {
    final p = await isar.userProfiles.get(1);
    if (p == null || p.schemaVersion >= current) return;
    await isar.writeTxn(() async {
      if (p.schemaVersion < 2) {
        // v2: macros can be unknown. Onboarding staples and items added without numbers were
        // stored as all-zero estimates, so oil and flour counted as 0 kcal. Let the AI fill them.
        final zero = (await isar.ingredients.where().findAll())
            .where((i) => i.per100.isZero && i.nutritionSource != DataSource.label)
            .toList();
        for (final i in zero) {
          i
            ..nutritionSource = DataSource.none
            ..nutritionConfirmedAt = null;
        }
        await isar.ingredients.putAll(zero);
      }
      if (p.schemaVersion < 3) {
        // v3: no more staples. Items that were "always there" become regular pantry items:
        // counted, deducted when cooked and costed. They were never deducted, so any amount
        // they show is a guess and goes to Quick Check.
        final legacy = await isar.ingredients.filter().legacyTrackingModeIsNotNull().findAll();
        for (final i in legacy) {
          if (i.legacyTrackingMode == 'staple' && i.qtyOnHand > 0) i.lastVerifiedAt = null;
          i.legacyTrackingMode = null;
        }
        await isar.ingredients.putAll(legacy);
        // Recipe rows stored with role "staple" already load as stock; store them that way.
        await isar.recipes.putAll(await isar.recipes.where().findAll());
      }
      p.schemaVersion = current;
      await isar.userProfiles.put(p);
    });
  }
}
