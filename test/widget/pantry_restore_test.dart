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

/// "I'm out" by mistake, found the next day: the item is in the pantry's search, and its
/// sheet takes the count back.
void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;
  late Directory tmp;
  late DateTime clockNow;

  setUp(() async {
    isar = await openTestDb();
    tmp = await Directory.systemTemp.createTemp('widget_');
    clockNow = DateTime.now();
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpPantry(WidgetTester tester) async {
    await DemoSeed.run(isar);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          secretStoreProvider.overrideWithValue(MemorySecretStore()),
          imageStoreProvider.overrideWithValue(ImageStore(tmp.path)),
          promptRepositoryProvider.overrideWithValue(PromptRepository(loadPromptAsset)),
          nowProvider.overrideWithValue(() => clockNow),
        ],
        child: TrackcalfinApp(router: buildRouter(onboarded: true, initialLocation: '/buy')),
      ),
    );
    await settle(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });
  }

  Future<Ingredient> yogurt() async => (await isar.ingredients.getByKey('greek_yogurt'))!;

  testWidgets("I'm out by mistake: found by search the next day, and Undo in its sheet puts it back", (tester) async {
    await pumpPantry(tester);
    final expires = (await yogurt()).expiresAt;

    await tester.dragUntilVisible(find.text('Greek-style yogurt'), find.byType(ListView).first, const Offset(0, -300));
    await settle(tester);
    await tester.tap(find.text('Greek-style yogurt'));
    await settle(tester);
    await tester.tap(find.text("I'm out"));
    await settle(tester);
    expect(find.text('Greek-style yogurt marked as out'), findsOneWidget);
    expect(find.text('450 g counts as eaten, €1.61'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
    expect((await yogurt()).qtyOnHand, 0);
    expect(await isar.foodUses.count(), greaterThan(0));
    final uses = await isar.foodUses.filter().ingredientKeyEqualTo('greek_yogurt').findAll();
    expect(uses.single.costMinor, 161);

    // The next day: the message is long gone, and setting the amount back would be "more".
    clockNow = clockNow.add(const Duration(days: 1));
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Search pantry'), 'yogurt');
    await settle(tester);
    expect(find.text('Out of stock (1)'), findsOneWidget);
    await tester.tap(find.text('Greek-style yogurt'));
    await settle(tester);
    expect(find.textContaining('Marked out on'), findsOneWidget);
    expect(find.textContaining('450 g counted as eaten, €1.61'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Undo'));
    await settle(tester);
    expect(find.text('Greek-style yogurt put back · 450 g'), findsOneWidget);
    expect(find.text('No longer counts as eaten'), findsOneWidget);
    var y = await yogurt();
    expect((y.qtyOnHand, y.expiresAt), (450.0, expires), reason: 'as it was, expiry too');
    expect(await isar.foodUses.filter().ingredientKeyEqualTo('greek_yogurt').count(), 0);
    expect(find.text('Out of stock (1)'), findsNothing);

    // Undo of the restore: out again, counted as eaten again.
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await settle(tester);
    y = await yogurt();
    expect(y.qtyOnHand, 0);
    expect((await isar.foodUses.get(uses.single.id))!.costMinor, 161);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a swipe that marks out: Undo puts it back with its old expiry, not as a new purchase', (tester) async {
    await pumpPantry(tester);
    final before = await yogurt();
    final tile = find.widgetWithText(ListTile, 'Greek-style yogurt');
    await tester.dragUntilVisible(tile, find.byType(ListView).first, const Offset(0, -300));
    await settle(tester);
    await tester.drag(tile, const Offset(-600, 0));
    await settle(tester);
    expect(find.text('Greek-style yogurt marked as out'), findsOneWidget);
    expect((await yogurt()).qtyOnHand, 0);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await settle(tester);
    final after = await yogurt();
    expect((after.qtyOnHand, after.expiresAt), (450.0, before.expiresAt));
    expect((after.lastPurchasedAt, after.lastPurchaseQty), (before.lastPurchasedAt, before.lastPurchaseQty));
    expect(await isar.foodUses.filter().ingredientKeyEqualTo('greek_yogurt').count(), 0);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
