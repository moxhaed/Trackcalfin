import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/scan_service.dart';
import '../../core/currency.dart';
import '../../core/day_clock.dart';
import '../../core/enums.dart';
import '../../core/money.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/price_book.dart';
import '../../domain/units.dart';
import '../../domain/validation/receipt_validator.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/photo_viewer.dart';
import '../common/search_suggestions.dart';
import '../common/store_prices.dart';
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

  /// What this receipt may be a copy of; null when nothing is (or it was since discarded).
  String? _duplicate;
  bool _showAll = false;
  bool _saving = false;
  bool _fxBusy = false;
  bool _pricesBusy = false;

  /// Lines that needed a look when the scan was opened. They stay under "Check" once answered,
  /// so nothing jumps away mid-edit.
  Set<int> _check = {};

  /// The scan is gone (discarded or cleaned up): say so instead of loading forever.
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  // Each handler below reads what it needs from `ref` before its first await, and checks
  // `mounted` after: the user can leave while it works, and Riverpod's ref throws after dispose.

  Future<void> _persist() async {
    if (_job != null) await ref.read(scanServiceProvider).updateJob(_job!);
  }

  String get _home => ref.read(profileProvider).value?.currency ?? 'EUR';

  int get _sum => _job!.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);

  Future<void> _reload() async {
    if (!mounted) return;
    final j = await ref.read(isarProvider).scanJobs.get(widget.jobId);
    if (!mounted) return;
    if (j == null) {
      setState(() => _gone = true);
      return;
    }
    final duplicate = j.maybeDuplicate ? await _describeDuplicate(j) : null;
    if (mounted) {
      setState(() {
        _job = j;
        _duplicate = duplicate;
        _check = {
          for (final (i, l) in j.lines.indexed)
            if (l.needsAttention) i,
        };
      });
    }
  }

  Future<String?> _describeDuplicate(ScanJob job) async {
    final isar = ref.read(isarProvider);
    final money = ref.read(moneyProvider);
    var txId = job.duplicateOfTxId;
    if (job.duplicateOfJobId != null) {
      final other = await isar.scanJobs.get(job.duplicateOfJobId!);
      if (other?.status == ScanStatus.needsReview) {
        return 'This looks like the same receipt as another scan waiting in your Inbox.';
      }
      txId = other?.status == ScanStatus.committed ? other!.transactionId : null;
    }
    final tx = txId == null ? null : await isar.transactions.get(txId);
    if (tx == null) return null;
    final amount = tx.originalCurrency == null
        ? money.format(tx.totalMinor)
        : moneyFor(tx.originalCurrency!).format(tx.originalTotalMinor ?? 0);
    final what = [?tx.merchant, dateLabel(tx.occurredAt, DateTime.now()), amount].join(' · ');
    return 'This looks like a receipt you already filed: $what.';
  }

  Future<void> _commit() async {
    final job = _job!;
    if (ScanService.isForeign(job, _home) && job.fxRate == null) return _setRate();
    final scans = ref.read(scanServiceProvider);
    final isar = ref.read(isarProvider);
    final prices = ref.read(priceServiceProvider);
    final nutrition = ref.read(nutritionServiceProvider);
    final money = ref.read(moneyProvider);
    setState(() => _saving = true);
    final stocked = job.lines
        .where(
          (l) => l.include && l.ingredientKey != null && (l.qty ?? 0) > 0 && l.effectFor(job.kind) != StockEffect.none,
        )
        .length;
    int? txId;
    try {
      await scans.updateJob(job);
      txId = await scans.commit(job.id);
    } on MissingExchangeRate {
      if (!mounted) return;
      setState(() => _saving = false);
      return _setRate();
    } catch (e) {
      // Not filed: keep the review open and say why, instead of a button stuck on saving.
      if (!mounted) return;
      setState(() => _saving = false);
      showInfo(context, 'Could not file it: $e');
      return;
    }
    final tx = txId == null ? null : await isar.transactions.get(txId);
    final tips = txId == null ? const <PriceTip>[] : await prices.tipsFor(txId);
    unawaited(nutrition.fillMissing());
    celebrate();
    // Filed even when the user left meanwhile: still say so (the app-wide messenger).
    if (mounted) Navigator.of(context).pop();
    final original = tx?.originalCurrency != null
        ? ' (${moneyFor(tx!.originalCurrency!).format(tx.originalTotalMinor ?? 0)})'
        : '';
    final when = tx == null ? '' : dayNote(tx.occurredAt, DateTime.now());
    notifyFiled(
      job.kind == ScanKind.pantry
          ? 'Pantry updated · ${itemCount(stocked)} verified'
          : '${job.merchant ?? 'Receipt'} ${money.format(tx?.totalMinor ?? _sum)}$original$when · '
                '${itemCount(stocked)} stocked',
      tips,
    );
  }

  Future<void> _discard() async {
    await ref.read(scanServiceProvider).discard(widget.jobId);
    // Already closed with Back: popping now would close the screen under it.
    if (mounted) Navigator.of(context).pop();
  }

  /// The receipt's date, set by hand; the time of day is kept.
  Future<void> _pickDate() async {
    final job = _job!;
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final current = job.purchasedAt ?? job.capturedAt;
    final picked = await showDatePicker(
      context: context,
      // A misread year can be out of range; start the picker on the nearest allowed day.
      initialDate: current.isAfter(now) ? now : (current.isBefore(first) ? first : current),
      firstDate: first,
      lastDate: now,
      helpText: 'Date on the receipt',
    );
    if (picked == null || !mounted) return;
    final scans = ref.read(scanServiceProvider);
    await _persist();
    final date = DateTime(picked.year, picked.month, picked.day, current.hour, current.minute);
    await scans.setPurchaseDate(job.id, date);
    await _reload();
  }

  Future<void> _setRate() async {
    final fx = ref.read(fxServiceProvider);
    final scans = ref.read(scanServiceProvider);
    final job = _job!;
    final home = _home;
    await _persist();
    final remembered = await fx.remembered(job.currency!, home);
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
    await scans.applyRate(job.id, q);
    await _reload();
  }

  Future<void> _retryRate() async {
    final scans = ref.read(scanServiceProvider);
    await _persist();
    if (!mounted) return;
    setState(() => _fxBusy = true);
    final q = await scans.refreshRate(widget.jobId);
    if (!mounted) return;
    setState(() => _fxBusy = false);
    if (q == null) showInfo(context, 'Still no rate. Enter what your card was charged instead.');
    await _reload();
  }

  Future<void> _retryPrices() async {
    final scans = ref.read(scanServiceProvider);
    await _persist();
    if (!mounted) return;
    setState(() => _pricesBusy = true);
    await scans.retryPrices(widget.jobId);
    if (!mounted) return;
    setState(() => _pricesBusy = false);
    await _reload();
  }

  Future<void> _changeCurrency() async {
    final job = _job!;
    final home = _home;
    final code = await showCurrencySheet(context, current: job.currency ?? home);
    if (code == null || !mounted) return;
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
    if (job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: _gone
            ? const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'This scan is gone',
                message: 'It was filed or discarded. Anything still waiting is in the Inbox.',
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
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
      (_check.contains(i) || job.lines[i].needsAttention ? attention : fine).add(i);
    }
    final sum = job.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);
    final now = DateTime.now();
    final date = pantry ? null : job.purchasedAt;
    final age = date == null ? 0 : DayClock.daysBetween(date, now);
    final dateNote = date == null
        ? null
        : job.flags.contains('date_missing')
        ? "No date was readable, so it's filed on the day of the photo, ${dateLabel(date, now)}."
        : job.flags.contains('date_adjusted')
        ? 'The printed date looked wrong, so the photo date (${dateLabel(date, now)}) is used.'
        : job.flags.contains('date_old')
        ? 'The printed date is ${dateLabel(date, now)}, over a year ago. Is that right?'
        : null;
    final usedUp = job.lines
        .where((l) => l.include && l.stockCheck == StockCheck.usedUp && l.effectFor(job.kind) == StockEffect.none)
        .length;
    final whatsLeft = [
      for (final l in job.lines)
        if (l.include && l.stockCheck == StockCheck.whatsLeft) l,
    ];
    final onHand = [
      for (final l in job.lines)
        if (l.include && l.stockCheck == StockCheck.onHand) l,
    ];
    final prices = [
      for (final l in job.lines)
        if (l.include && l.priceToConfirm) l,
    ];
    final found = prices.where((l) => l.priceSource == PriceSource.web).length;
    final searched = pantry && job.lines.any((l) => l.include && l.priceSource == PriceSource.web);

    Widget line(int i) => _LineEditor(
      key: ObjectKey(job.lines[i]),
      line: job.lines[i],
      job: job,
      ingredients: ingredients,
      receiptMoney: receiptMoney,
      toHome: toHome,
      homeMoney: money,
      onChanged: () => setState(() {}),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pantry ? 'Pantry photo' : (job.merchant ?? 'Receipt')),
        actions: [
          // Check a hard-to-read line against the receipt itself.
          if (keptPhotos(job.imagePaths).isNotEmpty)
            TextButton.icon(
              onPressed: () => showPhotos(context, job.imagePaths),
              icon: const Icon(Icons.photo_outlined, size: 18),
              label: const Text('Photo'),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          if (!pantry)
            Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      if (date != null) 'Bought ${dateLabel(date, now)}${age > 0 ? ' (${daysAgoLabel(age)})' : ''}',
                      '${job.lines.length} lines',
                    ].join(' · '),
                    style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                  label: const Text('Date'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (job.maybeDuplicate && _duplicate != null)
            _Banner(
              icon: Icons.copy_all_outlined,
              color: context.colors.serious,
              text: _duplicate!,
              actions: [
                TextButton(onPressed: _discard, child: const Text('Discard this one')),
                TextButton(
                  onPressed: () => setState(
                    () => job
                      ..duplicateOfTxId = null
                      ..duplicateOfJobId = null,
                  ),
                  child: const Text("It's a different one"),
                ),
              ],
            ),
          if (dateNote != null)
            _Banner(
              icon: Icons.event_busy_outlined,
              color: context.colors.warning,
              text: dateNote,
              actions: [
                TextButton(onPressed: _pickDate, child: const Text('Change date')),
                TextButton(
                  onPressed: () => setState(
                    () => job.flags = job.flags.where((f) => !ReceiptValidator.dateFlags.contains(f)).toList(),
                  ),
                  child: const Text("It's right"),
                ),
              ],
            )
          else if (date != null && whatsLeft.isNotEmpty)
            _Banner(
              icon: Icons.inventory_2_outlined,
              color: context.scheme.primary,
              text:
                  'Bought ${daysAgoLabel(age)}, so it is filed on ${dateLabel(date, now)}. What is left of it now? '
                  'What is gone counts as eaten in the days since, so those weeks add up.',
              actions: [
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in whatsLeft) {
                      l
                        ..stock = StockEffect.add
                        ..qtyLeft = null
                        ..thrownAway = false;
                    }
                  }),
                  child: const Text('All still here'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in whatsLeft) {
                      l
                        ..stock = StockEffect.none
                        ..qtyLeft = null
                        ..thrownAway = false;
                    }
                  }),
                  child: const Text('All eaten'),
                ),
              ],
            )
          else if (date != null && age >= 2)
            _Banner(
              icon: Icons.history,
              color: context.scheme.primary,
              text:
                  'Bought ${daysAgoLabel(age)}, so it is filed on ${dateLabel(date, now)} and freshness counts from then.'
                  '${usedUp == 0 ? '' : ' $usedUp ${usedUp == 1 ? "item doesn't" : "items don't"} keep that long: '
                            'only the money is filed for ${usedUp == 1 ? 'it' : 'them'}.'}',
            ),
          if (pantry && onHand.length > 1)
            _Banner(
              icon: Icons.content_copy_outlined,
              color: context.colors.warning,
              text: '${onHand.length} items are already in your pantry. Does the photo show the same ones, or extra?',
              actions: [
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in onHand) {
                      l.stock = StockEffect.replace;
                    }
                  }),
                  child: const Text('All the same'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in onHand) {
                      l.stock = StockEffect.add;
                    }
                  }),
                  child: const Text('All extra'),
                ),
              ],
            ),
          if (pantry && prices.length > 1)
            _Banner(
              icon: Icons.sell_outlined,
              color: context.colors.warning,
              text: found == 0
                  ? '${prices.length} prices are estimates. Are they about right?'
                  : 'Google found what ${found == prices.length ? 'these' : '$found of these'} cost in the shops'
                        '${found < prices.length ? ', the rest are estimates' : ''}. Are the prices right?',
              actions: [
                TextButton(
                  onPressed: () => setState(() {
                    for (final l in prices) {
                      l.priceConfirmed = true;
                    }
                  }),
                  child: const Text('All correct'),
                ),
              ],
            ),
          if (pantry && job.priceLookupError != null)
            _Banner(
              icon: Icons.cloud_off_outlined,
              color: context.colors.warning,
              text:
                  "Couldn't look prices up on Google (${_short(job.priceLookupError!)}). "
                  'The prices below are estimates from the photo.',
              actions: [
                TextButton(
                  onPressed: _pricesBusy ? null : _retryPrices,
                  child: Text(_pricesBusy ? 'Looking up…' : 'Try again'),
                ),
              ],
            ),
          if (searched)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SearchSuggestions(html: job.priceSearchHtml, queries: job.priceQueries),
            ),
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
          if (attention.isNotEmpty) ...[_Label('Check ${attention.length}'), for (final i in attention) line(i)],
          if (fine.isNotEmpty)
            _Label(
              pantry ? '${fine.length} ${fine.length == 1 ? 'item' : 'items'} detected' : '${fine.length} look good',
            ),
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
            for (final i in fine) line(i),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              TextButton(onPressed: _discard, child: const Text('Discard')),
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

/// An error message cut to a short reason for a banner.
String _short(String error) {
  final t = error.trim().replaceAll(RegExp(r'[.\s]+$'), '');
  return t.length <= 90 ? t : '${t.substring(0, 89)}…';
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
    super.key,
    required this.line,
    required this.job,
    required this.ingredients,
    required this.onChanged,
    required this.receiptMoney,
    required this.homeMoney,
    this.toHome,
  });
  final DraftLine line;

  /// The scan the line belongs to: its kind and dates drive the pantry question.
  final ScanJob job;
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
  late final _packPrice = TextEditingController(
    text: widget.line.packagePriceMinor == null ? '' : widget.homeMoney.toInput(widget.line.packagePriceMinor!),
  );

  /// A line that needed a look stays open after it's answered.
  late bool _open = widget.line.needsAttention;

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  bool get _pantry => widget.job.kind == ScanKind.pantry;

  @override
  void dispose() {
    _amount.dispose();
    _qty.dispose();
    _packPrice.dispose();
    super.dispose();
  }

  /// "Same as …? Yes": the line becomes that item, in its unit, and asks the pantry question anew.
  void _merge(DraftLine l, Ingredient merge) {
    setState(() {
      if (l.unit != merge.baseUnit) {
        // Convert into the existing item's unit; unknown if impossible.
        if (l.qty != null) {
          final converted = UnitConverter.toBase(l.qty!, l.unit, merge);
          l.qty = converted;
          if (converted == null) l.qtySource = QtySource.unknown;
          _qty.text = converted == null ? '' : _fmt(converted);
        }
        if (l.packageQty != null) {
          l.packageQty = UnitConverter.toBase(l.packageQty!, l.unit, merge);
          if (l.packageQty == null) l.packagePriceMinor = null;
        }
      }
      l.matchedIngredientId = merge.id;
      l.ingredientKey = merge.key;
      l.isNewIngredient = false;
      l.mergeCandidateId = null;
      l.profile = null;
      l.unit = merge.baseUnit;
      ReceiptValidator.checkStock(
        l,
        kind: widget.job.kind,
        existing: merge,
        purchasedAt: widget.job.purchasedAt,
        capturedAt: widget.job.capturedAt,
      );
      if (_pantry) ReceiptValidator.checkPrice(l, existing: merge);
    });
    widget.onChanged();
  }

  /// "Change" on the price question: the price of one pack and its size, as the user knows them.
  Future<void> _editPrice() async {
    final l = widget.line;
    final result = await showDialog<(int, double)>(
      context: context,
      builder: (_) => _PriceDialog(line: l, money: widget.homeMoney),
    );
    if (result == null || !mounted) return;
    final (price, size) = result;
    setState(() {
      l
        ..packagePriceMinor = price
        ..packageQty = size
        ..priceConfirmed = true;
      _packPrice.text = widget.homeMoney.toInput(price);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.line;
    final c = context.colors;
    final merge = l.mergeCandidateId == null ? null : widget.ingredients[l.mergeCandidateId];
    final current =
        widget.ingredients[l.matchedIngredientId] ??
        (l.isNewIngredient ? null : widget.ingredients.values.where((i) => i.key == l.ingredientKey).firstOrNull);
    final open = _open || l.needsAttention;
    final product = l.product != null && l.product!.toLowerCase() != l.name.toLowerCase() ? l.product : null;
    final outOfPantry = !_pantry && l.ingredientKey != null && l.effectFor(widget.job.kind) == StockEffect.none;
    // A shelf price prices the item only while it has no price paid.
    final priced = _pantry && l.estUnitCostMinor != null && ReceiptValidator.needsPrice(current);
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
                        if (product != null)
                          Text(
                            product,
                            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                          ),
                        Text(
                          [
                            if (l.qty != null) '${l.qtySource == QtySource.inferred ? '~' : ''}${qty(l.qty!, l.unit)}',
                            if (l.isNewIngredient && l.ingredientKey != null) 'new item',
                            if (l.ingredientKey == null && l.category != SpendCategory.groceries) l.category.label,
                            if (l.confidence == Confidence.low) 'hard to read',
                            if (_pantry && current != null && l.stockCheck == null)
                              'was ${qty(current.qtyOnHand, current.baseUnit)}',
                            if (priced && !l.priceToConfirm)
                              '${l.priceConfirmed ? '' : '~'}${widget.homeMoney.format(l.packagePriceMinor!)} '
                                  'for ${qty(l.packageQty!, l.unit)}',
                            if (outOfPantry) 'not added to the pantry',
                          ].join(' · '),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!_pantry)
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
                    TextButton(onPressed: () => _merge(l, merge), child: const Text('Yes')),
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
            if (priced && l.priceToConfirm && l.include)
              _PriceQuestion(
                line: l,
                money: widget.homeMoney,
                onConfirm: () {
                  setState(() => l.priceConfirmed = true);
                  widget.onChanged();
                },
                onChange: _editPrice,
              ),
            if (l.stockCheck == StockCheck.whatsLeft && l.include)
              _WhatsLeft(
                line: l,
                age: widget.job.purchasedAt == null
                    ? 0
                    : DayClock.daysBetween(widget.job.purchasedAt!, widget.job.capturedAt),
                onChanged: () {
                  setState(() {});
                  widget.onChanged();
                },
              )
            else if (l.stockCheck != null && l.include)
              _StockQuestion(
                line: l,
                job: widget.job,
                existing: current,
                onChanged: (effect) {
                  setState(() => l.stock = effect);
                  widget.onChanged();
                },
              ),
            if (open)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (!_pantry)
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
                        if (!_pantry) const SizedBox(width: 8),
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
                        if (_pantry &&
                            l.packageQty != null &&
                            ReceiptValidator.needsPrice(current) &&
                            !l.priceToConfirm) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _packPrice,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Price for ${qty(l.packageQty!, l.unit)}',
                                prefixText: '${widget.homeMoney.symbol} ',
                                isDense: true,
                              ),
                              onChanged: (v) {
                                final p = widget.homeMoney.parse(v);
                                // Typed by the user, so it's a checked price.
                                l
                                  ..packagePriceMinor = p != null && p > 0 ? p : null
                                  ..priceConfirmed = l.packagePriceMinor != null;
                                widget.onChanged();
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!_pantry) ...[
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
                                      if (cat != SpendCategory.groceries) {
                                        // Not food: nothing goes to the pantry, so nothing to ask.
                                        l
                                          ..ingredientKey = null
                                          ..stockCheck = null
                                          ..stock = null;
                                      }
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

/// Asks whether a line's quantity belongs in the pantry, with the result of each answer.
class _StockQuestion extends StatelessWidget {
  const _StockQuestion({required this.line, required this.job, required this.existing, required this.onChanged});
  final DraftLine line;
  final ScanJob job;

  /// The pantry item the line maps to, if it already exists.
  final Ingredient? existing;
  final ValueChanged<StockEffect> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = line;
    final now = DateTime.now();
    String amount(double v) => qty(v, l.unit);
    final have = existing?.qtyOnHand ?? 0;
    final q = l.qty;
    final counted = existing?.lastCountedAt;
    final bought = job.purchasedAt;
    final keeps = existing?.shelfLifeDays ?? l.profile?.shelfLifeDays;
    String when(DateTime d) {
      final label = dayLabel(d, now);
      return label == 'Today' || label == 'Yesterday' ? label.toLowerCase() : 'on $label';
    }

    final (IconData icon, String text, List<(String, StockEffect)> options) = switch (l.stockCheck!) {
      StockCheck.onHand => (
        Icons.content_copy_outlined,
        'Already in your pantry: ${amount(have)}.',
        [
          ('Same one${q == null ? '' : ' · ${amount(q)}'}', StockEffect.replace),
          ('Extra${q == null ? '' : ' · ${amount(have + q)} in all'}', StockEffect.add),
        ],
      ),
      StockCheck.counted => (
        Icons.fact_check_outlined,
        'You counted it ${counted == null ? 'recently' : when(counted)}, after this purchase, and the pantry '
            'has ${amount(have)}. Is this already part of it?',
        [('Already counted', StockEffect.none), ('Add${q == null ? '' : ' ${amount(q)}'}', StockEffect.add)],
      ),
      StockCheck.usedUp || StockCheck.whatsLeft => (
        Icons.hourglass_bottom,
        'Bought ${bought == null ? 'a while' : daysAgoLabel(DayClock.daysBetween(bought, now))}'
            '${keeps == null ? '' : ', and it keeps about $keeps ${keeps == 1 ? 'day' : 'days'}'}. Probably used up?',
        [('Used up', StockEffect.none), ('Still have it', StockEffect.add)],
      ),
    };
    final selected = l.effectFor(job.kind);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: context.colors.warning),
              const SizedBox(width: 6),
              Expanded(child: Text(text, style: context.text.bodyMedium)),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: [
              for (final (label, effect) in options)
                ChoiceChip(label: Text(label), selected: selected == effect, onSelected: (_) => onChanged(effect)),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Left { all, some, none, thrown }

/// An old receipt's item: how much is left now? What is gone counts as eaten (or thrown away)
/// over the days since it was bought, so the weeks it went in add up.
class _WhatsLeft extends StatefulWidget {
  const _WhatsLeft({required this.line, required this.age, required this.onChanged});
  final DraftLine line;

  /// Days since the purchase.
  final int age;
  final VoidCallback onChanged;

  @override
  State<_WhatsLeft> createState() => _WhatsLeftState();
}

class _WhatsLeftState extends State<_WhatsLeft> {
  late final _left = TextEditingController(text: widget.line.qtyLeft == null ? '' : _fmt(widget.line.qtyLeft!));

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  _Left get _answer {
    final l = widget.line;
    if (l.stock == StockEffect.none) return l.thrownAway ? _Left.thrown : _Left.none;
    return l.qtyLeft != null ? _Left.some : _Left.all;
  }

  @override
  void dispose() {
    _left.dispose();
    super.dispose();
  }

  void _set(_Left a) {
    final l = widget.line;
    setState(() {
      l
        ..stock = a == _Left.all || a == _Left.some ? StockEffect.add : StockEffect.none
        ..thrownAway = a == _Left.thrown
        ..qtyLeft = null;
      if (a == _Left.some) {
        // Start from half, rounded the way the item is counted.
        final half = (l.qty ?? 0) / 2;
        l.qtyLeft = l.unit == BaseUnit.pc ? half.roundToDouble() : (half / 10).roundToDouble() * 10;
        _left.text = _fmt(l.qtyLeft!);
      }
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.line;
    final q = l.qty;
    final answer = _answer;
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    final options = [
      (_Left.all, q == null ? 'All of it' : 'All of it · ${qty(q, l.unit)}'),
      if (q != null && q > (l.unit == BaseUnit.pc ? 1 : 0)) (_Left.some, 'Some'),
      (_Left.none, 'None: eaten'),
      (_Left.thrown, 'Thrown away'),
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.inventory_2_outlined, size: 18, color: context.colors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text("Bought ${daysAgoLabel(widget.age)}. What's left of it?", style: context.text.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final (a, label) in options)
                ChoiceChip(label: Text(label), selected: answer == a, onSelected: (_) => _set(a)),
            ],
          ),
          if (answer == _Left.some && q != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _left,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Left', suffixText: l.unit.label, isDense: true),
                      onChanged: (v) {
                        final left = double.tryParse(v.replaceAll(',', '.'));
                        l.qtyLeft = left?.clamp(0, q).toDouble();
                        widget.onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.qtyLeft == null ? '' : 'The other ${qty(q - l.qtyLeft!, l.unit)} counts as eaten',
                      style: muted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Pantry photos: is the shop price found on Google (or, if none was, the photo's estimate) right?
class _PriceQuestion extends StatelessWidget {
  const _PriceQuestion({required this.line, required this.money, required this.onConfirm, required this.onChange});
  final DraftLine line;
  final MoneyFormat money;
  final VoidCallback onConfirm;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l = line;
    final web = l.priceSource == PriceSource.web;
    final price = '${money.format(l.packagePriceMinor!)} for ${qty(l.packageQty!, l.unit)}';
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(web ? Icons.travel_explore : Icons.sell_outlined, size: 18, color: context.colors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  web
                      ? 'Google found $price${l.priceStore == null ? '' : ' at ${l.priceStore}'}. Is that the price?'
                      : 'Estimated at $price. Is that about what it costs?',
                  style: context.text.bodyMedium,
                ),
              ),
            ],
          ),
          if (l.priceNote != null)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text(l.priceNote!, style: muted),
            ),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(onPressed: onConfirm, child: const Text('Yes')),
              TextButton(onPressed: onChange, child: const Text('Change')),
              for (final link in l.priceLinks)
                TextButton.icon(
                  onPressed: () => openWebPage(link.uri),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(link.title.isEmpty ? 'Source' : link.title),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The price of one pack and the pack's size; pops (price in minor units, size in the line's unit).
class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.line, required this.money});
  final DraftLine line;
  final MoneyFormat money;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  late final _price = _selected(
    widget.line.packagePriceMinor == null ? '' : widget.money.toInput(widget.line.packagePriceMinor!),
  );
  late final _size = TextEditingController(text: _fmt(widget.line.packageQty));

  /// All selected, so typing replaces the price that was found.
  static TextEditingController _selected(String text) => TextEditingController.fromValue(
    TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: 0, extentOffset: text.length),
    ),
  );

  static String _fmt(double? v) =>
      v == null ? '' : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

  int? get _priceMinor {
    final p = widget.money.parse(_price.text);
    return p != null && p > 0 ? p : null;
  }

  double? get _sizeQty {
    final q = double.tryParse(_size.text.trim().replaceAll(',', '.'));
    return q != null && q > 0 ? q : null;
  }

  @override
  void dispose() {
    _price.dispose();
    _size.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.line;
    final price = _priceMinor;
    final size = _sizeQty;
    return AlertDialog(
      title: Text(l.name),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _price,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Price', prefixText: '${widget.money.symbol} '),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _size,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Pack size', suffixText: l.unit.label),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: price == null || size == null ? null : () => Navigator.of(context).pop((price, size)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
