import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/recipe.dart';

/// In-memory lookup of pantry ingredients by id and key.
class StockIndex {
  StockIndex(Iterable<Ingredient> items)
    : byId = {for (final i in items) i.id: i},
      byKey = {for (final i in items) i.key: i};

  final Map<int, Ingredient> byId;
  final Map<String, Ingredient> byKey;

  Iterable<Ingredient> get all => byId.values;

  Ingredient? resolve(RecipeIngredient ri) {
    if (ri.ingredientId != null) {
      final hit = byId[ri.ingredientId];
      if (hit != null) return hit;
    }
    if (ri.key.isEmpty) return null;
    return byKey[ri.key];
  }
}
