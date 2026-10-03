// Every main screen and sheet on a small phone (360 x 740 dp), light and dark, at text
// scale 1.0 and 1.3, with a keyboard up where a sheet has text fields: no overflow.
//
// Text is measured in Roboto, as on Android (test/support/real_fonts.dart). To look at
// the screens, set LAYOUT_SHOTS to a folder and each one is written there as a PNG:
//   LAYOUT_SHOTS=/tmp/shots flutter test test/widget/layout_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/app.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/app/router.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/features/buy/ingredient_sheet.dart';
import 'package:trackcalfin/features/buy/transaction_sheet.dart';
import 'package:trackcalfin/features/capture/ate_sheet.dart';
import 'package:trackcalfin/features/capture/cooked_sheet.dart';
import 'package:trackcalfin/features/capture/expense_sheet.dart';
import 'package:trackcalfin/features/capture/say_it_sheet.dart';
import 'package:trackcalfin/features/dashboard/dashboard_screen.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/real_fonts.dart';
import '../support/test_db.dart';

const _phone = Size(360, 740);
const _dpr = 3.0;
const _keyboard = 300.0;

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadRealFonts);

  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.3]) {
      final variant = '${dark ? 'dark' : 'light'}, text x$scale';

      testWidgets('tabs fit a small phone ($variant)', (tester) async {
        final p = await _Probe.open(tester, 'tabs', dark: dark, scale: scale);
        await p.run(() async {
          await p.visit('dashboard eaten');
          await tester.tap(find.text('Spent'));
          await p.visit('dashboard spent');
          await tester.tap(find.byType(StatusCircle));
          await p.visit('dashboard status sheet');
          await p.back();
          p.router.go('/buy');
          await p.visit('buy pantry');
          await tester.tap(find.textContaining('List'));
          await p.visit('buy list');
          await tester.tap(find.text('Ledger'));
          await p.visit('buy ledger');
          // One with a single line: it has the amount field.
          final tx = (await p.isar.transactions.where().findAll()).firstWhere((t) => t.lines.length == 1);
          showTransactionSheet(p.context, tx).ignore();
          await p.visit('transaction sheet');
          await p.back();
          p.router.go('/cook');
          await p.visit('cook');
          p.router.go('/settings');
          await p.visit('settings');
        });
      }, timeout: const Timeout(Duration(minutes: 3)));

      testWidgets('screens fit a small phone ($variant)', (tester) async {
        final p = await _Probe.open(tester, 'screens', dark: dark, scale: scale);
        await p.run(() async {
          p.router.push('/quick-check').ignore();
          await p.visit('quick check');
          await p.back();
          for (final r in await p.isar.recipes.where().findAll()) {
            p.router.push('/recipe/${r.id}').ignore();
            await p.visit('recipe ${r.id}');
            await p.back();
          }
          final recipe = (await p.isar.recipes.where().findFirst())!;
          p.router.push('/recipe/${recipe.id}/edit').ignore();
          await p.visit('recipe editor', keyboard: true);
          await p.back();
          p.router.push('/recipe/new').ignore();
          await p.visit('new recipe', keyboard: true);
          await p.back();
          p.router.push('/stats').ignore();
          await p.visit('stats');
          await p.back();
          p.router.push('/food-history').ignore();
          await p.visit('food history');
          await tester.tap(find.textContaining('· so far').first);
          await p.visit('food history month');
          await p.back();
          p.router.push('/inbox').ignore();
          await p.visit('inbox');
          for (final job in await p.isar.scanJobs.where().findAll()) {
            p.router.push('/inbox/${job.id}').ignore();
            await p.visit('review ${job.kind.name} ${job.merchant ?? ''}', keyboard: true);
            await p.back();
          }
        });
      }, timeout: const Timeout(Duration(minutes: 3)));

      testWidgets('sheets fit a small phone, keyboard up ($variant)', (tester) async {
        // Only Say it gets an answer; the app's other AI calls on start (the daily pick,
        // macros, scans) are turned away, so they leave the reply alone.
        final gemini = MockClient(
          (req) async => req.body.contains('logging assistant')
              ? geminiOk(jsonEncode(_sayItReply()))
              : http.Response('{"error":{"code":400,"message":"not in this test"}}', 400),
        );
        final p = await _Probe.open(tester, 'sheets', dark: dark, scale: scale, gemini: gemini);
        await p.run(() async {
          p.router.go('/buy');
          await p.settle();
          final chicken = (await p.isar.ingredients.getByKey('chicken_breast'))!;
          showIngredientSheet(p.context, ingredient: chicken).ignore();
          await p.visit('ingredient sheet');
          await tester.ensureVisible(find.widgetWithText(ActionChip, 'Edit'));
          await p.settle();
          await tester.tap(find.widgetWithText(ActionChip, 'Edit'));
          await p.visit('ingredient macros editor', keyboard: true);
          await tester.tap(find.byTooltip('Edit details'));
          await p.visit('ingredient details editor', keyboard: true);
          await p.back();
          final banana = (await p.isar.ingredients.getByKey('banana'))!;
          showIngredientSheet(p.context, ingredient: banana).ignore();
          await p.visit('ingredient sheet pieces');
          await p.back();
          showIngredientSheet(p.context).ignore();
          await p.visit('new ingredient', keyboard: true);
          await p.back();

          await tester.tap(find.byTooltip('Log something'));
          await p.visit('capture menu');
          await p.back();

          showSayIt(p.context).ignore();
          await p.visit('say it', keyboard: true);
          await p.visit('say it, no keyboard');
          await tester.enterText(find.byType(TextField).last, 'bought a coke zero, ate the chili and a döner');
          await tester.tap(find.text('Next'));
          await p.waitFor(find.text('Here is what I got'));
          await p.visit('say it review');
          await p.visit('say it review', keyboard: true);
          await p.back();

          showAteSheet(p.context).ignore();
          await p.visit('ate sheet');
          await p.visit('ate sheet', keyboard: true);
          await p.back();
          showAteSheet(p.context, quickAddFirst: true).ignore();
          await p.visit('ate something else', keyboard: true);
          await p.back();
          showCookedSheet(p.context).ignore();
          await p.visit('cooked sheet');
          await p.back();
          showExpenseSheet(p.context).ignore();
          await p.visit('expense sheet', keyboard: true);
          await tester.tap(find.text('Add a note'));
          await p.visit('expense sheet with a note', keyboard: true);
          await p.back();
        });
      }, timeout: const Timeout(Duration(minutes: 3)));

      testWidgets('onboarding fits a small phone ($variant)', (tester) async {
        final p = await _Probe.open(tester, 'onboarding', dark: dark, scale: scale, demo: false);
        await p.run(() async {
          for (var page = 1; page <= 4; page++) {
            await p.visit('onboarding $page', keyboard: page <= 2);
            if (page < 4) await tester.tap(find.text('Next'));
          }
        });
      }, timeout: const Timeout(Duration(minutes: 3)));
    }
  }
}

/// A Say it reply with one of each kind of step that fits the demo data: new items, a
/// pantry meal, a meal out, an expense and a price check, from the prompt's own examples.
Map<String, dynamic> _sayItReply() {
  List<dynamic> actions(int example) =>
      (jsonDecode(promptExamples('quick_log.v2.md')[example]) as Map<String, dynamic>)['actions'] as List;
  final priceCheck = {...actions(3).first as Map<String, dynamic>, 'key': 'chicken_breast', 'name': 'chicken'};
  return {
    'schema_version': 1,
    'actions': [...actions(2), ...actions(1).skip(1), priceCheck],
    'total_paid_minor': null,
    'question': null,
  };
}

/// Drives the app on a small phone and collects every overflow with where it happened.
class _Probe {
  _Probe._(this.tester, this.isar, this.router, this.group, this.variant);

  final WidgetTester tester;
  final Isar isar;
  final GoRouter router;
  final String group;
  final String variant;
  final _boundary = GlobalKey();
  final _overflows = <String>[];
  String _where = 'start';
  int _shot = 0;

  static Future<_Probe> open(
    WidgetTester tester,
    String group, {
    required bool dark,
    required double scale,
    bool demo = true,
    http.Client? gemini,
  }) async {
    final isar = await openTestDb();
    final tmp = await Directory.systemTemp.createTemp('layout_');
    addTearDown(() async {
      await closeTestDb(isar);
      await tmp.delete(recursive: true);
    });
    if (demo) await DemoSeed.run(isar);
    tester.view
      ..physicalSize = _phone * _dpr
      ..devicePixelRatio = _dpr
      ..padding = const FakeViewPadding(top: 24 * _dpr, bottom: 16 * _dpr)
      ..viewPadding = const FakeViewPadding(top: 24 * _dpr, bottom: 16 * _dpr);
    tester.platformDispatcher
      ..textScaleFactorTestValue = scale
      ..platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light;
    addTearDown(tester.view.reset);
    // The live binding lays the app out at its surface size, not the view's.
    await tester.binding.setSurfaceSize(_phone);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final router = buildRouter(onboarded: demo);
    final probe = _Probe._(tester, isar, router, group, '${dark ? 'dark' : 'light'}-$scale');
    await tester.pumpWidget(
      RepaintBoundary(
        key: probe._boundary,
        child: ProviderScope(
          overrides: [
            isarProvider.overrideWithValue(isar),
            secretStoreProvider.overrideWithValue(MemorySecretStore(gemini == null ? null : 'test-key')),
            imageStoreProvider.overrideWithValue(ImageStore(tmp.path)),
            promptRepositoryProvider.overrideWithValue(PromptRepository(loadPromptAsset)),
            if (gemini != null)
              aiGatewayProvider.overrideWith(
                (ref) => AiGateway(
                  isar: isar,
                  secrets: MemorySecretStore('test-key'),
                  prompts: PromptRepository(loadPromptAsset),
                  httpClient: gemini,
                ),
              ),
          ],
          child: TrackcalfinApp(router: router),
        ),
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });
    await probe.settle();
    return probe;
  }

  /// A context inside the app's screens, for opening sheets.
  BuildContext get context => tester.element(find.byType(Scaffold).first);

  /// Runs [body], then fails with every overflow it caused. Other errors fail as usual.
  Future<void> run(Future<void> Function() body) async {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (!text.contains('overflowed')) return previous?.call(details);
      final at = RegExp(r'lib/[\w/]+\.dart:\d+').firstMatch(details.toString())?.group(0) ?? '?';
      _overflows.add('$_where: ${text.split('\n').first} ($at)');
    };
    try {
      await body();
    } finally {
      FlutterError.onError = previous;
    }
    expect(_overflows, isEmpty, reason: 'overflows on a 360 dp phone ($variant)');
  }

  /// Real-time frames, so Isar watchers deliver and routes finish animating.
  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  /// Pumps until [finder] finds something, for answers that take a moment (the AI layer).
  Future<void> waitFor(Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(finder, findsWidgets);
  }

  /// Shows what is on screen now, with the keyboard up or down, and scrolls each list of the
  /// top screen or sheet through, so every row is laid out.
  Future<void> visit(String where, {bool keyboard = false}) async {
    _where = keyboard ? '$where (keyboard)' : where;
    tester.view
      ..viewInsets = FakeViewPadding(bottom: keyboard ? _keyboard * _dpr : 0)
      ..padding = FakeViewPadding(top: 24 * _dpr, bottom: keyboard ? 0 : 16 * _dpr);
    await settle();
    await _screenshot();
    for (final s in tester.stateList<ScrollableState>(find.byType(Scrollable))) {
      if (!s.mounted || !s.position.hasContentDimensions) continue;
      if (ModalRoute.of(s.context)?.isCurrent == false) continue;
      final pos = s.position;
      final step = pos.viewportDimension * 0.7;
      for (var at = pos.minScrollExtent + step; at < pos.maxScrollExtent + step; at += step) {
        pos.jumpTo(at.clamp(pos.minScrollExtent, pos.maxScrollExtent));
        await tester.pump(const Duration(milliseconds: 20));
      }
      if (pos.pixels > pos.minScrollExtent) {
        await _screenshot('end');
        pos.jumpTo(pos.minScrollExtent);
        await tester.pump(const Duration(milliseconds: 20));
      }
    }
  }

  /// Closes the top sheet, dialog or pushed screen.
  Future<void> back() async {
    tester.view
      ..viewInsets = FakeViewPadding.zero
      ..padding = const FakeViewPadding(top: 24 * _dpr, bottom: 16 * _dpr);
    await tester.binding.handlePopRoute();
    await settle();
  }

  Future<void> _screenshot([String suffix = '']) async {
    final dir = Platform.environment['LAYOUT_SHOTS'];
    if (dir == null) return;
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = _where.replaceAll(RegExp(r'[^\w]+'), '_');
    final n = (_shot++).toString().padLeft(2, '0');
    File('$dir/$variant/$group-$n-$file${suffix.isEmpty ? '' : '-$suffix'}.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  }
}
