// Redesign guard: the numbers on screen are the numbers lib/domain computes.
//
// Expected values come from the same domain functions the app uses, evaluated in the
// test (DemoSeed is relative to DateTime.now()). Assertions check that each formatted
// value is shown somewhere on the screen, not where or how it is styled.
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/currency.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/costing.dart';
import 'package:trackcalfin/domain/feasibility.dart';
import 'package:trackcalfin/domain/nutrition.dart';
import 'package:trackcalfin/domain/stock_index.dart';
import 'package:trackcalfin/domain/units.dart';
import 'package:trackcalfin/features/common/widgets.dart';

import '../support/app_harness.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final app = TestApp()..register();

  Future<UserProfile> profile() async => (await app.isar.userProfiles.get(1))!;
  Future<MoneyFormat> money() async => ProfileService.moneyFor(await profile());
  Future<Recipe> recipe(String title) async => (await app.isar.recipes.filter().titleEqualTo(title).findFirst())!;
  Future<StockIndex> stock() async => StockIndex(await app.isar.ingredients.where().findAll());

  testWidgets('dashboard shows what DashboardAggregator, VibeScorer and the streak compute', (tester) async {
    await app.pump(tester, tall: true);
    final now = DateTime.now();
    final p = await profile();
    final m = ProfileService.moneyFor(p);
    final todayKey = ProfileService.clockFor(p).dateKey(now);
    final pick = (await app.isar.recipes.where().suggestedForDateKeyEqualTo(todayKey).findAll()).firstOrNull;
    final view = await loadDashboard(app.isar, now, pick: pick);
    final s = view.state;

    // Vibe
    expect(view.vibe.score, isNotNull);
    expect(value('${view.vibe.score}'), findsWidgets, reason: 'vibe score');
    expect(textHas(view.vibe.label), findsWidgets, reason: 'vibe label');
    expect(textHas(view.vibe.insight), findsOneWidget, reason: 'vibe insight line');

    // Today: intake vs targets, rings in percent
    final kcalT = p.dailyKcalTarget;
    final protT = p.dailyProteinTargetG;
    expect(value('${s.today.kcal.round()}'), findsWidgets, reason: 'kcal eaten today');
    expect(value('${(s.today.kcal / kcalT * 100).round()}%'), findsWidgets, reason: 'kcal ring %');
    expect(value('${kcalT.round()}'), findsWidgets, reason: 'kcal target');
    expect(value('${s.today.proteinG.round()} g'), findsWidgets, reason: 'protein eaten today');
    expect(value('${(s.today.proteinG / protT * 100).round()}%'), findsWidgets, reason: 'protein ring %');
    expect(value('${protT.round()} g'), findsWidgets, reason: 'protein target');

    // Food spend: week and month vs budget (budget / 4.33), pace, ×4.33 projection
    expect(s.weeklyBudget, (p.monthlyFoodBudgetMinor / 4.33).round());
    for (final v in [s.weekFood, s.weeklyBudget, s.monthFood, s.monthlyBudget]) {
      expect(value(m.compact(v)), findsWidgets, reason: 'food spend ${m.compact(v)}');
    }
    for (final pace in [s.weekPace, s.monthPace]) {
      if (pace != null && pace > 1) {
        expect(value('${((pace - 1) * 100).round()}%'), findsWidgets, reason: 'pace pill % ahead');
      }
    }
    expect(s.collectingData, isFalse, reason: 'demo data has five weeks of history');
    expect(s.projectedMonth, (s.trailingWeekly * 4.33).round());
    expect(value(m.compact(s.projectedMonth!)), findsWidgets, reason: 'projected month');
    expect(value(m.compact(s.eatenWeek)), findsWidgets, reason: 'eaten this week');
    if (s.costPerMeal != null) expect(value(m.compact(s.costPerMeal!)), findsWidgets, reason: 'per home meal');
    if ((s.savedVsOut ?? 0) > 0) expect(value(m.compact(s.savedVsOut!)), findsWidgets, reason: 'saved vs out');

    // Other spend: spent / limit per category this month
    for (final c in s.nonFood.where((c) => c.limitMinor > 0 || c.spentMinor > 0)) {
      expect(textHas(c.category.label), findsWidgets, reason: 'other spend row ${c.category.label}');
      expect(value(m.format(c.spentMinor, whole: true)), findsWidgets, reason: '${c.category.label} spent');
      if (c.limitMinor > 0) {
        expect(value(m.format(c.limitMinor, whole: true)), findsWidgets, reason: '${c.category.label} limit');
      }
    }

    // Week: average of completed days (or last week), coverage, streak
    expect(s.avgKcal, isNotNull);
    expect(value(NumberFormat.decimalPattern().format(s.avgKcal!.round())), findsWidgets, reason: 'avg kcal');
    expect(value('${s.avgProtein!.round()} g'), findsWidgets, reason: 'avg protein');
    if (s.coverage != null) {
      expect(textWith('${s.completedDays}', 'logged'), findsWidgets, reason: 'days logged');
      expect(textWith('${s.elapsedDays}', 'logged'), findsWidgets, reason: 'days elapsed');
    }
    if (view.streak.days >= 2) {
      expect(textWith('${view.streak.days}', 'streak'), findsOneWidget, reason: 'streak');
    }
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets("today's pick, fridge and cook-again show Dart-computed cost, macros and feasibility", (tester) async {
    await app.pump(tester, initial: '/cook', tall: true);
    final m = await money();
    final st = await stock();
    final r = await recipe('Garlic chicken & spinach rice bowls');

    // LLM proposes, Dart disposes: the stored numbers are NutritionEngine's.
    final numbers = NutritionEngine.compute(r.ingredients, st);
    expect(numbers.costPerPortionMinor, r.costPerPortionMinor);
    expect(numbers.perPortion.kcal, closeTo(r.perPortion.kcal, 1e-6));

    expect(textHas(r.title), findsWidgets);
    expect(value(m.format(r.costPerPortionMinor)), findsWidgets, reason: 'cost per portion');
    expect(value('${r.perPortion.kcal.round()}'), findsWidgets, reason: 'kcal per portion');
    expect(value('${r.perPortion.proteinG.round()} g'), findsWidgets, reason: 'protein per portion');
    expect(r.totalMinutes, lessThan(60));
    expect(value('${r.totalMinutes} min'), findsWidgets, reason: 'total time');

    final portions = r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions;
    final f = FeasibilityChecker.check(r.ingredients, portions, st);
    expect(f.ready, isTrue);
    expect(find.descendant(of: find.byType(PortionStepper), matching: textCI('$portions')), findsOneWidget);
    expect(textWith('${f.maxPortionsNow}', 'max'), findsOneWidget, reason: 'stepper max hint');

    // Fridge
    final s = (await app.isar.cookSessions.where().statusEqualTo(CookStatus.active).findAll()).single;
    expect(textWith('${s.portionsRemaining}', 'left'), findsWidgets, reason: 'portions left');
    expect(value('${s.perPortion.proteinG.round()} g'), findsWidgets, reason: 'fridge protein per portion');
    final daysLeft = (s.fridgeExpiresAt!.difference(DateTime.now()).inHours / 24).ceil();
    expect(value('$daysLeft d'), findsWidgets, reason: 'fridge days left');

    // Cook again: feasibility per recipe at its last-cooked portions
    for (final title in ['Red lentil & chickpea dal', 'Lighter bacon carbonara', 'Salmon traybake']) {
      final x = await recipe(title);
      final fx = FeasibilityChecker.check(
        x.ingredients,
        x.lastPortionsCooked > 0 ? x.lastPortionsCooked : x.defaultPortions,
        st,
      );
      expect(textHas(title), findsWidgets);
      if (fx.ready) {
        expect(textWith('${fx.maxPortionsNow}', 'portion'), findsWidgets, reason: '$title: ready, max portions');
      } else {
        expect(textHas(fx.missing.isNotEmpty ? fx.missing.first : fx.shortfalls.first.item.name), findsWidgets);
      }
    }
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail: per-portion numbers, ingredient totals and stock follow the stepper', (tester) async {
    await app.pump(tester, initial: '/cook');
    final st0 = await stock();
    await scrollTo(tester, find.text('Lighter bacon carbonara'));
    await tapAndSettle(tester, find.text('Lighter bacon carbonara'));
    final m = await money();
    final r = await recipe('Lighter bacon carbonara');

    expect(value(m.format(r.costPerPortionMinor)), findsWidgets, reason: 'cost');
    expect(value('${r.perPortion.kcal.round()}'), findsWidgets, reason: 'kcal');
    for (final g in [r.perPortion.proteinG, r.perPortion.carbsG, r.perPortion.fatG]) {
      expect(value('${g.round()} g'), findsWidgets, reason: 'macro grams');
    }
    expect(value('${r.totalMinutes} min'), findsWidgets);
    expect(value('${r.fridgeLifeDays} d'), findsWidgets, reason: 'keeps in fridge');

    var portions = r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions;
    final f = FeasibilityChecker.check(r.ingredients, portions, st0);
    expect(f.ready, isTrue);
    expect(r.feasibilityStatus, 'ready_with_swaps');
    expect(textHas('swaps'), findsWidgets, reason: 'verdict: ready with swaps');
    expect(textHas(r.sourceQuery!), findsWidgets, reason: 'the question that produced it');

    void expectRows(int n) {
      for (final ri in r.ingredients) {
        expect(textHas(ri.name), findsWidgets, reason: ri.name);
        expect(value(UnitConverter.format(ri.qtyPerPortion * n, ri.unit)), findsWidgets, reason: '${ri.name} × $n');
        final ing = st0.resolve(ri);
        if (ri.role == IngredientRole.stock && ing != null) {
          expect(value(UnitConverter.format(ing.qtyOnHand, ing.baseUnit)), findsWidgets, reason: '${ri.name} on hand');
        }
        if ((ri.substitutesFor ?? '').isNotEmpty) expect(textHas(ri.substitutesFor!), findsWidgets);
      }
    }

    expectRows(portions);
    await scrollTo(tester, find.byTooltip('More portions'));
    await tapAndSettle(tester, find.byTooltip('More portions'));
    portions++;
    expect(find.descendant(of: find.byType(PortionStepper), matching: textCI('$portions')), findsOneWidget);
    await scrollTo(tester, textHas(r.ingredients.first.name));
    expectRows(portions);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('pantry and ledger show stock value, quantities, days left and per-filter totals', (tester) async {
    await app.pump(tester, initial: '/buy', tall: true);
    final m = await money();
    final now = DateTime.now();
    final all = await app.isar.ingredients.where().findAll();

    final chicken = all.firstWhere((i) => i.key == 'chicken_breast');
    expect(value(m.compact((chicken.qtyOnHand * chicken.avgCostPerUnitMinor).round())), findsWidgets);
    expect(value(UnitConverter.format(chicken.qtyOnHand, chicken.baseUnit)), findsWidgets);
    for (final ing in all.where((i) => ExpiryEstimator.useSoon(i, now))) {
      final d = ExpiryEstimator.daysLeft(ing, now)!;
      expect(textHas(ing.name), findsWidgets);
      expect(d > 0 ? textWith('$d', 'day') : textHas('today'), findsWidgets, reason: '${ing.name} days left');
    }
    for (final ing in all.where((i) => i.isLow)) {
      expect(value(UnitConverter.format(ing.qtyOnHand, ing.baseUnit)), findsWidgets, reason: '${ing.name} low');
    }

    await tapAndSettle(tester, textCI('Ledger'));
    final txs = await app.isar.transactions.where().findAll();
    final byDay = groupBy(txs, (Transaction t) => DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day));
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final d in days.take(3)) {
      final total = byDay[d]!.fold(0, (a, t) => a + t.totalMinor);
      expect(value(m.format(total)), findsWidgets, reason: 'day total $d');
      for (final t in byDay[d]!) {
        expect(value(m.format(t.totalMinor)), findsWidgets, reason: '${t.merchant} amount');
      }
    }

    // Category filter: amounts become the lines of that category only.
    await tapAndSettle(tester, textCI(SpendCategory.groceries.label));
    final lidl = txs.where((t) => t.merchant == 'Lidl').sorted((a, b) => b.occurredAt.compareTo(a.occurredAt)).first;
    final groceries = lidl.lines
        .where((l) => l.category == SpendCategory.groceries)
        .fold(0, (a, l) => a + l.totalMinor);
    expect(groceries, isNot(lidl.totalMinor));
    expect(value(m.format(groceries)), findsWidgets, reason: 'Lidl groceries-only amount');
    final cafe = txs.firstWhere((t) => t.merchant == 'Café');
    expect(find.text('Café'), findsNothing, reason: 'eating-out transaction filtered out');
    expect(value(m.format(cafe.totalMinor)), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('inbox and review show line sums, receipt totals and converted amounts', (tester) async {
    await app.pump(tester, initial: '/inbox');
    final m = await money();
    final p = await profile();
    final jobs = await app.isar.scanJobs.where().findAll();
    final aldi = jobs.firstWhere((j) => j.merchant == 'Aldi');
    final migros = jobs.firstWhere((j) => j.merchant!.startsWith('Migros'));
    int sum(ScanJob j) => j.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);
    int toHome(int minor) => Currency.convert(minor, from: migros.currency!, to: p.currency, rate: migros.fxRate!);
    final chf = MoneyFormat(currency: migros.currency!, digits: Currency.digitsOf(migros.currency!));

    expect(value(m.format(sum(aldi))), findsWidgets, reason: 'Aldi card amount');
    expect(value(m.format(toHome(sum(migros)))), findsWidgets, reason: 'Migros converted amount');
    expect(value(chf.format(sum(migros))), findsWidgets, reason: 'Migros original amount');

    await tapAndSettle(tester, textHas('Aldi'));
    expect(value(m.format(sum(aldi))), findsWidgets, reason: 'review total');
    expect(value(m.format(aldi.receiptTotalMinor!)), findsWidgets, reason: 'total on the receipt');
    for (final l in aldi.lines.where((l) => l.needsAttention)) {
      expect(textHas(l.name), findsWidgets);
      expect(value(m.format(l.totalMinor)), findsWidgets, reason: '${l.name} amount');
      expect(value(m.toInput(l.totalMinor)), findsWidgets, reason: '${l.name} amount field');
    }
    await popTop(tester);

    await tapAndSettle(tester, textHas('Migros'));
    expect(value(m.format(toHome(sum(migros)))), findsWidgets, reason: 'converted total');
    expect(value(chf.format(sum(migros))), findsWidgets, reason: 'receipt-currency total');
    expect(value(migros.fxRate!.toStringAsPrecision(5)), findsWidgets, reason: 'rate');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
