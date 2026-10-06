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

/// Amount, then tap a category button: the button IS the save (rule R2).
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
    unawaited(ref.read(metricsServiceProvider).record('expense', _timer.elapsed));
    celebrate();
    if (!mounted) return;
    final money = ref.read(moneyProvider);
    nav.pop();
    showUndoOn(messenger, '${money.format(parsed.amountMinor)} · ${cat.label}', onUndo: () => ledger.delete(id));
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final parsed = _parsed;
    final cats = _orderedCategories();
    final secondary = context.scheme.onSurfaceVariant;
    // The amount is the hero: 44 tabular digits in number mode. Typing "12.50 lunch" is a
    // sentence, so text mode drops to 28.
    final amountStyle = _textMode ? context.nums.large : context.nums.hero;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(header: true, child: Text('Log an expense', style: context.text.headlineSmall)),
              const SizedBox(height: AppSpace.x4),
              TextField(
                controller: _amount,
                autofocus: true,
                keyboardType: _textMode ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                style: amountStyle,
                decoration: InputDecoration(
                  prefixText: '${money.symbol} ',
                  prefixStyle: amountStyle.copyWith(color: secondary, fontWeight: FontWeight.w500),
                  hintText: _textMode ? '12.50 lunch' : '0.00',
                  hintStyle: amountStyle.copyWith(color: context.colors.textTertiary),
                  errorText: _error,
                  // 12 + the 4 a filled field adds puts the "€" 16 in, on the same line as the icons below.
                  contentPadding: const EdgeInsets.fromLTRB(AppSpace.x3, AppSpace.x2, AppSpace.x2, AppSpace.x2),
                  suffixIcon: IconButton(
                    tooltip: _textMode ? 'Numbers only' : 'Type "12.50 lunch"',
                    icon: Icon(_textMode ? Icons.dialpad_rounded : Icons.keyboard_outlined),
                    onPressed: () => setState(() => _textMode = !_textMode),
                  ),
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _commit(null),
              ),
              if (parsed != null && parsed.category != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.x2),
                  child: Text(
                    '${money.format(parsed.amountMinor)} · ${parsed.category!.label}. Press enter to save.',
                    style: context.text.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpace.x4),
              // Two columns of category buttons; a tap is the save.
              for (var i = 0; i < cats.length; i += 2) ...[
                if (i > 0) const SizedBox(height: AppSpace.x2),
                Row(
                  children: [
                    Expanded(
                      child: _CategoryButton(
                        category: cats[i],
                        parsed: parsed?.category == cats[i],
                        onTap: () => _commit(cats[i]),
                      ),
                    ),
                    const SizedBox(width: AppSpace.x2),
                    Expanded(
                      child: i + 1 < cats.length
                          ? _CategoryButton(
                              category: cats[i + 1],
                              parsed: parsed?.category == cats[i + 1],
                              onTap: () => _commit(cats[i + 1]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpace.x2),
              if (!_showNote)
                // The button's own 12 padding is pulled back so its icon sits on the margin.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: const Offset(-AppSpace.x3, 0),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showNote = true),
                      icon: const Icon(Icons.notes_rounded),
                      label: const Text('Add a note'),
                    ),
                  ),
                )
              else
                TextField(
                  controller: _note,
                  decoration: const InputDecoration(hintText: 'Note or merchant'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A category as a 52-tall button on the neutral fill; the one the typed text parsed to is
/// accent-tinted and carries a check (so it isn't marked by color alone). Tapping it saves.
class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.category, required this.parsed, required this.onTap});
  final SpendCategory category;
  final bool parsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.scheme;
    final ink = parsed ? s.onPrimaryContainer : s.onSurface;
    return SizedBox(
      height: 52,
      child: Material(
        color: parsed ? s.primaryContainer : context.colors.fill,
        borderRadius: BorderRadius.circular(AppRadius.input),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
            child: Row(
              children: [
                Icon(categoryIcon(category), size: 20, color: parsed ? s.onPrimaryContainer : s.onSurfaceVariant),
                const SizedBox(width: AppSpace.x2),
                // One line that shrinks a little at large text sizes rather than breaking a word.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      category.label,
                      maxLines: 1,
                      style: context.text.bodyLarge?.copyWith(
                        color: ink,
                        fontWeight: parsed ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (parsed) ...[const SizedBox(width: AppSpace.x1), Icon(Icons.check_rounded, size: 18, color: ink)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
