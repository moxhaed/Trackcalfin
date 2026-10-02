import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/daily_log.dart';
import '../data/isar/collections/food_use.dart';
import '../data/isar/collections/transaction.dart';
import 'used_up.dart';

/// Food money over a stretch of days: what was paid for groceries, what the food eaten was
/// worth (meals plus food found used up, as on the dashboard) and what was thrown away.
class FoodPeriod {
  FoodPeriod({
    required this.start,
    required this.end,
    required this.spentMinor,
    required this.eatenMinor,
    required this.thrownMinor,
    required this.current,
    this.weeks = const [],
    this.dataFrom,
  });

  /// When the period starts (its first day's rollover hour).
  final DateTime start;

  /// When the next period starts.
  final DateTime end;

  /// Groceries paid for, on the day they were paid.
  final int spentMinor;

  /// What the food eaten was worth, on the days it was eaten.
  final int eatenMinor;

  /// Food thrown away, on the day it was found gone or would have spoiled. Never eaten.
  final int thrownMinor;

  /// The period is still going: its numbers are so far.
  final bool current;

  /// A month's weeks, cut at the month's ends so they add up to it. Weeks that haven't
  /// started yet, or end before [dataFrom], are left out.
  final List<FoodPeriod> weeks;

  /// Set when the data starts partway through the period (the first month of use): the
  /// day it starts, so a half month isn't read as a cheap one. See [FoodHistory.partialDays].
  final DateTime? dataFrom;

  /// The period's last day.
  DateTime get lastDay => DayClock.addDays(end, -1);

  /// Spent minus eaten: above zero, groceries went into the pantry (or weren't logged
  /// as eaten); below, meals came out of food bought before.
  int get stockedMinor => spentMinor - eatenMinor;
}

/// Past budget months, spent next to eaten. Pure: same input, same output.
class FoodHistory {
  const FoodHistory._();

  /// How far back the history goes.
  static const maxMonths = 12;

  /// A first month whose data starts later than this many days in is marked partial
  /// ([FoodPeriod.dataFrom]); one that misses only its first days still counts as whole.
  static const partialDays = 3;

  /// Where the months [months] needs data from: the start of the oldest month shown.
  static DateTime oldestStart(DateTime now, DayClock clock) {
    var start = clock.monthStart(now);
    for (var i = 1; i < maxMonths; i++) {
      start = clock.previousMonthStart(start);
    }
    return start;
  }

  /// Budget months (they follow the user's month start day), oldest first: from the one
  /// holding [firstData] to the current one, at most [maxMonths]. [transactions], [logs] and
  /// [uses] cover at least [oldestStart] to [now].
  static List<FoodPeriod> months({
    required DateTime now,
    required DayClock clock,
    required List<Transaction> transactions,
    required List<DailyLog> logs,
    required List<FoodUse> uses,
    required DateTime? firstData,
  }) {
    final first = clock.monthStart(firstData != null && firstData.isBefore(now) ? firstData : now);
    final starts = [clock.monthStart(now)];
    while (starts.length < maxMonths && starts.first.isAfter(first)) {
      starts.insert(0, clock.previousMonthStart(starts.first));
    }
    final data = _Data(transactions, {for (final l in logs) l.dateKey: l.foodCostMinor}, uses);
    final from = firstData == null ? null : clock.dayStart(firstData);
    return [
      for (final start in starts)
        _month(
          start,
          clock.nextMonthStart(DayClock.addDays(start, 1)),
          now: now,
          clock: clock,
          data: data,
          dataFrom: start == starts.first && from != null && from.isAfter(DayClock.addDays(start, partialDays))
              ? from
              : null,
        ),
    ];
  }

  /// A month as the sum of its weeks, so the weeks always add up to it.
  static FoodPeriod _month(
    DateTime start,
    DateTime end, {
    required DateTime now,
    required DayClock clock,
    required _Data data,
    DateTime? dataFrom,
  }) {
    final weeks = <FoodPeriod>[];
    var cursor = start;
    while (cursor.isBefore(end) && !cursor.isAfter(now)) {
      final next = DayClock.addDays(clock.weekStart(cursor), 7);
      final to = next.isBefore(end) ? next : end;
      // Weeks before the data starts hold nothing: left out.
      if (dataFrom == null || to.isAfter(dataFrom)) {
        weeks.add(_period(cursor, to, now: now, clock: clock, data: data));
      }
      cursor = to;
    }
    return FoodPeriod(
      start: start,
      end: end,
      spentMinor: weeks.fold(0, (a, w) => a + w.spentMinor),
      eatenMinor: weeks.fold(0, (a, w) => a + w.eatenMinor),
      thrownMinor: weeks.fold(0, (a, w) => a + w.thrownMinor),
      current: now.isBefore(end),
      weeks: weeks,
      dataFrom: dataFrom,
    );
  }

  static FoodPeriod _period(
    DateTime start,
    DateTime end, {
    required DateTime now,
    required DayClock clock,
    required _Data data,
  }) {
    final fromKey = clock.dateKey(start);
    final lastKey = DayClock.addDaysToKey(clock.dateKey(end), -1);
    final todayKey = clock.dateKey(now);
    final toKey = lastKey < todayKey ? lastKey : todayKey;

    var spent = 0;
    for (final t in data.transactions) {
      if (t.occurredAt.isBefore(start) || !t.occurredAt.isBefore(end)) continue;
      for (final l in t.lines) {
        if (l.category.isFood) spent += l.totalMinor;
      }
    }
    var meals = 0;
    for (final k in DayClock.keysBetween(fromKey, toKey < fromKey ? fromKey : toKey)) {
      meals += data.mealCost[k] ?? 0;
    }
    var thrown = 0;
    for (final u in data.uses) {
      if (u.kind != UseKind.thrownAway) continue;
      final k = clock.dateKey(u.to);
      if (k >= fromKey && k <= toKey) thrown += u.costMinor;
    }
    return FoodPeriod(
      start: start,
      end: end,
      spentMinor: spent,
      eatenMinor: meals + UsedUp.eatenIn(data.uses, fromKey, toKey, clock).round(),
      thrownMinor: thrown,
      current: now.isBefore(end),
    );
  }
}

class _Data {
  _Data(this.transactions, this.mealCost, this.uses);
  final List<Transaction> transactions;
  final Map<int, int> mealCost;
  final List<FoodUse> uses;
}
