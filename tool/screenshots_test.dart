// Screenshots of every major screen, rendered by the real app on demo data.
//
//   flutter test tool/screenshots_test.dart                          # light
//   flutter test tool/screenshots_test.dart --dart-define=THEME=dark # dark
//
// SHOTS_DIR   Output folder (default build/screenshots/<theme>).
// SHOTS_ONLY  Comma-separated shot names to render (default: all).
//
// Each shot opens a fresh database seeded with DemoSeed, so shots are independent.
// The phone is 390×844 dp with a notch and home-indicator inset, written at 2×.
// Fonts come from the app's FontManifest plus Roboto and Material Icons from the
// Flutter SDK cache, so text renders as it does on a device.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

import '../test/support/fake_gemini.dart';
import '../test/support/test_db.dart';

const _theme = String.fromEnvironment('THEME', defaultValue: 'light');
const _size = Size(390, 844);
const _dpr = 2.0;

/// One screenshot: where to start, then optional steps (taps, scrolls) before capture.
class Shot {
  const Shot(this.name, this.route, {this.demo = true, this.steps});
  final String name;
  final String route;
  final bool demo;
  final Future<void> Function(WidgetTester tester, Isar isar)? steps;
}

/// Drags the page's main list: the largest vertical, on-screen Scrollable. (`Scrollable.first`
/// can be a text field's own horizontal Scrollable, e.g. the ask field on Cook.)
Future<void> _scroll(WidgetTester tester, double dy) async {
  final candidates = find.byType(Scrollable).hitTestable().evaluate().where((e) {
    final axis = (e.widget as Scrollable).axisDirection;
    return axis == AxisDirection.down || axis == AxisDirection.up;
  });
  Element? main;
  var best = 0.0;
  for (final e in candidates) {
    final size = tester.getSize(find.byElementPredicate((x) => x == e));
    if (size.width * size.height > best) {
      best = size.width * size.height;
      main = e;
    }
  }
  await tester.drag(
    main == null ? find.byType(Scrollable).first : find.byElementPredicate((x) => x == main),
    Offset(0, -dy),
  );
  await settle(tester);
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f.first);
  await settle(tester);
}

/// Taps the first match a user could actually tap, scrolling the page down until one shows.
Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  for (var i = 0; i < 8 && f.hitTestable().evaluate().isEmpty; i++) {
    await _scroll(tester, 250);
  }
  await _tap(tester, f.hitTestable());
}

final shots = <Shot>[
  const Shot('01-dashboard', '/'),
  Shot('02-dashboard-scrolled', '/', steps: (t, _) => _scroll(t, 600)),
  Shot('03-dashboard-bottom', '/', steps: (t, _) => _scroll(t, 2000)),
  const Shot('04-buy-pantry', '/buy'),
  Shot('05-buy-pantry-scrolled', '/buy', steps: (t, _) => _scroll(t, 700)),
  const Shot('06-buy-ledger', '/buy?tab=ledger'),
  const Shot('07-cook', '/cook'),
  Shot('08-cook-scrolled', '/cook', steps: (t, _) => _scroll(t, 500)),
  Shot(
    '09-recipe',
    '/cook',
    steps: (t, isar) async {
      await _tap(t, find.text('Garlic chicken & spinach rice bowls'));
    },
  ),
  Shot(
    '10-recipe-scrolled',
    '/cook',
    steps: (t, isar) async {
      await _tap(t, find.text('Garlic chicken & spinach rice bowls'));
      await _scroll(t, 600);
    },
  ),
  const Shot('11-inbox', '/inbox'),
  Shot('12-review', '/inbox', steps: (t, _) => _tap(t, find.textContaining('Aldi'))),
  Shot('13-review-fx', '/inbox', steps: (t, _) => _tap(t, find.textContaining('Migros'))),
  const Shot('14-settings', '/settings'),
  Shot('15-settings-scrolled', '/settings', steps: (t, _) => _scroll(t, 900)),
  const Shot('16-stats', '/stats'),
  const Shot('17-quick-check', '/quick-check'),
  const Shot('18-onboarding', '/', demo: false),
  Shot('19-onboarding-goals', '/', demo: false, steps: (t, _) => _tap(t, find.text('Get started'))),
  Shot('20-capture-sheet', '/', steps: (t, _) => _tap(t, find.byTooltip('Log something'))),
  Shot(
    '21-ate-sheet',
    '/',
    steps: (t, _) async {
      await _tap(t, find.byTooltip('Log something'));
      await _tap(t, find.text('I ate'));
    },
  ),
  Shot(
    '22-expense-sheet',
    '/',
    steps: (t, _) async {
      await _tap(t, find.byTooltip('Log something'));
      await _tap(t, find.text('Expense'));
    },
  ),
  Shot(
    '23-cooked-sheet',
    '/',
    steps: (t, _) async {
      await _tap(t, find.byTooltip('Log something'));
      await _tap(t, find.text('I cooked'));
    },
  ),
  Shot('24-ingredient-sheet', '/buy', steps: (t, _) => _tapVisible(t, find.text('Chicken breast'))),
  const Shot('25-recipe-editor', '/recipe/new'),
  Shot('26-vibe-sheet', '/', steps: (t, _) => _tap(t, find.textContaining('Vibe'))),
  Shot(
    '27-cooked-undo',
    '/cook',
    steps: (t, _) async {
      await _tap(t, find.text('I cooked this'));
    },
  ),
];

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final only = (Platform.environment['SHOTS_ONLY'] ?? '').split(',').where((s) => s.trim().isNotEmpty).toSet();
  final outDir = Directory(Platform.environment['SHOTS_DIR'] ?? 'build/screenshots/$_theme')
    ..createSync(recursive: true);

  setUpAll(_loadFonts);

  for (final shot in shots) {
    if (only.isNotEmpty && !only.any((o) => shot.name.contains(o.trim()))) continue;
    testWidgets(shot.name, (tester) async {
      final isar = await openTestDb();
      final tmp = await Directory.systemTemp.createTemp('shots_');
      final boundary = GlobalKey();
      final shadows = debugDisableShadows;
      try {
        if (shot.demo) await DemoSeed.run(isar);
        tester.view.physicalSize = _size * _dpr;
        tester.view.devicePixelRatio = _dpr;
        await tester.binding.setSurfaceSize(_size);
        tester.view.padding = const FakeViewPadding(top: 47 * _dpr, bottom: 34 * _dpr);
        tester.view.viewPadding = const FakeViewPadding(top: 47 * _dpr, bottom: 34 * _dpr);
        tester.platformDispatcher.platformBrightnessTestValue = _theme == 'dark'
            ? ui.Brightness.dark
            : ui.Brightness.light;
        debugDisableShadows = false;
        final router = buildRouter(onboarded: shot.demo, initialLocation: shot.route);
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: ProviderScope(
              overrides: [
                isarProvider.overrideWithValue(isar),
                secretStoreProvider.overrideWithValue(MemorySecretStore()),
                imageStoreProvider.overrideWithValue(ImageStore(tmp.path)),
                promptRepositoryProvider.overrideWithValue(PromptRepository(loadPromptAsset)),
              ],
              child: TrackcalfinApp(router: router),
            ),
          ),
        );
        await settle(tester);
        if (shot.steps != null) await shot.steps!(tester, isar);
        await settle(tester);
        final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: _dpr);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('${outDir.path}/${shot.name}.png')..writeAsBytesSync(bytes!.buffer.asUint8List());
        print('wrote ${file.path}');
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 200));
        debugDisableShadows = shadows;
        await tester.binding.setSurfaceSize(null);
        tester.view.reset();
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
        await closeTestDb(isar);
        await tmp.delete(recursive: true);
      }
    }, timeout: const Timeout(Duration(seconds: 90)));
  }
}

/// Real-time pumping (live binding) so Isar's native watchers can deliver.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 14; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _loadFonts() async {
  final sdk = Platform.environment['FLUTTER_ROOT'] ?? _flutterRoot();
  final material = '$sdk/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, Iterable<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      if (File(f).existsSync()) loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await loader.load();
  }

  await load('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
  await load('Roboto', [
    for (final w in ['Thin', 'Light', 'Regular', 'Medium', 'Bold', 'Black']) '$material/Roboto-$w.ttf',
  ]);

  // Fonts the app bundles (pubspec `fonts:`), from the test asset bundle.
  final manifest = json.decode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    if (family == 'MaterialIcons') continue;
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

String _flutterRoot() {
  // flutter_tester lives at <root>/bin/cache/artifacts/engine/<platform>/flutter_tester.
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.path != dir.parent.path) {
    if (File('${dir.path}/bin/flutter').existsSync()) return dir.path;
    dir = dir.parent;
  }
  throw StateError('Set FLUTTER_ROOT to the Flutter SDK');
}
