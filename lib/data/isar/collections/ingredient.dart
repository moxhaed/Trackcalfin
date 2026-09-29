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

  /// staple = always assumed available, never deducted (salt, oil, spices).
  @Enumerated(EnumType.name)
  TrackingMode trackingMode = TrackingMode.exact;

  /// On-hand quantity in [baseUnit]. Invariant: >= 0.
  double qtyOnHand = 0;

  /// Weighted average cost, minor units per base unit (0.998 = 9.98/kg).
  double avgCostPerUnitMinor = 0;

  /// Required when [baseUnit] is [BaseUnit.pc].
  double? gramsPerPiece;

  /// For ml items; null means 1.0.
  double? densityGPerMl;

  /// Per 100 g (g and pc items) or per 100 ml (ml items).
  Nutrition per100 = Nutrition();

  @Enumerated(EnumType.name)
  DataSource nutritionSource = DataSource.aiEstimate;

  int shelfLifeDays = 7;

  /// Soonest estimated expiry of what is on hand (see ExpiryEstimator).
  @Index()
  DateTime? expiresAt;

  double lowStockThreshold = 0;
  DateTime? lastPurchasedAt;
  double lastPurchaseQty = 0;

  /// null = needs verification (shortfall detected or never checked).
  DateTime? lastVerifiedAt;

  DateTime updatedAt = DateTime.now();

  @ignore
  bool get isStaple => trackingMode == TrackingMode.staple;

  @ignore
  bool get isLow => !isStaple && qtyOnHand > 0 && lowStockThreshold > 0 && qtyOnHand <= lowStockThreshold;
}
