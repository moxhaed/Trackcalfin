import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/category_style.dart';
import '../common/format.dart' show shortDate;

Future<void> showTransactionSheet(BuildContext context, Transaction tx) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => TransactionSheet(tx: tx),
);

class TransactionSheet extends ConsumerStatefulWidget {
  const TransactionSheet({super.key, required this.tx});
  final Transaction tx;

  @override
  ConsumerState<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends ConsumerState<TransactionSheet> {
  late final _amount = TextEditingController(text: ref.read(moneyProvider).toInput(widget.tx.totalMinor));
  late final _merchant = TextEditingController(text: widget.tx.merchant ?? widget.tx.note ?? '');
  late SpendCategory _category = widget.tx.primaryCategory;
  late DateTime _date = widget.tx.occurredAt;

  bool get _single => widget.tx.lines.length == 1;

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = ref.read(moneyProvider);
    await ref
        .read(ledgerServiceProvider)
        .update(
          widget.tx.id,
          amountMinor: _single ? money.parse(_amount.text) : null,
          category: _category,
          merchant: widget.tx.merchant != null || !_single ? _merchant.text.trim() : null,
          note: widget.tx.merchant == null && _single ? _merchant.text.trim() : null,
          at: _date,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final tx = widget.tx;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_single ? 'Edit expense' : (tx.merchant ?? 'Receipt'), style: context.text.titleLarge),
              const SizedBox(height: 12),
              if (_single)
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount', prefixText: '${money.symbol} '),
                )
              else
                Text('Total ${money.format(tx.totalMinor)}', style: context.text.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: _merchant,
                decoration: const InputDecoration(labelText: 'Merchant or note'),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in SpendCategory.values)
                    ChoiceChip(
                      avatar: Icon(categoryIcon(c), size: 16),
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(shortDate(_date)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute));
                },
              ),
              if (!_single) ...[
                const Divider(),
                for (final l in tx.lines)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(categoryIcon(l.category), size: 18),
                    title: Text(l.name),
                    subtitle: l.rawText.isNotEmpty ? Text(l.rawText) : null,
                    trailing: Text(money.format(l.totalMinor)),
                  ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _save, child: const Text('Save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
