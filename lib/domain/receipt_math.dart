import '../core/enums.dart';
import '../data/isar/collections/scan_job.dart';

/// Allocation of basket-level discounts and receipt totals.
class ReceiptMath {
  const ReceiptMath._();

  /// Spreads negative adjustment lines proportionally over product lines and
  /// removes them. Totals are preserved to the cent.
  static List<DraftLine> allocateAdjustments(List<DraftLine> lines) {
    final adjustments = lines.where((l) => l.lineType == LineType.adjustment).toList();
    final kept = lines.where((l) => l.lineType != LineType.adjustment).toList();
    if (adjustments.isEmpty) return kept;
    final adjTotal = adjustments.fold(0, (a, l) => a + l.totalMinor);
    final products = kept.where((l) => l.lineType == LineType.product && l.totalMinor > 0).toList();
    final base = products.fold(0, (a, l) => a + l.totalMinor);
    if (products.isEmpty || base == 0) return lines; // nothing to spread over; keep as-is
    var allocated = 0;
    for (final p in products) {
      final share = (adjTotal * p.totalMinor / base).round();
      p.totalMinor += share;
      allocated += share;
    }
    final drift = adjTotal - allocated;
    if (drift != 0) {
      products.reduce((a, b) => a.totalMinor >= b.totalMinor ? a : b).totalMinor += drift;
    }
    return kept;
  }

  static SpendCategory primaryCategory(Iterable<({SpendCategory category, int totalMinor})> lines) {
    final totals = <SpendCategory, int>{};
    for (final l in lines) {
      totals[l.category] = (totals[l.category] ?? 0) + l.totalMinor;
    }
    if (totals.isEmpty) return SpendCategory.other;
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
