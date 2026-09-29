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

  int? aiCallLogId;

  /// Set on commit.
  int? transactionId;
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

  @ignore
  bool get needsAttention =>
      confidence == Confidence.low ||
      mergeCandidateId != null ||
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
  bool suggestStaple = false;
}
