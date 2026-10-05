// Redesign guard: Cook-side user flows driven through the UI, with their database
// effect asserted (cook, fridge, eat, recipe actions, onboarding and settings).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/features/capture/ate_sheet.dart';
import 'package:trackcalfin/features/capture/cooked_sheet.dart';
import 'package:trackcalfin/features/common/widgets.dart';
import 'package:trackcalfin/features/cook/cook_screen.dart';
import 'package:trackcalfin/features/cook/recipe_detail_screen.dart';

import '../support/app_harness.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final app = TestApp()..register();

  Future<Ingredient> ing(String key) async => (await app.isar.ingredients.getByKey(key))!;
  Future<Recipe> recipe(String title) async => (await app.isar.recipes.filter().titleEqualTo(title).findFirst())!;
  Future<CookSession> fridge() async =>
      (await app.isar.cookSessions.where().findAll()).firstWhere((s) => s.recipeTitle.startsWith('Red lentil'));
  Future<CookSession> newestSession() async =>
      (await app.isar.cookSessions.where().findAll()).reduce((a, b) => a.id > b.id ? a : b);
  Future<DailyLog?> today() async {
    final p = (await app.isar.userProfiles.get(1))!;
    return app.isar.dailyLogs.getByDateKey(ProfileService.clockFor(p).dateKey(DateTime.now()));
  }

  testWidgets("today's pick: the stepper sets how much is cooked; Undo puts the stock back", (tester) async {
    await app.pump(tester, initial: '/cook');
    final r = await recipe('Garlic chicken & spinach rice bowls');
    final chicken0 = (await ing('chicken_breast')).qtyOnHand;
    final perPortion = r.ingredients.firstWhere((i) => i.key == 'chicken_breast').qtyPerPortion;
    final meals0 = (await today())?.meals.length ?? 0;

    await tapAndSettle(tester, find.byTooltip('Fewer portions'));
    expect(find.descendant(of: find.byType(PortionStepper), matching: textCI('2')), findsOneWidget);
    await tapAndSettle(tester, textCI('I cooked this'), frames: 12);

    expect((await ing('chicken_breast')).qtyOnHand, chicken0 - 2 * perPortion);
    final s = await newestSession();
    expect(s.recipeId, r.id);
    expect(s.portionsCooked, 2);
    expect(s.portionsRemaining, 1, reason: 'first portion logged, the rest goes to the fridge');
    final log = (await today())!;
    expect(log.meals.length, meals0 + 1);
    expect(log.meals.last.source, MealSource.cookedNow);
    expect(log.meals.last.cookSessionId, s.id);

    await tapAndSettle(tester, textCI('Undo'));
    expect((await ing('chicken_breast')).qtyOnHand, chicken0);
    expect((await app.isar.cookSessions.get(s.id))!.status, CookStatus.undone);
    expect((await today())?.meals.length ?? 0, meals0);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('fridge: Eat 1 logs intake and takes a portion; Undo gives it back', (tester) async {
    await app.pump(tester, initial: '/cook');
    final s0 = await fridge();
    final log0 = (await today())!;

    await tapAndSettle(tester, textCI('Eat 1'));
    final s1 = (await app.isar.cookSessions.get(s0.id))!;
    expect(s1.portionsRemaining, s0.portionsRemaining - 1);
    final log1 = (await today())!;
    expect(log1.meals.length, log0.meals.length + 1);
    final eaten = log1.meals.last;
    expect(eaten.source, MealSource.fridge);
    expect(eaten.cookSessionId, s0.id);
    expect(eaten.portions, 1);
    expect(log1.totals.kcal, closeTo(log0.totals.kcal + s0.perPortion.kcal, 1e-6));
    expect(log1.foodCostMinor, log0.foodCostMinor + s0.costPerPortionMinor);
    expect(textWith('${log1.totals.proteinG.round()}', 'protein'), findsWidgets, reason: 'protein so far today');

    await tapAndSettle(tester, textCI('Undo'));
    expect((await app.isar.cookSessions.get(s0.id))!.portionsRemaining, s0.portionsRemaining);
    expect((await today())!.meals.length, log0.meals.length);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('fridge menu: "+2 days" extends the fridge date, "toss" discards the rest', (tester) async {
    await app.pump(tester, initial: '/cook');
    final s0 = await fridge();
    final menu = find.descendant(of: find.byType(CookScreen), matching: find.byType(PopupMenuButton<String>));

    await tapAndSettle(tester, menu);
    await tapAndSettle(tester, textHas('+2'));
    final extended = (await fridge()).fridgeExpiresAt!;
    expect(extended.isAtSameMomentAs(DayClock.addDays(s0.fridgeExpiresAt!, 2)), isTrue, reason: '$extended');

    await tapAndSettle(tester, menu);
    await tapAndSettle(tester, textHas('toss'));
    final s2 = (await app.isar.cookSessions.get(s0.id))!;
    expect(s2.status, CookStatus.discarded);
    expect(s2.portionsRemaining, 0);
    expect(s2.portionsDiscarded, s0.portionsRemaining);
    expect(textCI('Eat 1'), findsNothing, reason: 'empty fridge hides the strip');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail: favorite toggles; delete pops back and Undo restores', (tester) async {
    await app.pump(tester, initial: '/cook');
    final salmon = await recipe('Salmon traybake');
    expect(salmon.favorite, isFalse);
    await scrollTo(tester, textExact('Salmon traybake'));
    await tapAndSettle(tester, textExact('Salmon traybake'));
    expect(find.byType(RecipeDetailScreen), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Favorite'));
    expect((await app.isar.recipes.get(salmon.id))!.favorite, isTrue);
    expect(find.byTooltip('Remove favorite'), findsOneWidget);

    final menu = find.descendant(of: find.byType(RecipeDetailScreen), matching: find.byType(PopupMenuButton<String>));
    await tapAndSettle(tester, menu);
    await tapAndSettle(tester, textCI('Delete'));
    expect(await app.isar.recipes.get(salmon.id), isNull);
    expect(find.byType(RecipeDetailScreen), findsNothing, reason: 'delete pops back to Cook');
    expect(find.byType(CookScreen), findsOneWidget);

    await tapAndSettle(tester, textCI('Undo'));
    expect((await app.isar.recipes.get(salmon.id))!.title, 'Salmon traybake');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail: cook 3 portions with the stepper; long-press a row to mark it out', (tester) async {
    await app.pump(tester, initial: '/cook');
    final r = await recipe('Lighter bacon carbonara');
    final pasta0 = (await ing('dry_pasta')).qtyOnHand;
    await scrollTo(tester, textExact(r.title));
    await tapAndSettle(tester, textExact(r.title));
    final detail = find.byType(RecipeDetailScreen);

    await tapAndSettle(tester, find.descendant(of: detail, matching: find.byTooltip('More portions')));
    await tapAndSettle(tester, find.descendant(of: detail, matching: textCI('I cooked this')), frames: 12);
    final perPortion = r.ingredients.firstWhere((i) => i.key == 'dry_pasta').qtyPerPortion;
    expect((await ing('dry_pasta')).qtyOnHand, pasta0 - 3 * perPortion);
    final s = await newestSession();
    expect(s.recipeId, r.id);
    expect(s.portionsCooked, 3);

    final row = find.descendant(of: detail, matching: textExact('Grana Padano'));
    await scrollTo(tester, row);
    await tester.longPress(row);
    await settle(tester, frames: 8);
    await tapAndSettle(tester, textHas('out of Grana Padano'));
    expect((await ing('grana_padano')).qtyOnHand, 0);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('capture: "I cooked" sheet cooks the tapped recipe at the stepper portions', (tester) async {
    await app.pump(tester);
    final p = (await app.isar.userProfiles.get(1))!;
    final dal = await recipe('Red lentil & chickpea dal');
    final lentils0 = (await ing('red_lentils')).qtyOnHand;
    await tapAndSettle(tester, find.byTooltip('Log something'));
    await tapAndSettle(tester, textCI('I cooked'));
    final sheet = find.byType(CookedSheet);
    expect(find.descendant(of: sheet, matching: textCI('${p.defaultPortions}')), findsOneWidget);
    await tapAndSettle(tester, find.descendant(of: sheet, matching: find.byTooltip('More portions')));
    await tapAndSettle(tester, find.descendant(of: sheet, matching: textExact(dal.title)), frames: 12);

    expect(find.byType(CookedSheet), findsNothing);
    final s = await newestSession();
    expect(s.recipeId, dal.id);
    expect(s.portionsCooked, p.defaultPortions + 1);
    final per = dal.ingredients.firstWhere((i) => i.key == 'red_lentils').qtyPerPortion;
    expect((await ing('red_lentils')).qtyOnHand, lentils0 - (p.defaultPortions + 1) * per);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('dashboard: "+ Meal" logs a hand-entered meal; the Today card updates; Undo removes it', (tester) async {
    await app.pump(tester);
    final log0 = (await today())!;
    await tapAndSettle(tester, textCI('Meal'));
    final sheet = find.byType(AteSheet);
    await tapAndSettle(tester, find.descendant(of: sheet, matching: textHas('something else')));
    await tester.enterText(find.descendant(of: sheet, matching: fieldLabelled('what')), 'Kebab');
    await tester.enterText(find.descendant(of: sheet, matching: fieldLabelled('kcal')), '650');
    await tester.enterText(find.descendant(of: sheet, matching: fieldLabelled('protein')), '35');
    await tester.enterText(find.descendant(of: sheet, matching: fieldLabelled('cost')), '8.50');
    await tapAndSettle(tester, find.descendant(of: sheet, matching: textHas('log meal')), frames: 12);

    expect(find.byType(AteSheet), findsNothing);
    final log1 = (await today())!;
    final m = log1.meals.last;
    expect(log1.meals.length, log0.meals.length + 1);
    expect(m.title, 'Kebab');
    expect(m.source, MealSource.quickAdd);
    expect(m.nutrition.kcal, 650);
    expect(m.nutrition.proteinG, 35);
    expect(m.costMinor, 850);
    expect(value('${log1.totals.kcal.round()}'), findsWidgets, reason: 'Today card shows the new total');

    await tapAndSettle(tester, textCI('Undo'));
    expect((await today())!.meals.length, log0.meals.length);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('settings: number, money, switch and theme edits are saved to the profile', (tester) async {
    await app.pump(tester, initial: '/settings');
    Future<UserProfile> profile() async => (await app.isar.userProfiles.get(1))!;
    Future<void> prompt(String tile, String text) async {
      await scrollTo(tester, textCI(tile));
      await tapAndSettle(tester, textCI(tile));
      await tester.enterText(find.byType(TextField), text);
      await tapAndSettle(tester, textCI('Save'));
    }

    await prompt('Daily calories', '2000');
    expect((await profile()).dailyKcalTarget, 2000);
    await prompt('Monthly food budget', '250');
    expect((await profile()).monthlyFoodBudgetMinor, 25000);
    final m = ProfileService.moneyFor(await profile());
    expect(value(m.compact((25000 / 4.33).round())), findsWidgets, reason: 'weekly budget follows');
    await prompt('Meals per day', '20');
    expect((await profile()).mealsPerDay, 8, reason: 'clamped to 1..8');

    await scrollTo(tester, textCI('Sunday recap'));
    await tapAndSettle(tester, textCI('Sunday recap'));
    expect((await profile()).weeklyRecapEnabled, isFalse);
    await scrollTo(tester, textCI('Dark'));
    await tapAndSettle(tester, textCI('Dark'));
    expect((await profile()).themeMode, 'dark');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('onboarding: goals, staples and rhythm are saved; Start lands on Cook', (tester) async {
    await app.pump(tester, demo: false);
    await tapAndSettle(tester, textCI('Get started'));
    await tester.enterText(fieldLabelled('budget'), '250');
    await tester.enterText(fieldLabelled('calories'), '2000');
    await tester.enterText(fieldLabelled('protein'), '120');
    await tapAndSettle(tester, textCI('Next'));
    final p1 = (await app.isar.userProfiles.get(1))!;
    expect(p1.monthlyFoodBudgetMinor, 25000);
    expect(p1.dailyKcalTarget, 2000);
    expect(p1.dailyProteinTargetG, 120);

    await tapAndSettle(tester, textCI('Next')); // staples (defaults)
    final staples = await app.isar.ingredients.filter().trackingModeEqualTo(TrackingMode.staple).findAll();
    expect(staples, isNotEmpty);
    expect(staples.every((s) => s.needsNutrition), isTrue, reason: 'staple macros start unknown');

    await tapAndSettle(tester, textCI('Next')); // API key (skipped)
    await tapAndSettle(tester, textCI('Next')); // pantry sweep (skipped)
    await tapAndSettle(tester, textCI('Start'), frames: 12);
    final p2 = (await app.isar.userProfiles.get(1))!;
    expect(p2.onboardingDone, isTrue);
    expect(p2.defaultPortions, 3, reason: 'rhythm page default');
    expect(p2.dailyPickMinuteOfDay, 450);
    expect(find.byType(CookScreen), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
