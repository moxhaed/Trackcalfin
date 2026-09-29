import 'package:isar_community/isar.dart';

import '../data/isar/collections/schemas.dart';

/// Local time-to-log measurement.
class MetricsService {
  MetricsService(this.isar);
  final Isar isar;

  Future<void> record(String action, Duration took) async {
    if (took.isNegative || took > const Duration(minutes: 10)) return;
    await isar.writeTxn(() => isar.metricEvents.put(MetricEvent()
      ..action = action
      ..millis = took.inMilliseconds
      ..at = DateTime.now()));
  }

  /// Median milliseconds per action over the last 30 days.
  Future<Map<String, ({int median, int count})>> medians() async {
    final since = DateTime.now().subtract(const Duration(days: 30));
    final all = await isar.metricEvents.filter().atGreaterThan(since).findAll();
    final by = <String, List<int>>{};
    for (final e in all) {
      by.putIfAbsent(e.action, () => []).add(e.millis);
    }
    return {
      for (final e in by.entries)
        e.key: (median: (e.value..sort())[e.value.length ~/ 2], count: e.value.length),
    };
  }
}
