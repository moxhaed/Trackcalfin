import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/app.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/app/router.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/application/fx_service.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/fx/fx_rate_client.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import 'fake_gemini.dart';
import 'test_db.dart';

/// The phone the guard tests run on: the same geometry as `tool/screenshots_test.dart`
/// (390 x 844 dp, notch and home-indicator insets, real Roboto and bundled fonts), so
/// they exercise the layouts the Design Director reviews.
///
/// Note: `LiveTestWidgetsFlutterBinding` ignores `tester.view.physicalSize` for its
/// viewport; only `binding.setSurfaceSize` changes it (otherwise it is 800 x 600).
const phoneSize = Size(390, 844);
const _dpr = 2.0;

/// Drives the real app (router, Isar, providers) the way `app_smoke_test.dart` does,
/// for the redesign guard tests. Network is never reached: Gemini and the FX client
/// get a mock HTTP client that fails fast (400, not retryable).
///
/// Usage: `final app = TestApp()..register();` at the top of `main()`, then
/// `await app.pump(tester, initial: '/buy')` in each test.
class TestApp {
  late Isar isar;
  late Directory tmp;

  /// Every outbound request a test made (should normally stay empty).
  final requests = <http.Request>[];

  void register() {
    setUpAll(loadAppFonts);
    setUp(() async {
      isar = await openTestDb();
      tmp = await Directory.systemTemp.createTemp('guard_');
      requests.clear();
    });
    tearDown(() async {
      await closeTestDb(isar);
      await tmp.delete(recursive: true);
    });
  }

  late final _offline = MockClient((req) async {
    requests.add(req);
    return http.Response('{"error":{"code":400,"message":"network is off in tests"}}', 400);
  });

  /// A [phoneSize] phone by default. [tall] makes the surface 2400 dp high so long
  /// screens build every card without scrolling (for value checks, not layout checks).
  Future<void> pump(
    WidgetTester tester, {
    String initial = '/',
    bool demo = true,
    bool tall = false,
    String? apiKey,
  }) async {
    if (demo) await DemoSeed.run(isar);
    final size = tall ? Size(phoneSize.width, 2400) : phoneSize;
    tester.view.physicalSize = size * _dpr;
    tester.view.devicePixelRatio = _dpr;
    tester.view.padding = const FakeViewPadding(top: 47 * _dpr, bottom: 34 * _dpr);
    tester.view.viewPadding = const FakeViewPadding(top: 47 * _dpr, bottom: 34 * _dpr);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      tester.view.reset();
    });
    final router = buildRouter(onboarded: demo, initialLocation: initial);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          secretStoreProvider.overrideWithValue(MemorySecretStore(apiKey)),
          imageStoreProvider.overrideWithValue(ImageStore(tmp.path)),
          promptRepositoryProvider.overrideWithValue(PromptRepository(loadPromptAsset)),
          aiGatewayProvider.overrideWith(
            (ref) => AiGateway(
              isar: ref.watch(isarProvider),
              secrets: ref.watch(secretStoreProvider),
              prompts: ref.watch(promptRepositoryProvider),
              httpClient: _offline,
            ),
          ),
          fxServiceProvider.overrideWith(
            (ref) => FxService(ref.watch(isarProvider), client: FxRateClient(_offline), now: ref.watch(nowProvider)),
          ),
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
}

/// Roboto and Material Icons from the SDK cache plus the app's bundled fonts, as in
/// `tool/screenshots_test.dart`, so text has device widths (the default test font is wider).
Future<void> loadAppFonts() async {
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
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.path != dir.parent.path) {
    if (File('${dir.path}/bin/flutter').existsSync()) return dir.path;
    dir = dir.parent;
  }
  throw StateError('Set FLUTTER_ROOT to the Flutter SDK');
}

/// Real-time pumping (live binding) so Isar's native watchers can deliver.
Future<void> settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps in real time until [condition] holds or [timeout] passes, and returns whether it
/// held. For waits that depend on Isar watchers and async providers, which are slower when
/// the machine is busy: wait for the state, then assert it as usual.
Future<bool> pumpUntil(
  WidgetTester tester,
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (true) {
    if (await condition()) return true;
    if (DateTime.now().isAfter(end)) return false;
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Waits until [finder] finds something (or, with [gone], nothing).
Future<void> waitFor(WidgetTester tester, Finder finder, {bool gone = false}) =>
    pumpUntil(tester, () => finder.evaluate().isEmpty == gone);

/// Pops the top route of the root navigator (closes a sheet or dialog).
Future<void> popTop(WidgetTester tester) async {
  rootNavigatorKey.currentState!.pop();
  await settle(tester);
}

// ---------------------------------------------------------------------------
// Finders that survive a visual redesign.

/// Display copy as a test compares it: no-break spaces (U+00A0, U+202F), which the design
/// uses to keep words together ("51 g", the last two words of a title), read as plain spaces.
String plainSpaces(String s) => s.replaceAll(RegExp('[\u00a0\u202f]'), ' ');

/// Like `find.text`, but a no-break space in the widget matches a space in [text]. Same
/// match set as `find.text` (Text widgets and editable text), so counts don't change.
Finder textExact(String text) {
  final want = plainSpaces(text);
  return find.byWidgetPredicate((w) {
    if (w is Text) return plainSpaces(w.data ?? w.textSpan?.toPlainText() ?? '') == want;
    if (w is EditableText) return plainSpaces(w.controller.text) == want;
    return false;
  }, description: 'text "$text"');
}

/// Like `find.textContaining` (Text widgets and editable text), tolerant of no-break spaces.
Finder textContains(String text) {
  final want = plainSpaces(text);
  return find.byWidgetPredicate((w) {
    if (w is Text) return plainSpaces(w.data ?? w.textSpan?.toPlainText() ?? '').contains(want);
    if (w is EditableText) return plainSpaces(w.controller.text).contains(want);
    return false;
  }, description: 'text containing "$text"');
}

/// Rendered text (RichText, so `Text.rich` and plain `Text` alike) or editable text whose
/// plain-spaced content matches [pattern].
Finder _richMatching(Pattern pattern, String description) => find.byWidgetPredicate((w) {
  if (w is RichText) return plainSpaces(w.text.toPlainText()).contains(pattern);
  if (w is EditableText) return plainSpaces(w.controller.text).contains(pattern);
  return false;
}, description: description);

/// Text exactly equal to [text], ignoring case, surrounding whitespace and no-break spaces.
/// Use for labels whose casing the design may change ("TODAY" vs "Today").
Finder textCI(String text) => _richMatching(
  RegExp('^\\s*${RegExp.escape(plainSpaces(text))}\\s*\$', caseSensitive: false),
  'text "$text" (any case)',
);

/// Text containing [pattern] (a string or RegExp), ignoring case for strings; no-break
/// spaces in the widget read as spaces.
Finder textHas(Pattern pattern) => _richMatching(
  pattern is String ? RegExp(RegExp.escape(plainSpaces(pattern)), caseSensitive: false) : pattern,
  'text containing $pattern',
);

/// A displayed value such as "€12.50", "650 g" or "2,184": matched with spaces and case
/// ignored, with or without thousands grouping ("2200" matches "2,200" and "2 200"), and
/// not as part of a longer number ("€12.50" does not match "€112.50").
Finder value(String expected) {
  const gap = r'[\s\u00a0\u202f]*';
  const group = r"[,'\s\u00a0\u202f]?";
  final chars = expected.trim().split('').where((c) => c.trim().isNotEmpty).toList();
  bool digit(int i) => i >= 0 && i < chars.length && RegExp(r'[0-9]').hasMatch(chars[i]);
  final body = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (chars[i] == ',' && digit(i - 1) && digit(i + 1)) continue; // grouping is optional
    body.write(RegExp.escape(chars[i]));
    if (i == chars.length - 1) break;
    final next = chars[i + 1] == ',' && digit(i) && digit(i + 2) ? i + 2 : i + 1;
    body.write(digit(i) && digit(next) ? group : gap);
  }
  final before = digit(0) ? r'(?<![0-9]|[0-9][.,])' : '';
  final after = digit(chars.length - 1) ? r'(?![0-9]|[.,][0-9])' : '';
  final re = RegExp('$before$body$after', caseSensitive: false);
  return find.byWidgetPredicate(
    (w) =>
        (w is RichText && re.hasMatch(w.text.toPlainText())) || (w is EditableText && re.hasMatch(w.controller.text)),
    description: 'value "$expected"',
  );
}

/// One text that shows [number] together with [word] (any order, any case), e.g.
/// `textWith('3', 'left')` matches "3 left" and "Left: 3" but not "13 left".
Finder textWith(String number, String word) => find.byWidgetPredicate((w) {
  if (w is! RichText) return false;
  final s = w.text.toPlainText().toLowerCase();
  if (!s.contains(word.toLowerCase())) return false;
  return RegExp('(^|[^0-9.,])${RegExp.escape(number)}(?![0-9]|[.,][0-9])').hasMatch(s);
}, description: 'text with "$number" and "$word"');

/// A text field whose label (or hint, when it has no label) contains [label], any case.
Finder fieldLabelled(String label) => find.byWidgetPredicate((w) {
  if (w is! TextField) return false;
  final d = w.decoration;
  return (d?.labelText ?? d?.hintText ?? '').toLowerCase().contains(label.toLowerCase());
}, description: 'text field labelled "$label"');

/// The vertical scrollable that takes the most room on screen (a screen's main list).
Finder mainScrollable(WidgetTester tester) {
  final all = find.byWidgetPredicate(
    (w) => w is Scrollable && (w.axisDirection == AxisDirection.down || w.axisDirection == AxisDirection.up),
  );
  Element? best;
  var bestArea = -1.0;
  for (final e in all.evaluate()) {
    final box = e.findRenderObject();
    if (box is! RenderBox || !box.hasSize) continue;
    final area = box.size.width * box.size.height;
    if (area > bestArea) {
      bestArea = area;
      best = e;
    }
  }
  expect(best, isNotNull, reason: 'no vertical scrollable on screen');
  return find.byElementPredicate((e) => identical(e, best), description: 'main scrollable');
}

/// Brings [finder] on screen: if it isn't built yet, scrolls the main list, then any
/// horizontal list (chip rows), forward and back, until it is. Works whatever the
/// list widgets are (ListView, CustomScrollView, chip rows).
Future<void> scrollTo(WidgetTester tester, Finder finder, {double step = 200}) async {
  if (finder.evaluate().isEmpty) {
    final horizontal = find
        .byWidgetPredicate(
          (w) => w is Scrollable && (w.axisDirection == AxisDirection.right || w.axisDirection == AxisDirection.left),
        )
        .evaluate()
        .toList();
    final lists = [mainScrollable(tester).evaluate().first, ...horizontal];
    outer:
    for (final list in lists) {
      final state = (list as StatefulElement).state as ScrollableState;
      final vertical = state.position.axis == Axis.vertical;
      for (final dir in [1.0, -1.0]) {
        for (var i = 0; i < 60; i++) {
          if (finder.evaluate().isNotEmpty) break outer;
          final before = state.position.pixels;
          final d = -dir * step;
          await tester.drag(find.byElementPredicate((e) => identical(e, list)), vertical ? Offset(0, d) : Offset(d, 0));
          await tester.pump(const Duration(milliseconds: 100));
          if (state.position.pixels == before) break;
        }
      }
    }
  }
  expect(finder, findsWidgets, reason: 'scrolled every list and did not find ${finder.describeMatch(Plurality.one)}');
  await tester.ensureVisible(finder.first);
  await settle(tester, frames: 2);
}

/// Whether the widget [finder] points at exposes [action] to accessibility: on the
/// semantics node it belongs to (a label inside a button), or on a node inside it
/// (a tooltip or text field wrapping the control).
bool hasSemanticsAction(WidgetTester tester, Finder finder, SemanticsAction action) {
  if (tester.getSemantics(finder.first).getSemanticsData().hasAction(action)) return true;
  var found = false;
  void visit(Element e) {
    if (found) return;
    if (e is RenderObjectElement) {
      final node = e.renderObject.debugSemantics;
      if (node != null && node.getSemanticsData().hasAction(action)) {
        found = true;
        return;
      }
    }
    e.visitChildren(visit);
  }

  finder.evaluate().first.visitChildren(visit);
  return found;
}

/// Asserts that the widget [finder] points at (or the control it belongs to) exposes an
/// enabled tap action to accessibility. True for any button, chip, tile, field or InkWell
/// with a handler; false for a disabled control or plain text.
void expectTappable(WidgetTester tester, Finder finder, {String? reason}) {
  expect(finder, findsWidgets, reason: reason);
  expect(
    hasSemanticsAction(tester, finder, SemanticsAction.tap),
    isTrue,
    reason: reason ?? 'expected ${finder.describeMatch(Plurality.one)} to be tappable',
  );
}

/// Same as [expectTappable], for long-press (rule R7 rows).
void expectLongPressable(WidgetTester tester, Finder finder, {String? reason}) {
  expect(finder, findsWidgets, reason: reason);
  expect(hasSemanticsAction(tester, finder, SemanticsAction.longPress), isTrue, reason: reason);
}

/// An action that is either on screen (by tooltip or label) or has moved into a menu
/// opened by one of [menus] (tooltips), e.g. the Buy header "Add" menu. Returns its finder
/// and whether a menu had to be opened (close it with [dismissPopup] if you don't tap).
Future<({Finder finder, bool inMenu})> revealAction(
  WidgetTester tester,
  String label, {
  List<String> menus = const ['Add'],
}) async {
  Finder direct() {
    final byTip = find.byTooltip(label);
    return byTip.evaluate().isNotEmpty ? byTip : textCI(label);
  }

  if (direct().evaluate().isNotEmpty) return (finder: direct(), inMenu: false);
  for (final m in menus) {
    final menu = find.byTooltip(m);
    if (menu.evaluate().isEmpty) continue;
    await tapAndSettle(tester, menu);
    if (direct().evaluate().isNotEmpty) return (finder: direct(), inMenu: true);
    await dismissPopup(tester);
  }
  fail('"$label" is neither on screen nor in the ${menus.join('/')} menu');
}

/// Taps an action found by [revealAction].
Future<void> tapAction(WidgetTester tester, String label, {List<String> menus = const ['Add']}) async {
  await tapAndSettle(tester, (await revealAction(tester, label, menus: menus)).finder);
}

/// Closes a popup menu by tapping its barrier.
Future<void> dismissPopup(WidgetTester tester) async {
  await tester.tapAt(const Offset(8, 120));
  await settle(tester, frames: 6);
}

/// Taps the first match and lets the app settle (route and sheet transitions take
/// about 300 ms, Isar watchers a few ms). Chip labels don't hit-test themselves (the
/// chip does), so the hit warning is off; every tap here is followed by an assertion
/// on its effect.
Future<void> tapAndSettle(WidgetTester tester, Finder finder, {int frames = 6}) async {
  await tester.tap(finder.first, warnIfMissed: false);
  await settle(tester, frames: frames);
}
