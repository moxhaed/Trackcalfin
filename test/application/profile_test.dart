import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/region.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

import '../support/test_db.dart';

void main() {
  late Isar isar;
  setUp(() async => isar = await openTestDb());
  tearDown(() => closeTestDb(isar));

  test("a first run takes money, country and language from the phone's region", () async {
    final p = await ProfileService(isar).load(country: 'us', language: 'de');
    expect((p.country, p.currency, p.currencyMinorDigits, p.outputLanguage), ('US', 'USD', 2, 'de'));
    expect((await isar.userProfiles.get(1))!.currency, 'USD', reason: 'saved');
    final again = await ProfileService(isar).load(country: 'JP');
    expect(again.currency, 'USD', reason: 'only a new profile is set from the region');

    final jp = ProfileService.defaults(country: 'JP');
    expect((jp.currency, jp.currencyMinorDigits), ('JPY', 0), reason: 'yen have no cents');
    final unknown = ProfileService.defaults(country: 'XX', language: 'tlh');
    expect((unknown.country, unknown.currency, unknown.outputLanguage), ('DE', 'EUR', 'en'));
  });

  test('changing the currency changes its decimals too', () {
    final p = ProfileService.defaults();
    ProfileService.applyCurrency(p, 'krw');
    expect((p.currency, p.currencyMinorDigits), ('KRW', 0));
    ProfileService.applyCurrency(p, 'CHF');
    expect((p.currency, p.currencyMinorDigits), ('CHF', 2));
  });

  test('names for people, codes for the app', () {
    expect(Region.countryName('ch'), 'Switzerland');
    expect(Region.countryName('XX'), 'XX');
    expect(Region.currencyOf('GB'), 'GBP');
    expect(Region.languageName('de'), 'Deutsch');
  });
}
