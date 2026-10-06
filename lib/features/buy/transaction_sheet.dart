import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/category_style.dart';
import '../common/format.dart' show shortDate;
import '../common/widgets.dart';
import 'fx_widgets.dart';

Future<void> showTransactionSheet(BuildContext context, Transaction tx) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
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
    final secondary = context.scheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_single ? 'Edit expense' : (tx.merchant ?? 'Receipt'), style: context.text.headlineSmall),
              const SizedBox(height: AppSpace.x4),
              if (_single)
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount', prefixText: '${money.symbol} '),
                )
              else
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Total ',
                        style: context.text.bodyMedium?.copyWith(color: secondary),
                      ),
                      TextSpan(text: money.format(tx.totalMinor), style: context.nums.medium),
                    ],
                  ),
                ),
              if (tx.originalCurrency != null && tx.fxRate != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.tight),
                  child: SeparatedText(
                    'Paid ${moneyFor(tx.originalCurrency!).format(tx.originalTotalMinor ?? 0)} · '
                    '1 ${tx.originalCurrency} = ${rateText(tx.fxRate!)} ${tx.currency}',
                    style: context.text.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpace.x3),
              TextField(
                controller: _merchant,
                decoration: const InputDecoration(labelText: 'Merchant or note'),
              ),
              const SizedBox(height: AppSpace.x3),
              Wrap(
                spacing: AppSpace.x2,
                runSpacing: AppSpace.x2,
                children: [
                  for (final c in SpendCategory.values)
                    AppChoiceChip(
                      icon: categoryIcon(c),
                      label: c.label,
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.x2),
              AppRow(
                leading: const Icon(Icons.event_outlined, size: 20),
                title: shortDate(_date),
                chevron: true,
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
                const Divider(height: 0.5, thickness: 0.5),
                for (final l in tx.lines)
                  AppRow(
                    leading: Icon(categoryIcon(l.category), size: 20),
                    title: l.name,
                    subtitle: l.rawText.isNotEmpty ? l.rawText : null,
                    value: money.format(l.totalMinor),
                  ),
              ],
              const SizedBox(height: AppSpace.x5),
              FilledButton(style: AppTheme.largeButton, onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
