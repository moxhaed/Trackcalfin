import '../../core/day_clock.dart';
import '../../core/enums.dart';
import '../../data/ai/dto/receipt_dto.dart';
import '../../data/isar/collections/ingredient.dart';
import '../../data/isar/collections/scan_job.dart';
import '../ingredient_matcher.dart';
import '../nutrition.dart';

class ScanDraft {
  ScanDraft({
    required this.kind,
    required this.lines,
    required this.flags,
    this.merchant,
    this.purchasedAt,
    this.receiptTotalMinor,
    this.currency,
  });
  final ScanKind kind;
  final String? merchant;
  final DateTime? purchasedAt;
  final int? receiptTotalMinor;
  final String? currency;
  final List<DraftLine> lines;
  final List<String> flags;

  /// The extraction passed every check in docs/05 §5.5: nothing was misread or guessed.
  bool get clean =>
      kind == ScanKind.receipt &&
      !flags.contains('total_mismatch') &&
      !flags.contains('foreign_currency') &&
      !flags.contains('currency_uncertain') &&
      !flags.contains('merge_proposed') &&
      !flags.any(ReceiptValidator.dateFlags.contains) &&
      lines.every((l) => l.confidence != Confidence.low) &&
      lines.every((l) => l.ingredientKey == null || l.qtySource != QtySource.unknown);

  /// Auto-commit rule: clean, and no line asks whether it belongs in the pantry.
  /// A possible duplicate receipt (ScanService) also holds it for review.
  bool get autoCommitEligible => clean && lines.every((l) => l.stockCheck == null);
}

/// Turns a parsed Prompt A result into an editable, flagged ScanJob draft.
class ReceiptValidator {
  const ReceiptValidator._();

  static const maxLineMinor = 100000;
  static const minLineMinor = -50000;

  /// A printed date further back than this is more likely a misread year than an old receipt.
  static const maxAgeDays = 365;

  /// date_missing: nothing printed, so the photo date is used. date_adjusted: printed in the
  /// future, so the photo date is used. date_old: over a year back, kept but worth a look.
  static const dateFlags = {'date_missing', 'date_adjusted', 'date_old'};

  static ScanDraft validate(
    ReceiptExtraction x, {
    required IngredientMatcher matcher,
    required String homeCurrency,
    required DateTime capturedAt,
  }) {
    final flags = <String>{};
    final lines = <DraftLine>[];
    final pantry = x.imageType == ScanKind.pantry;

    // R6: date. An old receipt keeps its printed date: the expense belongs to that day and
    // freshness counts from then. Only a date in the future can't be right.
    DateTime? date;
    if (x.imageType == ScanKind.receipt) {
      date = x.purchasedAt;
      if (date == null) {
        date = capturedAt;
        flags.add('date_missing');
      } else if (date.isAfter(capturedAt.add(const Duration(days: 1)))) {
        date = capturedAt;
        flags.add('date_adjusted');
      } else if (DayClock.daysBetween(date, capturedAt) > maxAgeDays) {
        flags.add('date_old');
      }
    }

    for (final item in x.items) {
      final line = DraftLine()
        ..rawText = item.rawText
        ..name = item.name
        ..lineType = item.lineType
        ..category = item.category
        ..totalMinor = item.totalMinor
        ..confidence = item.confidence
        ..qtySource = item.qtySource
        ..qty = item.qty
        ..unit = item.unit ?? BaseUnit.g;

      // R3: money bounds
      if (item.totalMinor > maxLineMinor || item.totalMinor < minLineMinor) {
        line.confidence = Confidence.low;
        flags.add('money_out_of_bounds');
      }
      // R4: quantity bounds
      final q = item.qty;
      if (q != null && !_plausibleQty(q, item.unit)) {
        line.confidence = Confidence.low;
        line.qtySource = QtySource.unknown;
        line.qty = null;
      }

      final isGrocery = item.category == SpendCategory.groceries && item.lineType == LineType.product;
      if (isGrocery && item.ingredientKey != null) {
        line.product = item.product;
        // Receipts print the price; a shelf price only prices what a pantry photo found.
        final shelf = item.shelfPrice;
        if (pantry && shelf != null && shelf.priceMinor <= maxLineMinor && _plausibleQty(shelf.packageQty, item.unit)) {
          line
            ..packageQty = shelf.packageQty
            ..packagePriceMinor = shelf.priceMinor;
        }
        final match = matcher.resolve(rawText: item.rawText, key: item.ingredientKey, name: item.name);
        Ingredient? existing;
        switch (match.kind) {
          case MatchKind.alias:
          case MatchKind.key:
            line
              ..ingredientKey = match.ingredient!.key
              ..matchedIngredientId = match.ingredient!.id
              ..isNewIngredient = false;
            alignUnit(line, match.ingredient!.baseUnit, match.ingredient!.gramsPerPiece);
            existing = match.ingredient;
          case MatchKind.fuzzy:
            line
              ..ingredientKey = item.ingredientKey
              ..isNewIngredient = true
              ..mergeCandidateId = match.ingredient!.id
              ..profile = _profile(item);
            flags.add('merge_proposed');
          case MatchKind.none:
            line
              ..ingredientKey = item.ingredientKey
              ..isNewIngredient = true
              ..profile = _profile(item);
        }
        if (line.profile != null && !NutritionEngine.atwaterPlausible(line.profile!.per100)) {
          flags.add('nutrition_suspect');
        }
        if (line.qty == null) line.qtySource = QtySource.unknown;
        checkStock(line, kind: x.imageType, existing: existing, purchasedAt: date, capturedAt: capturedAt);
        if (pantry) checkPrice(line, existing: existing);
      }
      lines.add(line);
    }

    // R2: totals
    if (x.imageType == ScanKind.receipt) {
      final sum = lines.fold(0, (a, l) => a + l.totalMinor);
      final total = x.receiptTotalMinor;
      if (total == null) {
        flags.add('total_missing');
      } else {
        final tol = (total.abs() * 0.01).round() < 2 ? 2 : (total.abs() * 0.01).round();
        if ((sum - total).abs() > tol) flags.add('total_mismatch');
      }
    }
    if (x.warnings.any((w) => w.startsWith('total_mismatch'))) flags.add('total_mismatch');
    if (x.warnings.any((w) => w.startsWith('currency_uncertain'))) flags.add('currency_uncertain');

    // R8: currency
    final currency = x.currency ?? homeCurrency;
    if (x.imageType == ScanKind.receipt && currency.toUpperCase() != homeCurrency.toUpperCase()) {
      flags.add('foreign_currency');
    }

    return ScanDraft(
      kind: x.imageType,
      merchant: x.merchant,
      purchasedAt: date,
      receiptTotalMinor: x.receiptTotalMinor,
      currency: currency,
      lines: lines,
      flags: flags.toList(),
    );
  }

  static bool _plausibleQty(double q, BaseUnit? unit) => q >= 0 && (unit == BaseUnit.pc ? q <= 60 : q <= 25000);

  /// R9: whether a line's quantity belongs in the pantry. Sets [DraftLine.stockCheck] when
  /// the user should be asked, with the likely answer in [DraftLine.stock]:
  /// - pantry photo, item already on hand: the same one is the default (the photo counts it);
  /// - receipt, item counted after this purchase: the count probably includes it already;
  /// - receipt older than the item keeps: probably used up.
  /// Either receipt case still files the money. [existing] is the pantry item the line maps to.
  static void checkStock(
    DraftLine line, {
    required ScanKind kind,
    required Ingredient? existing,
    required DateTime? purchasedAt,
    required DateTime capturedAt,
  }) {
    line
      ..stockCheck = null
      ..stock = null;
    if (line.ingredientKey == null) return;
    if (kind == ScanKind.pantry) {
      if (existing != null && existing.qtyOnHand > 0) line.stockCheck = StockCheck.onHand;
      return;
    }
    if (kind != ScanKind.receipt || purchasedAt == null) return;
    final counted = existing?.lastCountedAt;
    if (counted != null && counted.isAfter(purchasedAt)) {
      line
        ..stockCheck = StockCheck.counted
        ..stock = StockEffect.none;
      return;
    }
    final keeps = existing?.shelfLifeDays ?? line.profile?.shelfLifeDays;
    if (keeps != null && DayClock.daysBetween(purchasedAt, capturedAt) > keeps) {
      line
        ..stockCheck = StockCheck.usedUp
        ..stock = StockEffect.none;
    }
  }

  /// Whether a pantry item still needs a shop price: it has none, or only an estimate.
  static bool needsPrice(Ingredient? existing) =>
      existing == null || existing.avgCostPerUnitMinor <= 0 || existing.costIsEstimate;

  /// Pantry photos: a shelf price is used, and so asked about, only while the item has no price
  /// paid. [existing] is the pantry item the line maps to.
  static void checkPrice(DraftLine line, {required Ingredient? existing}) {
    line.priceSource = needsPrice(existing) && line.estUnitCostMinor != null
        ? (line.priceSource ?? PriceSource.estimate)
        : null;
  }

  /// Whether two receipts look like the same piece of paper: same day and total, and the
  /// same store when both name one ("Migros" and "Migros Zürich" count as the same).
  static bool sameReceipt({
    required String? merchant,
    required DateTime day,
    required int totalMinor,
    required String? otherMerchant,
    required DateTime otherDay,
    required int otherTotalMinor,
  }) {
    if (totalMinor == 0 || totalMinor != otherTotalMinor) return false;
    if (DayClock.daysBetween(day, otherDay) != 0) return false;
    final a = _store(merchant);
    final b = _store(otherMerchant);
    return a == null || b == null || a.startsWith(b) || b.startsWith(a);
  }

  static String? _store(String? merchant) {
    final s = (merchant ?? '').toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
    return s.isEmpty ? null : s;
  }

  /// Moves a line's quantities into [target] (a matched item's unit). Simple conversions
  /// only; a quantity that can't be converted becomes unknown.
  static void alignUnit(DraftLine line, BaseUnit target, double? gramsPerPiece) {
    if (line.unit == target) return;
    if (line.qty != null) {
      line.qty = _convert(line.qty!, line.unit, target, gramsPerPiece);
      if (line.qty == null) line.qtySource = QtySource.unknown;
    }
    if (line.packageQty != null) {
      line.packageQty = _convert(line.packageQty!, line.unit, target, gramsPerPiece);
      if (line.packageQty == null) line.packagePriceMinor = null;
    }
    line.unit = target;
  }

  /// g and ml count as the same here (a receipt doesn't say how dense a drink is), so
  /// 6 cans of a 340 g cola are 2040 ml, and 1980 ml of a cola counted in cans is 6 pc.
  static double? _convert(double q, BaseUnit from, BaseUnit to, double? gramsPerPiece) {
    if (from == to) return q;
    if (from != BaseUnit.pc && to != BaseUnit.pc) return q;
    if (gramsPerPiece == null || gramsPerPiece <= 0) return null;
    return from == BaseUnit.pc ? q * gramsPerPiece : (q / gramsPerPiece).roundToDouble();
  }

  static NewIngredientProfile _profile(ReceiptItemDto item) {
    final p = item.newIngredient;
    if (p == null) {
      return NewIngredientProfile()
        ..name = item.name
        ..unit = item.unit ?? BaseUnit.g;
    }
    return NewIngredientProfile()
      ..name = p.name.isEmpty ? item.name : p.name
      ..category = p.category
      ..unit = p.unit
      ..gramsPerPiece = p.gramsPerPiece ?? (p.unit == BaseUnit.pc ? 50 : null)
      ..densityGPerMl = p.densityGPerMl
      ..per100 = p.per100
      ..shelfLifeDays = p.shelfLifeDays.clamp(1, 3650);
  }
}
