import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/costing.dart';
import 'clock.dart';
import 'recipe_service.dart';

/// Hand edits to the pantry.
class PantryService {
  PantryService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  /// "Greek yogurt 10%" -> "greek_yogurt".
  static String slugify(String name) {
    final s = name
        .toLowerCase()
        .replaceAll(RegExp(r'[äàáâ]'), 'a')
        .replaceAll(RegExp(r'[öòóô]'), 'o')
        .replaceAll(RegExp(r'[üùúû]'), 'u')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final words = s.split('_').where((w) => w.isNotEmpty && !RegExp(r'^\d+$').hasMatch(w)).take(4);
    final out = words.join('_');
    if (out.isEmpty) return 'item';
    return RegExp(r'^[a-z]').hasMatch(out) ? out : 'i_$out';
  }

  Future<String> uniqueKey(String base) async {
    var key = base;
    var n = 2;
    while (await isar.ingredients.getByKey(key) != null) {
      key = '${base}_$n';
      n++;
    }
    return key;
  }

  /// Creates or updates an ingredient. New ones get a unique key and count as verified.
  /// Updates refresh the numbers of recipes that use it.
  Future<int> upsert(Ingredient ing) async {
    final t = now();
    return isar.writeTxn(() async {
      final isNew = ing.id == Isar.autoIncrement || ing.key.isEmpty;
      if (isNew) {
        ing.key = await uniqueKey(ing.key.isEmpty ? slugify(ing.name) : ing.key);
        ing.lastVerifiedAt ??= t;
        if (ing.qtyOnHand > 0 && ing.expiresAt == null && ing.shelfLifeDays > 0) {
          ing.lastPurchasedAt ??= t;
          ing.lastPurchaseQty = ing.qtyOnHand;
          ing.expiresAt = t.add(Duration(days: ing.shelfLifeDays));
        }
      }
      ing.updatedAt = t;
      final id = await isar.ingredients.put(ing);
      if (!isNew) await RecipeService.refreshUsing(isar, {id});
      return id;
    });
  }

  /// Sets the on-hand quantity (Quick Check, adjust, pantry photo). Counts as verified.
  Future<void> setQuantity(int id, double qty) async {
    final t = now();
    await isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing == null) return;
      final before = ing.qtyOnHand;
      ing.qtyOnHand = qty < 0 ? 0 : qty;
      if (ing.qtyOnHand < before) {
        ExpiryEstimator.onDeplete(ing);
      } else if (before <= 0 && ing.qtyOnHand > 0) {
        ing.expiresAt = t.add(Duration(days: ing.shelfLifeDays));
        ing.lastPurchasedAt ??= t;
        ing.lastPurchaseQty = ing.qtyOnHand;
      }
      ing.lastVerifiedAt = t;
      ing.updatedAt = t;
      await isar.ingredients.put(ing);
    });
  }

  Future<void> markOut(int id) => setQuantity(id, 0);

  Future<void> verify(int id) async {
    await isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing == null) return;
      ing.lastVerifiedAt = now();
      await isar.ingredients.put(ing);
    });
  }

  Future<void> setTracking(int id, TrackingMode mode) async {
    await isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing == null) return;
      ing.trackingMode = mode;
      await isar.ingredients.put(ing);
    });
  }

  Future<Ingredient?> delete(int id) async {
    return isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing != null) await isar.ingredients.delete(id);
      return ing;
    });
  }

  Future<void> restore(Ingredient ing) async {
    await isar.writeTxn(() => isar.ingredients.put(ing));
  }

  /// Onboarding staples: creates missing staple ingredients by name. Their macros
  /// start unknown; NutritionService.fillMissing asks the AI.
  Future<void> ensureStaples(List<String> names) async {
    await isar.writeTxn(() async {
      for (final name in names) {
        final key = slugify(name);
        final existing = await isar.ingredients.getByKey(key);
        if (existing != null) {
          existing.trackingMode = TrackingMode.staple;
          await isar.ingredients.put(existing);
          continue;
        }
        await isar.ingredients.put(
          Ingredient()
            ..key = key
            ..name = name
            ..trackingMode = TrackingMode.staple
            ..category = _stapleCategory(key)
            ..baseUnit = _stapleUnit(key)
            ..shelfLifeDays = 365
            ..lastVerifiedAt = now(),
        );
      }
    });
  }

  static IngredientCategory _stapleCategory(String key) {
    if (key.contains('oil') || key.contains('butter')) return IngredientCategory.oilsFats;
    if (key.contains('flour') || key.contains('rice') || key.contains('pasta')) return IngredientCategory.grainsPasta;
    return IngredientCategory.spicesCondiments;
  }

  static BaseUnit _stapleUnit(String key) =>
      key.contains('oil') || key.contains('vinegar') || key.contains('sauce') ? BaseUnit.ml : BaseUnit.g;
}
