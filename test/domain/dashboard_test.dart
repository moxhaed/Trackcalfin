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
    expect(s.weekFood, 4000);
    expect(s.monthFood, 4000);
    expect(s.weeklyBudget, (30000 / 4.33).round());
    // trailing 28 days: Sep 4 04:00 .. Oct 1 -> 7000*4 + 4000 = 32000 / 28 * 7 = 8000
    expect(s.trailingWeekly, 8000);
    expect(s.projectedMonth, (8000 * 4.33).round());
    // Oct 1 at 20:00: month fraction is ~0.02, so the 0.2 floor applies
    expect(s.monthPace, closeTo(4000 / (30000 * 0.2), 1e-9));
    final eo = s.nonFood.firstWhere((c) => c.category == SpendCategory.eatingOut);
    expect(eo.spentMinor, 1500);
    expect(eo.limitMinor, 6000);
    expect(s.collectingData, isFalse);
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
    expect(s.collectingData, isTrue);
    expect(s.projectedMonth, isNull);
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
    expect(s.eatenWeek, 1200);
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
