import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/currency.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/domain/fx.dart';

void main() {
  test('minor-unit digits per currency', () {
    expect(Currency.digitsOf('EUR'), 2);
    expect(Currency.digitsOf('jpy'), 0);
    expect(Currency.digitsOf('KWD'), 3);
  });

  test('conversion respects both currencies\' digits', () {
    expect(Currency.convert(4210, from: 'CHF', to: 'EUR', rate: 1.0712), 4510); // 42.10 CHF -> 45.10 EUR
    expect(Currency.convert(1200, from: 'JPY', to: 'EUR', rate: 0.0062), 744); // ¥1,200 -> €7.44
    expect(Currency.convert(1000, from: 'EUR', to: 'KWD', rate: 0.33), 3300); // €10 -> 3.300 KWD
    expect(Currency.convert(-250, from: 'USD', to: 'EUR', rate: 0.92), -230);
  });

  test('rate implied by what the card was charged', () {
    expect(Currency.impliedRate(foreignMinor: 4210, from: 'CHF', homeMinor: 4535, to: 'EUR'), closeTo(1.0772, 1e-4));
    expect(Currency.impliedRate(foreignMinor: 0, from: 'CHF', homeMinor: 100, to: 'EUR'), isNull);
  });

  test('converted lines add up exactly to the converted total', () {
    final lines = [333, 333, 334, 125, -50];
    final out = FxMath.convertLines(lines, from: 'USD', to: 'EUR', rate: 0.9237);
    final total = Currency.convert(lines.fold(0, (a, b) => a + b), from: 'USD', to: 'EUR', rate: 0.9237);
    expect(out.fold(0, (a, b) => a + b), total);
    expect(out.length, lines.length);
    expect(out.last, lessThan(0));
  });

  test('letter currency codes get a space', () {
    expect(const MoneyFormat(currency: 'CHF').format(2310), 'CHF 23.10');
    expect(const MoneyFormat(currency: 'CHF').format(-2310), '-CHF 23.10');
    expect(const MoneyFormat(currency: 'JPY', digits: 0).format(1200), '¥1,200');
    expect(const MoneyFormat().format(2310), '€23.10');
  });

  test('plausible rates', () {
    expect(FxMath.plausible(1.07), isTrue);
    expect(FxMath.plausible(0), isFalse);
    expect(FxMath.plausible(1e7), isFalse);
  });
}
