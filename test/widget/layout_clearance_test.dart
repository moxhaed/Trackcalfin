// Redesign guard: content never ends up hidden under a bar it can't scroll past.
//
// Tab bodies scroll behind the floating nav (`extendBody`), and pushed screens may scroll
// behind their own bottom bar (Recipe detail's cook bar). Either way, at the end of the list
// the last text must sit above the bar. A list that pads with a MediaQuery read *outside*
// its Scaffold misses the bar's height and fails this.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/app/floating_nav.dart';
import 'package:trackcalfin/features/cook/recipe_detail_screen.dart';

import '../support/app_harness.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final app = TestApp()..register();

  /// Scrolls the main list to its very end (lazy lists grow their extent as they build).
  Future<Finder> scrollToEnd(WidgetTester tester) async {
    final list = mainScrollable(tester);
    final state = tester.state<ScrollableState>(list);
    var last = -1.0;
    for (var i = 0; i < 20 && state.position.maxScrollExtent != last; i++) {
      last = state.position.maxScrollExtent;
      state.position.jumpTo(last);
      await settle(tester, frames: 3);
    }
    return list;
  }

  /// The bottom edge of the lowest text inside [list].
  double lowestText(WidgetTester tester, Finder list) {
    var bottom = double.negativeInfinity;
    for (final e in find.descendant(of: list, matching: find.byType(RichText)).evaluate()) {
      final box = e.renderObject! as RenderBox;
      if (!box.hasSize || !box.attached) continue;
      final b = box.localToGlobal(Offset(0, box.size.height)).dy;
      if (b > bottom) bottom = b;
    }
    return bottom;
  }

  Future<void> expectEndClears(WidgetTester tester, Finder bar, String where) async {
    final list = await scrollToEnd(tester);
    final barTop = tester.getRect(bar).top;
    expect(lowestText(tester, list), lessThanOrEqualTo(barTop + 0.5), reason: '$where: last text under the bar');
  }

  testWidgets('tab lists end above the floating nav', (tester) async {
    await app.pump(tester);
    final nav = find.byType(FloatingNav);
    await expectEndClears(tester, nav, 'Dashboard');
    await tapAndSettle(tester, textCI('Buy'));
    await expectEndClears(tester, nav, 'Buy · Pantry');
    await tapAndSettle(tester, textCI('Ledger'));
    await expectEndClears(tester, nav, 'Buy · Ledger');
    await tapAndSettle(tester, textCI('Cook'));
    await expectEndClears(tester, nav, 'Cook');
    await tapAndSettle(tester, textCI('Settings'));
    await expectEndClears(tester, nav, 'Settings');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail ends above its bottom bar', (tester) async {
    await app.pump(tester, initial: '/cook');
    await tapAndSettle(tester, find.text('Garlic chicken & spinach rice bowls'));
    final scaffold = find.descendant(of: find.byType(RecipeDetailScreen), matching: find.byType(Scaffold)).first;
    final bar = tester.widget<Scaffold>(scaffold).bottomNavigationBar;
    expect(bar, isNotNull, reason: 'the stepper and "I cooked this" live in a bottom bar');
    await expectEndClears(tester, find.byWidget(bar!), 'Recipe detail');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
