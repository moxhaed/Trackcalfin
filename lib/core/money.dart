import 'package:intl/intl.dart';

/// Formats and parses integer minor-unit amounts for one currency.
class MoneyFormat {
  const MoneyFormat({this.currency = 'EUR', this.digits = 2, this.locale = 'en'});

  final String currency;
  final int digits;
  final String locale;

  int get _factor {
    var f = 1;
    for (var i = 0; i < digits; i++) {
      f *= 10;
    }
    return f;
  }

  String get symbol => NumberFormat.simpleCurrency(locale: locale, name: currency).currencySymbol;

  /// 1250 -> "€12.50". [whole] drops the minor digits: "€13".
  String format(int minor, {bool whole = false, bool signed = false}) {
    final f = NumberFormat.simpleCurrency(locale: locale, name: currency, decimalDigits: whole ? 0 : digits);
    final text = f.format(minor / _factor);
    if (signed && minor > 0) return '+$text';
    return text;
  }

  /// Whole units from 20 up or when there are no cents ("€164", "€0", "€2.55").
  String compact(int minor) => format(minor, whole: minor.abs() >= 20 * _factor || minor % _factor == 0);

  /// "12,50" / "12.5" / "€ 12" -> minor units. Returns null when no number is found.
  int? parse(String input) {
    final m = RegExp(r'(\d+)(?:[.,](\d{1,2}))?').firstMatch(input);
    if (m == null) return null;
    final whole = int.parse(m.group(1)!);
    var frac = m.group(2) ?? '';
    if (digits == 0) return whole;
    frac = frac.padRight(digits, '0').substring(0, digits);
    return whole * _factor + (frac.isEmpty ? 0 : int.parse(frac));
  }

  /// Minor units -> plain number string for text fields ("12.50").
  String toInput(int minor) => (minor / _factor).toStringAsFixed(digits);
}
