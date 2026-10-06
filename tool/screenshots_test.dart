// Screenshots of every major screen, rendered by the real app on demo data.
//
//   flutter test tool/screenshots_test.dart                          # light
//   flutter test tool/screenshots_test.dart --dart-define=THEME=dark # dark
//
// SHOTS_DIR   Output folder (default build/screenshots/<theme>).
// SHOTS_ONLY  Comma-separated shot names to render (default: all).
//
// Shots are DemoSeed data by default; `empty` seeds only an onboarded profile, and `textScale`
// sets the system text scale for the shot.
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
import 'package:trackcalfin/app/theme.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/features/common/widgets.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../test/support/fake_gemini.dart';
import '../test/support/test_db.dart';

const _theme = String.fromEnvironment('THEME', defaultValue: 'light');
const _size = Size(390, 844);
const _dpr = 2.0;

/// One screenshot: where to start, then optional steps (taps, scrolls) before capture.
class Shot {
  const Shot(
    this.name,
    this.route, {
    this.demo = true,
    this.empty = false,
    this.textScale = 1.0,
    this.steps,
    this.gallery,
  });
  final String name;
  final String route;

  /// Seeds DemoSeed data. Without it (and without [empty]) the app starts un-onboarded.
  final bool demo;

  /// An onboarded profile and nothing else: the empty states of the tabs.
  final bool empty;

  /// The system text scale (1.3 for the large-text shots).
  final double textScale;
  final Future<void> Function(WidgetTester tester, Isar isar)? steps;

  /// Renders this page of shared components on the app theme instead of a route.
  final Widget Function()? gallery;
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
  for (var i = 0; i < 20 && f.hitTestable().evaluate().isEmpty; i++) {
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
  Shot('06b-buy-ledger-scrolled', '/buy?tab=ledger', steps: (t, _) => _scroll(t, 500)),
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
  // Opened from the Buy tab (a push), so the back arrow shows.
  Shot('11-inbox', '/buy', steps: (t, _) => _tap(t, find.byTooltip('Inbox'))),
  Shot('12-review', '/inbox', steps: (t, _) => _tap(t, find.textContaining('Aldi'))),
  Shot('13-review-fx', '/inbox', steps: (t, _) => _tap(t, find.textContaining('Migros'))),
  const Shot('14-settings', '/settings'),
  Shot('15-settings-scrolled', '/settings', steps: (t, _) => _scroll(t, 900)),
  // Opened from Settings (a push), so the back arrow shows.
  Shot('16-stats', '/settings', steps: (t, _) => _tapVisible(t, find.text('Stats'))),
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
  // Opened from Cook (a push), so the back arrow shows.
  Shot('25-recipe-editor', '/cook', steps: (t, _) => _tap(t, find.byTooltip('Write a recipe'))),
  Shot('26-vibe-sheet', '/', steps: (t, _) => _tap(t, find.textContaining('Vibe'))),
  Shot(
    '27-cooked-undo',
    '/cook',
    steps: (t, _) async {
      await _tap(t, find.text('I cooked this'));
    },
  ),
  // An onboarded profile and no data: the tabs' empty states.
  const Shot('28-empty-dashboard', '/', demo: false, empty: true),
  const Shot('29-empty-buy', '/buy', demo: false, empty: true),
  const Shot('30-empty-cook', '/cook', demo: false, empty: true),
  // System text at 1.3×.
  const Shot('31-dashboard-1.3x', '/', textScale: 1.3),
  const Shot('32-cook-1.3x', '/cook', textScale: 1.3),
  const Shot('33-pantry-1.3x', '/buy', textScale: 1.3),
  // Shared components that no screen uses yet (DESIGN_SYSTEM §7), for review.
  Shot('90-components', '/', gallery: () => const _GalleryA()),
  Shot('91-components', '/', gallery: () => const _GalleryB()),
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
        if (shot.empty) await ProfileService(isar).save(ProfileService.defaults()..onboardingDone = true);
        tester.view.physicalSize = _size * _dpr;
        tester.view.devicePixelRatio = _dpr;
        await tester.binding.setSurfaceSize(_size);
        tester.view.padding = const FakeViewPadding(top: 47 * _dpr, bottom: 34 * _dpr);
        tester.view.viewPadding = const FakeViewPadding(top: 47 * _dpr, bottom: 34 * _dpr);
        tester.platformDispatcher.platformBrightnessTestValue = _theme == 'dark'
            ? ui.Brightness.dark
            : ui.Brightness.light;
        tester.platformDispatcher.textScaleFactorTestValue = shot.textScale;
        debugDisableShadows = false;
        final router = buildRouter(onboarded: shot.demo || shot.empty, initialLocation: shot.route);
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: shot.gallery != null
                ? MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.build(_theme == 'dark' ? Brightness.dark : Brightness.light),
                    home: Scaffold(
                      appBar: TabHeader(title: shot.name.substring(3)),
                      body: shot.gallery!(),
                    ),
                  )
                : ProviderScope(
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
        tester.platformDispatcher.clearTextScaleFactorTestValue();
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

class _GalleryA extends StatelessWidget {
  const _GalleryA();

  @override
  Widget build(BuildContext context) {
    void none() {}
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        AppSegmented<int>(segments: const {0: 'Pantry', 1: 'Ledger'}, selected: 0, onChanged: (_) {}),
        SectionTitle(
          'In the fridge',
          trailing: TextButton(onPressed: none, child: const Text('See all')),
        ),
        AppGroup(
          separatorIndent: AppGroup.indentIcon,
          children: [
            AppRow(
              leading: const Icon(Icons.kitchen_outlined),
              title: 'Red lentil & chickpea dal',
              subtitle: '2 left · 2 d · 26 g protein',
              trailing: FilledButton.tonal(
                style: AppTheme.tonalButton(context, small: true),
                onPressed: none,
                child: const Text('Eat 1'),
              ),
            ),
            AppRow(
              leading: const Icon(Icons.restaurant_outlined),
              title: 'Salmon traybake',
              subtitle: 'Missing Salmon fillet',
              chevron: true,
              onTap: none,
            ),
          ],
        ),
        const GroupHeader('Produce', icon: Icons.eco_outlined, value: '€7.80'),
        AppGroup(
          children: [
            AppRow(title: 'Daily calories', value: '2,200 kcal', valueMuted: true, onTap: none),
            AppRow(title: 'Bananas', subtitle: '€0.75 · 2 days left', value: '3 pc', onTap: none),
            AppRow(
              title: 'Notifications',
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            AppRow(
              leading: const GlyphCircle(Icons.restaurant_outlined),
              title: 'Café',
              subtitle: '12:12',
              value: '€7.80',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AppNotice(message: 'Scans wait here until the AI can read them.', title: 'Add a Gemini API key'),
        const SizedBox(height: 12),
        AppNotice(
          kind: NoticeKind.warning,
          message: 'Items add up to €8.36 but the receipt says €10.27.',
          actions: [TextButton(onPressed: none, child: const Text('Mark as correct'))],
        ),
        const SizedBox(height: 12),
        const AppNotice(kind: NoticeKind.critical, message: "Couldn't load this.", meta: 'TimeoutException after 20 s'),
        const SizedBox(height: 12),
        AppNotice(kind: NoticeKind.success, message: 'Ready with swaps', onTap: none),
      ],
    );
  }
}

class _GalleryB extends StatelessWidget {
  const _GalleryB();

  @override
  Widget build(BuildContext context) {
    void none() {}
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppChoiceChip(label: 'All', selected: true, onSelected: (_) {}),
            AppChoiceChip(
              label: 'Groceries',
              icon: Icons.shopping_basket_outlined,
              selected: false,
              onSelected: (_) {},
            ),
            AppChoiceChip(label: 'Eating out', icon: Icons.restaurant_outlined, selected: true, onSelected: (_) {}),
            AppToggleChip(label: 'oven', selected: true, onSelected: (_) {}),
            AppToggleChip(label: 'grill', selected: false, onSelected: (_) {}),
            AppActionChip(label: 'Add', icon: Icons.add_rounded, onPressed: none),
            AppActionChip(label: 'Cumin', icon: Icons.help_outline_rounded, iconColor: c.warning, onPressed: none),
            AppInputChip(label: 'peanut', onDeleted: none),
            const Tag('high protein'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 72,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              PantryTile(name: 'Spinach', quantity: '210 g', note: 'use today', urgent: true, onTap: none),
              const SizedBox(width: 8),
              PantryTile(name: 'Bananas', quantity: '3 pc', note: '2 days', onTap: none),
              const SizedBox(width: 8),
              PantryTile(name: 'Whole milk', quantity: '150 ml', runningLow: true, onTap: none),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // The capture sheet's grid: 20 side padding, 10 gaps, about 110 per tile.
        GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 110 / 104,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CaptureTile(
              icon: Icons.receipt_long_outlined,
              title: 'Scan receipt',
              subtitle: 'Choose photo',
              onTap: none,
            ),
            CaptureTile(icon: Icons.payments_outlined, title: 'Expense', subtitle: 'Non-food too', onTap: none),
            CaptureTile(icon: Icons.restaurant_outlined, title: 'I ate', subtitle: 'Fridge or other', onTap: none),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Food spend',
          trailing: StatusPill(label: 'On pace', color: c.good, icon: Icons.check_rounded, ink: c.goodInk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(valueSpan(context, '982 kcal', context.nums.large)),
              const SizedBox(height: 8),
              PaceBar(fraction: 0.78, marker: 0.86, color: c.good),
              const SizedBox(height: 8),
              PaceBar(fraction: 0.4, marker: 0.3, color: c.warning, height: 4),
              const SizedBox(height: 12),
              Row(
                children: [
                  RingGauge(
                    fraction: 0.97,
                    color: c.good,
                    center: Text('97', style: context.nums.large.copyWith(fontSize: 24, height: 28 / 24)),
                  ),
                  const SizedBox(width: 16),
                  StatusPill(label: '12% ahead', color: c.warning, icon: Icons.north_east_rounded, ink: c.warningInk),
                  const SizedBox(width: 12),
                  PortionStepper(value: 3, onChanged: (_) {}, hint: 'max 3'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppSkeleton(
          child: SectionCard(
            title: 'Today',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 120, style: context.nums.large),
                const SizedBox(height: 8),
                const SkeletonBlock(height: 6, radius: 3),
              ],
            ),
          ),
        ),
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'All clear',
          message: 'Scans that need a look land here. Clean receipts are filed automatically.',
        ),
      ],
    );
  }
}
