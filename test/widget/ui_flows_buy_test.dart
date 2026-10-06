// Redesign guard: Buy-side user flows driven through the UI, with their database
// effect asserted (pantry, ledger, expense capture, receipt review, quick check).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/costing.dart';
import 'package:trackcalfin/domain/quick_check.dart';
import 'package:trackcalfin/features/buy/review_screen.dart';
import 'package:trackcalfin/features/buy/transaction_sheet.dart';
import 'package:trackcalfin/features/capture/expense_sheet.dart';
import 'package:trackcalfin/features/settings/quick_check_screen.dart';

import '../support/app_harness.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final app = TestApp()..register();

  Future<Ingredient> ing(String key) async => (await app.isar.ingredients.getByKey(key))!;
  Finder dismissibleOf(String text) => find.ancestor(of: textExact(text), matching: find.byType(Dismissible));

  testWidgets('pantry: swipe marks an item out, Undo restores the quantity', (tester) async {
    await app.pump(tester, initial: '/buy');
    final before = await ing('spinach');
    expect(before.qtyOnHand, greaterThan(0));
    final tile = dismissibleOf('Spinach');
    await scrollTo(tester, tile);
    await tester.drag(tile, const Offset(-500, 0));
    await settle(tester);
    expect((await ing('spinach')).qtyOnHand, 0, reason: 'swipe = markOut');
    expect(textHas('Spinach'), findsWidgets, reason: 'undo snackbar names the item');

    await tapAndSettle(tester, textCI('Undo'));
    final after = await ing('spinach');
    expect(after.qtyOnHand, before.qtyOnHand);
    expect(after.lastVerifiedAt, isNotNull);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('expense: amount + category chip logs it in one tap; Undo deletes it', (tester) async {
    await app.pump(tester, initial: '/buy');
    final count = await app.isar.transactions.count();
    await tapAction(tester, 'Log expense');
    final sheet = find.byType(ExpenseSheet);
    await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)).first, '12.50');
    await settle(tester, frames: 3);
    await tapAndSettle(tester, find.descendant(of: sheet, matching: textCI(SpendCategory.eatingOut.label)));

    expect(find.byType(ExpenseSheet), findsNothing, reason: 'the chip is the save');
    final tx = (await app.isar.transactions.where().findAll()).firstWhere((t) => t.totalMinor == 1250);
    expect(await app.isar.transactions.count(), count + 1);
    expect(tx.primaryCategory, SpendCategory.eatingOut);
    expect(tx.source, TxSource.manual);
    expect(tx.currency, 'EUR');
    expect(tx.lines.single.totalMinor, 1250);
    expect(tx.lines.single.category, SpendCategory.eatingOut);

    await tapAndSettle(tester, textCI('Undo'));
    expect(await app.isar.transactions.get(tx.id), isNull);
    expect(await app.isar.transactions.count(), count);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('expense: typed "7.80 lunch" + enter is parsed; a new keyword is learned', (tester) async {
    await app.pump(tester, initial: '/buy');
    Future<Transaction> logText(String text, {SpendCategory? chip}) async {
      await tapAction(tester, 'Log expense');
      final sheet = find.byType(ExpenseSheet);
      await tester.enterText(find.descendant(of: sheet, matching: find.byType(TextField)).first, text);
      await settle(tester, frames: 3);
      if (chip == null) {
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await settle(tester, frames: 8);
      } else {
        await tapAndSettle(tester, find.descendant(of: sheet, matching: textCI(chip.label)));
      }
      expect(find.byType(ExpenseSheet), findsNothing);
      final all = await app.isar.transactions.where().findAll();
      return all.reduce((a, b) => a.id > b.id ? a : b);
    }

    final lunch = await logText('7.80 lunch');
    expect(lunch.totalMinor, 780);
    expect(lunch.primaryCategory, SpendCategory.eatingOut, reason: 'built-in keyword');
    expect(lunch.note, 'lunch');
    expect(lunch.source, TxSource.quickText);

    final first = await logText('9 zorbing', chip: SpendCategory.entertainment);
    expect(first.primaryCategory, SpendCategory.entertainment);
    final p = (await app.isar.userProfiles.get(1))!;
    expect(p.learnedKeywords.any((k) => k.keyword == 'zorbing' && k.category == SpendCategory.entertainment), isTrue);

    final again = await logText('5 zorbing');
    expect(again.totalMinor, 500);
    expect(again.primaryCategory, SpendCategory.entertainment, reason: 'learned keyword');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('ledger: swipe deletes a transaction, Undo restores it; tap edits amount and category', (tester) async {
    await app.pump(tester, initial: '/buy');
    await tapAndSettle(tester, textCI('Ledger'));
    final cafe = (await app.isar.transactions.filter().merchantEqualTo('Café').findFirst())!;

    await tester.drag(dismissibleOf('Café'), const Offset(-500, 0));
    await settle(tester);
    expect(await app.isar.transactions.get(cafe.id), isNull);
    await tapAndSettle(tester, textCI('Undo'));
    final restored = (await app.isar.transactions.get(cafe.id))!;
    expect(restored.totalMinor, cafe.totalMinor);

    await tapAndSettle(tester, textExact('Café'));
    final sheet = find.byType(TransactionSheet);
    expect(sheet, findsOneWidget);
    await tester.enterText(find.descendant(of: sheet, matching: fieldLabelled('amount')), '9.10');
    await tapAndSettle(tester, find.descendant(of: sheet, matching: textCI(SpendCategory.other.label)));
    await tapAndSettle(tester, find.descendant(of: sheet, matching: textCI('Save')));
    expect(find.byType(TransactionSheet), findsNothing);
    final edited = (await app.isar.transactions.get(cafe.id))!;
    expect(edited.totalMinor, 910);
    expect(edited.lines.single.totalMinor, 910);
    expect(edited.primaryCategory, SpendCategory.other);
    expect(edited.lines.single.category, SpendCategory.other);
    expect(edited.merchant, 'Café');
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('review: untick a line, Looks good files the rest with WAC stock; Discard drops a scan', (tester) async {
    await app.pump(tester, initial: '/inbox');
    final jobs = await app.isar.scanJobs.where().findAll();
    final aldi = jobs.firstWhere((j) => j.merchant == 'Aldi');
    final migros = jobs.firstWhere((j) => j.merchant!.startsWith('Migros'));
    final milk = await ing('whole_milk');
    final m = ProfileService.moneyFor((await app.isar.userProfiles.get(1))!);

    await tapAndSettle(tester, textHas('Aldi'));
    expect(find.byType(ReviewScreen), findsOneWidget);
    // Only the line that needs attention is expanded: untick it.
    final low = aldi.lines.singleWhere((l) => l.needsAttention);
    final box = find.descendant(of: find.byType(ReviewScreen), matching: find.byType(Checkbox));
    expect(box, findsOneWidget);
    await tapAndSettle(tester, box);
    final kept = aldi.lines.where((l) => l != low).toList();
    final total = kept.fold(0, (a, l) => a + l.totalMinor);
    expect(value(m.format(total)), findsWidgets, reason: 'total follows the checkbox');

    await tapAndSettle(tester, textCI('Looks good'), frames: 12);
    expect(find.byType(ReviewScreen), findsNothing);
    final job = (await app.isar.scanJobs.get(aldi.id))!;
    expect(job.status, ScanStatus.committed);
    final tx = (await app.isar.transactions.get(job.transactionId!))!;
    expect(tx.totalMinor, total);
    expect(tx.lines.map((l) => l.name), kept.map((l) => l.name));
    expect(tx.source, TxSource.receiptScan);
    expect(await app.isar.ingredients.getByKey(low.ingredientKey!), isNull, reason: 'unticked line not stocked');

    final milkLine = kept.firstWhere((l) => l.ingredientKey == 'whole_milk');
    CostingEngine.applyPurchase(
      milk,
      qtyAdded: milkLine.qty!,
      lineTotalMinor: milkLine.totalMinor,
      at: aldi.purchasedAt!,
    );
    final milkAfter = await ing('whole_milk');
    expect(milkAfter.qtyOnHand, milk.qtyOnHand);
    expect(milkAfter.avgCostPerUnitMinor, closeTo(milk.avgCostPerUnitMinor, 1e-9));
    final broccoli = await ing('broccoli');
    expect(broccoli.qtyOnHand, 500);
    expect(broccoli.avgCostPerUnitMinor, closeTo(129 / 500, 1e-9));

    await tapAndSettle(tester, textHas('Migros'));
    await tapAndSettle(tester, textCI('Discard'));
    expect(find.byType(ReviewScreen), findsNothing);
    expect((await app.isar.scanJobs.get(migros.id))!.status, ScanStatus.discarded);
    expect(textHas('Migros'), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 60)));

  testWidgets('quick check: swipe right keeps an item, Gone marks the next one out', (tester) async {
    await app.pump(tester);
    final deck = QuickCheck.candidates(await app.isar.ingredients.where().findAll(), DateTime.now());
    expect(deck.length, greaterThanOrEqualTo(2));
    await tapAndSettle(tester, textHas('Quick check'));
    expect(find.byType(QuickCheckScreen), findsOneWidget);
    expect(textHas(deck[0].name), findsWidgets);

    final card = find.descendant(of: find.byType(QuickCheckScreen), matching: find.byType(Dismissible));
    await tester.drag(card, const Offset(500, 0));
    await settle(tester);
    final kept = (await app.isar.ingredients.get(deck[0].id))!;
    expect(kept.qtyOnHand, deck[0].qtyOnHand, reason: 'right = still have it');
    expect(kept.lastVerifiedAt, isNotNull);

    expect(textHas(deck[1].name), findsWidgets);
    await tapAndSettle(tester, textCI('Gone'));
    expect((await app.isar.ingredients.get(deck[1].id))!.qtyOnHand, 0);
  }, timeout: const Timeout(Duration(seconds: 60)));

  // KNOWN BUG, fix approved by the Guardian (UI layer, lib/features/settings/quick_check_screen.dart):
  // the screen snapshots its deck with ref.read(quickCheckProvider) on first build, before the
  // pantry stream emits, so a cold open (the weekly-recap notification's "/quick-check" deep
  // link) shows "Nothing to check". Flip [quickCheckColdOpenFixed] when the fix lands.
  testWidgets(
    'quick check opened cold (deep link) shows the same deck as the dashboard chip',
    (tester) async {
      await app.pump(tester, initial: '/quick-check');
      final deck = QuickCheck.candidates(await app.isar.ingredients.where().findAll(), DateTime.now());
      expect(deck, isNotEmpty);
      expect(textHas(deck.first.name), findsWidgets, reason: 'first card');
      expect(textWith('${deck.length}', 'quick check'), findsOneWidget, reason: 'progress "1 / ${deck.length}"');
      await tapAndSettle(tester, textCI('Gone'));
      expect((await app.isar.ingredients.get(deck.first.id))!.qtyOnHand, 0);
    },
    skip: !quickCheckColdOpenFixed,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

/// Set to true when the cold-open Quick check bug is fixed (see the test above).
const quickCheckColdOpenFixed = true;
