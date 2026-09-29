/// Logical days with a rollover hour: a 00:30 snack belongs to the previous day.
class DayClock {
  const DayClock({this.rolloverHour = 4, this.weekStartsOn = DateTime.monday});

  final int rolloverHour;
  final int weekStartsOn;

  DateTime _logicalDate(DateTime t) {
    final shifted = t.subtract(Duration(hours: rolloverHour));
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  /// yyyymmdd of the logical day containing [t].
  int dateKey(DateTime t) => keyOf(_logicalDate(t));

  static int keyOf(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

  /// Calendar date (midnight) for a key.
  static DateTime dateOfKey(int key) => DateTime(key ~/ 10000, (key ~/ 100) % 100, key % 100);

  /// Moment the logical day containing [t] started.
  DateTime dayStart(DateTime t) {
    final d = _logicalDate(t);
    return DateTime(d.year, d.month, d.day, rolloverHour);
  }

  DateTime startOfKey(int key) {
    final d = dateOfKey(key);
    return DateTime(d.year, d.month, d.day, rolloverHour);
  }

  DateTime weekStart(DateTime now) {
    final d = _logicalDate(now);
    final back = (d.weekday - weekStartsOn) % 7;
    return DateTime(d.year, d.month, d.day - back, rolloverHour);
  }

  DateTime monthStart(DateTime now) {
    final d = _logicalDate(now);
    return DateTime(d.year, d.month, 1, rolloverHour);
  }

  DateTime nextMonthStart(DateTime now) {
    final d = _logicalDate(now);
    return DateTime(d.year, d.month + 1, 1, rolloverHour);
  }

  /// Adds whole calendar days, keeping the wall-clock time (DST-safe).
  static DateTime addDays(DateTime t, int days) =>
      DateTime(t.year, t.month, t.day + days, t.hour, t.minute, t.second);

  /// Whole calendar days from [a] to [b] (DST-safe).
  static int daysBetween(DateTime a, DateTime b) {
    final ua = DateTime.utc(a.year, a.month, a.day);
    final ub = DateTime.utc(b.year, b.month, b.day);
    return ub.difference(ua).inDays;
  }

  /// Fraction of [start, end) elapsed at [now], clamped to 0..1.
  static double elapsedFraction(DateTime start, DateTime end, DateTime now) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 1;
    final done = now.difference(start).inSeconds;
    return (done / total).clamp(0.0, 1.0);
  }

  /// Keys for the logical days from [fromKey] to [toKey] inclusive.
  static List<int> keysBetween(int fromKey, int toKey) {
    final out = <int>[];
    var d = dateOfKey(fromKey);
    final end = dateOfKey(toKey);
    while (!d.isAfter(end)) {
      out.add(keyOf(d));
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return out;
  }

  static int addDaysToKey(int key, int days) {
    final d = dateOfKey(key);
    return keyOf(DateTime(d.year, d.month, d.day + days));
  }
}
