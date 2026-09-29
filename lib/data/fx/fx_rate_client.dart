import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/fx.dart';

/// European Central Bank reference rates via Frankfurter (free, no API key).
/// Only the two currency codes and a date leave the device.
class FxRateClient {
  FxRateClient(
    this.httpClient, {
    this.baseUrl = 'https://api.frankfurter.dev/v1',
    this.timeout = const Duration(seconds: 8),
  });

  final http.Client httpClient;
  final String baseUrl;
  final Duration timeout;

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Rate for [date] (the ECB rate of that business day), or null when the
  /// service is unreachable or doesn't know the currency.
  Future<FxQuote?> fetch(String from, String to, DateTime date, {DateTime? now}) async {
    final today = now ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final isToday = !day.isBefore(DateTime(today.year, today.month, today.day));
    final uri = Uri.parse(
      '$baseUrl/${isToday ? 'latest' : _ymd(day)}?base=${from.toUpperCase()}&symbols=${to.toUpperCase()}',
    );
    try {
      final res = await httpClient.get(uri).timeout(timeout);
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body);
      if (json is! Map) return null;
      final rate = (json['rates'] as Map?)?[to.toUpperCase()];
      if (rate is! num || !FxMath.plausible(rate.toDouble())) return null;
      return FxQuote(
        from: from.toUpperCase(),
        to: to.toUpperCase(),
        rate: rate.toDouble(),
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? day,
        source: FxSource.ecb,
      );
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
