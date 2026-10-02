import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/data/isar/collections/user_profile.dart';
import 'package:trackcalfin/domain/dashboard.dart';
import 'package:trackcalfin/domain/vibe.dart';

import 'fixtures.dart';

void main() {
  const clock = DayClock();
  // Thursday 1 Oct 2026, 20:00. Week started Mon 28 Sep.
  final now = DateTime(2026, 10, 1, 20);

  UserProfile profile() => UserProfile()
    ..monthlyFoodBudgetMinor = 30000
    ..dailyKcalTarget = 2200
    ..dailyProteinTargetG = 140
    ..monthlyCategoryLimits = [
      CategoryLimit()
        ..category = SpendCategory.eatingOut
        ..limitMinor = 6000,
    ];

  test('spend: week, month, trailing weekly x4.33, pace floor, non-food', () {
    final txs = [
      tx(DateTime(2026, 9, 5, 12), 7000),
      tx(DateTime(2026, 9, 12, 12), 7000),
      tx(DateTime(2026, 9, 19, 12), 7000),
      tx(DateTime(2026, 9, 26, 12), 7000),
      tx(DateTime(2026, 10, 1, 9), 4000),
      tx(DateTime(2026, 10, 1, 13), 1500, category: SpendCategory.eatingOut),
    ];
    final s = DashboardAggregator.compute(
      DashboardInput(
        now: now,
        clock: clock,
        profile: profile(),
        transactions: txs,
        logs: const [],
        firstTransactionAt: DateTime(2026, 8, 20, 12),
      ),
    );
    expect(s.spent.week, 4000);
    expect(s.spent.month, 4000);
    expect(s.weeklyBudget, (30000 / 4.33).round());
    // trailing 28 days: Sep 4 04:00 .. Oct 1 -> 7000*4 + 4000 = 32000 / 28 * 7 = 8000
    expect(s.spent.trailingWeekly, 8000);
    expect(s.spent.projectedMonth, (8000 * 4.33).round());
    // Oct 1 at 20:00: month fraction is ~0.02, so the 0.2 floor applies
    expect(s.spent.monthPace, closeTo(4000 / (30000 * 0.2), 1e-9));
    final eo = s.nonFood.firstWhere((c) => c.category == SpendCategory.eatingOut);
    expect(eo.spentMinor, 1500);
    expect(eo.limitMinor, 6000);
    expect(s.spent.collecting, isFalse);
  });

  test('a budget month from payday to payday', () {
    final s = DashboardAggregator.compute(
      DashboardInput(
        now: now, // Thu 1 Oct
        clock: const DayClock(monthStartDay: 17),
        profile: profile()..monthStartDay = 17,
        transactions: [tx(DateTime(2026, 9, 16, 12), 5000), tx(DateTime(2026, 9, 20, 12), 3000)],
        logs: const [],
        firstTransactionAt: DateTime(2026, 8, 1),
      ),
    );
    expect(s.monthStart, DateTime(2026, 9, 17, 4));
    expect(s.customMonth, isTrue);
    expect(s.spent.month, 3000, reason: 'the 16th was last month');
    expect(s.daysLeftInMonth, 16);
  });

  test('cold start: fewer than 7 days of data', () {
    final s = DashboardAggregator.compute(
      DashboardInput(
        now: now,
        clock: clock,
        profile: profile(),
        transactions: [tx(DateTime(2026, 9, 30, 10), 3000)],
        logs: const [],
        firstTransactionAt: DateTime(2026, 9, 30, 10),
      ),
    );
    expect(s.spent.collecting, isTrue);
    expect(s.spent.projectedMonth, isNull);
  });

  test('eaten: groceries count when they are eaten, so a big shop does not spike the week', () {
    final logs = [
      for (var d = DateTime(2026, 9, 4); d.isBefore(DateTime(2026, 9, 28)); d = d.add(const Duration(days: 1)))
        dayLog(clock.dateKey(d.add(const Duration(hours: 12))), 2000, 100, costMinor: 600),
      dayLog(20260928, 2000, 100, costMinor: 500),
      dayLog(20260929, 2000, 100, costMinor: 600),
      dayLog(20260930, 2000, 100, costMinor: 700),
      dayLog(20261001, 900, 60, costMinor: 400), // today
    ];
    final s = DashboardAggregator.compute(
      DashboardInput(
        now: now,
        clock: clock,
        profile: profile(),
        transactions: [tx(DateTime(2026, 9, 28, 18), 9000)],
        logs: logs,
        firstTransactionAt: DateTime(2026, 8, 1, 12),
        firstMealAt: DateTime(2026, 9, 4),
      ),
    );
    expect((s.spent.week, s.spent.month), (9000, 0), reason: 'the big shop lands on Monday');
    expect((s.eaten.week, s.eaten.month), (2200, 400));
    // 24 days at 600 + 2200 this week = 16600 over 28 days -> 4150 a week
    expect(s.eaten.trailingWeekly, 4150);
    expect(s.eaten.projectedMonth, (4150 * 4.33).round());
    expect(s.eaten.monthPace, closeTo(400 / (30000 * 0.2), 1e-9));
    expect(s.eaten.collecting, isFalse);
    expect(s.basis, FoodBasis.eaten, reason: 'the default');
    expect(s.food, same(s.eaten));
  });

  test('eaten: the projection waits for 7 days of logged meals', () {
    final s = DashboardAggregator.compute(
      DashboardInput(
        now: now,
        clock: clock,
        profile: profile(),
        transactions: const [],
        logs: [dayLog(20260930, 2000, 100, costMinor: 700)],
        firstMealAt: DateTime(2026, 9, 30),
      ),
    );
    expect(s.eaten.collecting, isTrue);
    expect(s.eaten.projectedMonth, isNull);
  });

  test('macros: average over completed logged days, today excluded, coverage', () {
    final logs = [
      dayLog(20260928, 2000, 120, costMinor: 400, meals: 2),
      dayLog(20260930, 2400, 150, costMinor: 600, meals: 3),
      dayLog(20261001, 900, 60, costMinor: 200), // today
    ];
    final s = DashboardAggregator.compute(
      DashboardInput(now: now, clock: clock, profile: profile(), transactions: const [], logs: logs),
    );
    expect(s.avgKcal, 2200);
    expect(s.avgProtein, 135);
    expect(s.completedDays, 2);
    expect(s.elapsedDays, 3);
    expect(s.coverage, closeTo(2 / 3, 1e-9));
    expect(s.today.kcal, 900);
    expect(s.eaten.week, 1200);
    expect(s.homeMealsWeek, 6);
    expect(s.costPerMeal, 200);
    expect(s.savedVsOut, (6 * 1500 - 1200));
    expect(s.weekBars.length, 7);
    expect(s.weekBars.where((b) => b.isFuture).length, 3);
  });

  test('macros fall back to last week on Monday', () {
    final monday = DateTime(2026, 9, 28, 10);
    final s = DashboardAggregator.compute(
      DashboardInput(
        now: monday,
        clock: clock,
        profile: profile(),
        transactions: const [],
        logs: [dayLog(20260925, 1800, 100), dayLog(20260926, 2200, 140)],
      ),
    );
    expect(s.avgIsLastWeek, isTrue);
    expect(s.avgKcal, 2000);
    expect(s.coverage, isNull);
  });

  group('VibeScorer', () {
    const money = MoneyFormat();

    test('the food part goes by what the user chose to see: eaten or spent', () {
      DashboardState state(FoodBasis basis) => DashboardAggregator.compute(
        DashboardInput(
          now: DateTime(2026, 10, 15, 20),
          clock: clock,
          profile: profile()..foodBasis = basis,
          // Spent 20 000 on the 1st, ate 5 000 worth since.
          transactions: [tx(DateTime(2026, 10, 1, 10), 20000)],
          logs: [for (var d = 1; d <= 10; d++) dayLog(20261000 + d, 2000, 140, costMinor: 500)],
          firstTransactionAt: DateTime(2026, 8, 1),
          firstMealAt: DateTime(2026, 9, 1),
        ),
      );
      final spent = VibeScorer.score(state(FoodBasis.spent), profile(), money);
      final eaten = VibeScorer.score(state(FoodBasis.eaten), profile(), money);
      expect(spent.components['food'], lessThan(50), reason: 'two thirds of the budget spent by mid-month');
      expect(eaten.components['food'], 100, reason: 'a third of it eaten');
    });

    test('score math and component formulas', () {
      expect(VibeScorer.paceScore(1.0), 100);
      expect(VibeScorer.paceScore(1.25), 50);
      expect(VibeScorer.paceScore(1.6), 0);
      expect(VibeScorer.kcalScore(2200 * 1.05, 2200), closeTo(100, 1e-9));
      expect(VibeScorer.kcalScore(2200 * 1.175, 2200), closeTo(50, 1e-6));
      expect(VibeScorer.labelFor(85), 'Locked in');
      expect(VibeScorer.labelFor(70), 'On track');
      expect(VibeScorer.labelFor(50), 'Drifting');
      expect(VibeScorer.labelFor(49), 'Reset mode');
    });

    test('weights renormalize over available goals; protein insight names the pick', () {
      final logs = [dayLog(20260928, 2200, 70), dayLog(20260929, 2200, 70), dayLog(20260930, 2200, 70)];
      final p = profile()
        ..monthlyFoodBudgetMinor = 0
        ..monthlyCategoryLimits = [];
      final s = DashboardAggregator.compute(
        DashboardInput(now: now, clock: clock, profile: p, transactions: const [], logs: logs),
      );
      final v = VibeScorer.score(s, p, money, pickTitle: 'Chili', pickProtein: 46);
      expect(v.components.keys.toSet(), {'protein', 'kcal', 'logging'});
      // protein 50, kcal 100, logging 100 -> (0.2*50 + 0.15*100 + 0.2*100) / 0.55
      expect(v.score, ((0.2 * 50 + 0.15 * 100 + 0.2 * 100) / 0.55).round());
      expect(v.insight, 'Protein is 50% under target. Chili has 46 g.');
    });

    test('nothing to score yet', () {
      final p = profile()
        ..monthlyFoodBudgetMinor = 0
        ..monthlyCategoryLimits = [];
      final monday = DateTime(2026, 9, 28, 10);
      final s = DashboardAggregator.compute(
        DashboardInput(now: monday, clock: clock, profile: p, transactions: const [], logs: const []),
      );
      final v = VibeScorer.score(s, p, money);
      expect(v.score, isNull);
      expect(v.label, 'Getting started');
    });
  });
}
