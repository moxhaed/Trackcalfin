/// ISO 4217 minor-unit digits and currency conversion in integer minor units.
class Currency {
  const Currency._();

  /// Currencies whose minor unit is not 2 digits. Everything else uses 2.
  static const _digits = {
    'JPY': 0,
    'KRW': 0,
    'ISK': 0,
    'CLP': 0,
    'VND': 0,
    'PYG': 0,
    'UGX': 0,
    'XAF': 0,
    'XOF': 0,
    'HUF': 2,
    'KWD': 3,
    'BHD': 3,
    'OMR': 3,
    'JOD': 3,
    'TND': 3,
    'LYD': 3,
    'IQD': 3,
  };

  static int digitsOf(String code) => _digits[code.toUpperCase()] ?? 2;

  static int _pow10(int n) {
    var f = 1;
    for (var i = 0; i < n; i++) {
      f *= 10;
    }
    return f;
  }

  /// Converts [minor] units of [from] into minor units of [to] at [rate]
  /// (1 unit of [from] = [rate] units of [to]), rounded half away from zero.
  static int convert(int minor, {required String from, required String to, required double rate}) {
    final major = minor / _pow10(digitsOf(from));
    return (major * rate * _pow10(digitsOf(to))).round();
  }

  /// Major-unit value of [minor] (for display and rate derivation).
  static double toMajor(int minor, String code) => minor / _pow10(digitsOf(code));

  /// Rate implied by "the receipt total was [foreignMinor], my card was charged [homeMinor]".
  static double? impliedRate({
    required int foreignMinor,
    required String from,
    required int homeMinor,
    required String to,
  }) {
    if (foreignMinor == 0) return null;
    return toMajor(homeMinor, to) / toMajor(foreignMinor, from);
  }
}
