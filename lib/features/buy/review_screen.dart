import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/messenger.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/widgets.dart';

/// Review card: good lines collapsed, amber lines open, one "Looks good".
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.jobId});
  final int jobId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  ScanJob? _job;
  bool _showAll = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ref.read(isarProvider).scanJobs.get(widget.jobId).then((j) => setState(() => _job = j));
  }

  Future<void> _persist() async {
    if (_job != null) await ref.read(scanServiceProvider).updateJob(_job!);
  }

  Future<void> _commit() async {
    setState(() => _saving = true);
    await _persist();
    final money = ref.read(moneyProvider);
    final job = _job!;
    final total = job.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);
    final stocked = job.lines.where((l) => l.include && l.ingredientKey != null && (l.qty ?? 0) > 0).length;
    await ref.read(scanServiceProvider).commit(job.id);
    celebrate();
    if (!mounted) return;
    Navigator.of(context).pop();
    notifyApp(
      job.kind == ScanKind.pantry
          ? 'Pantry updated · $stocked items verified'
          : '${job.merchant ?? 'Receipt'} ${money.format(total)} · $stocked items stocked',
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    if (job == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final money = ref.watch(moneyProvider);
    final pantry = job.kind == ScanKind.pantry;
    final ingredients = {for (final i in ref.watch(ingredientsProvider).value ?? const <Ingredient>[]) i.id: i};
    final attention = <int>[];
    final fine = <int>[];
    for (var i = 0; i < job.lines.length; i++) {
      (job.lines[i].needsAttention ? attention : fine).add(i);
    }
    final sum = job.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);
    return Scaffold(
      appBar: AppBar(title: Text(pantry ? 'Pantry photo' : (job.merchant ?? 'Receipt'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          if (!pantry)
            Text(
              '${job.purchasedAt != null ? shortDate(job.purchasedAt!) : ''} · ${job.lines.length} lines',
              style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          const SizedBox(height: 8),
          if (job.flags.contains('total_mismatch') && job.receiptTotalMinor != null)
            _Banner(
              icon: Icons.calculate_outlined,
              color: context.colors.serious,
              text:
                  'Items add up to ${money.format(sum)} but the receipt says ${money.format(job.receiptTotalMinor!)}. '
                  'Fix an amount below or file it as is.',
            ),
          if (job.flags.contains('foreign_currency'))
            _Banner(
              icon: Icons.currency_exchange,
              color: context.colors.warning,
              text: 'This receipt is in ${job.currency}. Edit amounts into your home currency before filing.',
            ),
          if (job.flags.contains('date_adjusted'))
            _Banner(
              icon: Icons.event_busy_outlined,
              color: context.colors.warning,
              text: 'The printed date looked wrong, so the photo date is used.',
            ),
          if (attention.isNotEmpty) ...[
            _Label('Check ${attention.length}'),
            for (final i in attention)
              _LineEditor(
                line: job.lines[i],
                pantry: pantry,
                ingredients: ingredients,
                onChanged: () => setState(() {}),
              ),
          ],
          _Label(pantry ? '${fine.length} items detected' : '${fine.length} look good'),
          if (!_showAll && fine.isNotEmpty)
            Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: context.colors.good),
                title: Text(fine.take(4).map((i) => job.lines[i].name).join(', ') + (fine.length > 4 ? '…' : '')),
                trailing: const Text('Show'),
                onTap: () => setState(() => _showAll = true),
              ),
            )
          else
            for (final i in fine)
              _LineEditor(
                line: job.lines[i],
                pantry: pantry,
                ingredients: ingredients,
                onChanged: () => setState(() {}),
              ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              TextButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  await ref.read(scanServiceProvider).discard(job.id);
                  nav.pop();
                },
                child: const Text('Discard'),
              ),
              const Spacer(),
              if (!pantry) Text(money.format(sum), style: context.text.titleMedium),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _commit,
                icon: const Icon(Icons.check),
                label: Text(pantry ? 'Update pantry' : 'Looks good'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(
      text.toUpperCase(),
      style: context.text.labelMedium?.copyWith(letterSpacing: 0.8, color: context.scheme.onSurfaceVariant),
    ),
  );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}

class _LineEditor extends ConsumerStatefulWidget {
  const _LineEditor({required this.line, required this.pantry, required this.ingredients, required this.onChanged});
  final DraftLine line;
  final bool pantry;
  final Map<int, Ingredient> ingredients;
  final VoidCallback onChanged;

  @override
  ConsumerState<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends ConsumerState<_LineEditor> {
  late final _amount = TextEditingController(text: ref.read(moneyProvider).toInput(widget.line.totalMinor));
  late final _qty = TextEditingController(text: widget.line.qty == null ? '' : _fmt(widget.line.qty!));
  bool _open = false;

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _amount.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.line;
    final money = ref.watch(moneyProvider);
    final c = context.colors;
    final merge = l.mergeCandidateId == null ? null : widget.ingredients[l.mergeCandidateId];
    final current = l.matchedIngredientId == null ? null : widget.ingredients[l.matchedIngredientId];
    final open = _open || l.needsAttention;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: l.include,
                  onChanged: (v) {
                    setState(() => l.include = v ?? true);
                    widget.onChanged();
                  },
                ),
                Icon(categoryIcon(l.category), size: 18, color: context.scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _open = !_open),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.name, style: context.text.titleSmall),
                        Text(
                          [
                            if (l.qty != null) '${l.qtySource == QtySource.inferred ? '~' : ''}${qty(l.qty!, l.unit)}',
                            if (l.isNewIngredient && l.ingredientKey != null) 'new item',
                            if (l.ingredientKey == null && l.category != SpendCategory.groceries) l.category.label,
                            if (l.confidence == Confidence.low) 'hard to read',
                            if (widget.pantry && current != null) 'was ${qty(current.qtyOnHand, current.baseUnit)}',
                          ].join(' · '),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!widget.pantry) Text(money.format(l.totalMinor), style: context.text.titleSmall),
              ],
            ),
            if (merge != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Row(
                  children: [
                    Icon(Icons.merge_type, size: 18, color: c.warning),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Same as "${merge.name}"?', style: context.text.bodyMedium)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          l.matchedIngredientId = merge.id;
                          l.ingredientKey = merge.key;
                          l.isNewIngredient = false;
                          l.mergeCandidateId = null;
                          l.unit = merge.baseUnit;
                        });
                        widget.onChanged();
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => l.mergeCandidateId = null);
                        widget.onChanged();
                      },
                      child: const Text('No, new'),
                    ),
                  ],
                ),
              ),
            if (open)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (!widget.pantry)
                          Expanded(
                            child: TextField(
                              controller: _amount,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '${money.symbol} ',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                l.totalMinor = money.parse(v) ?? l.totalMinor;
                                if (v.trim().startsWith('-')) l.totalMinor = -l.totalMinor.abs();
                                widget.onChanged();
                              },
                            ),
                          ),
                        if (!widget.pantry) const SizedBox(width: 8),
                        if (l.ingredientKey != null)
                          Expanded(
                            child: TextField(
                              controller: _qty,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                suffixText: l.unit.label,
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final q = double.tryParse(v.replaceAll(',', '.'));
                                l.qty = q;
                                l.qtySource = q == null ? QtySource.unknown : QtySource.printed;
                                if (l.confidence == Confidence.low && q != null) l.confidence = Confidence.medium;
                                widget.onChanged();
                              },
                            ),
                          ),
                      ],
                    ),
                    if (!widget.pantry) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final cat in SpendCategory.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(cat.label),
                                  selected: l.category == cat,
                                  onSelected: (_) {
                                    setState(() {
                                      l.category = cat;
                                      if (cat != SpendCategory.groceries) l.ingredientKey = null;
                                    });
                                    widget.onChanged();
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (l.confidence == Confidence.low)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() => l.confidence = Confidence.medium);
                            widget.onChanged();
                          },
                          child: const Text('Mark as correct'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
