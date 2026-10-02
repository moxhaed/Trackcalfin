import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/app.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/app/router.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
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

  Future<void> pumpApp(WidgetTester tester, {String initial = '/', bool demo = true}) async {
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
    expect(find.text('FOOD SPEND'), findsOneWidget);
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

  testWidgets('pantry photo review asks "same one or extra?" and prices what it found', (tester) async {
    await pumpApp(tester, initial: '/inbox');
    await tester.tap(find.textContaining('Pantry photo ·'));
    await settle(tester);
    expect(find.text('Barilla Spaghetti n.5, 500 g'), findsOneWidget);
    expect(find.textContaining('Already in your pantry: 900 g'), findsOneWidget);
    await tester.tap(find.textContaining('Extra ·'));
    await settle(tester);
    await tester.tap(find.text('Update pantry'));
    await settle(tester);
    final pasta = (await isar.ingredients.getByKey('dry_pasta'))!;
    expect(pasta.qtyOnHand, 1400);
    expect(pasta.avgCostPerUnitMinor, 0.18, reason: 'a price paid is kept over an estimate');
    final peanut = (await isar.ingredients.getByKey('peanut_butter'))!;
    expect(peanut.qtyOnHand, 300);
    expect(peanut.avgCostPerUnitMinor, closeTo(349 / 350, 1e-9));
    expect(peanut.costIsEstimate, isTrue);
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
