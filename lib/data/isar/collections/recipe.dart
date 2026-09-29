import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';
import 'nutrition.dart';

part 'recipe.g.dart';

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  late String title;

  /// At most 70 chars; notification line and card subtitle.
  String hook = '';
  String why = '';
  String cuisine = '';

  @Enumerated(EnumType.name)
  RecipeOrigin origin = RecipeOrigin.manual;

  @Index()
  @Enumerated(EnumType.name)
  RecipeStatus status = RecipeStatus.suggested;

  /// yyyymmdd the daily pick is for; null for non-daily recipes.
  @Index()
  int? suggestedForDateKey;

  /// The user's words, for spontaneous recipes.
  String? sourceQuery;

  int defaultPortions = 1;
  int prepMinutes = 0;
  int cookMinutes = 0;
  int activeMinutes = 0;
  int fridgeLifeDays = 3;

  List<RecipeIngredient> ingredients = [];
  List<String> steps = [];
  List<String> tags = [];

  /// Dart-computed at generation; recomputed on cook.
  Nutrition perPortion = Nutrition();
  int costPerPortionMinor = 0;

  /// The model's own estimate, kept only for divergence monitoring.
  Nutrition? aiPerPortion;
  int? aiCostPerPortionMinor;

  List<String> validationFlags = [];

  /// Spontaneous verdict: ready, ready_with_swaps, missing_items.
  String? feasibilityStatus;
  String? summary;
  List<String> omitted = [];
  List<ShoppingItem> shoppingList = [];

  @Index()
  bool favorite = false;

  int timesCooked = 0;
  DateTime? lastCookedAt;

  /// Default for the portion stepper.
  int lastPortionsCooked = 0;
  String? promptVersion;
  DateTime createdAt = DateTime.now();

  @ignore
  int get totalMinutes => prepMinutes + cookMinutes;
}

@embedded
class RecipeIngredient {
  /// Ingredient key or staple key; empty for missing items.
  String key = '';
  String name = '';

  /// Resolved by IngredientMatcher at save time.
  int? ingredientId;
  double qtyPerPortion = 0;

  @Enumerated(EnumType.name)
  BaseUnit unit = BaseUnit.g;

  @Enumerated(EnumType.name)
  IngredientRole role = IngredientRole.stock;

  String? prepNote;
  String? substitutesFor;

  /// Only for role == missing (model estimates).
  int? estCostMinor;
  Nutrition? estNutritionPerPortion;
}

@embedded
class ShoppingItem {
  String name = '';
  String packageDesc = '';
  int estCostMinor = 0;

  /// "missing", "short" or "suggestion".
  String reason = 'missing';
}
