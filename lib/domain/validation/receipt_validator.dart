import '../../core/enums.dart';
import '../../data/ai/dto/receipt_dto.dart';
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

  /// Auto-commit rule from docs/05 §5.5.
  bool get autoCommitEligible =>
      kind == ScanKind.receipt &&
      !flags.contains('total_mismatch') &&
      !flags.contains('foreign_currency') &&
      !flags.contains('merge_proposed') &&
      !flags.contains('date_adjusted') &&
      lines.every((l) => l.confidence != Confidence.low) &&
      lines.every((l) => l.ingredientKey == null || l.qtySource != QtySource.unknown);
}

/// Turns a parsed Prompt A result into an editable, flagged ScanJob draft.
class ReceiptValidator {
  const ReceiptValidator._();

  static const maxLineMinor = 100000;
  static const minLineMinor = -50000;

  static ScanDraft validate(
    ReceiptExtraction x, {
    required IngredientMatcher matcher,
    required String homeCurrency,
    required DateTime capturedAt,
  }) {
    final flags = <String>{};
    final lines = <DraftLine>[];

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
      if (q != null && (q < 0 || (item.unit == BaseUnit.pc ? q > 60 : q > 25000))) {
        line.confidence = Confidence.low;
        line.qtySource = QtySource.unknown;
        line.qty = null;
      }

      final isGrocery = item.category == SpendCategory.groceries && item.lineType == LineType.product;
      if (isGrocery && item.ingredientKey != null) {
        final match = matcher.resolve(rawText: item.rawText, key: item.ingredientKey, name: item.name);
        switch (match.kind) {
          case MatchKind.alias:
          case MatchKind.key:
            line
              ..ingredientKey = match.ingredient!.key
              ..matchedIngredientId = match.ingredient!.id
              ..isNewIngredient = false;
            _alignUnit(line, match.ingredient!.baseUnit, match.ingredient!.gramsPerPiece);
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

    // R8: currency
    final currency = x.currency ?? homeCurrency;
    if (x.imageType == ScanKind.receipt && currency.toUpperCase() != homeCurrency.toUpperCase()) {
      flags.add('foreign_currency');
    }

    // R6: date
    var date = x.purchasedAt;
    if (date != null) {
      final future = date.isAfter(capturedAt.add(const Duration(days: 1)));
      final old = capturedAt.difference(date).inDays > 60;
      if (future || old) {
        date = capturedAt;
        flags.add('date_adjusted');
      }
    }

    return ScanDraft(
      kind: x.imageType,
      merchant: x.merchant,
      purchasedAt: date ?? (x.imageType == ScanKind.receipt ? capturedAt : null),
      receiptTotalMinor: x.receiptTotalMinor,
      currency: currency,
      lines: lines,
      flags: flags.toList(),
    );
  }

  static void _alignUnit(DraftLine line, BaseUnit target, double? gramsPerPiece) {
    if (line.qty == null || line.unit == target) {
      line.unit = target;
      return;
    }
    // Simple conversions only; anything else becomes an unknown quantity.
    final q = line.qty!;
    double? converted;
    if (line.unit == BaseUnit.ml && target == BaseUnit.g) converted = q;
    if (line.unit == BaseUnit.g && target == BaseUnit.ml) converted = q;
    if (line.unit == BaseUnit.pc && target == BaseUnit.g && gramsPerPiece != null) converted = q * gramsPerPiece;
    if (line.unit == BaseUnit.g && target == BaseUnit.pc && gramsPerPiece != null && gramsPerPiece > 0) {
      converted = (q / gramsPerPiece).roundToDouble();
    }
    line.unit = target;
    if (converted == null) {
      line.qty = null;
      line.qtySource = QtySource.unknown;
    } else {
      line.qty = converted;
    }
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
      ..shelfLifeDays = p.shelfLifeDays.clamp(1, 3650)
      ..suggestStaple = p.suggestStaple;
  }
}
