import 'package:isar_community/isar.dart';

part 'metric_event.g.dart';

/// Local-only time-to-log measurement (Settings -> Stats).
@collection
class MetricEvent {
  Id id = Isar.autoIncrement;

  /// expense, scan, cook, eat, quick_check, ask.
  @Index()
  String action = '';
  int millis = 0;
  DateTime at = DateTime.now();
}
