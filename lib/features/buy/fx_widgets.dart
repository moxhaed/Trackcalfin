import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/currency.dart';
import '../../core/money.dart';
import '../../domain/fx.dart';

MoneyFormat moneyFor(String currency) => MoneyFormat(currency: currency, digits: Currency.digitsOf(currency));

String fxSourceLabel(String? source, DateTime? date) {
  final d = date == null ? '' : ', ${DateFormat('d MMM').format(date)}';
  return switch (source) {
    'ecb' => 'European Central Bank rate$d',
    'charged' => 'from the amount your card was charged',
    'manual' => 'your rate',
    'remembered' => 'the last rate you used$d',
    _ => '',
  };
}

String rateText(double rate) => rate >= 100 ? rate.toStringAsFixed(2) : rate.toStringAsPrecision(5);

/// Shown at the top of the review screen for receipts in another currency.
class ConversionCard extends StatelessWidget {
  const ConversionCard({
    super.key,
    required this.from,
    required this.to,
    required this.foreignTotal,
    required this.rate,
    required this.source,
    required this.date,
    required this.onSetRate,
    required this.onChangeCurrency,
    required this.onRetry,
    this.busy = false,
  });

  final String from;
  final String to;
  final int foreignTotal;
  final double? rate;
  final String? source;
  final DateTime? date;
  final VoidCallback onSetRate;
  final VoidCallback onChangeCurrency;
  final VoidCallback onRetry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasRate = rate != null;
    final color = hasRate ? context.scheme.primary : c.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.currency_exchange, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Receipt in $from', style: context.text.titleSmall)),
              if (busy) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 6),
          if (hasRate) ...[
            Text(
              '${moneyFor(from).format(foreignTotal)}  →  '
              '${moneyFor(to).format(Currency.convert(foreignTotal, from: from, to: to, rate: rate!))}',
              style: context.text.titleMedium,
            ),
            Text(
              '1 $from = ${rateText(rate!)} $to · ${fxSourceLabel(source, date)}',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          ] else
            Text(
              'No exchange rate yet (you may be offline). Type what your card was charged, '
              'or enter the rate, and every line is converted for you.',
              style: context.text.bodyMedium,
            ),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: onSetRate,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(hasRate ? 'Change rate' : 'Set rate'),
              ),
              TextButton(onPressed: onChangeCurrency, child: const Text('Wrong currency?')),
              if (!hasRate) TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ],
      ),
    );
  }
}

/// "What did your card charge?" or "1 CHF = ? EUR". Returns the chosen quote.
Future<FxQuote?> showRateSheet(
  BuildContext context, {
  required String from,
  required String to,
  required int foreignTotal,
  double? currentRate,
  FxQuote? remembered,
}) => showModalBottomSheet<FxQuote>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) =>
      _RateSheet(from: from, to: to, foreignTotal: foreignTotal, currentRate: currentRate, remembered: remembered),
);

class _RateSheet extends StatefulWidget {
  const _RateSheet({
    required this.from,
    required this.to,
    required this.foreignTotal,
    this.currentRate,
    this.remembered,
  });
  final String from;
  final String to;
  final int foreignTotal;
  final double? currentRate;
  final FxQuote? remembered;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  bool _charged = true;
  final _charge = TextEditingController();
  late final _rate = TextEditingController(text: widget.currentRate == null ? '' : rateText(widget.currentRate!));

  @override
  void dispose() {
    _charge.dispose();
    _rate.dispose();
    super.dispose();
  }

  double? get _value {
    if (_charged) {
      final home = moneyFor(widget.to).parse(_charge.text);
      if (home == null || home <= 0) return null;
      return Currency.impliedRate(foreignMinor: widget.foreignTotal, from: widget.from, homeMinor: home, to: widget.to);
    }
    final r = double.tryParse(_rate.text.replaceAll(',', '.').trim());
    return r == null || !FxMath.plausible(r) ? null : r;
  }

  void _done(double rate, FxSource source) => Navigator.of(
    context,
  ).pop(FxQuote(from: widget.from, to: widget.to, rate: rate, date: DateTime.now(), source: source));

  @override
  Widget build(BuildContext context) {
    final fromMoney = moneyFor(widget.from);
    final toMoney = moneyFor(widget.to);
    final v = _value;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Convert ${widget.from} to ${widget.to}', style: context.text.titleLarge),
              const SizedBox(height: 4),
              Text('Receipt total: ${fromMoney.format(widget.foreignTotal)}', style: context.text.bodyMedium),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Amount charged'), icon: Icon(Icons.credit_card)),
                    ButtonSegment(value: false, label: Text('Exchange rate'), icon: Icon(Icons.percent)),
                  ],
                  selected: {_charged},
                  onSelectionChanged: (s) => setState(() => _charged = s.first),
                ),
              ),
              const SizedBox(height: 12),
              if (_charged)
                TextField(
                  controller: _charge,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'What your card was charged',
                    helperText: 'Check your banking app. Card fees are included, so the ledger matches your bank.',
                    helperMaxLines: 2,
                    prefixText: '${toMoney.symbol} ',
                  ),
                  onChanged: (_) => setState(() {}),
                )
              else
                TextField(
                  controller: _rate,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: '1 ${widget.from} =', suffixText: widget.to),
                  onChanged: (_) => setState(() {}),
                ),
              const SizedBox(height: 8),
              if (v != null)
                Text(
                  _charged
                      ? '= 1 ${widget.from} ≈ ${rateText(v)} ${widget.to}'
                      : 'Total ${toMoney.format(Currency.convert(widget.foreignTotal, from: widget.from, to: widget.to, rate: v))}',
                  style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
              if (widget.remembered != null) ...[
                const SizedBox(height: 8),
                ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(
                    'Use last rate: ${rateText(widget.remembered!.rate)} '
                    '(${DateFormat('d MMM').format(widget.remembered!.date)})',
                  ),
                  onPressed: () => _done(widget.remembered!.rate, FxSource.remembered),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: v == null ? null : () => _done(v, _charged ? FxSource.charged : FxSource.manual),
                  child: const Text('Convert all lines'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const commonCurrencies = [
  'EUR',
  'USD',
  'GBP',
  'CHF',
  'CAD',
  'AUD',
  'JPY',
  'SEK',
  'NOK',
  'DKK',
  'PLN',
  'CZK',
  'HUF',
  'TRY',
  'MXN',
  'THB',
];

/// Pick the currency the receipt is actually in.
Future<String?> showCurrencySheet(BuildContext context, {required String current}) => showModalBottomSheet<String>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => _CurrencySheet(current: current),
);

/// Owns its text controller: the sheet's builder runs again whenever the keyboard moves, and a
/// controller made there was replaced (losing what was typed) and never disposed.
class _CurrencySheet extends StatefulWidget {
  const _CurrencySheet({required this.current});
  final String current;

  @override
  State<_CurrencySheet> createState() => _CurrencySheetState();
}

class _CurrencySheetState extends State<_CurrencySheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    final ctrl = _ctrl;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Which currency is the receipt in?', style: context.text.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in commonCurrencies)
                    ChoiceChip(label: Text(c), selected: c == current, onSelected: (_) => Navigator.of(context).pop(c)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 3,
                decoration: const InputDecoration(labelText: 'Other (3-letter code)', counterText: ''),
                onSubmitted: (v) {
                  final code = v.trim().toUpperCase();
                  if (RegExp(r'^[A-Z]{3}$').hasMatch(code)) Navigator.of(context).pop(code);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
