import 'dart:math' as math;

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/daily_log.dart';
import '../data/isar/collections/nutrition.dart';
import '../data/isar/collections/transaction.dart';
import '../data/isar/collections/user_profile.dart';

const weeksPerMonth = 4.33;
const paceFloor = 0.2;

class CategorySpend {
  CategorySpend(this.category, this.spentMinor, this.limitMinor, this.pace);
  final SpendCategory category;
  final int spentMinor;
  final int limitMinor;
  final double? pace;
}

class DayBar {
  DayBar(this.dateKey, this.kcal, this.proteinG, {required this.isToday, required this.isFuture, required this.logged});
  final int dateKey;
  final double kcal;
  final double proteinG;
  final bool isToday;
  final bool isFuture;
  final bool logged;
}

class DashboardInput {
  DashboardInput({
    required this.now,
    required this.clock,
    required this.profile,
    required this.transactions,
    required this.logs,
    this.firstTransactionAt,
    this.eatingOutAvgMinor,
  });

  final DateTime now;
  final DayClock clock;
  final UserProfile profile;

  /// Committed transactions covering at least [monthStart - 28 d, now].
  final List<Transaction> transactions;

  /// DailyLogs for this week and last week.
  final List<DailyLog> logs;
  final DateTime? firstTransactionAt;

  /// Mean eating-out transaction over 90 days (null when < 3 transactions).
  final int? eatingOutAvgMinor;
}

class DashboardState {
  DashboardState({
    required this.weekFood,
    required this.monthFood,
    required this.weeklyBudget,
    required this.monthlyBudget,
    required this.weekPace,
    required this.monthPace,
    required this.trailingWeekly,
    required this.projectedMonth,
    required this.collectingData,
    required this.nonFood,
    required this.eatenWeek,
    required this.homeMealsWeek,
    required this.costPerMeal,
    required this.savedVsOut,
    required this.today,
    required this.todayMeals,
    required this.avgKcal,
    required this.avgProtein,
    required this.avgIsLastWeek,
    required this.completedDays,
    required this.elapsedDays,
    required this.weekBars,
    required this.weekElapsedFraction,
    required this.monthElapsedFraction,
    required this.daysLeftInMonth,
  });

  // Food spend (cash basis)
  final int weekFood;
  final int monthFood;
  final int weeklyBudget;
  final int monthlyBudget;
  final double? weekPace;
  final double? monthPace;
  final int trailingWeekly;
  final int? projectedMonth;
  final bool collectingData;

  final List<CategorySpend> nonFood;

  // Food eaten (value of consumption)
  final int eatenWeek;
  final double homeMealsWeek;
  final int? costPerMeal;
  final int? savedVsOut;

  // Macros
  final Nutrition today;
  final int todayMeals;
  final double? avgKcal;
  final double? avgProtein;
  final bool avgIsLastWeek;
  final int completedDays;
  final int elapsedDays;
  final List<DayBar> weekBars;

  final double weekElapsedFraction;
  final double monthElapsedFraction;
  final int daysLeftInMonth;

  double? get coverage => elapsedDays == 0 ? null : completedDays / elapsedDays;
  int get nonFoodSpent => nonFood.fold(0, (a, c) => a + c.spentMinor);
  int get nonFoodLimit => nonFood.fold(0, (a, c) => a + c.limitMinor);
}

/// All dashboard numbers. Pure: same input, same output.
class DashboardAggregator {
  const DashboardAggregator._();

  static const nonFoodCategories = [
    SpendCategory.household,
    SpendCategory.clothes,
    SpendCategory.eatingOut,
    SpendCategory.entertainment,
    SpendCategory.other,
  ];

  static int _sum(Iterable<Transaction> txs, bool Function(SpendCategory) test) {
    var total = 0;
    for (final t in txs) {
      for (final l in t.lines) {
        if (test(l.category)) total += l.totalMinor;
      }
    }
    return total;
  }

  static Iterable<Transaction> _between(List<Transaction> txs, DateTime from, DateTime to) =>
      txs.where((t) => !t.occurredAt.isBefore(from) && !t.occurredAt.isAfter(to));

  static double? _pace(int spent, int budget, double elapsed) {
    if (budget <= 0) return null;
    return spent / (budget * math.max(elapsed, paceFloor));
  }

  static DashboardState compute(DashboardInput input) {
    final now = input.now;
    final clock = input.clock;
    final p = input.profile;

    final weekStart = clock.weekStart(now);
    final weekEnd = DayClock.addDays(weekStart, 7);
    final monthStart = clock.monthStart(now);
    final monthEnd = clock.nextMonthStart(now);
    final weekFraction = DayClock.elapsedFraction(weekStart, weekEnd, now);
    final monthFraction = DayClock.elapsedFraction(monthStart, monthEnd, now);

    // --- Food spend -------------------------------------------------------
    final weekFood = _sum(_between(input.transactions, weekStart, now), (c) => c.isFood);
    final monthFood = _sum(_between(input.transactions, monthStart, now), (c) => c.isFood);
    final daysSinceFirst = input.firstTransactionAt == null
        ? 0
        : DayClock.daysBetween(input.firstTransactionAt!, now) + 1;
    final collecting = daysSinceFirst < 7;
    final n = daysSinceFirst.clamp(7, 28);
    final trailingFrom = clock.dayStart(DayClock.addDays(now, -(n - 1)));
    final trailingFood = _sum(_between(input.transactions, trailingFrom, now), (c) => c.isFood);
    final trailingWeekly = (trailingFood / n * 7).round();
    final monthlyBudget = p.monthlyFoodBudgetMinor;
    final weeklyBudget = (monthlyBudget / weeksPerMonth).round();

    // --- Non-food ---------------------------------------------------------
    final monthTx = _between(input.transactions, monthStart, now).toList();
    final nonFood = [
      for (final c in nonFoodCategories)
        CategorySpend(
          c,
          _sum(monthTx, (x) => x == c),
          p.limitFor(c),
          _pace(_sum(monthTx, (x) => x == c), p.limitFor(c), monthFraction),
        ),
    ];

    // --- Intake -----------------------------------------------------------
    final todayKey = clock.dateKey(now);
    final weekStartKey = clock.dateKey(weekStart);
    final logsByKey = {for (final l in input.logs) l.dateKey: l};
    final weekKeys = DayClock.keysBetween(weekStartKey, DayClock.addDaysToKey(weekStartKey, 6));
    final pastKeys = weekKeys.where((k) => k < todayKey).toList();
    final completed = pastKeys.where((k) => (logsByKey[k]?.mealsCount ?? 0) > 0).toList();

    double? avgKcal;
    double? avgProtein;
    var avgIsLastWeek = false;
    if (completed.isNotEmpty) {
      avgKcal = completed.map((k) => logsByKey[k]!.totals.kcal).reduce((a, b) => a + b) / completed.length;
      avgProtein = completed.map((k) => logsByKey[k]!.totals.proteinG).reduce((a, b) => a + b) / completed.length;
    } else {
      final lastWeekKeys = DayClock.keysBetween(
        DayClock.addDaysToKey(weekStartKey, -7),
        DayClock.addDaysToKey(weekStartKey, -1),
      );
      final lw = lastWeekKeys.where((k) => (logsByKey[k]?.mealsCount ?? 0) > 0).toList();
      if (lw.isNotEmpty) {
        avgIsLastWeek = true;
        avgKcal = lw.map((k) => logsByKey[k]!.totals.kcal).reduce((a, b) => a + b) / lw.length;
        avgProtein = lw.map((k) => logsByKey[k]!.totals.proteinG).reduce((a, b) => a + b) / lw.length;
      }
    }

    final weekLogs = weekKeys.map((k) => logsByKey[k]).whereType<DailyLog>().toList();
    final eatenWeek = weekLogs.fold(0, (a, l) => a + l.foodCostMinor);
    final homeMeals = weekLogs.fold<double>(
      0,
      (a, l) => a + l.meals.where((m) => m.source != MealSource.quickAdd).fold<double>(0, (b, m) => b + m.portions),
    );
    final homeCost = weekLogs.fold<int>(
      0,
      (a, l) => a + l.meals.where((m) => m.source != MealSource.quickAdd).fold<int>(0, (b, m) => b + m.costMinor),
    );
    final eatingOutAvg = input.eatingOutAvgMinor ?? p.eatingOutAvgMealMinor;
    final savedVsOut = homeMeals > 0 ? (homeMeals * eatingOutAvg - homeCost).round() : null;

    final todayLog = logsByKey[todayKey];
    final bars = [
      for (final k in weekKeys)
        DayBar(
          k,
          logsByKey[k]?.totals.kcal ?? 0,
          logsByKey[k]?.totals.proteinG ?? 0,
          isToday: k == todayKey,
          isFuture: k > todayKey,
          logged: (logsByKey[k]?.mealsCount ?? 0) > 0,
        ),
    ];

    return DashboardState(
      weekFood: weekFood,
      monthFood: monthFood,
      weeklyBudget: weeklyBudget,
      monthlyBudget: monthlyBudget,
      weekPace: _pace(weekFood, weeklyBudget, weekFraction),
      monthPace: _pace(monthFood, monthlyBudget, monthFraction),
      trailingWeekly: trailingWeekly,
      projectedMonth: collecting ? null : (trailingWeekly * weeksPerMonth).round(),
      collectingData: collecting,
      nonFood: nonFood,
      eatenWeek: eatenWeek,
      homeMealsWeek: homeMeals,
      costPerMeal: homeMeals > 0 ? (homeCost / homeMeals).round() : null,
      savedVsOut: savedVsOut,
      today: todayLog?.totals ?? Nutrition(),
      todayMeals: todayLog?.mealsCount ?? 0,
      avgKcal: avgKcal,
      avgProtein: avgProtein,
      avgIsLastWeek: avgIsLastWeek,
      completedDays: completed.length,
      elapsedDays: pastKeys.length,
      weekBars: bars,
      weekElapsedFraction: weekFraction,
      monthElapsedFraction: monthFraction,
      daysLeftInMonth: DayClock.daysBetween(now, monthEnd),
    );
  }
}
