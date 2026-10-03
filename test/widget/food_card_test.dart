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
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

/// "How can I have eaten €9 this week and only €7 this month?": the Food card says when each began.
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

  Future<void> pumpDashboard(WidgetTester tester, DateTime now) async {
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
          nowProvider.overrideWithValue(() => now),
        ],
        child: TrackcalfinApp(router: buildRouter(onboarded: true, initialLocation: '/')),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });
  }

  testWidgets('a week that began last month says so, and the month says when it began', (tester) async {
    await pumpDashboard(tester, DateTime(2026, 10, 3, 20)); // Saturday
    expect(find.text('Since Mon 28 Sep, so it includes the end of September'), findsOneWidget);
    expect(find.textContaining('Since Thu 1 Oct · '), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('a week inside the month needs no dates', (tester) async {
    await pumpDashboard(tester, DateTime(2026, 10, 8, 20)); // Thursday, the week from Mon 5 Oct
    expect(find.textContaining('so it includes the end of'), findsNothing);
    expect(find.textContaining('Since Thu 1 Oct'), findsNothing);
    expect(find.textContaining('Heading for'), findsOneWidget, reason: 'the projection is still there');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
