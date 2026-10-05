// Redesign guard (Buy, Cook, recipe detail): every action is still exposed, enabled.
// Split from action_reachability_test.dart so the two files run in parallel.
//
// Controls are found by tooltip, semantics or stable data text (category labels,
// recipe and ingredient names), and must expose an enabled tap (or long-press)
// action to accessibility. A few taps check that the action still opens the right
// screen or sheet (by widget type, so restyled sheets keep passing).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/features/buy/buy_screen.dart';
import 'package:trackcalfin/features/buy/inbox_screen.dart';
import 'package:trackcalfin/features/buy/ingredient_sheet.dart';
import 'package:trackcalfin/features/buy/transaction_sheet.dart';
import 'package:trackcalfin/features/capture/expense_sheet.dart';
import 'package:trackcalfin/features/cook/cook_screen.dart';
import 'package:trackcalfin/features/cook/recipe_detail_screen.dart';
import 'package:trackcalfin/features/cook/recipe_editor_screen.dart';

import '../support/app_harness.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final app = TestApp()..register();

  Future<void> back(WidgetTester tester) async {
    expectTappable(tester, find.byTooltip('Back'), reason: 'pushed screens keep a back button');
    await tapAndSettle(tester, find.byTooltip('Back'));
  }

  testWidgets('buy: scan, pantry photo, expense, add item, inbox, pantry/ledger, search', (tester) async {
    await app.pump(tester, initial: '/buy');
    // On screen today; the redesign may move them into a header "Add" menu.
    for (final label in ['Scan receipt', 'Pantry photo', 'Log expense', 'Add pantry item']) {
      final action = await revealAction(tester, label);
      expectTappable(tester, action.finder, reason: label);
      if (action.inMenu) await dismissPopup(tester);
    }
    expectTappable(tester, find.byTooltip('Inbox'));
    expectTappable(tester, textCI('Pantry'));
    expectTappable(tester, textCI('Ledger'));

    // Search filters the pantry.
    final search = fieldLabelled('search');
    expect(search, findsOneWidget);
    await tester.enterText(search, 'spin');
    await settle(tester, frames: 4);
    expect(textExact('Spinach'), findsWidgets);
    expect(textExact('Chicken breast'), findsNothing);
    await tester.enterText(search, '');
    await settle(tester, frames: 4);

    // Item tap opens the item sheet with its quick actions.
    await scrollTo(tester, textExact('Bacon'));
    await tapAndSettle(tester, textExact('Bacon'));
    expect(find.byType(IngredientSheet), findsOneWidget);
    final sheet = find.byType(IngredientSheet);
    expectTappable(tester, find.descendant(of: sheet, matching: find.byTooltip('Edit details')));
    for (final label in ["I'm out", 'Looks right', 'Confirm', 'Scan label', 'Edit']) {
      expectTappable(
        tester,
        find.descendant(of: sheet, matching: textCI(label)),
        reason: 'item sheet: $label',
      );
    }
    await popTop(tester);

    await tapAction(tester, 'Add pantry item');
    expect(find.byType(IngredientSheet), findsOneWidget);
    await popTop(tester);

    await tapAction(tester, 'Log expense');
    expect(find.byType(ExpenseSheet), findsOneWidget);
    for (final c in SpendCategory.values) {
      expectTappable(tester, find.descendant(of: find.byType(ExpenseSheet), matching: textCI(c.label)));
    }
    expectTappable(tester, find.byTooltip('Type "12.50 lunch"'), reason: 'expense: text mode toggle');
    await popTop(tester);

    await tapAndSettle(tester, find.byTooltip('Inbox'));
    expect(find.byType(InboxScreen), findsOneWidget);
    expectTappable(tester, textHas('Aldi'));
    expectTappable(tester, textHas('Migros'));
    await back(tester);
    expect(find.byType(BuyScreen), findsOneWidget);

    // Ledger: filter chips and transaction sheet.
    await tapAndSettle(tester, textCI('Ledger'));
    expectTappable(tester, textCI('All'));
    for (final c in SpendCategory.values) {
      await scrollTo(tester, textCI(c.label));
      expectTappable(tester, textCI(c.label), reason: 'ledger filter ${c.label}');
    }
    await tapAndSettle(tester, textExact('Café'));
    expect(find.byType(TransactionSheet), findsOneWidget);
    expectTappable(tester, find.descendant(of: find.byType(TransactionSheet), matching: textCI('Save')));
    await popTop(tester);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('cook: ask + mic/send, stepper, I cooked this, fridge Eat 1 + menu, rotation, write recipe', (
    tester,
  ) async {
    await app.pump(tester, initial: '/cook');
    final ask = find.descendant(of: find.byType(CookScreen), matching: find.byType(TextField));
    expect(ask, findsOneWidget, reason: 'one ask field');
    expectTappable(tester, ask);
    const mic = 'Hold to talk, or tap to send';
    expectTappable(tester, find.byTooltip(mic));
    expectTappable(tester, find.byTooltip('Fewer portions'));
    expectTappable(tester, find.byTooltip('More portions'));
    expectTappable(tester, textCI('I cooked this'));
    expectTappable(tester, textCI('Eat 1'));
    expectTappable(tester, find.byTooltip('Write a recipe'));
    expect(find.descendant(of: find.byType(CookScreen), matching: find.byType(RefreshIndicator)), findsOneWidget);

    // Fridge menu: extend, toss, undo.
    final menu = find.descendant(of: find.byType(CookScreen), matching: find.byType(PopupMenuButton<String>));
    expect(menu, findsOneWidget);
    await tapAndSettle(tester, menu);
    for (final word in ['+2', 'toss', 'undo']) {
      expectTappable(tester, textHas(word), reason: 'fridge menu: $word');
    }
    await dismissPopup(tester);

    // Ask without a key: the service's answer is shown.
    await tester.enterText(ask, 'carbonara for two');
    await settle(tester, frames: 3);
    await tapAndSettle(tester, find.byTooltip(mic));
    expect(textHas('Add a Gemini API key in Settings to ask for recipes.'), findsOneWidget);

    // Pull to refresh keeps the pick.
    await tester.fling(mainScrollable(tester), const Offset(0, 400), 1200);
    await settle(tester, frames: 10);
    expect(textExact('Garlic chicken & spinach rice bowls'), findsOneWidget);

    // Pick card and rotation open the recipe; the pen opens the editor.
    await tapAndSettle(tester, textExact('Garlic chicken & spinach rice bowls'));
    expect(find.byType(RecipeDetailScreen), findsOneWidget);
    await back(tester);
    await scrollTo(tester, textExact('Lighter bacon carbonara'));
    expectTappable(tester, textExact('Lighter bacon carbonara'));
    await tapAndSettle(tester, textExact('Lighter bacon carbonara'));
    expect(find.byType(RecipeDetailScreen), findsOneWidget);
    await back(tester);
    await tapAndSettle(tester, find.byTooltip('Write a recipe'));
    expect(find.byType(RecipeEditorScreen), findsOneWidget);
    expectTappable(tester, textCI('Save'));
    expectTappable(tester, textHas('Add ingredient'));
    await back(tester);
    expect(app.requests, isEmpty, reason: 'no network without a key');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('cook with an API key: swap is offered and nothing calls the AI on its own', (tester) async {
    await app.pump(tester, initial: '/cook', apiKey: 'test-key');
    expectTappable(tester, textCI('Swap'));
    await tapAndSettle(tester, textCI('Buy'));
    await tapAndSettle(tester, find.byTooltip('Inbox'));
    expect(textHas('Gemini API key'), findsNothing, reason: 'no "add a key" card once a key is set');
    expect(app.requests, isEmpty, reason: 'opening screens must not spend AI quota');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('recipe detail: favorite, menu (edit/save/delete), stepper, cook, long-press a row', (tester) async {
    await app.pump(tester, initial: '/cook');
    await tapAndSettle(tester, textExact('Garlic chicken & spinach rice bowls'));
    final detail = find.byType(RecipeDetailScreen);
    expectTappable(tester, find.byTooltip('Favorite'));
    expectTappable(tester, find.descendant(of: detail, matching: find.byTooltip('Fewer portions')));
    expectTappable(tester, find.descendant(of: detail, matching: find.byTooltip('More portions')));
    expectTappable(tester, find.descendant(of: detail, matching: textCI('I cooked this')));
    expectLongPressable(tester, find.descendant(of: detail, matching: textExact('Chicken breast')));

    final menu = find.descendant(of: detail, matching: find.byType(PopupMenuButton<String>));
    expectTappable(tester, menu);
    await tapAndSettle(tester, menu);
    // A suggested recipe can also be saved to the rotation.
    for (final label in ['Edit', 'Save to Cook again', 'Delete']) {
      expectTappable(tester, textCI(label), reason: 'recipe menu: $label');
    }
    await tapAndSettle(tester, textCI('Edit'));
    expect(find.byType(RecipeEditorScreen), findsOneWidget);
    await back(tester);
    expect(find.byType(RecipeDetailScreen), findsOneWidget);

    await tester.longPress(find.descendant(of: detail, matching: textExact('Chicken breast')));
    await settle(tester);
    expectTappable(tester, textHas('out of Chicken breast'));
    expectTappable(tester, textHas('Adjust'));
    await popTop(tester);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
