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

import '../support/app_harness.dart' show textCI, textContains, textExact, textHas;
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
    expect(textContains('Vibe ·'), findsOneWidget);
    expect(textCI('TODAY'), findsOneWidget);
    expect(textCI('FOOD SPEND'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await settle(tester);
    expect(textHas(RegExp(r'^\s*other spend', caseSensitive: false)), findsOneWidget);
    expect(textCI('CALORIES THIS WEEK'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('buy tab shows pantry and ledger', (tester) async {
    await pumpApp(tester, initial: '/buy');
    expect(textCI('USE SOON'), findsOneWidget);
    expect(textExact('Spinach'), findsWidgets);
    await tester.tap(textExact('Ledger'));
    await settle(tester);
    expect(textExact('Lidl'), findsWidgets);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('cook tab shows the offline pick, fridge and rotation', (tester) async {
    await pumpApp(tester, initial: '/cook');
    expect(textExact('Garlic chicken & spinach rice bowls'), findsOneWidget);
    expect(textCI('IN THE FRIDGE'), findsOneWidget);
    expect(textCI('COOK AGAIN'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('cooking from the pick deducts stock and fills the fridge', (tester) async {
    await pumpApp(tester, initial: '/cook');
    await tester.tap(textExact('I cooked this'));
    await settle(tester);
    expect(textContains('in the fridge'), findsWidgets);
    final chicken = await isar.ingredients.getByKey('chicken_breast');
    expect(chicken!.qtyOnHand, 650 - 3 * 180);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail and inbox review open', (tester) async {
    await pumpApp(tester, initial: '/inbox');
    expect(textContains('Aldi'), findsOneWidget);
    await tester.tap(textContains('Aldi'));
    await settle(tester);
    expect(textExact('Looks good'), findsOneWidget);
    expect(textContains('receipt says'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a foreign receipt files in the home currency and keeps the original', (tester) async {
    await pumpApp(tester, initial: '/inbox');
    expect(textContains('(CHF 23.10)'), findsOneWidget);
    await tester.tap(textContains('Migros'));
    await settle(tester);
    expect(textExact('Receipt in CHF'), findsOneWidget);
    expect(textContains('European Central Bank rate'), findsOneWidget);
    await tester.tap(textExact('Looks good'));
    await settle(tester);
    final tx = await isar.transactions.filter().originalCurrencyEqualTo('CHF').findFirst();
    expect(tx, isNotNull);
    expect(tx!.currency, 'EUR');
    expect(tx.originalTotalMinor, 2310);
    expect(tx.totalMinor, 2474);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('floating nav switches tabs and opens capture', (tester) async {
    await pumpApp(tester);
    await tester.tap(textExact('Cook'));
    await settle(tester);
    expect(textCI('IN THE FRIDGE'), findsOneWidget);
    await tester.tap(find.byTooltip('Log something'));
    await settle(tester);
    expect(textExact('I cooked'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('pantry macros: unknown banner, confirm and edit a staple', (tester) async {
    await pumpApp(tester, initial: '/buy');
    final salt = (await isar.ingredients.getByKey('salt'))!..nutritionSource = DataSource.none;
    await isar.writeTxn(() => isar.ingredients.put(salt));
    await settle(tester);
    expect(textExact('1 item has no macros'), findsOneWidget);
    await tester.tap(textExact('Fill with AI'));
    await settle(tester);
    expect(textExact('Add a Gemini API key in Settings first.'), findsOneWidget);

    await tester.dragUntilVisible(textExact('Cumin'), find.byType(ListView).first, const Offset(0, -300));
    await settle(tester);
    expect(textContains('Review macros ·'), findsOneWidget);
    await tester.tap(textExact('Cumin'));
    await settle(tester);
    expect(textCI('NUTRITION PER 100 G'), findsOneWidget);
    expect(textExact('AI estimate'), findsOneWidget);

    await tester.tap(textExact('Confirm'));
    await settle(tester);
    expect((await isar.ingredients.getByKey('cumin'))!.nutritionConfirmedAt, isNotNull);
    expect(textExact('Confirmed'), findsOneWidget);

    await tester.tap(textExact('Edit'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'kcal'), '380');
    await tester.tap(textExact('Save macros'));
    await settle(tester);
    final cumin = (await isar.ingredients.getByKey('cumin'))!;
    expect(cumin.per100.kcal, 380);
    expect(cumin.per100.proteinG, 18, reason: 'untouched fields keep their values');
    expect(cumin.nutritionSource, DataSource.user);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('settings and onboarding render', (tester) async {
    await pumpApp(tester, initial: '/settings');
    expect(textExact('Monthly food budget'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('fresh install starts in onboarding', (tester) async {
    await pumpApp(tester, demo: false);
    expect(textExact('Your kitchen, on autopilot'), findsOneWidget);
    await tester.tap(textExact('Get started'));
    await settle(tester);
    expect(textExact('Your goals'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));
}

/// Real-time pumping (live binding) so Isar's native watchers can deliver.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
