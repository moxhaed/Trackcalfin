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

CookbookLine line(String name, String key, double qty, {BaseUnit unit = BaseUnit.g}) => CookbookLine()
  ..asWritten = '$qty ${unit.label} $name'
  ..name = name
  ..key = key
  ..qty = qty
  ..unit = unit;

CookbookDraft draft(int entry, String title, int page, List<CookbookLine> lines) => CookbookDraft()
  ..entry = entry
  ..title = title
  ..page = page
  ..servings = 2
  ..cookMinutes = 30
  ..ingredients = lines
  ..steps = ['Cook it all for 30 min.'];

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

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('cookbook review: have and missing, filters, select, open one, save in one go and Undo', (tester) async {
    await DemoSeed.run(isar);
    const titles = ['Onion soup', 'Tahini cauliflower', 'Garlic chicken & spinach rice bowls'];
    final job = CookbookImport()
      ..fileName = 'test-kitchen.pdf'
      ..bookTitle = 'Test Kitchen'
      ..sizeBytes = 1200000
      ..pageCount = 120
      ..indexDone = true
      ..entries = [
        for (final (i, t) in titles.indexed)
          CookbookEntry()
            ..title = t
            ..page = 10 + i
            ..state = CookbookEntryState.done,
      ]
      ..drafts = [
        draft(0, titles[0], 10, [line('Onions', 'onion', 300), line('Salt', 'salt', 4)]),
        draft(1, titles[1], 11, [
          line('Cauliflower', 'cauliflower', 1, unit: BaseUnit.pc),
          line('Tahini', 'tahini', 60),
        ]),
        draft(2, titles[2], 12, [line('Onions', 'onion', 100)]),
      ];
    final id = await isar.writeTxn(() => isar.cookbookImports.put(job));
    final recipesBefore = await isar.recipes.count();

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
        ],
        child: TrackcalfinApp(router: buildRouter(onboarded: true, initialLocation: '/cookbook-import/$id')),
      ),
    );
    await settle(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });

    expect(find.textContaining('120 pages'), findsOneWidget);
    expect(find.text('You have all 2'), findsOneWidget);
    expect(find.text('You have 0 of 2 · missing cauliflower, tahini'), findsOneWidget);
    expect(find.text('Already in your recipes'), findsOneWidget);
    expect(find.text('Save 2 recipes'), findsOneWidget, reason: 'a recipe already saved starts unticked');

    await tester.tap(find.text('Cookable now · 2'));
    await settle(tester);
    expect(find.text('Tahini cauliflower'), findsNothing);
    await tester.tap(find.text('All · 3'));
    await settle(tester);
    await tester.tap(find.text('None'));
    await settle(tester);
    expect(find.text('Save 0 recipes'), findsOneWidget);
    await tester.tap(find.text('Select all'));
    await settle(tester);
    expect(find.text('Save 3 recipes'), findsOneWidget);
    await tester.tap(find.descendant(of: find.widgetWithText(ListTile, titles[2]), matching: find.byType(Checkbox)));
    await settle(tester);
    expect(find.text('Save 2 recipes'), findsOneWidget);

    await tester.tap(find.text('Tahini cauliflower'));
    await settle(tester);
    expect(find.text('METHOD (SHORTENED)'), findsOneWidget);
    expect(find.textContaining('not in your pantry'), findsNWidgets(2));
    await tester.tapAt(const Offset(20, 40));
    await settle(tester);

    await tester.tap(find.text('Save 2 recipes'));
    await settle(tester);
    final saved = await isar.recipes.filter().originEqualTo(RecipeOrigin.cookbook).findAll();
    expect(saved.map((r) => (r.title, r.sourceBook)).toSet(), {
      ('Onion soup', 'Test Kitchen'),
      ('Tahini cauliflower', 'Test Kitchen'),
    });
    expect(find.text('Saved 2 recipes from Test Kitchen'), findsOneWidget);
    expect(find.text('Onion soup'), findsNothing, reason: 'saved ones leave the review');
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(await isar.recipes.count(), recipesBefore);
    expect(find.text('Onion soup'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
