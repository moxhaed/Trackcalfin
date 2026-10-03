/// Logical days with a rollover hour: a 00:30 snack belongs to the previous day.
class DayClock {
  const DayClock({this.rolloverHour = 4, this.weekStartsOn = DateTime.monday, this.monthStartDay = 1});

  final int rolloverHour;
  final int weekStartsOn;

  /// The day a budget month starts on, like payday: 1 = calendar months. A month without
  /// that day (31 in April) starts on its last day.
  final int monthStartDay;

  /// By the wall clock, not by elapsed hours: on a DST day 04:30 is still past a 04:00 rollover.
  DateTime _logicalDate(DateTime t) => DateTime(t.year, t.month, t.hour < rolloverHour ? t.day - 1 : t.day);

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

  /// The budget month's start in calendar month [month] of [year] (month 0 is last December).
  DateTime _startIn(int year, int month) {
    final last = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, monthStartDay > last ? last : monthStartDay, rolloverHour);
  }

  /// Start of the budget month containing [now].
  DateTime monthStart(DateTime now) {
    final d = _logicalDate(now);
    final here = _startIn(d.year, d.month);
    return d.day >= here.day ? here : _startIn(d.year, d.month - 1);
  }

  DateTime nextMonthStart(DateTime now) {
    final s = monthStart(now);
    return _startIn(s.year, s.month + 1);
  }

  /// Start of the budget month before the one starting at [start].
  DateTime previousMonthStart(DateTime start) => monthStart(DateTime(start.year, start.month, start.day - 1, 12));

  /// Adds whole calendar days, keeping the wall-clock time (DST-safe).
  static DateTime addDays(DateTime t, int days) => DateTime(t.year, t.month, t.day + days, t.hour, t.minute, t.second);

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
