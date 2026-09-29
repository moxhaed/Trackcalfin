/// Enums shared by the Isar schema, the domain engines and the AI DTOs.
///
/// Stored by name (`@Enumerated(EnumType.name)`), so values can be reordered
/// safely. AI JSON uses snake_case; see `data/ai/dto/enum_codec.dart`.
library;

enum BaseUnit { g, ml, pc }

enum TrackingMode { exact, staple }

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

enum DataSource { aiEstimate, user, label }

enum Confidence { high, medium, low }

enum QtySource { printed, inferred, estimated, unknown }

enum TxSource { receiptScan, manual, quickText }

enum RecipeOrigin { dailyAuto, spontaneous, manual }

enum RecipeStatus { suggested, saved, dismissed, archived }

enum IngredientRole { stock, staple, missing }

enum CookStatus { active, finished, discarded, undone }

enum MealSource { cookedNow, fridge, quickAdd }

enum ScanStatus { queued, processing, needsReview, committed, failed, discarded }

enum ScanKind { unknown, receipt, pantry, unreadable }

enum AiTask { receipt, dailyRecipe, spontaneousRecipe }

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
