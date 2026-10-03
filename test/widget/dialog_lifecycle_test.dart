import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/app/theme.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/features/capture/say_it_sheet.dart';
import 'package:trackcalfin/features/common/text_prompt.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

/// A dialog's text field is still mounted while the dialog animates out. These walk through
/// that exit the way a phone does: the keyboard still composing a word, Save, then every frame.
void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;
  late Directory tmp;

  setUp(() async {
    isar = await openTestDb();
    await ProfileService(isar).load();
    tmp = await Directory.systemTemp.createTemp('dialogs_');
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  /// Frames through a dialog's exit animation, failing on the first exception.
  Future<void> frames(WidgetTester tester, {int n = 12}) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      final e = tester.takeException();
      if (e != null) fail('frame $i threw: $e');
    }
  }

  /// What an Android keyboard leaves behind: the typed word is still underlined (composing).
  Future<void> typeLikeAKeyboard(WidgetTester tester, Finder field, String text) async {
    await tester.enterText(field, text);
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
        composing: TextRange(start: 0, end: text.length),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpHost(WidgetTester tester, Widget Function(BuildContext) button, {FakeGemini? fake}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          imageStoreProvider.overrideWithValue(ImageStore(tmp.path)),
          promptRepositoryProvider.overrideWithValue(PromptRepository(loadPromptAsset)),
          if (fake != null)
            aiGatewayProvider.overrideWith(
              (ref) => AiGateway(
                isar: isar,
                secrets: MemorySecretStore('test-key'),
                prompts: PromptRepository(loadPromptAsset),
                httpClient: fake.client,
              ),
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light),
          home: Scaffold(
            body: Center(child: Builder(builder: button)),
          ),
        ),
      ),
    );
    await frames(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });
  }

  testWidgets('Say it: typing the price paid while the keyboard composes, then Save, keeps the sheet working', (
    tester,
  ) async {
    final cola = await PantryService(isar).upsert(
      Ingredient()
        ..name = 'Cola Zero'
        ..key = 'cola_zero'
        ..category = IngredientCategory.beverages
        ..baseUnit = BaseUnit.pc
        ..gramsPerPiece = 340
        ..qtyOnHand = 5
        ..avgCostPerUnitMinor = 75,
    );
    // Bought a Coke Zero for 1.29 and drank it.
    final fake = FakeGemini()..reply(promptExample('quick_log.v2.md'));
    await pumpHost(
      tester,
      (context) => TextButton(onPressed: () => showSayIt(context), child: const Text('open')),
      fake: fake,
    );
    await tester.tap(find.text('open'));
    await frames(tester);
    await tester.enterText(find.byType(TextField), 'bought a coke zero for 1.29 and drank it');
    await tester.tap(find.text('Next'));
    await frames(tester, n: 20);
    expect(find.text('Here is what I got'), findsOneWidget);

    await tester.tap(find.text('Change price'));
    await frames(tester);
    expect(find.text('What did you pay?'), findsOneWidget);
    await typeLikeAKeyboard(
      tester,
      find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)),
      '1.49',
    );
    await tester.tap(find.text('Save'));
    await frames(tester, n: 20);
    expect(find.text('What did you pay?'), findsNothing);
    expect(find.textContaining('1.49'), findsWidgets, reason: 'the card shows the price typed');

    await tester.tap(find.text('Log 2 things'));
    await frames(tester, n: 20);
    final tx = (await isar.transactions.where().findFirst())!;
    expect((tx.totalMinor, tx.lines.single.ingredientId), (149, cola));
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a text prompt survives Save, Done and Cancel while the keyboard composes', (tester) async {
    final answers = <String?>[];
    await pumpHost(
      tester,
      (context) => TextButton(
        onPressed: () async => answers.add(await showTextPrompt(context, title: 'Budget', initial: '300')),
        child: const Text('ask'),
      ),
    );
    final field = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));

    await tester.tap(find.text('ask'));
    await frames(tester);
    await typeLikeAKeyboard(tester, field, '350');
    await tester.tap(find.text('Save'));
    await frames(tester);

    await tester.tap(find.text('ask'));
    await frames(tester);
    await typeLikeAKeyboard(tester, field, '360');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await frames(tester);

    await tester.tap(find.text('ask'));
    await frames(tester);
    await typeLikeAKeyboard(tester, field, '370');
    await tester.tap(find.text('Cancel'));
    await frames(tester);

    expect(answers, ['350', '360', null]);
    expect(find.byType(AlertDialog), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
