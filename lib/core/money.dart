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
    var text = f.format(minor / _factor);
    // Letter codes read better with a space: "CHF 23.10", not "CHF23.10".
    final sym = f.currencySymbol;
    if (RegExp(r'^[A-Za-z]{2,}$').hasMatch(sym) && !text.contains('$sym ')) {
      text = text.replaceFirst(sym, '$sym ');
    }
    if (signed && minor > 0) return '+$text';
    return text;
  }

  /// Whole units from 20 up or when there are no cents ("€164", "€0", "€2.55").
  String compact(int minor) => format(minor, whole: minor.abs() >= 20 * _factor || minor % _factor == 0);

  /// The first amount in a text, with its thousands separators: "12,50", "1.299,00",
  /// "1 299,00", "1,299.00", ",50".
  static final amountPattern = RegExp("\\d{1,3}(?:[   '’]\\d{3})+(?:[.,]\\d+)?|[\\d.,]*\\d");

  static final _grouping = RegExp("[   '’]");
  static final _nonDigits = RegExp(r'\D');

  /// "12,50" / "12.5" / "€ 12" / "1.299,00" / ",50" -> minor units. Returns null when no number
  /// is found. The last separator is the decimal one, unless it is followed by exactly three
  /// digits in a currency with fewer decimals ("1.200" is 1200 euros, "1.29" is 1.29).
  int? parse(String input) {
    final m = amountPattern.firstMatch(input);
    if (m == null) return null;
    final s = m.group(0)!.replaceAll(_grouping, '');
    final last = s.lastIndexOf(RegExp('[.,]'));
    var whole = s;
    var frac = '';
    if (last >= 0) {
      final before = s.substring(0, last).replaceAll(_nonDigits, '');
      final after = s.substring(last + 1);
      final sep = s[last];
      final mixed = s.contains('.') && s.contains(',');
      final repeated = s.indexOf(sep) != last;
      final thousands =
          !mixed && (repeated || (after.length == 3 && digits != 3 && before.replaceAll('0', '').isNotEmpty));
      if (thousands) {
        whole = s.replaceAll(_nonDigits, '');
      } else {
        whole = before;
        frac = after;
      }
    }
    final major = whole.isEmpty ? 0 : int.tryParse(whole);
    if (major == null) return null;
    // Fraction digits past the currency's are rounded half up.
    final kept = frac.length > digits ? frac.substring(0, digits) : frac.padRight(digits, '0');
    final up = frac.length > digits && frac.codeUnitAt(digits) >= 0x35 ? 1 : 0;
    return major * _factor + (kept.isEmpty ? 0 : int.parse(kept)) + up;
  }

  /// Minor units -> plain number string for text fields ("12.50").
  String toInput(int minor) => (minor / _factor).toStringAsFixed(digits);
}
