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
      ..createdAt = at
      // What undoing this count needs to put the item back as it was.
      ..countLeft = after < 0 ? 0 : after
      ..expiresBefore = ing.expiresAt
      ..countedBefore = ing.lastCountedAt;
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
  static double eatenIn(Iterable<FoodUse> uses, int fromKey, int toKey, DayClock clock) =>
      eatenInSpans(spans(uses, clock), fromKey, toKey);

  /// The eaten [uses] with their days worked out, for [eatenInSpans]: summing many periods
  /// (a year of weeks) works the days out once, not once a period.
  static List<UseSpan> spans(Iterable<FoodUse> uses, DayClock clock) {
    final out = <UseSpan>[];
    for (final u in uses) {
      if (u.kind != UseKind.eaten || u.costMinor <= 0) continue;
      final a = DayClock.dayNumber(clock.dateKey(u.from));
      final b = DayClock.dayNumber(clock.dateKey(u.to));
      out.add(UseSpan(a, b < a ? a : b, u.costMinor));
    }
    return out;
  }

  /// [eatenIn] over [spans]: each one's share of its days that fall from [fromKey] to [toKey].
  static double eatenInSpans(Iterable<UseSpan> spans, int fromKey, int toKey) {
    final lo = DayClock.dayNumber(fromKey);
    final hi = DayClock.dayNumber(toKey);
    var total = 0.0;
    for (final s in spans) {
      final inside = math.min(s.last, hi) - math.max(s.first, lo) + 1;
      if (inside > 0) total += s.costMinor * inside / (s.last - s.first + 1);
    }
    return total;
  }

  /// How long what a count found gone can be taken back from the item's sheet.
  static const takeBackDays = 30;

  /// The newest use a count of [ing] recorded (not a receipt's), while it can be taken back:
  /// from the last [takeBackDays] days. [uses] are the item's.
  static CountedUse? lastCount(Ingredient ing, Iterable<FoodUse> uses, DateTime now) {
    FoodUse? last;
    for (final u in uses) {
      if (u.ingredientKey != ing.key || u.transactionId != null) continue;
      if (last == null ||
          u.createdAt.isAfter(last.createdAt) ||
          (u.createdAt.isAtSameMomentAs(last.createdAt) && u.id > last.id)) {
        last = u;
      }
    }
    if (last == null || last.createdAt.isBefore(DayClock.addDays(now, -takeBackDays))) return null;
    final putsBack = !countedSince(ing, last);
    // Counted again since, and thrown away: it was never eaten, and the count since holds the amount.
    if (!putsBack && last.kind != UseKind.eaten) return null;
    final left = last.countLeft;
    return CountedUse(last, putsBack: putsBack, markedOut: left != null ? left <= 0 : putsBack && ing.qtyOnHand <= 0);
  }

  /// [ing] was counted again after [use] was recorded: that count holds the amount now.
  static bool countedSince(Ingredient ing, FoodUse use) => ing.lastCountedAt?.isAfter(use.createdAt) ?? false;

  /// Undoes the count that recorded [use] on [ing], as if it never happened: what it found
  /// gone is back on hand, with the expiry and last count the item had. What happened since
  /// (a purchase, cooking) stays. Only when nothing was counted since ([CountedUse.putsBack]).
  static void putBack(Ingredient ing, FoodUse use, DateTime at) {
    final had = ing.qtyOnHand;
    ing.qtyOnHand = had + use.qtyBase;
    // Counts from before the snapshot was kept: the latest purchase's expiry, as onDeplete does.
    final back =
        use.expiresBefore ??
        (use.countLeft == null && ing.lastPurchasedAt != null
            ? DayClock.addDays(ing.lastPurchasedAt!, ing.shelfLifeDays)
            : null);
    // The soonest expiry of what is on hand: what came back, or a purchase since.
    final since = had > 0 ? ing.expiresAt : null;
    ing.expiresAt = since == null || (back != null && back.isBefore(since)) ? back : since;
    if (use.countLeft != null) ing.lastCountedAt = use.countedBefore;
    ing.updatedAt = at;
  }

  static DateTime _clamp(DateTime since, DateTime at) {
    final earliest = DayClock.addDays(at, -maxDays);
    return since.isBefore(earliest) ? earliest : since;
  }
}

/// What the last count of an item found gone ([use]), and how it is taken back.
class CountedUse {
  const CountedUse(this.use, {required this.putsBack, required this.markedOut});
  final FoodUse use;

  /// Nothing was counted since: taking it back also puts the amount back on hand. Otherwise
  /// a later count holds the amount, and only the use goes (it wasn't eaten after all).
  final bool putsBack;

  /// The count left nothing: the item was marked out.
  final bool markedOut;
}

/// An eaten use's days as [DayClock.dayNumber]s, first to last (inclusive), and its cost.
class UseSpan {
  const UseSpan(this.first, this.last, this.costMinor);
  final int first;
  final int last;
  final int costMinor;
}
