import '../core/day_clock.dart';
import '../data/isar/collections/ingredient.dart';

/// Weighted-average costing (one number per ingredient).
class CostingEngine {
  const CostingEngine._();

  /// Adds a purchase to [ing]. A zero or negative [lineTotalMinor] means the
  /// price is unknown: quantity is added, the average cost is left alone.
  static void applyPurchase(
    Ingredient ing, {
    required double qtyAdded,
    required int lineTotalMinor,
    required DateTime at,
  }) {
    if (qtyAdded <= 0) return;
    final qtyBefore = ing.qtyOnHand;
    if (lineTotalMinor > 0) {
      final unitCost = lineTotalMinor / qtyAdded;
      if (qtyBefore <= 0 || ing.avgCostPerUnitMinor <= 0) {
        ing.avgCostPerUnitMinor = unitCost;
      } else {
        ing.avgCostPerUnitMinor =
            (qtyBefore * ing.avgCostPerUnitMinor + qtyAdded * unitCost) / (qtyBefore + qtyAdded);
      }
    }
    ing.qtyOnHand = qtyBefore + qtyAdded;
    ing.lastPurchasedAt = at;
    ing.lastPurchaseQty = qtyAdded;
    ing.lastVerifiedAt = at;
    ing.updatedAt = at;
    ExpiryEstimator.onPurchase(ing, qtyBefore: qtyBefore, at: at);
  }
}

/// A single `expiresAt` per ingredient: the soonest expiry of what's on hand,
/// with a two-lot FIFO approximation.
class ExpiryEstimator {
  const ExpiryEstimator._();

  static const shelfStableDays = 180;
  static const useSoonDays = 3;

  static void onPurchase(Ingredient ing, {required double qtyBefore, required DateTime at}) {
    final fresh = DayClock.addDays(at, ing.shelfLifeDays);
    final current = ing.expiresAt;
    ing.expiresAt = (qtyBefore > 0 && current != null && current.isBefore(fresh)) ? current : fresh;
  }

  /// Call after qtyOnHand decreased.
  static void onDeplete(Ingredient ing) {
    if (ing.qtyOnHand <= 0) {
      ing.qtyOnHand = 0;
      ing.expiresAt = null;
    } else if (ing.lastPurchasedAt != null && ing.qtyOnHand <= ing.lastPurchaseQty + 1e-9) {
      // The older lot is used up; what's left is from the latest purchase.
      ing.expiresAt = DayClock.addDays(ing.lastPurchasedAt!, ing.shelfLifeDays);
    }
  }

  static bool isShelfStable(Ingredient ing) => ing.isStaple || ing.shelfLifeDays >= shelfStableDays;

  /// Days until the item spoils; null when shelf-stable or unknown.
  static int? daysLeft(Ingredient ing, DateTime now) {
    if (isShelfStable(ing) || ing.expiresAt == null) return null;
    final d = DayClock.daysBetween(now, ing.expiresAt!);
    return d < 0 ? 0 : d;
  }

  static bool useSoon(Ingredient ing, DateTime now) {
    if (ing.qtyOnHand <= 0) return false;
    final d = daysLeft(ing, now);
    return d != null && d <= useSoonDays;
  }
}
