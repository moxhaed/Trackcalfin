// Redesign guard: every primary screen still exposes each of its actions, enabled.
//
// Controls are found by tooltip, semantics or stable data text (category labels,
// recipe and ingredient names), and must expose an enabled tap (or long-press)
// action to accessibility. A few taps check that the action still opens the right
// screen or sheet (by widget type, so restyled sheets keep passing).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/app/providers.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/features/buy/buy_screen.dart';
import 'package:trackcalfin/features/capture/ate_sheet.dart';
import 'package:trackcalfin/features/capture/cooked_sheet.dart';
import 'package:trackcalfin/features/capture/expense_sheet.dart';
import 'package:trackcalfin/features/cook/cook_screen.dart';
import 'package:trackcalfin/features/settings/quick_check_screen.dart';
import 'package:trackcalfin/features/settings/settings_screen.dart';
import 'package:trackcalfin/features/settings/stats_screen.dart';

import '../support/app_harness.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final app = TestApp()..register();

  Future<void> back(WidgetTester tester) async {
    expectTappable(tester, find.byTooltip('Back'), reason: 'pushed screens keep a back button');
    await tapAndSettle(tester, find.byTooltip('Back'));
  }

  testWidgets('shell: four tabs, inbox badge and the global capture button', (tester) async {
    await app.pump(tester);
    // Screen readers must be able to activate each tab (Semantics onTap in floating_nav.dart _PillTab).
    for (final tab in ['Dashboard', 'Buy', 'Cook', 'Settings']) {
      expectTappable(tester, find.bySemanticsLabel(RegExp('^$tab', caseSensitive: false)), reason: 'tab $tab');
    }
    expectTappable(tester, find.byTooltip('Log something'));
    final inbox = (await app.isar.scanJobs.where().findAll()).where((j) => j.status == ScanStatus.needsReview).length;
    expect(textCI('$inbox'), findsWidgets, reason: 'inbox badge on the Buy tab');

    await tapAndSettle(tester, textCI('Buy'));
    expect(find.byType(BuyScreen), findsOneWidget);
    await tapAndSettle(tester, textCI('Cook'));
    expect(find.byType(CookScreen), findsOneWidget);
    await tapAndSettle(tester, textCI('Settings'));
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tapAndSettle(tester, textCI('Dashboard'));
    expect(textHas('Vibe'), findsWidgets);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('capture sheet: six entry points, each opens its flow', (tester) async {
    await app.pump(tester);
    await tapAndSettle(tester, find.byTooltip('Log something'));
    for (final label in ['Scan receipt', 'From photos', 'Pantry', 'Expense', 'I cooked', 'I ate']) {
      expectTappable(tester, textCI(label), reason: 'capture: $label');
    }
    await tapAndSettle(tester, textCI('Expense'));
    expect(find.byType(ExpenseSheet), findsOneWidget);
    await popTop(tester);

    await tapAndSettle(tester, find.byTooltip('Log something'));
    await tapAndSettle(tester, textCI('I cooked'));
    expect(find.byType(CookedSheet), findsOneWidget);
    expectTappable(tester, find.descendant(of: find.byType(CookedSheet), matching: find.byTooltip('More portions')));
    expectTappable(tester, find.descendant(of: find.byType(CookedSheet), matching: textHas('Red lentil')));
    await popTop(tester);

    await tapAndSettle(tester, find.byTooltip('Log something'));
    await tapAndSettle(tester, textCI('I ate'));
    expect(find.byType(AteSheet), findsOneWidget);
    expectTappable(tester, find.descendant(of: find.byType(AteSheet), matching: textCI('Eat 1')));
    expectTappable(tester, find.descendant(of: find.byType(AteSheet), matching: textHas('something else')));
    await popTop(tester);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('dashboard: quick check, add meal, vibe explanation', (tester) async {
    await app.pump(tester);
    expectTappable(tester, textHas('Quick check'));
    expectTappable(tester, textCI('Meal'), reason: 'Today card: add a meal');
    expectTappable(tester, textHas('Vibe'), reason: 'vibe card opens its explanation');

    await tapAndSettle(tester, textHas('Vibe'));
    final view = await loadDashboard(app.isar, DateTime.now());
    expect(view.vibe.components, isNotEmpty);
    for (final c in view.vibe.components.values) {
      expect(find.descendant(of: find.byType(BottomSheet), matching: value('${c.round()}')), findsWidgets);
    }
    await popTop(tester);

    await tapAndSettle(tester, textCI('Meal'));
    expect(find.byType(AteSheet), findsOneWidget);
    await popTop(tester);

    await tapAndSettle(tester, textHas('Quick check'));
    expect(find.byType(QuickCheckScreen), findsOneWidget);
    for (final label in ['Gone', 'Adjust', 'Yes']) {
      expectTappable(tester, textCI(label), reason: 'quick check: $label');
    }
    await back(tester);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('settings: goals, limits, toggles, data tools; stats opens', (tester) async {
    await app.pump(tester, initial: '/settings');
    final p = (await app.isar.userProfiles.get(1))!;
    final m = ProfileService.moneyFor(p);
    expect(
      value(m.compact((p.monthlyFoodBudgetMinor / 4.33).round())),
      findsWidgets,
      reason: 'weekly = monthly ÷ 4.33',
    );
    for (final label in [
      'Monthly food budget',
      'Daily calories',
      'Target cost per portion',
      SpendCategory.eatingOut.label,
      'Log the first portion when I cook',
      'Notifications',
      'File clean receipts automatically',
      'Gemini API key',
      'Dark',
      'Currency (ISO code)',
      'New day starts at',
      'Quick check',
      'Stats',
      'Export backup',
      'Import backup',
      'Run onboarding again',
    ]) {
      await scrollTo(tester, textCI(label));
      expectTappable(tester, textCI(label), reason: 'settings: $label');
    }
    await tapAndSettle(tester, textCI('Stats'));
    expect(find.byType(StatsScreen), findsOneWidget);
    await back(tester);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
