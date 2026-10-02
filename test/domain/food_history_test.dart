import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/food_history.dart';

import 'fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 1, 20); // Thursday

  final transactions = [
    tx(DateTime(2026, 8, 20, 12), 3000),
    tx(DateTime(2026, 9, 1, 2), 700), // 2 am belongs to 31 Aug
    tx(DateTime(2026, 9, 5, 12), 5000),
    tx(DateTime(2026, 9, 30, 12), 2000, category: SpendCategory.household),
    tx(DateTime(2026, 10, 1, 9), 1500),
  ];
  final logs = [
    dayLog(20260825, 2000, 100, costMinor: 400),
    dayLog(20260910, 2000, 100, costMinor: 600),
    dayLog(20261001, 2000, 100, costMinor: 250),
  ];
  final uses = [
    // Found gone on 1 Oct, used from 26 Sep: 6 days at 100.
    FoodUse()
      ..from = DateTime(2026, 9, 26, 12)
      ..to = DateTime(2026, 10, 1, 12)
      ..costMinor = 600,
    FoodUse()
      ..from = DateTime(2026, 9, 10, 12)
      ..to = DateTime(2026, 9, 20, 12)
      ..costMinor = 300
      ..kind = UseKind.thrownAway,
  ];

  test('calendar months: spent, eaten (meals and used-up food) and thrown away, weeks adding up', () {
    final months = FoodHistory.months(
      now: now,
      clock: const DayClock(),
      transactions: transactions,
      logs: logs,
      uses: uses,
      firstData: DateTime(2026, 8, 20, 12),
    );
    expect(
      [for (final m in months) m.start],
      [DateTime(2026, 8, 1, 4), DateTime(2026, 9, 1, 4), DateTime(2026, 10, 1, 4)],
    );
    final [aug, sep, oct] = months;
    expect((aug.spentMinor, aug.eatenMinor, aug.thrownMinor, aug.current), (3700, 400, 0, false));
    expect(aug.dataFrom, DateTime(2026, 8, 20, 4), reason: 'a first half month is marked');
    expect(aug.weeks.first.start, DateTime(2026, 8, 17, 4), reason: 'from the week the data starts in');
    expect((sep.spentMinor, sep.eatenMinor, sep.thrownMinor), (5000, 1100, 300), reason: 'household is not food');
    expect(sep.dataFrom, isNull);
    expect(sep.stockedMinor, 3900);
    expect((oct.spentMinor, oct.eatenMinor, oct.current), (1500, 350, true));

    // September's weeks start on Mondays, cut at the month's ends.
    expect([for (final w in sep.weeks) (w.start.day, w.lastDay.day)], [(1, 6), (7, 13), (14, 20), (21, 27), (28, 30)]);
    expect([for (final w in sep.weeks) w.eatenMinor], [0, 600, 0, 200, 300]);
    expect(sep.weeks.fold(0, (a, w) => a + w.spentMinor), sep.spentMinor);
    expect(sep.weeks.fold(0, (a, w) => a + w.thrownMinor), 300);
    expect([for (final w in oct.weeks) (w.start.day, w.lastDay.day, w.current)], [(1, 4, true)]);
  });

  test('payday months start on the month start day; weeks not started yet are left out', () {
    final months = FoodHistory.months(
      now: now,
      clock: const DayClock(monthStartDay: 17),
      transactions: transactions,
      logs: logs,
      uses: uses,
      firstData: DateTime(2026, 8, 20, 12),
    );
    expect([for (final m in months) (m.start.month, m.start.day)], [(8, 17), (9, 17)]);
    final [aug, sep] = months;
    expect(aug.spentMinor, 3000 + 700 + 5000);
    expect(aug.lastDay, DateTime(2026, 9, 16, 4));
    expect(aug.dataFrom, isNull, reason: 'it misses only its first 3 days: whole enough to judge');
    expect([for (final w in sep.weeks) (w.start.day, w.lastDay.day)], [(17, 20), (21, 27), (28, 4)]);
    expect(sep.weeks.last.current, isTrue);
    expect((sep.spentMinor, sep.eatenMinor, sep.thrownMinor), (1500, 600 + 250, 300));
  });

  test('no data yet: just the current month; at most a year back', () {
    const clock = DayClock();
    final none = FoodHistory.months(
      now: now,
      clock: clock,
      transactions: const [],
      logs: const [],
      uses: const [],
      firstData: null,
    );
    expect(none.single.start, DateTime(2026, 10, 1, 4));
    expect(none.single.weeks.single.spentMinor, 0);

    final long = FoodHistory.months(
      now: now,
      clock: clock,
      transactions: const [],
      logs: const [],
      uses: const [],
      firstData: DateTime(2023, 1, 1),
    );
    expect(long.length, FoodHistory.maxMonths);
    expect(long.first.start, FoodHistory.oldestStart(now, clock));
    expect(long.first.start, DateTime(2025, 11, 1, 4));
  });
}
