import '../../../core/enums.dart';

/// AI snake_case strings <-> Dart enums. Explicit maps: an unknown value is an error.
class EnumCodec {
  const EnumCodec._();

  static const spendCategory = {
    'groceries': SpendCategory.groceries,
    'household': SpendCategory.household,
    'clothes': SpendCategory.clothes,
    'eating_out': SpendCategory.eatingOut,
    'entertainment': SpendCategory.entertainment,
    'other': SpendCategory.other,
  };

  static const ingredientCategory = {
    'produce': IngredientCategory.produce,
    'meat_fish': IngredientCategory.meatFish,
    'dairy_eggs': IngredientCategory.dairyEggs,
    'grains_pasta': IngredientCategory.grainsPasta,
    'legumes_nuts': IngredientCategory.legumesNuts,
    'canned_jarred': IngredientCategory.cannedJarred,
    'bakery': IngredientCategory.bakery,
    'frozen': IngredientCategory.frozen,
    'spices_condiments': IngredientCategory.spicesCondiments,
    'oils_fats': IngredientCategory.oilsFats,
    'beverages': IngredientCategory.beverages,
    'snacks_sweets': IngredientCategory.snacksSweets,
    'other': IngredientCategory.other,
  };

  static const lineType = {
    'product': LineType.product,
    'adjustment': LineType.adjustment,
    'deposit': LineType.deposit,
    'fee': LineType.fee,
  };

  static const qtySource = {
    'printed': QtySource.printed,
    'inferred': QtySource.inferred,
    'estimated': QtySource.estimated,
    'unknown': QtySource.unknown,
  };

  static const confidence = {'high': Confidence.high, 'medium': Confidence.medium, 'low': Confidence.low};

  static const unit = {'g': BaseUnit.g, 'ml': BaseUnit.ml, 'pc': BaseUnit.pc};

  static const role = {'stock': IngredientRole.stock, 'missing': IngredientRole.missing};

  static const imageType = {'receipt': ScanKind.receipt, 'pantry': ScanKind.pantry, 'unreadable': ScanKind.unreadable};

  static String categoryKey(IngredientCategory c) => ingredientCategory.entries.firstWhere((e) => e.value == c).key;

  static String unitKey(BaseUnit u) => u.label;
}
