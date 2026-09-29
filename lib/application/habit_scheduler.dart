import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/dashboard.dart';
import '../platform/notifications.dart';
import 'clock.dart';
import 'daily_pick_service.dart';
import 'profile_service.dart';

/// Plans the notification rhythm: tomorrow's pick, meal-time actions, weekly recap.
class HabitScheduler {
  HabitScheduler({required this.isar, required this.picks, Notifications? notifications, Now? now})
    : notifications = notifications ?? Notifications.instance,
      now = now ?? DateTime.now;

  final Isar isar;
  final DailyPickService picks;
  final Notifications notifications;
  final Now now;

  Future<UserProfile> _profile() async => await isar.userProfiles.get(1) ?? ProfileService.defaults();

  DateTime _at(DateTime day, int minuteOfDay) =>
      DateTime(day.year, day.month, day.day, minuteOfDay ~/ 60, minuteOfDay % 60);

  /// "Plan tonight, notify tomorrow": generate tomorrow's pick while the app is
  /// alive, then schedule the morning notification with the real hook.
  Future<void> planTomorrowIfEvening() async {
    final p = await _profile();
    if (!p.notificationsEnabled) return;
    final t = now();
    if (t.hour < 19) return;
    final tomorrow = DayClock.addDays(DateTime(t.year, t.month, t.day, 12), 1);
    final out = await picks.ensure(forDate: tomorrow);
    final r = out.recipe;
    if (r == null || !out.fromAi) return;
    await notifications.scheduleDailyPick(
      at: _at(tomorrow, p.dailyPickMinuteOfDay),
      title: 'Today: ${r.title}',
      body: r.hook.isNotEmpty ? r.hook : 'Tap to see it',
    );
  }

  /// Schedules today's pick notification if it's still ahead of us.
  Future<void> scheduleTodayPick(Recipe? pick) async {
    final p = await _profile();
    if (!p.notificationsEnabled || pick == null) return;
    final at = _at(now(), p.dailyPickMinuteOfDay);
    if (at.isAfter(now())) {
      await notifications.scheduleDailyPick(
        at: at,
        title: 'Today: ${pick.title}',
        body: pick.hook.isNotEmpty ? pick.hook : 'Tap to see it',
      );
    }
  }

  /// Meal reminders only exist while the fridge has portions.
  Future<void> refreshMealReminders() async {
    final p = await _profile();
    await notifications.cancelMealReminders();
    if (!p.notificationsEnabled) return;
    final active = await isar.cookSessions.where().statusEqualTo(CookStatus.active).sortByCookedAt().findAll();
    final portions = active.fold(0, (a, s) => a + s.portionsRemaining);
    if (portions == 0) return;
    final first = active.first;
    final t = now();
    for (final (i, m) in p.mealReminderMinutes.take(6).indexed) {
      var at = _at(t, m);
      if (!at.isAfter(t)) at = DayClock.addDays(at, 1);
      final label = m < 11 * 60 ? 'Breakfast' : (m < 16 * 60 ? 'Lunch' : 'Dinner');
      await notifications.scheduleMealReminder(
        slot: i,
        at: at,
        title: '$label: ${first.recipeTitle} (${first.portionsRemaining} left)',
        body: portions > first.portionsRemaining
            ? '$portions prepped portions in the fridge'
            : 'Tap "Ate it" to log it without opening the app',
      );
    }
  }

  /// Sunday 18:00 recap with this week's numbers so far.
  Future<void> scheduleWeeklyRecap() async {
    final p = await _profile();
    if (!p.notificationsEnabled || !p.weeklyRecapEnabled) return;
    final t = now();
    final clock = ProfileService.clockFor(p);
    final weekStart = clock.weekStart(t);
    final sunday = DayClock.addDays(DateTime(weekStart.year, weekStart.month, weekStart.day, 18), 6);
    if (!sunday.isAfter(t)) return;
    final weekStartKey = clock.dateKey(weekStart);
    final logs = await isar.dailyLogs
        .where()
        .dateKeyBetween(DayClock.addDaysToKey(weekStartKey, -7), DayClock.addDaysToKey(weekStartKey, 6))
        .findAll();
    final s = DashboardAggregator.compute(
      DashboardInput(now: t, clock: clock, profile: p, transactions: const [], logs: logs),
    );
    final money = ProfileService.moneyFor(p);
    final parts = <String>[
      '${s.homeMealsWeek.round()} home meals',
      if (s.costPerMeal != null) '${money.compact(s.costPerMeal!)}/meal',
      if ((s.savedVsOut ?? 0) > 0) '~${money.compact(s.savedVsOut!)} saved vs eating out',
    ];
    await notifications.scheduleWeeklyRecap(at: sunday, body: '${parts.join(' · ')}. Quick Check takes 30 s.');
  }
}
