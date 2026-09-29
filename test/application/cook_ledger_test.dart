import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/cook_service.dart';
import 'package:trackcalfin/application/ledger_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/recipe_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

import '../support/test_db.dart';

void main() {
  late Isar isar;
  var clockNow = DateTime(2026, 9, 28, 19);
  DateTime now() => clockNow;

  setUp(() async {
    isar = await openTestDb();
    await ProfileService(isar).load();
    clockNow = DateTime(2026, 9, 28, 19);
  });
  tearDown(() => closeTestDb(isar));

  Future<int> seedRecipe() async {
    final pantry = PantryService(isar, now: now);
    await pantry.upsert(Ingredient()
      ..name = 'Chicken breast'
      ..qtyOnHand = 650
      ..avgCostPerUnitMinor = 1.0
      ..per100 = Nutrition(kcal: 110, proteinG: 23));
    await pantry.upsert(Ingredient()
      ..name = 'White rice'
      ..qtyOnHand = 1000
      ..avgCostPerUnitMinor = 0.2
      ..shelfLifeDays = 365
      ..per100 = Nutrition(kcal: 360, proteinG: 7));
    final r = Recipe()
      ..title = 'Chicken rice'
      ..defaultPortions = 3
      ..ingredients = [
        RecipeIngredient()
          ..key = 'chicken_breast'
          ..qtyPerPortion = 180,
        RecipeIngredient()
          ..key = 'white_rice'
          ..qtyPerPortion = 100,
      ];
    return RecipeService(isar, now: now).save(r);
  }

  test('cook x3 -> stock down, fridge has 2, first portion logged; eat; undo', () async {
    final recipeId = await seedRecipe();
    final cook = CookService(isar, now: now);
    final res = await cook.cook(recipeId, 3);
    expect(res.portionsInFridge, 2);
    expect(res.plan.costPerPortionMinor, 180 + 20);

    final chicken = await isar.ingredients.getByKey('chicken_breast');
    expect(chicken!.qtyOnHand, 650 - 540);
    final log = await isar.dailyLogs.getByDateKey(20260928);
    expect(log!.mealsCount, 1);
    expect(log.totals.proteinG, closeTo(41.4 + 7, 1e-9));
    expect(log.foodCostMinor, 200);

    // Next day lunch
    clockNow = DateTime(2026, 9, 29, 12, 30);
    final entry = await cook.eatOldest();
    expect(entry, isNotNull);
    final s = await isar.cookSessions.get(res.sessionId);
    expect(s!.portionsRemaining, 1);
    expect((await isar.dailyLogs.getByDateKey(20260929))!.mealsCount, 1);

    // Delete that meal: the portion returns to the fridge
    await cook.deleteMeal(20260929, entry!);
    expect((await isar.cookSessions.get(res.sessionId))!.portionsRemaining, 2);

    // Invariant: remaining + discarded + eaten == cooked
    await cook.discardPortions(res.sessionId, 1);
    final s2 = (await isar.cookSessions.get(res.sessionId))!;
    final eaten = (await isar.dailyLogs.where().findAll())
        .expand((l) => l.meals)
        .where((m) => m.cookSessionId == res.sessionId)
        .fold<double>(0, (a, m) => a + m.portions);
    expect(s2.portionsRemaining + s2.portionsDiscarded + eaten, 3);

    await cook.undoCook(res.sessionId);
    expect((await isar.ingredients.getByKey('chicken_breast'))!.qtyOnHand, 650);
    expect((await isar.dailyLogs.getByDateKey(20260928))!.mealsCount, 0);
    expect((await isar.recipes.get(recipeId))!.timesCooked, 0);
  });

  test('shortfall sets stock to 0 and flags for Quick Check', () async {
    final recipeId = await seedRecipe();
    await CookService(isar, now: now).cook(recipeId, 4);
    final chicken = (await isar.ingredients.getByKey('chicken_breast'))!;
    expect(chicken.qtyOnHand, 0);
    expect(chicken.lastVerifiedAt, isNull);
    expect(chicken.expiresAt, isNull);
  });

  test('quick add meal logs to the logical day (rollover at 04:00)', () async {
    clockNow = DateTime(2026, 9, 29, 0, 30);
    await CookService(isar, now: now).quickAddMeal(title: 'Toast', kcal: 250, proteinG: 8);
    expect((await isar.dailyLogs.getByDateKey(20260928))!.totals.kcal, 250);
  });

  test('quick expense, keyword learning, delete and restore', () async {
    final ledger = LedgerService(isar, now: now);
    final id = await ledger.logQuickExpense(
      amountMinor: 1250,
      category: SpendCategory.eatingOut,
      note: 'ramen',
      learnKeyword: 'ramen',
    );
    final p = (await isar.userProfiles.get(1))!;
    expect(p.learnedKeywords.single.keyword, 'ramen');
    final tx = await ledger.delete(id);
    expect(await isar.transactions.count(), 0);
    await ledger.restore(tx!);
    expect((await isar.transactions.get(id))!.totalMinor, 1250);
  });

  test('manual purchase updates WAC and writes the ledger in one go; delete takes stock back', () async {
    final pantry = PantryService(isar, now: now);
    final id = await pantry.upsert(Ingredient()
      ..name = 'Milk'
      ..baseUnit = BaseUnit.ml
      ..qtyOnHand = 0);
    final ledger = LedgerService(isar, now: now);
    final txId = await ledger.applyManualPurchase(ingredientId: id, qty: 1000, totalMinor: 109);
    final milk = (await isar.ingredients.get(id))!;
    expect(milk.qtyOnHand, 1000);
    expect(milk.avgCostPerUnitMinor, closeTo(0.109, 1e-9));
    expect((await isar.transactions.get(txId))!.lines.single.qtyBase, 1000);
    await ledger.delete(txId);
    expect((await isar.ingredients.get(id))!.qtyOnHand, 0);
  });

  test('slugify and unique keys', () async {
    expect(PantryService.slugify('Greek yogurt 10%'), 'greek_yogurt');
    expect(PantryService.slugify('Crème fraîche'), 'creme_fraiche');
    expect(PantryService.slugify('123'), 'item');
    final pantry = PantryService(isar, now: now);
    await pantry.upsert(Ingredient()..name = 'Egg');
    final id2 = await pantry.upsert(Ingredient()..name = 'Egg');
    expect((await isar.ingredients.get(id2))!.key, 'egg_2');
  });
}
