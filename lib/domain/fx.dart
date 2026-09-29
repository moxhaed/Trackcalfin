import '../core/currency.dart';

/// Where an exchange rate came from, shown to the user next to the rate.
enum FxSource { ecb, manual, charged, remembered }

class FxQuote {
  const FxQuote({required this.from, required this.to, required this.rate, required this.date, required this.source});
  final String from;
  final String to;

  /// 1 [from] = [rate] [to].
  final double rate;

  /// Date the rate applies to (ECB publishes on business days).
  final DateTime date;
  final FxSource source;
}

/// Pure conversion of receipt lines into the home currency.
class FxMath {
  const FxMath._();

  /// Converts every line and fixes rounding drift on the largest line, so the
  /// converted lines add up exactly to the converted receipt total.
  static List<int> convertLines(
    List<int> foreignMinor, {
    required String from,
    required String to,
    required double rate,
  }) {
    final out = [for (final m in foreignMinor) Currency.convert(m, from: from, to: to, rate: rate)];
    if (out.isEmpty) return out;
    final target = Currency.convert(foreignMinor.fold<int>(0, (a, b) => a + b), from: from, to: to, rate: rate);
    final drift = target - out.fold<int>(0, (a, b) => a + b);
    if (drift != 0) {
      var largest = 0;
      for (var i = 1; i < out.length; i++) {
        if (out[i].abs() > out[largest].abs()) largest = i;
      }
      out[largest] += drift;
    }
    return out;
  }

  /// A rate that is clearly a typo (e.g. 0 or a million).
  static bool plausible(double rate) => rate > 0.00001 && rate < 100000;
}
