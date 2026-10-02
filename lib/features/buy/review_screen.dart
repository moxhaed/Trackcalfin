import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/messenger.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/scan_service.dart';
import '../../core/currency.dart';
import '../../core/enums.dart';
import '../../core/money.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/units.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'fx_widgets.dart';

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
  bool _fxBusy = false;

  @override
  void initState() {
    super.initState();
    ref.read(isarProvider).scanJobs.get(widget.jobId).then((j) => setState(() => _job = j));
  }

  Future<void> _persist() async {
    if (_job != null) await ref.read(scanServiceProvider).updateJob(_job!);
  }

  String get _home => ref.read(profileProvider).value?.currency ?? 'EUR';

  int get _sum => _job!.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);

  Future<void> _reload() async {
    final j = await ref.read(isarProvider).scanJobs.get(widget.jobId);
    if (mounted && j != null) setState(() => _job = j);
  }

  Future<void> _commit() async {
    final job = _job!;
    if (ScanService.isForeign(job, _home) && job.fxRate == null) return _setRate();
    setState(() => _saving = true);
    await _persist();
    final money = ref.read(moneyProvider);
    final stocked = job.lines.where((l) => l.include && l.ingredientKey != null && (l.qty ?? 0) > 0).length;
    int? txId;
    try {
      txId = await ref.read(scanServiceProvider).commit(job.id);
    } on MissingExchangeRate {
      setState(() => _saving = false);
      return _setRate();
    }
    final tx = txId == null ? null : await ref.read(isarProvider).transactions.get(txId);
    unawaited(ref.read(nutritionServiceProvider).fillMissing());
    celebrate();
    if (!mounted) return;
    Navigator.of(context).pop();
    final original = tx?.originalCurrency != null
        ? ' (${moneyFor(tx!.originalCurrency!).format(tx.originalTotalMinor ?? 0)})'
        : '';
    notifyApp(
      job.kind == ScanKind.pantry
          ? 'Pantry updated · $stocked items verified'
          : '${job.merchant ?? 'Receipt'} ${money.format(tx?.totalMinor ?? _sum)}$original · $stocked items stocked',
    );
  }

  Future<void> _setRate() async {
    await _persist();
    final job = _job!;
    final home = _home;
    final remembered = await ref.read(fxServiceProvider).remembered(job.currency!, home);
    if (!mounted) return;
    final q = await showRateSheet(
      context,
      from: job.currency!,
      to: home,
      foreignTotal: _sum,
      currentRate: job.fxRate,
      remembered: remembered,
    );
    if (q == null) return;
    await ref.read(scanServiceProvider).applyRate(job.id, q);
    await _reload();
  }

  Future<void> _retryRate() async {
    await _persist();
    setState(() => _fxBusy = true);
    final q = await ref.read(scanServiceProvider).refreshRate(widget.jobId);
    if (!mounted) return;
    setState(() => _fxBusy = false);
    if (q == null) showInfo(context, 'Still no rate. Enter what your card was charged instead.');
    await _reload();
  }

  Future<void> _changeCurrency() async {
    final job = _job!;
    final home = _home;
    final code = await showCurrencySheet(context, current: job.currency ?? home);
    if (code == null) return;
    job
      ..currency = code
      ..fxRate = null
      ..fxSource = null
      ..fxDate = null
      ..flags = [
        ...job.flags.where((f) => f != 'currency_uncertain' && f != 'foreign_currency'),
        if (code != home.toUpperCase()) 'foreign_currency',
      ];
    await _persist();
    if (code != home.toUpperCase()) await _retryRate();
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    if (job == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final money = ref.watch(moneyProvider);
    final home = ref.watch(profileProvider).value?.currency ?? 'EUR';
    final pantry = job.kind == ScanKind.pantry;
    final foreign = ScanService.isForeign(job, home);
    final receiptMoney = foreign ? moneyFor(job.currency!) : money;
    int Function(int)? toHome;
    if (foreign && job.fxRate != null) {
      toHome = (m) => Currency.convert(m, from: job.currency!, to: home, rate: job.fxRate!);
    }
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
                  'Items add up to ${receiptMoney.format(sum)} but the receipt says ${receiptMoney.format(job.receiptTotalMinor!)}. '
                  'Fix an amount below or file it as is.',
            ),
          if (foreign)
            ConversionCard(
              from: job.currency!,
              to: home,
              foreignTotal: sum,
              rate: job.fxRate,
              source: job.fxSource,
              date: job.fxDate,
              busy: _fxBusy,
              onSetRate: _setRate,
              onRetry: _retryRate,
              onChangeCurrency: _changeCurrency,
            ),
          if (job.flags.contains('currency_uncertain') && !pantry)
            _Banner(
              icon: Icons.help_outline,
              color: context.colors.warning,
              text: "Couldn't read the currency, so ${job.currency ?? home} was assumed.",
              actions: [
                TextButton(onPressed: _changeCurrency, child: const Text('Change')),
                TextButton(
                  onPressed: () =>
                      setState(() => job.flags = job.flags.where((f) => f != 'currency_uncertain').toList()),
                  child: const Text("It's right"),
                ),
              ],
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
                receiptMoney: receiptMoney,
                toHome: toHome,
                homeMoney: money,
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
                receiptMoney: receiptMoney,
                toHome: toHome,
                homeMoney: money,
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
              if (!pantry)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      toHome != null ? money.format(toHome(sum)) : receiptMoney.format(sum),
                      style: context.text.titleMedium,
                    ),
                    if (toHome != null) Text(receiptMoney.format(sum), style: context.text.labelSmall),
                  ],
                ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _commit,
                icon: Icon(foreign && job.fxRate == null ? Icons.currency_exchange : Icons.check),
                label: Text(pantry ? 'Update pantry' : (foreign && job.fxRate == null ? 'Set rate' : 'Looks good')),
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
  const _Banner({required this.icon, required this.color, required this.text, this.actions = const []});
  final IconData icon;
  final Color color;
  final String text;
  final List<Widget> actions;

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: context.text.bodyMedium),
              if (actions.isNotEmpty) Wrap(spacing: 4, children: actions),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LineEditor extends ConsumerStatefulWidget {
  const _LineEditor({
    required this.line,
    required this.pantry,
    required this.ingredients,
    required this.onChanged,
    required this.receiptMoney,
    required this.homeMoney,
    this.toHome,
  });
  final DraftLine line;
  final bool pantry;
  final Map<int, Ingredient> ingredients;
  final VoidCallback onChanged;

  /// Amounts are edited in the receipt's currency (so they match the paper).
  final MoneyFormat receiptMoney;
  final MoneyFormat homeMoney;

  /// Converts to the home currency for display; null when not foreign or no rate yet.
  final int Function(int minor)? toHome;

  @override
  ConsumerState<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends ConsumerState<_LineEditor> {
  late final _amount = TextEditingController(text: widget.receiptMoney.toInput(widget.line.totalMinor));
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
                if (!widget.pantry)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.toHome != null
                            ? widget.homeMoney.format(widget.toHome!(l.totalMinor))
                            : widget.receiptMoney.format(l.totalMinor),
                        style: context.text.titleSmall,
                      ),
                      if (widget.toHome != null)
                        Text(widget.receiptMoney.format(l.totalMinor), style: context.text.labelSmall),
                    ],
                  ),
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
                          if (l.qty != null && l.unit != merge.baseUnit) {
                            // Convert into the existing item's unit; unknown if impossible.
                            final converted = UnitConverter.toBase(l.qty!, l.unit, merge);
                            l.qty = converted;
                            if (converted == null) l.qtySource = QtySource.unknown;
                            _qty.text = converted == null ? '' : _fmt(converted);
                          }
                          l.matchedIngredientId = merge.id;
                          l.ingredientKey = merge.key;
                          l.isNewIngredient = false;
                          l.mergeCandidateId = null;
                          l.profile = null;
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
                                prefixText: '${widget.receiptMoney.symbol} ',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                l.totalMinor = widget.receiptMoney.parse(v) ?? l.totalMinor;
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
