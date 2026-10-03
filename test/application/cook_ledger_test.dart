import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/cook_service.dart';
import 'package:trackcalfin/application/daily_pick_service.dart';
import 'package:trackcalfin/application/habit_scheduler.dart';
import 'package:trackcalfin/application/ledger_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/recipe_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/platform/notifications.dart';
import 'package:trackcalfin/platform/secret_store.dart';

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
    await pantry.upsert(
      Ingredient()
        ..name = 'Chicken breast'
        ..qtyOnHand = 650
        ..avgCostPerUnitMinor = 1.0
        ..per100 = Nutrition(kcal: 110, proteinG: 23),
    );
    await pantry.upsert(
      Ingredient()
        ..name = 'White rice'
        ..qtyOnHand = 1000
        ..avgCostPerUnitMinor = 0.2
        ..shelfLifeDays = 365
        ..per100 = Nutrition(kcal: 360, proteinG: 7),
    );
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
    final id = await pantry.upsert(
      Ingredient()
        ..name = 'Milk'
        ..baseUnit = BaseUnit.ml
        ..qtyOnHand = 0,
    );
    final ledger = LedgerService(isar, now: now);
    final txId = await ledger.applyManualPurchase(ingredientId: id, qty: 1000, totalMinor: 109);
    final milk = (await isar.ingredients.get(id))!;
    expect(milk.qtyOnHand, 1000);
    expect(milk.avgCostPerUnitMinor, closeTo(0.109, 1e-9));
    expect((await isar.transactions.get(txId))!.lines.single.qtyBase, 1000);
    await ledger.delete(txId);
    expect((await isar.ingredients.get(id))!.qtyOnHand, 0);
  });

  test('a count that finds less records what went as eaten since the last count; it can be thrown away', () async {
    final pantry = PantryService(isar, now: now);
    final oats = await pantry.upsert(
      Ingredient()
        ..name = 'Oats'
        ..key = 'oats'
        ..qtyOnHand = 1000
        ..avgCostPerUnitMinor = 0.2,
    );
    clockNow = DateTime(2026, 10, 5, 9);
    final useId = await pantry.setQuantity(oats, 250);
    final use = (await isar.foodUses.get(useId!))!;
    expect((use.qtyBase, use.costMinor, use.kind), (750.0, 150, UseKind.eaten));
    expect((use.from, use.to), (DateTime(2026, 9, 28, 19), DateTime(2026, 10, 5, 9)), reason: 'since it was counted');
    await pantry.setUseKind(useId, UseKind.thrownAway);
    expect((await isar.foodUses.get(useId))!.kind, UseKind.thrownAway);
    expect(await pantry.setQuantity(oats, 400), isNull, reason: 'more than before: nothing went');
    // Right after the count, going back up is a correction: the use shrinks by as much.
    expect(((await isar.foodUses.get(useId))!.qtyBase, (await isar.foodUses.get(useId))!.costMinor), (600.0, 120));

    // Marked out by mistake and undone: nothing counts as eaten.
    final outId = await pantry.markOut(oats);
    await pantry.setQuantity(oats, 400);
    expect(await isar.foodUses.get(outId!), isNull);

    // Later on, more is just more: what went before stays eaten.
    clockNow = DateTime(2026, 10, 5, 9, 10);
    await pantry.setQuantity(oats, 900);
    expect((await isar.foodUses.get(useId))!.qtyBase, 600);
  });

  test('eating straight from the pantry: stock out, macros and cost logged; deleting puts it back', () async {
    final pantry = PantryService(isar, now: now);
    final banana = await pantry.upsert(
      Ingredient()
        ..name = 'Banana'
        ..baseUnit = BaseUnit.pc
        ..gramsPerPiece = 120
        ..qtyOnHand = 3
        ..avgCostPerUnitMinor = 25
        ..per100 = Nutrition(kcal: 89, proteinG: 1.1)
        ..nutritionSource = DataSource.aiEstimate,
    );
    final cook = CookService(isar, now: now);
    final id = (await cook.eatFromPantry(banana, 1))!;
    expect((await isar.ingredients.get(banana))!.qtyOnHand, 2);
    final log = (await isar.dailyLogs.getByDateKey(20260928))!;
    final meal = log.meals.single;
    expect((meal.source, meal.title, meal.ingredientKey, meal.qtyBase), (MealSource.pantry, 'Banana', 'banana', 1.0));
    expect(meal.nutrition.kcal, closeTo(106.8, 0.01), reason: '120 g at 89 kcal per 100 g');
    expect((meal.costMinor, log.foodCostMinor), (25, 25));

    await cook.deleteMeal(20260928, id);
    expect((await isar.ingredients.get(banana))!.qtyOnHand, 3);
    expect((await isar.dailyLogs.getByDateKey(20260928))!.meals, isEmpty);

    // More than the pantry had: all of it goes, and the count is worth a check.
    await cook.eatFromPantry(banana, 5);
    final after = (await isar.ingredients.get(banana))!;
    expect((after.qtyOnHand, after.lastVerifiedAt), (0, null));
  });

  test('undo of a deleted purchase puts back what the delete took, not the whole line', () async {
    final pantry = PantryService(isar, now: now);
    final id = await pantry.upsert(
      Ingredient()
        ..name = 'Milk'
        ..baseUnit = BaseUnit.ml,
    );
    final ledger = LedgerService(isar, now: now);
    final txId = await ledger.applyManualPurchase(ingredientId: id, qty: 1000, totalMinor: 109);
    await CookService(isar, now: now).eatFromPantry(id, 800);
    final removed = await ledger.delete(txId);
    expect((await isar.ingredients.get(id))!.qtyOnHand, 0, reason: 'only 200 ml were left to take');
    await ledger.restore(removed!);
    final milk = (await isar.ingredients.get(id))!;
    expect((milk.qtyOnHand, milk.expiresAt), (200.0, DateTime(2026, 10, 5, 19)));
  });

  test('deleting a purchase takes its price out of the weighted average; undo puts it back', () async {
    final pantry = PantryService(isar, now: now);
    final id = await pantry.upsert(
      Ingredient()
        ..name = 'Chicken breast'
        ..qtyOnHand = 500
        ..avgCostPerUnitMinor = 1.0,
    );
    final ledger = LedgerService(isar, now: now);
    // A typo: 50.00 instead of 5.00 for 500 g.
    final txId = await ledger.applyManualPurchase(ingredientId: id, qty: 500, totalMinor: 5000);
    expect((await isar.ingredients.get(id))!.avgCostPerUnitMinor, closeTo(5.5, 1e-9));
    final removed = await ledger.delete(txId);
    final after = (await isar.ingredients.get(id))!;
    expect(after.qtyOnHand, 500);
    expect(after.avgCostPerUnitMinor, closeTo(1.0, 1e-9), reason: 'the typo no longer prices the chicken');
    await ledger.restore(removed!);
    final back = (await isar.ingredients.get(id))!;
    expect(back.qtyOnHand, 1000);
    expect(back.avgCostPerUnitMinor, closeTo(5.5, 1e-9));
  });

  test('undoing a cook puts the recipe and the Quick Check flag back as they were', () async {
    final recipeId = await seedRecipe();
    await isar.writeTxn(() async {
      final r = (await isar.recipes.get(recipeId))!;
      await isar.recipes.put(r..status = RecipeStatus.suggested);
    });
    final before = (await isar.recipes.get(recipeId))!;
    final cook = CookService(isar, now: now);
    final res = await cook.cook(recipeId, 4); // 720 g of chicken wanted, 650 there: a shortfall
    expect((await isar.ingredients.getByKey('chicken_breast'))!.lastVerifiedAt, isNull);
    await cook.undoCook(res.sessionId);
    final r = (await isar.recipes.get(recipeId))!;
    expect(
      (r.status, r.timesCooked, r.lastCookedAt, r.lastPortionsCooked, r.costPerPortionMinor),
      (RecipeStatus.suggested, 0, null, 0, before.costPerPortionMinor),
    );
    final chicken = (await isar.ingredients.getByKey('chicken_breast'))!;
    expect((chicken.qtyOnHand, chicken.lastVerifiedAt), (650.0, DateTime(2026, 9, 28, 19)));
    expect(chicken.expiresAt, DateTime(2026, 10, 5, 19));
  });

  test('deleting the portion logged right after cooking puts it in the fridge', () async {
    final recipeId = await seedRecipe();
    final cook = CookService(isar, now: now);
    final res = await cook.cook(recipeId, 1);
    expect((await isar.cookSessions.get(res.sessionId))!.status, CookStatus.finished);
    await cook.deleteMeal(20260928, res.autoLoggedEntryId!);
    final s = (await isar.cookSessions.get(res.sessionId))!;
    expect((s.portionsRemaining, s.status), (1, CookStatus.active));
  });

  test("a pick still from yesterday (before the rollover) isn't announced for this morning", () async {
    clockNow = DateTime(2026, 9, 29, 1, 30); // the logical day is still 28 Sep
    final sent = _SentNotifications();
    final scheduler = HabitScheduler(
      isar: isar,
      picks: DailyPickService(
        isar: isar,
        ai: AiGateway(isar: isar, secrets: MemorySecretStore(), prompts: PromptRepository((_) async => '')),
      ),
      notifications: sent,
      now: now,
    );
    await scheduler.scheduleTodayPick(
      Recipe()
        ..title = 'Old'
        ..suggestedForDateKey = 20260928,
    );
    expect(sent.picks, isEmpty);
    await scheduler.scheduleTodayPick(
      Recipe()
        ..title = 'New'
        ..suggestedForDateKey = 20260929,
    );
    expect(sent.picks, [(DateTime(2026, 9, 29, 7, 30), 'Today: New')]);
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

/// Records the daily pick notifications instead of scheduling them.
class _SentNotifications implements Notifications {
  final picks = <(DateTime, String)>[];

  @override
  Future<void> scheduleDailyPick({required DateTime at, required String title, required String body}) async =>
      picks.add((at, title));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}
