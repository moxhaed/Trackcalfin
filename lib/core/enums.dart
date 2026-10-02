/// Enums shared by the Isar schema, the domain engines and the AI DTOs.
///
/// Stored by name (`@Enumerated(EnumType.name)`), so values can be reordered
/// safely. AI JSON uses snake_case; see `data/ai/dto/enum_codec.dart`.
library;

enum BaseUnit { g, ml, pc }

enum IngredientCategory {
  produce,
  meatFish,
  dairyEggs,
  grainsPasta,
  legumesNuts,
  cannedJarred,
  bakery,
  frozen,
  spicesCondiments,
  oilsFats,
  beverages,
  snacksSweets,
  other,
}

enum SpendCategory { groceries, household, clothes, eatingOut, entertainment, other }

enum LineType { product, adjustment, deposit, fee }

/// Where an ingredient's macros came from. [none] = nothing known yet; the AI fills it in.
enum DataSource { none, aiEstimate, user, label }

enum Confidence { high, medium, low }

enum QtySource { printed, inferred, estimated, unknown }

enum TxSource { receiptScan, manual, quickText }

enum RecipeOrigin { dailyAuto, spontaneous, manual }

enum RecipeStatus { suggested, saved, dismissed, archived }

/// Every recipe ingredient comes from the pantry (stock) or has to be bought (missing).
/// Nothing is assumed to be in the kitchen without being scanned.
enum IngredientRole { stock, missing }

enum CookStatus { active, finished, discarded, undone }

enum MealSource { cookedNow, fridge, quickAdd }

enum ScanStatus { queued, processing, needsReview, committed, failed, discarded }

enum ScanKind { unknown, receipt, pantry, unreadable }

/// What filing a scan line does to the pantry. The money is filed either way.
enum StockEffect {
  /// The quantity is added to what's on hand: a purchase, or an extra one on a pantry photo.
  add,

  /// The quantity becomes what's on hand: a pantry photo counts what is there.
  replace,

  /// The pantry stays as it is: the item was already counted, or is used up.
  none,
}

/// Why a scan line asks whether its quantity belongs in the pantry.
enum StockCheck {
  /// Pantry photo: the item is already on hand. The same one, or another?
  onHand,

  /// Receipt: the item was counted after this purchase, so the count may already include it.
  counted,

  /// Receipt: bought longer ago than it keeps, so it's probably used up.
  usedUp,
}

enum AiTask { receipt, dailyRecipe, spontaneousRecipe, nutritionEstimate, nutritionLabel }

extension BaseUnitLabel on BaseUnit {
  String get label => switch (this) {
    BaseUnit.g => 'g',
    BaseUnit.ml => 'ml',
    BaseUnit.pc => 'pc',
  };
}

extension SpendCategoryLabel on SpendCategory {
  String get label => switch (this) {
    SpendCategory.groceries => 'Groceries',
    SpendCategory.household => 'Household',
    SpendCategory.clothes => 'Clothes',
    SpendCategory.eatingOut => 'Eating out',
    SpendCategory.entertainment => 'Entertainment',
    SpendCategory.other => 'Other',
  };

  bool get isFood => this == SpendCategory.groceries;
}

extension IngredientCategoryLabel on IngredientCategory {
  String get label => switch (this) {
    IngredientCategory.produce => 'Produce',
    IngredientCategory.meatFish => 'Meat & fish',
    IngredientCategory.dairyEggs => 'Dairy & eggs',
    IngredientCategory.grainsPasta => 'Grains & pasta',
    IngredientCategory.legumesNuts => 'Legumes & nuts',
    IngredientCategory.cannedJarred => 'Canned & jarred',
    IngredientCategory.bakery => 'Bakery',
    IngredientCategory.frozen => 'Frozen',
    IngredientCategory.spicesCondiments => 'Spices & condiments',
    IngredientCategory.oilsFats => 'Oils & fats',
    IngredientCategory.beverages => 'Beverages',
    IngredientCategory.snacksSweets => 'Snacks & sweets',
    IngredientCategory.other => 'Other',
  };
}
