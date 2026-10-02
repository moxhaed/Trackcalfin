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

/// Food money counted one way: what left the wallet, or what the food eaten was worth.
class FoodTotals {
  FoodTotals({
    required this.week,
    required this.month,
    required this.weekPace,
    required this.monthPace,
    required this.trailingWeekly,
    required this.projectedMonth,
    required this.collecting,
  });
  final int week;
  final int month;
  final double? weekPace;
  final double? monthPace;

  /// Per week, over the last 7 to 28 days that have data.
  final int trailingWeekly;

  /// [trailingWeekly] × 4.33; null while [collecting].
  final int? projectedMonth;

  /// Fewer than 7 days of data so far.
  final bool collecting;
}

class DashboardInput {
  DashboardInput({
    required this.now,
    required this.clock,
    required this.profile,
    required this.transactions,
    required this.logs,
    this.firstTransactionAt,
    this.firstMealAt,
    this.eatingOutAvgMinor,
  });

  final DateTime now;
  final DayClock clock;
  final UserProfile profile;

  /// Committed transactions covering at least [monthStart - 28 d, now].
  final List<Transaction> transactions;

  /// DailyLogs covering at least last week, this month and the last 28 days.
  final List<DailyLog> logs;
  final DateTime? firstTransactionAt;

  /// The day the first meal was logged; the eaten projection waits for 7 days of them.
  final DateTime? firstMealAt;

  /// Mean eating-out transaction over 90 days (null when < 3 transactions).
  final int? eatingOutAvgMinor;
}

class DashboardState {
  DashboardState({
    required this.spent,
    required this.eaten,
    required this.basis,
    required this.weeklyBudget,
    required this.monthlyBudget,
    required this.nonFood,
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
    required this.monthStart,
  });

  /// Groceries paid for (cash basis): an expense counts on the day it was paid.
  final FoodTotals spent;

  /// What the food eaten was worth (DailyLog cost): groceries count when they are eaten.
  /// Smoother than [spent], which jumps on a big shop that lasts two weeks.
  final FoodTotals eaten;

  /// Which of the two the food card and the Vibe Check go by.
  final FoodBasis basis;
  final int weeklyBudget;
  final int monthlyBudget;

  final List<CategorySpend> nonFood;

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

  /// When this budget month started: the 1st, or the user's month start day.
  final DateTime monthStart;

  /// The budget month doesn't follow the calendar (it starts on, say, the 17th).
  bool get customMonth => monthStart.day != 1;

  double? get coverage => elapsedDays == 0 ? null : completedDays / elapsedDays;
  FoodTotals get food => basis == FoodBasis.eaten ? eaten : spent;
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

    final monthlyBudget = p.monthlyFoodBudgetMinor;
    final weeklyBudget = (monthlyBudget / weeksPerMonth).round();

    /// One basis: [total] sums it from a moment on; [first] is when its data starts.
    FoodTotals food(int Function(DateTime from) total, DateTime? first) {
      final days = first == null ? 0 : DayClock.daysBetween(first, now) + 1;
      final n = days.clamp(7, 28);
      final trailingWeekly = (total(clock.dayStart(DayClock.addDays(now, -(n - 1)))) / n * 7).round();
      final week = total(weekStart);
      final month = total(monthStart);
      return FoodTotals(
        week: week,
        month: month,
        weekPace: _pace(week, weeklyBudget, weekFraction),
        monthPace: _pace(month, monthlyBudget, monthFraction),
        trailingWeekly: trailingWeekly,
        projectedMonth: days < 7 ? null : (trailingWeekly * weeksPerMonth).round(),
        collecting: days < 7,
      );
    }

    // --- Food spent (what left the wallet) and eaten (what it was worth) ----
    final spent = food(
      (from) => _sum(_between(input.transactions, from, now), (c) => c.isFood),
      input.firstTransactionAt,
    );
    final todayKeyForFood = clock.dateKey(now);
    final eaten = food((from) {
      final fromKey = clock.dateKey(from);
      return input.logs
          .where((l) => l.dateKey >= fromKey && l.dateKey <= todayKeyForFood)
          .fold(0, (a, l) => a + l.foodCostMinor);
    }, input.firstMealAt);

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
    // Home meals are cooked ones; a can of cola from the pantry is no meal saved from eating out.
    bool home(MealEntry m) => m.source == MealSource.cookedNow || m.source == MealSource.fridge;
    final homeMeals = weekLogs.fold<double>(
      0,
      (a, l) => a + l.meals.where(home).fold<double>(0, (b, m) => b + m.portions),
    );
    final homeCost = weekLogs.fold<int>(0, (a, l) => a + l.meals.where(home).fold<int>(0, (b, m) => b + m.costMinor));
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
      spent: spent,
      eaten: eaten,
      basis: p.foodBasis,
      weeklyBudget: weeklyBudget,
      monthlyBudget: monthlyBudget,
      nonFood: nonFood,
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
      monthStart: monthStart,
    );
  }
}
