import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/dashboard.dart';
import 'package:trackcalfin/domain/used_up.dart';

import 'fixtures.dart';

void main() {
  const clock = DayClock();
  final now = DateTime(2026, 10, 1, 20); // Thursday; the week started Mon 28 Sep

  test('a count that finds less: the difference went since the last count, at its average cost', () {
    final rice = ingredient('white_rice', qty: 1000, cost: 0.3, counted: DateTime(2026, 9, 21, 10));
    final use = UsedUp.fromCount(rice, before: 1000, after: 400, at: now)!;
    expect((use.qtyBase, use.costMinor, use.kind), (600.0, 180, UseKind.eaten));
    expect((use.from, use.to), (DateTime(2026, 9, 21, 10), now));

    expect(UsedUp.fromCount(rice, before: 400, after: 400, at: now), isNull, reason: 'nothing went');
    expect(UsedUp.fromCount(ingredient('salt', qty: 500), before: 500, after: 0, at: now), isNull, reason: 'no price');
    final never = UsedUp.fromCount(ingredient('oats', qty: 500, cost: 0.2), before: 500, after: 0, at: now)!;
    expect(never.from, DayClock.addDays(now, -7), reason: 'never counted or bought: the last week');
  });

  test('an old receipt: what went is spread from the purchase to now, or until it would have spoiled', () {
    final bought = DateTime(2026, 9, 22, 18);
    final chicken = UsedUp.fromReceipt(
      key: 'chicken_breast',
      name: 'Chicken breast',
      gone: 500,
      costMinor: 499,
      bought: bought,
      found: now,
      keepsDays: 2,
    )!;
    expect((chicken.from, chicken.to), (bought, DateTime(2026, 9, 24, 18)));
    final rice = UsedUp.fromReceipt(
      key: 'white_rice',
      name: 'Rice',
      gone: 300,
      costMinor: 90,
      bought: bought,
      found: now,
      keepsDays: 365,
      kind: UseKind.thrownAway,
    )!;
    expect((rice.to, rice.kind), (now, UseKind.thrownAway));
  });

  test('eaten value is spread evenly over the days it went in, and thrown-away food is not eaten', () {
    final uses = [
      FoodUse()
        ..from = DateTime(2026, 9, 24, 12)
        ..to =
            DateTime(2026, 10, 3, 12) // 10 days, 100 a day
        ..costMinor = 1000,
      FoodUse()
        ..from = DateTime(2026, 9, 28, 12)
        ..to = DateTime(2026, 9, 29, 12)
        ..costMinor = 500
        ..kind = UseKind.thrownAway,
    ];
    expect(UsedUp.eatenIn(uses, 20260928, 20261004, clock), closeTo(600, 1e-9));
    expect(UsedUp.eatenIn(uses, 20261001, 20261001, clock), closeTo(100, 1e-9));

    final s = DashboardAggregator.compute(
      DashboardInput(
        now: now,
        clock: clock,
        profile: UserProfile()..monthlyFoodBudgetMinor = 30000,
        transactions: const [],
        logs: [dayLog(20260929, 2000, 100, costMinor: 450)],
        uses: uses,
        firstMealAt: DateTime(2026, 9, 1),
      ),
    );
    // This week up to Thursday: the meal (450) and 4 days of the use (400).
    expect(s.eaten.week, 850);
    expect(s.eaten.month, 100, reason: 'October so far: one day of the use');
  });

  test('eaten in a period: counting days by number gives exactly what listing them gave', () {
    // The day-by-day reference: each use's days listed, those in the period counted.
    double listed(List<FoodUse> uses, int fromKey, int toKey) {
      var total = 0.0;
      for (final u in uses) {
        if (u.kind != UseKind.eaten || u.costMinor <= 0) continue;
        final a = clock.dateKey(u.from);
        final b = clock.dateKey(u.to);
        final days = DayClock.keysBetween(a, b < a ? a : b);
        final inside = days.where((k) => k >= fromKey && k <= toKey).length;
        if (inside > 0) total += u.costMinor * inside / days.length;
      }
      return total;
    }

    // Across a year (DST changes in the test's zone included), uses ending before they start too.
    final base = DateTime(2025, 1, 1, 10);
    final uses = [
      for (var i = 0; i < 400; i++)
        FoodUse()
          ..from = base.add(Duration(hours: i * 23 + 2))
          ..to = base.add(Duration(hours: i * 23 + 2 + (i % 13) * 37 - (i % 5 == 0 ? 50 : 0)))
          ..costMinor = i % 17 == 0 ? 0 : 100 + i * 7
          ..kind = i % 9 == 0 ? UseKind.thrownAway : UseKind.eaten,
    ];
    for (var d = -5; d < 420; d += 3) {
      for (final len in [-2, 0, 1, 6, 30]) {
        final from = clock.dateKey(base.add(Duration(days: d)));
        final to = clock.dateKey(base.add(Duration(days: d + len)));
        expect(UsedUp.eatenIn(uses, from, to, clock), listed(uses, from, to), reason: '$from..$to');
      }
    }
  });
}
