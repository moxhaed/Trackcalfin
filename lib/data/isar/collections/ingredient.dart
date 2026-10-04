import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';
import 'nutrition.dart';

part 'ingredient.g.dart';

/// A canonical pantry ingredient and how much of it is on hand.
@collection
class Ingredient {
  Id id = Isar.autoIncrement;

  /// Stable slug shared with the AI ("chicken_breast"). Never renamed after creation.
  @Index(unique: true, replace: false)
  String key = '';

  String name = '';

  /// Normalized raw receipt strings confirmed for this ingredient ("HOCHL BRUSTFILET").
  @Index(type: IndexType.hashElements)
  List<String> aliases = [];

  @Enumerated(EnumType.name)
  IngredientCategory category = IngredientCategory.other;

  @Enumerated(EnumType.name)
  BaseUnit baseUnit = BaseUnit.g;

  /// "staple" for items that were assumed always available before schema 3. Only
  /// Migrations reads it, to turn them into regular items.
  @Name('trackingMode')
  String? legacyTrackingMode;

  /// On-hand quantity in [baseUnit]. Invariant: >= 0.
  double qtyOnHand = 0;

  /// Weighted average cost, minor units per base unit (0.998 = 9.98/kg).
  double avgCostPerUnitMinor = 0;

  /// [avgCostPerUnitMinor] is an AI shelf-price estimate from a pantry photo, not a price
  /// paid. The next real price replaces it instead of averaging with it.
  bool costIsEstimate = false;

  /// Required when [baseUnit] is [BaseUnit.pc].
  double? gramsPerPiece;

  /// What one piece is called, singular ("can", "tortilla", "cup"), for [BaseUnit.pc] items:
  /// the app says "6 cans" instead of "6 pc". Null says "pc".
  String? pieceName;

  /// Grams in one ml: for ml items, and for gram items measured with spoons or cups (sugar 0.85,
  /// flour 0.53). Null means 1.0.
  double? densityGPerMl;

  /// Per 100 g (g and pc items) or per 100 ml (ml items).
  Nutrition per100 = Nutrition();

  /// [DataSource.none] until something fills [per100] (NutritionService.fillMissing).
  @Enumerated(EnumType.name)
  DataSource nutritionSource = DataSource.none;

  /// When the user confirmed [per100]: a label scan, their own numbers or "Confirm".
  /// null = unconfirmed estimate.
  DateTime? nutritionConfirmedAt;

  int shelfLifeDays = 7;

  /// Soonest estimated expiry of what is on hand (see ExpiryEstimator).
  @Index()
  DateTime? expiresAt;

  double lowStockThreshold = 0;
  DateTime? lastPurchasedAt;
  double lastPurchaseQty = 0;

  /// null = needs verification (shortfall detected or never checked).
  DateTime? lastVerifiedAt;

  /// When the quantity was last counted by looking: a pantry photo, Quick Check or a hand
  /// adjustment. Purchases don't set it. A receipt from before this may be part of the count.
  DateTime? lastCountedAt;

  DateTime updatedAt = DateTime.now();

  @ignore
  bool get needsNutrition => nutritionSource == DataSource.none;

  @ignore
  bool get isLow => qtyOnHand > 0 && lowStockThreshold > 0 && qtyOnHand <= lowStockThreshold;
}
