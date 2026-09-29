import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../core/money.dart';
import '../data/isar/collections/schemas.dart';

class ProfileService {
  ProfileService(this.isar);
  final Isar isar;

  static UserProfile defaults() => UserProfile()
    ..monthlyCategoryLimits = [
      CategoryLimit()
        ..category = SpendCategory.household
        ..limitMinor = 4000,
      CategoryLimit()
        ..category = SpendCategory.clothes
        ..limitMinor = 5000,
      CategoryLimit()
        ..category = SpendCategory.eatingOut
        ..limitMinor = 6000,
      CategoryLimit()
        ..category = SpendCategory.entertainment
        ..limitMinor = 4000,
    ]
    ..equipment = ['oven'];

  Future<UserProfile> load() async {
    final p = await isar.userProfiles.get(1);
    if (p != null) return p;
    final d = defaults();
    await isar.writeTxn(() => isar.userProfiles.put(d));
    return d;
  }

  Future<void> save(UserProfile p) async {
    p.id = 1;
    await isar.writeTxn(() => isar.userProfiles.put(p));
  }

  Future<void> update(void Function(UserProfile p) change) async {
    await isar.writeTxn(() async {
      final p = await isar.userProfiles.get(1) ?? defaults();
      change(p);
      p.id = 1;
      await isar.userProfiles.put(p);
    });
  }

  static DayClock clockFor(UserProfile p) =>
      DayClock(rolloverHour: p.dayRolloverHour, weekStartsOn: p.weekStartsOn);

  static MoneyFormat moneyFor(UserProfile p) =>
      MoneyFormat(currency: p.currency, digits: p.currencyMinorDigits);
}
