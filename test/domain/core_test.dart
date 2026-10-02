import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/data/isar/collections/ingredient.dart';
import 'package:trackcalfin/domain/units.dart';

void main() {
  group('DayClock', () {
    const clock = DayClock();

    test('rollover: 03:59 belongs to the previous day, 04:00 starts a new one', () {
      expect(clock.dateKey(DateTime(2026, 9, 28, 23, 59)), 20260928);
      expect(clock.dateKey(DateTime(2026, 9, 29, 3, 59)), 20260928);
      expect(clock.dateKey(DateTime(2026, 9, 29, 4, 0)), 20260929);
    });

    test('week start is Monday at the rollover hour, across a month boundary', () {
      final ws = clock.weekStart(DateTime(2026, 10, 2, 12)); // Friday
      expect(ws, DateTime(2026, 9, 28, 4));
      final sundayNight = clock.weekStart(DateTime(2026, 10, 5, 2)); // Mon 02:00 is still Sunday
      expect(sundayNight, DateTime(2026, 9, 28, 4));
    });

    test('month start and elapsed fraction', () {
      final now = DateTime(2026, 9, 16, 4);
      expect(clock.monthStart(now), DateTime(2026, 9, 1, 4));
      final f = DayClock.elapsedFraction(clock.monthStart(now), clock.nextMonthStart(now), now);
      expect(f, closeTo(0.5, 0.01));
    });

    test('a month that starts on payday: the 17th, and the 31st in short months', () {
      const payday = DayClock(monthStartDay: 17);
      expect(payday.monthStart(DateTime(2026, 10, 2, 12)), DateTime(2026, 9, 17, 4));
      expect(payday.nextMonthStart(DateTime(2026, 10, 2, 12)), DateTime(2026, 10, 17, 4));
      expect(payday.monthStart(DateTime(2026, 10, 17, 9)), DateTime(2026, 10, 17, 4));
      expect(payday.monthStart(DateTime(2026, 10, 17, 3)), DateTime(2026, 9, 17, 4), reason: 'before the rollover');
      expect(payday.monthStart(DateTime(2026, 1, 5, 12)), DateTime(2025, 12, 17, 4), reason: 'across the year');
      expect(payday.previousMonthStart(DateTime(2026, 9, 17, 4)), DateTime(2026, 8, 17, 4));

      const last = DayClock(monthStartDay: 31);
      expect(last.monthStart(DateTime(2026, 3, 10, 12)), DateTime(2026, 2, 28, 4), reason: 'February has no 31st');
      expect(last.nextMonthStart(DateTime(2026, 3, 10, 12)), DateTime(2026, 3, 31, 4));
      expect(last.nextMonthStart(DateTime(2026, 4, 2, 12)), DateTime(2026, 4, 30, 4));
    });

    test('daysBetween is calendar based across DST', () {
      expect(DayClock.daysBetween(DateTime(2026, 3, 28, 12), DateTime(2026, 3, 30, 1)), 2);
      expect(DayClock.daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
    });

    test('keysBetween spans months', () {
      expect(DayClock.keysBetween(20260929, 20261002), [20260929, 20260930, 20261001, 20261002]);
      expect(DayClock.addDaysToKey(20260930, 1), 20261001);
    });
  });

  group('MoneyFormat', () {
    const m = MoneyFormat();
    test('formats minor units', () {
      expect(m.format(1250), '€12.50');
      expect(m.format(16400, whole: true), '€164');
      expect(m.compact(255), '€2.55');
      expect(m.compact(16400), '€164');
      expect(m.compact(6928), '€69');
      expect(m.compact(0), '€0');
    });
    test('parses comma and dot decimals', () {
      expect(m.parse('12,5'), 1250);
      expect(m.parse('12.50'), 1250);
      expect(m.parse('€ 7'), 700);
      expect(m.parse('abc'), isNull);
    });
  });

  group('UnitConverter', () {
    Ingredient ing(BaseUnit u, {double? gpp, double? density}) => Ingredient()
      ..key = 'x'
      ..name = 'x'
      ..baseUnit = u
      ..gramsPerPiece = gpp
      ..densityGPerMl = density;

    test('identity', () {
      expect(UnitConverter.toBase(250, BaseUnit.g, ing(BaseUnit.g)), 250);
    });
    test('pc without piece weight cannot convert', () {
      expect(UnitConverter.toBase(2, BaseUnit.pc, ing(BaseUnit.g)), isNull);
      expect(UnitConverter.toBase(100, BaseUnit.g, ing(BaseUnit.pc)), isNull);
    });
    test('pc <-> g and ml <-> g with density', () {
      expect(UnitConverter.toBase(2, BaseUnit.pc, ing(BaseUnit.g, gpp: 55)), 110);
      expect(UnitConverter.toBase(110, BaseUnit.g, ing(BaseUnit.pc, gpp: 55)), 2);
      expect(UnitConverter.toBase(92, BaseUnit.g, ing(BaseUnit.ml, density: 0.92)), closeTo(100, 1e-9));
    });
    test('factor: units of one kind per unit of another, pieces by their weight', () {
      expect(UnitConverter.factor(BaseUnit.ml, BaseUnit.pc, toGramsPerPiece: 340), closeTo(1 / 340, 1e-12));
      expect(UnitConverter.factor(BaseUnit.pc, BaseUnit.g, fromGramsPerPiece: 55), 55);
      expect(UnitConverter.factor(BaseUnit.ml, BaseUnit.g, density: 0.92), closeTo(0.92, 1e-12));
      expect(UnitConverter.factor(BaseUnit.pc, BaseUnit.pc, fromGramsPerPiece: 50, toGramsPerPiece: 100), 0.5);
      expect(UnitConverter.factor(BaseUnit.g, BaseUnit.g), 1);
      expect(UnitConverter.factor(BaseUnit.ml, BaseUnit.pc), isNull, reason: 'a piece needs its weight');
    });
    test('parses human quantities', () {
      expect(UnitConverter.parseHuman('1,5 kg').toString(), '1500.0 g');
      expect(UnitConverter.parseHuman('6x0,33l')!.qty, closeTo(1980, 1e-9));
      expect(UnitConverter.parseHuman('10 stk')!.unit, BaseUnit.pc);
      expect(UnitConverter.parseHuman('250')!.unit, BaseUnit.g);
    });
    test('formats', () {
      expect(UnitConverter.format(1500, BaseUnit.g), '1.5 kg');
      expect(UnitConverter.format(250, BaseUnit.g), '250 g');
      expect(UnitConverter.format(1.5, BaseUnit.pc), '1.5 pc');
    });
  });
}
