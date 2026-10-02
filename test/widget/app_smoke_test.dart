import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/app.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/app/router.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/features/buy/ingredient_sheet.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;
  late Directory tmp;

  setUp(() async {
    isar = await openTestDb();
    tmp = await Directory.systemTemp.createTemp('widget_');
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    String initial = '/',
    bool demo = true,
    List<Override> overrides = const [],
  }) async {
    if (demo) await DemoSeed.run(isar);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final router = buildRouter(onboarded: demo, initialLocation: initial);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          secretStoreProvider.overrideWithValue(MemorySecretStore()),
          imageStoreProvider.overrideWithValue(ImageStore(tmp.path)),
          promptRepositoryProvider.overrideWithValue(PromptRepository(loadPromptAsset)),
          ...overrides,
        ],
        child: TrackcalfinApp(router: router),
      ),
    );
    await settle(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });
  }

  testWidgets('dashboard renders every card from demo data', (tester) async {
    await pumpApp(tester);
    expect(find.textContaining('Vibe ·'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('FOOD'), findsOneWidget);
    expect(find.textContaining('Groceries count when you eat them'), findsOneWidget, reason: 'eaten is the default');
    expect(find.text('spent this week'), findsOneWidget);
    await tester.tap(find.text('Spent'));
    await settle(tester);
    expect((await isar.userProfiles.get(1))!.foodBasis, FoodBasis.spent);
    expect(find.text('eaten this week'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await settle(tester);
    expect(find.text('OTHER SPEND · MONTH'), findsOneWidget);
    expect(find.text('CALORIES THIS WEEK'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('buy tab shows pantry and ledger', (tester) async {
    await pumpApp(tester, initial: '/buy');
    expect(find.text('USE SOON'), findsOneWidget);
    expect(find.text('Spinach'), findsWidgets);
    await tester.tap(find.text('Ledger'));
    await settle(tester);
    expect(find.text('Lidl'), findsWidgets);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('cook tab shows the offline pick, fridge and rotation', (tester) async {
    await pumpApp(tester, initial: '/cook');
    expect(find.text('Garlic chicken & spinach rice bowls'), findsOneWidget);
    expect(find.text('IN THE FRIDGE'), findsOneWidget);
    expect(find.text('COOK AGAIN'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('cooking from the pick deducts stock and fills the fridge', (tester) async {
    await pumpApp(tester, initial: '/cook');
    await tester.tap(find.text('I cooked this'));
    await settle(tester);
    expect(find.textContaining('in the fridge'), findsWidgets);
    final chicken = await isar.ingredients.getByKey('chicken_breast');
    expect(chicken!.qtyOnHand, 650 - 3 * 180);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail and inbox review open', (tester) async {
    await pumpApp(tester, initial: '/inbox');
    expect(find.textContaining('Aldi'), findsOneWidget);
    await tester.tap(find.textContaining('Aldi'));
    await settle(tester);
    expect(find.text('Looks good'), findsOneWidget);
    expect(find.textContaining('receipt says'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a foreign receipt files in the home currency and keeps the original', (tester) async {
    await pumpApp(tester, initial: '/inbox');
    expect(find.textContaining('(CHF 23.10)'), findsOneWidget);
    await tester.tap(find.textContaining('Migros'));
    await settle(tester);
    expect(find.text('Receipt in CHF'), findsOneWidget);
    expect(find.textContaining('European Central Bank rate'), findsOneWidget);
    await tester.tap(find.text('Looks good'));
    await settle(tester);
    final tx = await isar.transactions.filter().originalCurrencyEqualTo('CHF').findFirst();
    expect(tx, isNotNull);
    expect(tx!.currency, 'EUR');
    expect(tx.originalTotalMinor, 2310);
    expect(tx.totalMinor, 2474);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('floating nav switches tabs and opens capture', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Cook'));
    await settle(tester);
    expect(find.text('IN THE FRIDGE'), findsOneWidget);
    await tester.tap(find.byTooltip('Log something'));
    await settle(tester);
    expect(find.text('I cooked'), findsOneWidget);
    expect(find.text('Count food you already have'), findsOneWidget, reason: 'says what a pantry photo is for');
    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(find.text('I cooked'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('say it: reads what you did, shows it, logs it on one tap and Undo takes it back', (tester) async {
    final fake = FakeGemini()
      ..replyJson({
        'schema_version': 1,
        'actions': [
          {
            'type': 'expense',
            'when': null,
            'source': null,
            'key': null,
            'name': 'Haircut',
            'qty': null,
            'unit': null,
            'batch_id': null,
            'recipe_id': null,
            'portions': null,
            'ate_portions': null,
            'paid_minor': 2500,
            'est_price_minor': null,
            'category': 'other',
            'merchant': null,
            'nutrition': null,
            'new_ingredient': null,
          },
        ],
        'total_paid_minor': null,
        'question': null,
      });
    await pumpApp(
      tester,
      overrides: [
        aiGatewayProvider.overrideWith(
          (ref) => AiGateway(
            isar: isar,
            secrets: MemorySecretStore('test-key'),
            prompts: PromptRepository(loadPromptAsset),
            httpClient: fake.client,
          ),
        ),
      ],
    );
    final before = await isar.transactions.count();
    await tester.tap(find.byTooltip('Log something'));
    await settle(tester);
    await tester.tap(find.text('Say it'));
    await settle(tester);
    expect(find.textContaining('Nothing is saved until you check it'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'spent 25 on a haircut');
    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(find.text('Here is what I got'), findsOneWidget);
    expect(find.textContaining('Haircut ·'), findsOneWidget);
    expect(await isar.transactions.count(), before, reason: 'nothing is saved before Log it');
    await tester.tap(find.text('Log it'));
    await settle(tester);
    final haircut = await isar.transactions.filter().noteEqualTo('Haircut').findFirst();
    expect((haircut!.totalMinor, haircut.primaryCategory), (2500, SpendCategory.other));
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(await isar.transactions.filter().noteEqualTo('Haircut').findFirst(), isNull);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('pantry macros: unknown banner, confirm and edit an item', (tester) async {
    await pumpApp(tester, initial: '/buy');
    final salt = (await isar.ingredients.getByKey('salt'))!..nutritionSource = DataSource.none;
    await isar.writeTxn(() => isar.ingredients.put(salt));
    await settle(tester);
    expect(find.text('1 item has no macros'), findsOneWidget);
    await tester.tap(find.text('Fill with AI'));
    await settle(tester);
    expect(find.text('Add a Gemini API key in Settings first.'), findsOneWidget);

    await tester.dragUntilVisible(find.text('Cumin'), find.byType(ListView).first, const Offset(0, -300));
    await settle(tester);
    expect(find.textContaining('Review macros ·'), findsOneWidget);
    await tester.tap(find.text('Cumin'));
    await settle(tester);
    expect(find.text('NUTRITION PER 100 G'), findsOneWidget);
    expect(find.text('AI estimate'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await settle(tester);
    expect((await isar.ingredients.getByKey('cumin'))!.nutritionConfirmedAt, isNotNull);
    expect(find.text('Confirmed'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'kcal'), '380');
    await tester.tap(find.text('Save macros'));
    await settle(tester);
    final cumin = (await isar.ingredients.getByKey('cumin'))!;
    expect(cumin.per100.kcal, 380);
    expect(cumin.per100.proteinG, 18, reason: 'untouched fields keep their values');
    expect(cumin.nutritionSource, DataSource.user);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('switching an item from ml to cans keeps its amount and price per can right', (tester) async {
    await DemoSeed.run(isar);
    await isar.writeTxn(
      () => isar.ingredients.put(
        Ingredient()
          ..key = 'cola_zero'
          ..name = 'Cola Zero'
          ..category = IngredientCategory.beverages
          ..baseUnit = BaseUnit.ml
          ..qtyOnHand = 1980
          ..avgCostPerUnitMinor = 449 / 1980
          ..lowStockThreshold = 660
          ..lastPurchaseQty = 1980
          ..nutritionSource = DataSource.aiEstimate,
      ),
    );
    await pumpApp(tester, initial: '/buy');
    final cola = (await isar.ingredients.getByKey('cola_zero'))!;
    unawaited(showIngredientSheet(tester.element(find.byType(Scaffold).first), ingredient: cola));
    await settle(tester);
    await tester.tap(find.byTooltip('Edit details'));
    await settle(tester);
    await tester.tap(find.descendant(of: find.byType(SegmentedButton<BaseUnit>), matching: find.text('pc')));
    await settle(tester);
    Future<void> save() async {
      await tester.ensureVisible(find.text('Save'));
      await settle(tester);
      await tester.tap(find.text('Save'));
      await settle(tester);
    }

    await save();
    expect(find.text('How much does one weigh?'), findsOneWidget, reason: 'cans need their weight');
    await tester.enterText(find.widgetWithText(TextField, 'Grams per piece'), '340');
    await settle(tester);
    expect(find.widgetWithText(TextField, '6'), findsOneWidget, reason: '1980 ml are 6 cans');
    await save();

    final after = (await isar.ingredients.getByKey('cola_zero'))!;
    expect((after.baseUnit, after.gramsPerPiece, after.qtyOnHand), (BaseUnit.pc, 340.0, 6.0));
    expect(after.avgCostPerUnitMinor, closeTo(449 / 1980 * 340, 1e-6), reason: 'about 77 cents a can');
    expect(after.lowStockThreshold, 2);
    expect(after.lastCountedAt, isNull, reason: 'the same cans in another unit, not a new count');
    expect(after.needsNutrition, isTrue, reason: 'per 100 ml numbers are not per 100 g');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('pantry photo review asks "same one or extra?" and prices what it found', (tester) async {
    await pumpApp(tester, initial: '/inbox');
    await tester.tap(find.textContaining('Pantry photo ·'));
    await settle(tester);
    expect(find.text('Barilla Spaghetti n.5, 500 g'), findsOneWidget);
    expect(find.textContaining('Already in your pantry: 900 g'), findsOneWidget);
    await tester.tap(find.textContaining('Extra ·'));
    await settle(tester);
    // The new item's shop price was looked up on Google: is it right?
    expect(find.textContaining('Google found'), findsOneWidget, reason: 'spaghetti has a price paid: no question');
    expect(find.textContaining('for 350 g at REWE. Is that the price?'), findsOneWidget);
    expect(find.text('Ültje Erdnussbutter crunchy 350 g Preis'), findsOneWidget, reason: 'the search behind it');
    await tester.tap(find.text('Change'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Price'), '2.99');
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.textContaining('Is that the price?'), findsNothing);
    expect(find.text('Peanut butter'), findsOneWidget, reason: 'an answered line stays where it was');
    await tester.tap(find.text('Update pantry'));
    await settle(tester);
    final pasta = (await isar.ingredients.getByKey('dry_pasta'))!;
    expect(pasta.qtyOnHand, 1400);
    expect(pasta.avgCostPerUnitMinor, 0.18, reason: 'a price paid is kept over an estimate');
    final peanut = (await isar.ingredients.getByKey('peanut_butter'))!;
    expect(peanut.qtyOnHand, 300);
    expect(peanut.avgCostPerUnitMinor, closeTo(299 / 350, 1e-9));
    expect(peanut.costIsEstimate, isFalse, reason: 'the user set the price');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('pantry photo review: "All correct" confirms every price; a failed lookup says why', (tester) async {
    await DemoSeed.run(isar);
    final id = await isar.writeTxn(
      () => isar.scanJobs.put(
        ScanJob()
          ..status = ScanStatus.needsReview
          ..kind = ScanKind.pantry
          ..capturedAt = DateTime.now()
          ..priceLookupError = 'Timed out after 90s'
          ..lines = [
            for (final (name, key, price) in [('Tahini', 'tahini', 349), ('Buckwheat', 'buckwheat', 229)])
              DraftLine()
                ..name = name
                ..ingredientKey = key
                ..isNewIngredient = true
                ..qty = 400
                ..qtySource = QtySource.estimated
                ..packageQty = 500
                ..packagePriceMinor = price
                ..priceSource = PriceSource.estimate
                ..profile = (NewIngredientProfile()
                  ..name = name
                  ..category = IngredientCategory.legumesNuts),
          ],
      ),
    );
    await pumpApp(tester, initial: '/inbox/$id');
    expect(find.textContaining("Couldn't look prices up on Google (Timed out after 90s)"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('2 prices are estimates'), findsOneWidget);
    final asks = find.textContaining('Is that about what it costs?', skipOffstage: false);
    expect(asks, findsNWidgets(2));
    await tester.tap(find.text('All correct'));
    await settle(tester);
    expect(asks, findsNothing);
    await tester.tap(find.text('Update pantry'));
    await settle(tester);
    final tahini = (await isar.ingredients.getByKey('tahini'))!;
    expect(tahini.avgCostPerUnitMinor, closeTo(349 / 500, 1e-9));
    expect(tahini.costIsEstimate, isFalse);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a week-old receipt asks what is left; the rest counts as eaten', (tester) async {
    await DemoSeed.run(isar);
    final bought = DateTime.now().subtract(const Duration(days: 9));
    final id = await isar.writeTxn(
      () => isar.scanJobs.put(
        ScanJob()
          ..status = ScanStatus.needsReview
          ..kind = ScanKind.receipt
          ..merchant = 'Aldi'
          ..purchasedAt = bought
          ..receiptTotalMinor = 199
          ..currency = 'EUR'
          ..lines = [
            DraftLine()
              ..rawText = 'HAFERDRINK 1,99'
              ..name = 'Oat drink'
              ..totalMinor = 199
              ..ingredientKey = 'oat_drink'
              ..isNewIngredient = true
              ..qty = 1000
              ..unit = BaseUnit.ml
              ..qtySource = QtySource.printed
              ..stockCheck = StockCheck.whatsLeft
              ..stock = StockEffect.add
              ..profile = (NewIngredientProfile()
                ..name = 'Oat drink'
                ..category = IngredientCategory.beverages
                ..unit = BaseUnit.ml
                ..shelfLifeDays = 10),
          ],
      ),
    );
    await pumpApp(tester, initial: '/inbox/$id');
    expect(find.textContaining('What is left of it now?'), findsOneWidget);
    expect(find.text("Bought 9 days ago. What's left of it?"), findsOneWidget);
    await tester.tap(find.text('Some'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Left'), '250');
    await settle(tester);
    expect(find.text('The other 750 ml counts as eaten'), findsOneWidget);
    await tester.tap(find.text('Looks good'));
    await settle(tester);
    expect((await isar.ingredients.getByKey('oat_drink'))!.qtyOnHand, 250);
    final use = (await isar.foodUses.filter().ingredientKeyEqualTo('oat_drink').findFirst())!;
    expect((use.qtyBase, use.costMinor, use.kind), (750.0, (199 * 0.75).round(), UseKind.eaten));
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('an old receipt shows its date and a possible duplicate', (tester) async {
    await DemoSeed.run(isar);
    final filed = (await isar.transactions.where().findFirst())!;
    final bought = DateTime.now().subtract(const Duration(days: 9));
    await isar.writeTxn(
      () => isar.scanJobs.put(
        ScanJob()
          ..status = ScanStatus.needsReview
          ..kind = ScanKind.receipt
          ..merchant = 'Penny'
          ..purchasedAt = bought
          ..receiptTotalMinor = 249
          ..currency = 'EUR'
          ..duplicateOfTxId = filed.id
          ..lines = [
            DraftLine()
              ..rawText = 'KUECHENROLLE 2,49'
              ..name = 'Kitchen roll'
              ..category = SpendCategory.household
              ..totalMinor = 249,
          ],
      ),
    );
    await pumpApp(tester, initial: '/inbox');
    expect(find.textContaining('already filed?'), findsOneWidget);
    await tester.tap(find.textContaining('Penny'));
    await settle(tester);
    expect(find.textContaining('9 days ago'), findsWidgets);
    expect(find.textContaining('looks like a receipt you already filed'), findsOneWidget);
    await tester.tap(find.text("It's a different one"));
    await settle(tester);
    expect(find.textContaining('looks like a receipt you already filed'), findsNothing);
    await tester.tap(find.text('Date'));
    await settle(tester);
    expect(find.text('Date on the receipt'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    await tester.tap(find.text('Looks good'));
    await settle(tester);
    final tx = await isar.transactions.filter().merchantEqualTo('Penny').findFirst();
    expect(tx!.occurredAt, bought, reason: 'filed on the day it was bought');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('settings and onboarding render', (tester) async {
    await pumpApp(tester, initial: '/settings');
    expect(find.text('Monthly food budget'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('fresh install starts in onboarding', (tester) async {
    await pumpApp(tester, demo: false);
    expect(find.text('Your kitchen, on autopilot'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await settle(tester);
    expect(find.text('Your goals'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));
}

/// Real-time pumping (live binding) so Isar's native watchers can deliver.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
