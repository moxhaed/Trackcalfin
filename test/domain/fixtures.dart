import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

int _id = 1;

Ingredient ingredient(
  String key, {
  double qty = 0,
  BaseUnit unit = BaseUnit.g,
  double cost = 0,
  double kcal = 0,
  double protein = 0,
  double carbs = 0,
  double fat = 0,
  double? gpp,
  int shelf = 7,
  DateTime? expiresAt,
  DateTime? verified,
  DateTime? counted,
  bool costIsEstimate = false,
}) => Ingredient()
  ..id = _id++
  ..key = key
  ..name = key.replaceAll('_', ' ')
  ..qtyOnHand = qty
  ..baseUnit = unit
  ..avgCostPerUnitMinor = cost
  ..per100 = Nutrition(kcal: kcal, proteinG: protein, carbsG: carbs, fatG: fat)
  ..gramsPerPiece = gpp
  ..shelfLifeDays = shelf
  ..expiresAt = expiresAt
  ..lastVerifiedAt = verified
  ..lastCountedAt = counted
  ..costIsEstimate = costIsEstimate;

RecipeIngredient ri(String key, double qty, {BaseUnit unit = BaseUnit.g, IngredientRole role = IngredientRole.stock}) =>
    RecipeIngredient()
      ..key = key
      ..name = key.replaceAll('_', ' ')
      ..qtyPerPortion = qty
      ..unit = unit
      ..role = role;

Transaction tx(DateTime at, int minor, {SpendCategory category = SpendCategory.groceries}) => Transaction()
  ..occurredAt = at
  ..totalMinor = minor
  ..primaryCategory = category
  ..lines = [
    LineItem()
      ..name = 'x'
      ..category = category
      ..totalMinor = minor,
  ];

DailyLog dayLog(int key, double kcal, double protein, {int costMinor = 200, int meals = 1}) {
  final log = DailyLog()..dateKey = key;
  for (var i = 0; i < meals; i++) {
    log.meals.add(
      MealEntry()
        ..title = 'meal'
        ..nutrition = Nutrition(kcal: kcal / meals, proteinG: protein / meals)
        ..costMinor = costMinor ~/ meals,
    );
  }
  log.recomputeTotals();
  return log;
}
