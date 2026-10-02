import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/nutrition.dart';
import '../domain/stock_index.dart';
import 'clock.dart';

/// Saving, favoriting and recomputing recipes.
class RecipeService {
  RecipeService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  /// Resolves ingredient ids by key and refreshes the Dart-computed numbers.
  static void refreshNumbers(Recipe r, StockIndex stock) {
    for (final ri in r.ingredients) {
      if (ri.role == IngredientRole.missing) continue;
      final ing = stock.resolve(ri);
      if (ing != null) {
        ri.ingredientId = ing.id;
        ri.key = ing.key;
        if (ri.name.isEmpty) ri.name = ing.name;
      }
    }
    final n = NutritionEngine.compute(r.ingredients, stock);
    r.perPortion = n.perPortion;
    r.costPerPortionMinor = n.costPerPortionMinor;
  }

  /// Recomputes the stored numbers of every recipe that uses one of [ingredientIds]
  /// (after its macros, unit or piece weight changed). Call inside a write transaction.
  static Future<void> refreshUsing(Isar isar, Set<int> ingredientIds) async {
    if (ingredientIds.isEmpty) return;
    final stock = StockIndex(await isar.ingredients.where().findAll());
    final recipes = await isar.recipes.filter().not().statusEqualTo(RecipeStatus.archived).findAll();
    final hit = recipes.where((r) => r.ingredients.any((ri) => ingredientIds.contains(stock.resolve(ri)?.id))).toList();
    for (final r in hit) {
      refreshNumbers(r, stock);
    }
    await isar.recipes.putAll(hit);
  }

  Future<int> save(Recipe r, {bool markSaved = true}) async {
    return isar.writeTxn(() async {
      final stock = StockIndex(await isar.ingredients.where().findAll());
      refreshNumbers(r, stock);
      if (markSaved && r.status == RecipeStatus.suggested) r.status = RecipeStatus.saved;
      return isar.recipes.put(r);
    });
  }

  Future<void> setFavorite(int id, bool value) async {
    await isar.writeTxn(() async {
      final r = await isar.recipes.get(id);
      if (r == null) return;
      r.favorite = value;
      if (value && r.status == RecipeStatus.suggested) r.status = RecipeStatus.saved;
      await isar.recipes.put(r);
    });
  }

  Future<void> setStatus(int id, RecipeStatus status) async {
    await isar.writeTxn(() async {
      final r = await isar.recipes.get(id);
      if (r == null) return;
      r.status = status;
      await isar.recipes.put(r);
    });
  }

  Future<Recipe?> delete(int id) async {
    return isar.writeTxn(() async {
      final r = await isar.recipes.get(id);
      if (r != null) await isar.recipes.delete(id);
      return r;
    });
  }

  Future<void> restore(Recipe r) => isar.writeTxn(() => isar.recipes.put(r));

  /// Saved recipes for "Cook again": favorites or cooked before, not archived.
  Future<List<Recipe>> cookAgain() async {
    final all = await isar.recipes.filter().not().statusEqualTo(RecipeStatus.archived).findAll();
    return all.where((r) => r.favorite || r.timesCooked > 0 || r.status == RecipeStatus.saved).toList()..sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return (b.lastCookedAt ?? b.createdAt).compareTo(a.lastCookedAt ?? a.createdAt);
    });
  }
}
