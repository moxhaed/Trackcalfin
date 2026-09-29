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
    if (txs == null) return const Center(child: CircularProgressIndicator());
    final list = txs.where(_matches).toList();
    final byDay = groupBy(list, (Transaction t) => DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day));
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
              ),
              for (final c in SpendCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(categoryIcon(c), size: 16),
                    label: Text(c.label),
                    selected: _filter == c,
                    onSelected: (_) => setState(() => _filter = _filter == c ? null : c),
                  ),
                ),
            ],
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
                  padding: const EdgeInsets.only(bottom: 110),
                  itemCount: days.length,
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final items = byDay[day]!;
                    final total = items.fold(0, (a, t) => a + _amount(t));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(dayLabel(day, now), style: context.text.titleSmall)),
                              Text(money.format(total), style: context.text.labelLarge),
                            ],
                          ),
                        ),
                        for (final t in items) _TxTile(tx: t, amount: _amount(t)),
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
        padding: const EdgeInsets.only(right: 24),
        color: context.scheme.errorContainer,
        child: Icon(Icons.delete_outline, color: context.scheme.onErrorContainer),
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.scheme.surfaceContainerHighest,
          child: Icon(categoryIcon(tx.primaryCategory), size: 20),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            timeOf(tx.occurredAt),
            if (tx.lines.length > 1) '${tx.lines.length} items',
            if (stocked > 0) '$stocked stocked',
            if (tx.source == TxSource.receiptScan) 'scanned',
          ].join(' · '),
        ),
        trailing: Text(money.format(amount), style: context.text.titleSmall),
        onTap: () => showTransactionSheet(context, tx),
      ),
    );
  }
}
