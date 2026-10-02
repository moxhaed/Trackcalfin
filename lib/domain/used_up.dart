import 'dart:math' as math;

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/food_use.dart';
import '../data/isar/collections/ingredient.dart';

/// Food that is gone without a logged meal: a count found less than the pantry had, or an
/// old receipt's item is partly or all used up. It counts as eaten (unless thrown away),
/// spread evenly over the days it went in, so past weeks show what was really eaten.
class UsedUp {
  const UsedUp._();

  /// Use is spread over at most this many days: older than that, a guess about when is noise.
  static const maxDays = 60;

  /// Without a purchase or count to go by, the use is put in the last week.
  static const defaultDays = 7;

  /// A count of [ing] found [after] where the pantry had [before]: the difference went since
  /// the item was last counted or bought. Call it before the count updates [ing].
  /// Null when nothing went, or it had no price (it changes no money then).
  static FoodUse? fromCount(
    Ingredient ing, {
    required double before,
    required double after,
    required DateTime at,
    UseKind kind = UseKind.eaten,
  }) {
    final gone = before - after;
    if (gone <= 1e-9) return null;
    final cost = (gone * ing.avgCostPerUnitMinor).round();
    if (cost <= 0) return null;
    DateTime? since;
    for (final t in [ing.lastCountedAt, ing.lastPurchasedAt]) {
      if (t != null && t.isBefore(at) && (since == null || t.isAfter(since))) since = t;
    }
    return FoodUse()
      ..from = _clamp(since ?? DayClock.addDays(at, -defaultDays), at)
      ..to = at
      ..ingredientKey = ing.key
      ..name = ing.name
      ..qtyBase = gone
      ..costMinor = cost
      ..kind = kind
      ..createdAt = at;
  }

  /// An old receipt's item, [gone] of it no longer there when the receipt is filed at [found]:
  /// used between [bought] and [found], or until it would have spoiled ([keepsDays]).
  static FoodUse? fromReceipt({
    required String key,
    required String name,
    required double gone,
    required int costMinor,
    required DateTime bought,
    required DateTime found,
    required int keepsDays,
    UseKind kind = UseKind.eaten,
    int? transactionId,
  }) {
    if (gone <= 1e-9 || costMinor <= 0) return null;
    final spoiled = DayClock.addDays(bought, math.max(1, keepsDays));
    final to = spoiled.isBefore(found) ? spoiled : found;
    return FoodUse()
      ..from = bought
      ..to = to.isAfter(bought) ? to : bought
      ..ingredientKey = key
      ..name = name
      ..qtyBase = gone
      ..costMinor = costMinor
      ..kind = kind
      ..transactionId = transactionId
      ..createdAt = found;
  }

  /// What the eaten [uses] were worth on the days [fromKey] to [toKey] (inclusive), each
  /// spread evenly over the days from its `from` to its `to`.
  static double eatenIn(Iterable<FoodUse> uses, int fromKey, int toKey, DayClock clock) {
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

  static DateTime _clamp(DateTime since, DateTime at) {
    final earliest = DayClock.addDays(at, -maxDays);
    return since.isBefore(earliest) ? earliest : since;
  }
}
