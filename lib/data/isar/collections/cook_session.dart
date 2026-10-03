import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';
import 'nutrition.dart';

part 'cook_session.g.dart';

/// One cooking event. Its remaining portions are "the fridge".
@collection
class CookSession {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime cookedAt = DateTime.now();

  int recipeId = 0;
  String recipeTitle = '';

  int portionsCooked = 1;
  int portionsRemaining = 0;
  int portionsDiscarded = 0;

  /// Snapshots at cook time (WAC and nutrition at that moment).
  Nutrition perPortion = Nutrition();
  int costPerPortionMinor = 0;

  /// Exact deductions: makes undo lossless and exposes stock drift.
  List<StockDelta> deltas = [];

  @Index()
  @Enumerated(EnumType.name)
  CookStatus status = CookStatus.active;

  DateTime? fridgeExpiresAt;

  /// The recipe as it was before this cook, so undo can put it back. Null on older sessions.
  @Enumerated(EnumType.name)
  RecipeStatus? recipeStatusBefore;
  DateTime? recipeLastCookedBefore;
  int recipeLastPortionsBefore = 0;
}

@embedded
class StockDelta {
  int ingredientId = 0;
  String key = '';

  /// Base units.
  double requested = 0;

  /// Actually removed (<= requested).
  double deducted = 0;

  /// requested - deducted; > 0 means stock was under-counted.
  double shortfall = 0;

  /// The ingredient's last check and expiry before the deduction, for undo.
  DateTime? verifiedBefore;
  DateTime? expiresBefore;
}
