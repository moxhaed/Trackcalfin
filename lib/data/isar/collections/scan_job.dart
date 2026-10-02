import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';
import 'nutrition.dart';

part 'scan_job.g.dart';

/// Async AI queue item and editable review draft for receipt/pantry photos.
@collection
class ScanJob {
  Id id = Isar.autoIncrement;

  @Index()
  @Enumerated(EnumType.name)
  ScanStatus status = ScanStatus.queued;

  /// Set from the AI's image_type.
  @Enumerated(EnumType.name)
  ScanKind kind = ScanKind.unknown;

  /// "receipt", "pantry" or null.
  String? userHint;

  List<String> imagePaths = [];
  DateTime capturedAt = DateTime.now();
  int attempts = 0;
  String? lastError;

  // Parsed + validated AI result = editable draft.
  String? merchant;
  DateTime? purchasedAt;
  int? receiptTotalMinor;
  String? currency;
  List<DraftLine> lines = [];

  /// total_mismatch, foreign_currency, merge_proposed, ...
  List<String> flags = [];

  /// Foreign-currency receipts: 1 [currency] = [fxRate] home currency.
  /// Line amounts stay in the receipt's currency until commit.
  double? fxRate;

  /// ecb, manual, charged or remembered (see FxSource).
  String? fxSource;
  DateTime? fxDate;

  int? aiCallLogId;

  /// Set on commit.
  int? transactionId;

  /// A receipt that looks like this one (same store, day and total): already filed as this
  /// transaction, or waiting in the Inbox as this scan. Cleared when the user says it's another.
  int? duplicateOfTxId;
  int? duplicateOfJobId;

  @ignore
  bool get maybeDuplicate => duplicateOfTxId != null || duplicateOfJobId != null;
}

@embedded
class DraftLine {
  String rawText = '';
  String name = '';

  @Enumerated(EnumType.name)
  LineType lineType = LineType.product;

  @Enumerated(EnumType.name)
  SpendCategory category = SpendCategory.groceries;

  int totalMinor = 0;

  String? ingredientKey;

  /// From IngredientMatcher.
  int? matchedIngredientId;

  /// Fuzzy proposal awaiting the user.
  int? mergeCandidateId;
  bool isNewIngredient = false;

  double? qty;

  @Enumerated(EnumType.name)
  BaseUnit unit = BaseUnit.g;

  @Enumerated(EnumType.name)
  QtySource qtySource = QtySource.unknown;

  @Enumerated(EnumType.name)
  Confidence confidence = Confidence.high;

  /// The user can untick a line before commit.
  bool include = true;

  /// Only when [isNewIngredient].
  NewIngredientProfile? profile;

  /// The exact product the AI recognized: brand, name, variant and pack size.
  String? product;

  /// Pantry photos: the size of one pack of [product] (in [unit]) and its typical shelf price
  /// in home-currency minor units. Becomes the item's cost when it has no price yet.
  double? packageQty;
  int? packagePriceMinor;

  /// What filing does to the pantry. null = the default for the scan (see [effectFor]).
  @Enumerated(EnumType.name)
  StockEffect? stock;

  /// Why the line asks whether its quantity belongs in the pantry; the answer goes in [stock].
  @Enumerated(EnumType.name)
  StockCheck? stockCheck;

  /// [stock], or the default: a receipt adds, a pantry photo counts what is there.
  StockEffect effectFor(ScanKind kind) => stock ?? (kind == ScanKind.pantry ? StockEffect.replace : StockEffect.add);

  /// Shelf price per base unit (minor units); null without a usable estimate.
  @ignore
  double? get estUnitCostMinor {
    final q = packageQty;
    final p = packagePriceMinor;
    if (q == null || p == null || q <= 0 || p <= 0) return null;
    return p / q;
  }

  @ignore
  bool get needsAttention =>
      confidence == Confidence.low ||
      mergeCandidateId != null ||
      stockCheck != null ||
      (ingredientKey != null && qtySource == QtySource.unknown);
}

@embedded
class NewIngredientProfile {
  String name = '';

  @Enumerated(EnumType.name)
  IngredientCategory category = IngredientCategory.other;

  @Enumerated(EnumType.name)
  BaseUnit unit = BaseUnit.g;

  double? gramsPerPiece;
  double? densityGPerMl;
  Nutrition per100 = Nutrition();
  int shelfLifeDays = 7;
}
