import '../data/isar/collections/ingredient.dart';

/// Picks the pantry items most likely to be wrong.
class QuickCheck {
  const QuickCheck._();

  static const maxCards = 10;

  static bool isPerishable(Ingredient i) => i.shelfLifeDays <= 14;

  static bool isSuspect(Ingredient i, DateTime now) {
    if (i.qtyOnHand <= 0) return false;
    if (i.lastVerifiedAt == null) return true;
    final age = now.difference(i.lastVerifiedAt!).inDays;
    if (age > (isPerishable(i) ? 7 : 21)) return true;
    return i.expiresAt != null && i.expiresAt!.isBefore(now);
  }

  static List<Ingredient> candidates(Iterable<Ingredient> all, DateTime now) {
    final list = all.where((i) => isSuspect(i, now)).toList()
      ..sort((a, b) {
        final fa = a.lastVerifiedAt == null ? 0 : 1;
        final fb = b.lastVerifiedAt == null ? 0 : 1;
        if (fa != fb) return fa - fb;
        return (b.qtyOnHand * b.avgCostPerUnitMinor).compareTo(a.qtyOnHand * a.avgCostPerUnitMinor);
      });
    return list.take(maxCards).toList();
  }
}
