import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../domain/quick_text_parser.dart';
import '../common/category_style.dart';
import '../common/widgets.dart';

Future<void> showExpenseSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => const ExpenseSheet(),
);

/// Amount, then tap a category chip: the chip IS the save (rule R2).
class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({super.key});

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _timer = LogTimer();
  bool _textMode = false;
  bool _showNote = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  List<SpendCategory> _orderedCategories() {
    final hour = DateTime.now().hour;
    final recent = (ref.read(transactionsProvider).value ?? const [])
        .where((t) => t.source != TxSource.receiptScan)
        .take(30)
        .map((t) => t.primaryCategory)
        .toList();
    final score = <SpendCategory, double>{for (final c in SpendCategory.values) c: 0};
    for (var i = 0; i < recent.length; i++) {
      score[recent[i]] = score[recent[i]]! + (30 - i) / 30;
    }
    final mealTime = (hour >= 11 && hour <= 14) || (hour >= 18 && hour <= 22);
    if (mealTime) score[SpendCategory.eatingOut] = score[SpendCategory.eatingOut]! + 3;
    final list = SpendCategory.values.toList()..sort((a, b) => score[b]!.compareTo(score[a]!));
    return list;
  }

  ParsedExpense? get _parsed {
    final profile = ref.read(profileProvider).value;
    return QuickTextParser.parse(
      _amount.text,
      learned: profile?.learnedKeywords ?? const [],
      money: ref.read(moneyProvider),
    );
  }

  Future<void> _commit(SpendCategory? category) async {
    final parsed = _parsed;
    if (parsed == null) {
      setState(() => _error = 'Type an amount first');
      return;
    }
    final cat = category ?? parsed.category;
    if (cat == null) {
      setState(() => _error = 'Tap a category to save');
      return;
    }
    final note = [parsed.note, _note.text.trim()].where((s) => s.isNotEmpty).join(' · ');
    final learn = parsed.keyword != null && parsed.note.isNotEmpty && parsed.category != cat ? parsed.keyword : null;
    final ledger = ref.read(ledgerServiceProvider);
    final profile = ref.read(profileProvider).value;
    final metrics = ref.read(metricsServiceProvider);
    final money = ref.read(moneyProvider);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final id = await ledger.logQuickExpense(
      amountMinor: parsed.amountMinor,
      category: cat,
      note: note.isEmpty ? null : note,
      source: parsed.note.isNotEmpty ? TxSource.quickText : TxSource.manual,
      currency: profile?.currency ?? 'EUR',
      learnKeyword: learn ?? (parsed.category == null && parsed.keyword != null ? parsed.keyword : null),
    );
    unawaited(metrics.record('expense', _timer.elapsed));
    celebrate();
    if (!mounted) return;
    nav.pop();
    showUndoOn(messenger, '${money.format(parsed.amountMinor)} · ${cat.label}', onUndo: () => ledger.delete(id));
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final parsed = _parsed;
    final cats = _orderedCategories();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        // With the keyboard up there may be no room for every category: scroll to them.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log an expense', style: context.text.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _amount,
                autofocus: true,
                keyboardType: _textMode ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                style: context.text.headlineMedium,
                decoration: InputDecoration(
                  prefixText: '${money.symbol} ',
                  hintText: _textMode ? '12.50 lunch' : '0.00',
                  errorText: _error,
                  suffixIcon: IconButton(
                    tooltip: _textMode ? 'Numbers only' : 'Type "12.50 lunch"',
                    icon: Icon(_textMode ? Icons.dialpad : Icons.keyboard),
                    onPressed: () => setState(() => _textMode = !_textMode),
                  ),
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _commit(null),
              ),
              if (parsed != null && parsed.category != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${money.format(parsed.amountMinor)} · ${parsed.category!.label}. Press enter to save.',
                    style: context.text.bodySmall,
                  ),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in cats)
                    ActionChip(
                      avatar: Icon(categoryIcon(c), size: 18),
                      label: Text(c.label),
                      backgroundColor: parsed?.category == c ? context.scheme.primaryContainer : null,
                      onPressed: () => _commit(c),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              if (!_showNote)
                TextButton.icon(
                  onPressed: () => setState(() => _showNote = true),
                  icon: const Icon(Icons.notes, size: 18),
                  label: const Text('Add a note'),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: _note,
                    decoration: const InputDecoration(hintText: 'Note or merchant'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
