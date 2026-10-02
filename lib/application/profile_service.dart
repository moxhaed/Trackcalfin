import 'package:isar_community/isar.dart';

import '../core/currency.dart';
import '../core/day_clock.dart';
import '../core/enums.dart';
import '../core/money.dart';
import '../core/region.dart';
import '../data/isar/collections/schemas.dart';

class ProfileService {
  ProfileService(this.isar);
  final Isar isar;

  /// A new profile: goals and limits to start from. Money, country and language come from
  /// the phone's region when it is known ([country] "US": dollars), else euros in Germany.
  static UserProfile defaults({String? country, String? language}) {
    final p = _base();
    final currency = Region.currencyOf(country);
    if (currency != null) {
      p.country = country!.toUpperCase();
      applyCurrency(p, currency);
    }
    if (language != null && Region.languages.containsKey(language.toLowerCase())) {
      p.outputLanguage = language.toLowerCase();
    }
    return p;
  }

  /// Sets the home currency and how many decimals it has (yen none, euros two).
  static void applyCurrency(UserProfile p, String code) => p
    ..currency = code.toUpperCase()
    ..currencyMinorDigits = Currency.digitsOf(code);

  static UserProfile _base() => UserProfile()
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

  /// The profile, created on first run from the phone's region ([country], [language]).
  Future<UserProfile> load({String? country, String? language}) async {
    final p = await isar.userProfiles.get(1);
    if (p != null) return p;
    final d = defaults(country: country, language: language);
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

  /// A stored profile from before the month start day reads it as 0: calendar months.
  static DayClock clockFor(UserProfile p) => DayClock(
    rolloverHour: p.dayRolloverHour,
    weekStartsOn: p.weekStartsOn,
    monthStartDay: p.monthStartDay.clamp(1, 31),
  );

  static MoneyFormat moneyFor(UserProfile p) => MoneyFormat(currency: p.currency, digits: p.currencyMinorDigits);
}
