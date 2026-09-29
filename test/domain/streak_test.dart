import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/domain/streak.dart';

void main() {
  const today = 20261001; // Thursday
  Set<int> days(List<int> offsets) => {for (final o in offsets) DayClock.addDaysToKey(today, -o)};

  test('counts consecutive days including today', () {
    final r = StreakCalculator.compute(days([0, 1, 2, 3]), today);
    expect(r.days, 4);
    expect(r.todayLogged, isTrue);
  });

  test('today not logged yet does not break the streak', () {
    final r = StreakCalculator.compute(days([1, 2, 3]), today);
    expect(r.days, 3);
    expect(r.todayLogged, isFalse);
  });

  test('one missed day per week is frozen; a second gap in the same week ends it', () {
    // Thu logged, Wed missed (freeze), Tue+Mon logged, Sun (prev week) logged, Sat missed (freeze), Fri logged.
    final r = StreakCalculator.compute(days([0, 2, 3, 4, 6, 7]), today);
    expect(r.days, 6);
    expect(r.freezesUsed, 2);
    final broken = StreakCalculator.compute(days([0, 2, 4, 5]), today);
    expect(broken.days, 2);
  });

  test('two missed days in a row end the streak', () {
    expect(StreakCalculator.compute(days([0, 3, 4]), today).days, 1);
  });

  test('empty history', () {
    expect(StreakCalculator.compute({}, today).days, 0);
  });
}
