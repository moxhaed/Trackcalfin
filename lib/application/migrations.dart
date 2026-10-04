import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';

/// One-off data upgrades at startup. [UserProfile.schemaVersion] is the last one applied.
class Migrations {
  const Migrations._();

  static const current = 6;

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
      // v4: shop prices for pantry photos are looked up with Google. A stored profile reads
      // the new switch as false, so turn it on.
      if (p.schemaVersion < 4) p.lookUpPrices = true;
      if (p.schemaVersion < 5) {
        // v5: lines keep how much was bought (qtyBought) to compare store prices. Receipt and
        // manual purchases stocked all of it, so it is their qtyBase. Say it buys are left
        // out: their price may be an estimate, not what the store charged.
        final units = {for (final i in await isar.ingredients.where().findAll()) i.key: i.baseUnit};
        final txs = await isar.transactions.filter().not().sourceEqualTo(TxSource.quickText).findAll();
        final changed = <Transaction>[];
        for (final t in txs) {
          var touched = false;
          for (final l in t.lines) {
            if (l.ingredientKey != null && l.qtyBase != null && l.qtyBought == null) {
              l
                ..qtyBought = l.qtyBase
                ..unit = units[l.ingredientKey];
              touched = true;
            }
          }
          if (touched) changed.add(t);
        }
        await isar.transactions.putAll(changed);
      }
      // v6: one request per photo (docs/07 §7.5). The Google price search after every pantry
      // photo was a second one; v4 switched it on for everybody. Review offers it on a tap.
      if (p.schemaVersion < 6) p.lookUpPrices = false;
      p.schemaVersion = current;
      await isar.userProfiles.put(p);
    });
  }
}
