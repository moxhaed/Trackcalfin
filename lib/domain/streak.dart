import '../core/day_clock.dart';

class StreakResult {
  StreakResult(this.days, this.freezesUsed, {required this.todayLogged});
  final int days;
  final int freezesUsed;
  final bool todayLogged;
}

/// Consecutive logged days with one automatic "freeze" per calendar week,
/// so a single missed day never resets the streak (docs/01 §1.6).
class StreakCalculator {
  const StreakCalculator._();

  /// [logged] = dateKeys with at least one meal or transaction.
  static StreakResult compute(Set<int> logged, int todayKey, {int weekStartsOn = DateTime.monday}) {
    final todayLogged = logged.contains(todayKey);
    var key = todayLogged ? todayKey : DayClock.addDaysToKey(todayKey, -1);
    var days = 0;
    var freezes = 0;
    final frozenWeeks = <int>{};
    int weekOf(int k) {
      final d = DayClock.dateOfKey(k);
      final back = (d.weekday - weekStartsOn) % 7;
      return DayClock.keyOf(DateTime(d.year, d.month, d.day - back));
    }

    for (var guard = 0; guard < 400; guard++) {
      if (logged.contains(key)) {
        days++;
      } else {
        final w = weekOf(key);
        // A freeze only bridges a gap: the day before must be logged.
        final prev = DayClock.addDaysToKey(key, -1);
        if (frozenWeeks.contains(w) || !logged.contains(prev) || days == 0) break;
        frozenWeeks.add(w);
        freezes++;
      }
      key = DayClock.addDaysToKey(key, -1);
    }
    return StreakResult(days, freezes, todayLogged: todayLogged);
  }
}
