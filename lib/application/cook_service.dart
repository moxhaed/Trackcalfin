import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/costing.dart';
import '../domain/depletion.dart';
import '../domain/nutrition.dart';
import '../domain/stock_index.dart';
import 'clock.dart';
import 'recipe_service.dart';

class CookResult {
  CookResult(this.sessionId, this.plan, this.autoLoggedEntryId, this.portionsInFridge);
  final int sessionId;
  final CookPlan plan;
  final String? autoLoggedEntryId;
  final int portionsInFridge;
}

/// Cooking, the fridge, and eating.
class CookService {
  CookService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  Future<DayClock> _clock() async {
    final p = await isar.userProfiles.get(1);
    return DayClock(rolloverHour: p?.dayRolloverHour ?? 4, weekStartsOn: p?.weekStartsOn ?? DateTime.monday);
  }

  static String _entryId(DateTime t) => t.microsecondsSinceEpoch.toString();

  Future<DailyLog> _logFor(int dateKey) async =>
      await isar.dailyLogs.getByDateKey(dateKey) ?? (DailyLog()..dateKey = dateKey);

  /// "I cooked this xN": deduct stock, open a fridge session, log the first portion.
  Future<CookResult> cook(int recipeId, int portions, {bool? autoLogFirst}) async {
    final t = now();
    final clock = await _clock();
    return isar.writeTxn(() async {
      final recipe = await isar.recipes.get(recipeId);
      if (recipe == null) throw StateError('Recipe $recipeId not found');
      final profile = await isar.userProfiles.get(1);
      final logFirst = autoLogFirst ?? profile?.autoLogFirstPortion ?? true;
      final stock = StockIndex(await isar.ingredients.where().findAll());
      final plan = DepletionEngine.plan(recipe.ingredients, portions, stock);
      final touched = DepletionEngine.apply(plan, stock, t);
      await isar.ingredients.putAll(touched);

      final session = CookSession()
        ..cookedAt = t
        ..recipeId = recipe.id
        ..recipeTitle = recipe.title
        ..portionsCooked = portions
        ..portionsRemaining = portions - (logFirst ? 1 : 0)
        ..perPortion = plan.perPortion
        ..costPerPortionMinor = plan.costPerPortionMinor
        ..deltas = plan.deltas
        ..fridgeExpiresAt = DayClock.addDays(t, recipe.fridgeLifeDays)
        ..status = CookStatus.active;
      if (session.portionsRemaining <= 0) session.status = CookStatus.finished;
      final sessionId = await isar.cookSessions.put(session);

      String? entryId;
      if (logFirst) {
        final log = await _logFor(clock.dateKey(t));
        entryId = _entryId(t);
        log.meals = [
          ...log.meals,
          MealEntry()
            ..entryId = entryId
            ..eatenAt = t
            ..source = MealSource.cookedNow
            ..cookSessionId = sessionId
            ..recipeId = recipe.id
            ..title = recipe.title
            ..portions = 1
            ..nutrition = plan.perPortion.copy()
            ..costMinor = plan.costPerPortionMinor,
        ];
        log.recomputeTotals();
        await isar.dailyLogs.put(log);
      }

      recipe
        ..timesCooked += 1
        ..lastCookedAt = t
        ..lastPortionsCooked = portions
        ..perPortion = plan.perPortion
        ..costPerPortionMinor = plan.costPerPortionMinor;
      if (recipe.status == RecipeStatus.suggested || recipe.status == RecipeStatus.dismissed) {
        recipe.status = RecipeStatus.saved;
      }
      await isar.recipes.put(recipe);
      return CookResult(sessionId, plan, entryId, session.portionsRemaining);
    });
  }

  /// Lossless undo of [cook]: stock back, meal entries removed, session undone.
  Future<void> undoCook(int sessionId) async {
    final t = now();
    await isar.writeTxn(() async {
      final s = await isar.cookSessions.get(sessionId);
      if (s == null || s.status == CookStatus.undone) return;
      final stock = StockIndex(await isar.ingredients.where().findAll());
      await isar.ingredients.putAll(DepletionEngine.revert(s.deltas, stock, t));
      final logs = await isar.dailyLogs.where().findAll();
      for (final log in logs) {
        if (log.meals.any((m) => m.cookSessionId == sessionId)) {
          log.meals = log.meals.where((m) => m.cookSessionId != sessionId).toList();
          log.recomputeTotals();
          await isar.dailyLogs.put(log);
        }
      }
      s.status = CookStatus.undone;
      s.portionsRemaining = 0;
      await isar.cookSessions.put(s);
      final recipe = await isar.recipes.get(s.recipeId);
      if (recipe != null && recipe.timesCooked > 0) {
        recipe.timesCooked -= 1;
        await isar.recipes.put(recipe);
      }
    });
  }

  /// Logs eating [portions] from a fridge session. Returns the meal entry id.
  Future<String?> eatPortion(int sessionId, {int portions = 1, DateTime? at}) async {
    final t = at ?? now();
    final clock = await _clock();
    return isar.writeTxn(() async {
      final s = await isar.cookSessions.get(sessionId);
      if (s == null || s.status != CookStatus.active || s.portionsRemaining <= 0) return null;
      final eaten = portions > s.portionsRemaining ? s.portionsRemaining : portions;
      s.portionsRemaining -= eaten;
      if (s.portionsRemaining == 0) s.status = CookStatus.finished;
      await isar.cookSessions.put(s);
      final log = await _logFor(clock.dateKey(t));
      final id = _entryId(t);
      log.meals = [
        ...log.meals,
        MealEntry()
          ..entryId = id
          ..eatenAt = t
          ..source = MealSource.fridge
          ..cookSessionId = s.id
          ..recipeId = s.recipeId
          ..title = s.recipeTitle
          ..portions = eaten.toDouble()
          ..nutrition = s.perPortion.scale(eaten.toDouble())
          ..costMinor = s.costPerPortionMinor * eaten,
      ];
      log.recomputeTotals();
      await isar.dailyLogs.put(log);
      return id;
    });
  }

  /// Something eaten straight from the pantry (a banana, a yogurt, a can of cola): taken out
  /// of stock and logged with its macros and cost. Returns the meal's entry id; [deleteMeal]
  /// puts the stock back.
  Future<String?> eatFromPantry(int ingredientId, double qty, {DateTime? at}) async {
    if (qty <= 0) return null;
    final t = at ?? now();
    final clock = await _clock();
    return isar.writeTxn(() async {
      final ing = await isar.ingredients.get(ingredientId);
      if (ing == null) return null;
      final had = ing.qtyOnHand;
      final taken = qty < had ? qty : had;
      ing
        ..qtyOnHand = had - taken
        ..updatedAt = t;
      ExpiryEstimator.onDeplete(ing);
      // Ate more than the pantry had: a purchase was missed, so the count is worth a check.
      if (qty > had + 1e-9) ing.lastVerifiedAt = null;
      await isar.ingredients.put(ing);
      final log = await _logFor(clock.dateKey(t));
      final id = _entryId(t);
      log.meals = [
        ...log.meals,
        MealEntry()
          ..entryId = id
          ..eatenAt = t
          ..source = MealSource.pantry
          ..title = ing.name
          ..portions = 1
          ..ingredientKey = ing.key
          ..qtyBase = taken
          ..nutrition = (ing.needsNutrition ? null : NutritionEngine.nutrientsFor(ing, qty)) ?? Nutrition()
          ..costMinor = (qty * ing.avgCostPerUnitMinor).round(),
      ];
      log.recomputeTotals();
      await isar.dailyLogs.put(log);
      await RecipeService.refreshUsing(isar, {ing.id});
      return id;
    });
  }

  Future<List<CookSession>> activeSessions() =>
      isar.cookSessions.where().statusEqualTo(CookStatus.active).sortByCookedAt().findAll();

  /// Notification action: eat from the oldest active batch.
  Future<String?> eatOldest() async {
    final active = await activeSessions();
    if (active.isEmpty) return null;
    return eatPortion(active.first.id);
  }

  /// Removes a meal entry; a fridge portion goes back to its session.
  Future<void> deleteMeal(int dateKey, String entryId) async {
    await isar.writeTxn(() async {
      final log = await isar.dailyLogs.getByDateKey(dateKey);
      if (log == null) return;
      final entry = log.meals.where((m) => m.entryId == entryId).firstOrNull;
      if (entry == null) return;
      log.meals = log.meals.where((m) => m.entryId != entryId).toList();
      log.recomputeTotals();
      await isar.dailyLogs.put(log);
      if (entry.cookSessionId != null && entry.source == MealSource.fridge) {
        final s = await isar.cookSessions.get(entry.cookSessionId!);
        if (s != null && s.status != CookStatus.undone) {
          s.portionsRemaining += entry.portions.round();
          s.status = CookStatus.active;
          await isar.cookSessions.put(s);
        }
      }
      // Eaten from the pantry: what it took out of stock goes back.
      if (entry.source == MealSource.pantry && entry.ingredientKey != null && (entry.qtyBase ?? 0) > 0) {
        final ing = await isar.ingredients.getByKey(entry.ingredientKey!);
        if (ing != null) {
          final before = ing.qtyOnHand;
          ing.qtyOnHand = before + entry.qtyBase!;
          if (before <= 0 && ing.lastPurchasedAt != null) {
            ing.expiresAt = DayClock.addDays(ing.lastPurchasedAt!, ing.shelfLifeDays);
          }
          await isar.ingredients.put(ing);
        }
      }
    });
  }

  Future<void> discardPortions(int sessionId, [int? n]) async {
    await isar.writeTxn(() async {
      final s = await isar.cookSessions.get(sessionId);
      if (s == null) return;
      final k = n == null || n > s.portionsRemaining ? s.portionsRemaining : n;
      s.portionsRemaining -= k;
      s.portionsDiscarded += k;
      if (s.portionsRemaining == 0) s.status = CookStatus.discarded;
      await isar.cookSessions.put(s);
    });
  }

  Future<void> extendFridge(int sessionId, int days) async {
    await isar.writeTxn(() async {
      final s = await isar.cookSessions.get(sessionId);
      if (s == null) return;
      final base = s.fridgeExpiresAt == null || s.fridgeExpiresAt!.isBefore(now()) ? now() : s.fridgeExpiresAt!;
      s.fridgeExpiresAt = DayClock.addDays(base, days);
      await isar.cookSessions.put(s);
    });
  }

  /// Something you ate that wasn't cooked from a recipe.
  Future<String> quickAddMeal({
    required String title,
    required double kcal,
    required double proteinG,
    double carbsG = 0,
    double fatG = 0,
    int costMinor = 0,
    DateTime? at,
  }) async {
    final t = at ?? now();
    final clock = await _clock();
    return isar.writeTxn(() async {
      final log = await _logFor(clock.dateKey(t));
      final id = _entryId(t);
      log.meals = [
        ...log.meals,
        MealEntry()
          ..entryId = id
          ..eatenAt = t
          ..source = MealSource.quickAdd
          ..title = title
          ..nutrition = Nutrition(kcal: kcal, proteinG: proteinG, carbsG: carbsG, fatG: fatG)
          ..costMinor = costMinor,
      ];
      log.recomputeTotals();
      await isar.dailyLogs.put(log);
      return id;
    });
  }
}
