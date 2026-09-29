import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/app.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/app/router.dart';
import 'package:trackcalfin/application/demo_seed.dart';
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
