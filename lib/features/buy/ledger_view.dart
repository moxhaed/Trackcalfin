import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'fx_widgets.dart';
import 'transaction_sheet.dart';

class LedgerView extends ConsumerStatefulWidget {
  const LedgerView({super.key});

  @override
  ConsumerState<LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends ConsumerState<LedgerView> {
  SpendCategory? _filter;

  bool _matches(Transaction t) => _filter == null || t.lines.any((l) => l.category == _filter);

  int _amount(Transaction t) =>
      _filter == null ? t.totalMinor : t.lines.where((l) => l.category == _filter).fold(0, (a, l) => a + l.totalMinor);

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(transactionsProvider).value;
    final money = ref.watch(moneyProvider);
    if (txs == null) return const SizedBox.shrink();
    final list = txs.where(_matches).toList();
    final byDay = groupBy(list, (Transaction t) => DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day));
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    return Column(
      children: [
        // 48 tall so the chips keep their tap targets (the 36 chips sit 6 inside it); 16 padding
        // inside, so the row scrolls to the edges. The list clips at its bottom, so the
        // scrolled-under hairline sits there.
        ScrollEdge(
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
              itemCount: SpendCategory.values.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpace.x2),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return AppChoiceChip(
                    label: 'All',
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  );
                }
                final c = SpendCategory.values[i - 1];
                return AppChoiceChip(
                  label: c.label,
                  icon: categoryIcon(c),
                  selected: _filter == c,
                  onSelected: (_) => setState(() => _filter = _filter == c ? null : c),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions yet',
                  message: 'Scan a receipt or log an expense with the + button.',
                )
              : ListView.builder(
                  // 10 + the first header's 8 = 18 below the strip box, so 24 below the chips themselves.
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    10,
                    AppSpace.screen,
                    MediaQuery.paddingOf(context).bottom + AppSpace.x6,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final items = byDay[day]!;
                    final total = items.fold(0, (a, t) => a + _amount(t));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GroupHeader(dayLabel(day, now), value: money.format(total), first: i == 0),
                        AppGroup(
                          separatorIndent: AppGroup.indentGlyph,
                          children: [for (final t in items) _TxTile(tx: t, amount: _amount(t))],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TxTile extends ConsumerWidget {
  const _TxTile({required this.tx, required this.amount});
  final Transaction tx;
  final int amount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final title = tx.merchant ?? tx.note ?? (tx.lines.length == 1 ? tx.lines.first.name : tx.primaryCategory.label);
    final stocked = tx.lines.where((l) => l.ingredientId != null).length;
    return Dismissible(
      key: ValueKey('tx-${tx.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpace.x6),
        color: context.colors.critical,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        final ledger = ref.read(ledgerServiceProvider);
        final messenger = ScaffoldMessenger.of(context);
        final removed = await ledger.delete(tx.id);
        if (removed != null) {
          showUndoOn(
            messenger,
            'Deleted ${money.format(removed.totalMinor)}',
            detail: stocked > 0 ? 'Its $stocked pantry items were taken back out' : null,
            onUndo: () => ledger.restore(removed),
          );
        }
      },
      child: AppRow(
        leading: GlyphCircle(categoryIcon(tx.primaryCategory)),
        title: title,
        subtitle: [
          timeOf(tx.occurredAt),
          if (tx.lines.length > 1) '${tx.lines.length} items',
          if (stocked > 0) '$stocked stocked',
          if (tx.originalCurrency != null) moneyFor(tx.originalCurrency!).format(tx.originalTotalMinor ?? 0),
          if (tx.source == TxSource.receiptScan && tx.originalCurrency == null) 'scanned',
        ].join(' · '),
        value: money.format(amount),
        onTap: () => showTransactionSheet(context, tx),
      ),
    );
  }
}
