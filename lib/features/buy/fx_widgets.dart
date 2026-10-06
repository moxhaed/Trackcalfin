import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/currency.dart';
import '../../core/money.dart';
import '../../domain/fx.dart';
import '../common/widgets.dart';

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
    final hasRate = rate != null;
    return AppNotice(
      kind: hasRate ? NoticeKind.info : NoticeKind.warning,
      icon: Icons.currency_exchange_rounded,
      title: 'Receipt in $from',
      trailing: busy ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      body: hasRate
          ? Text(
              '${moneyFor(from).format(foreignTotal)} → '
              '${moneyFor(to).format(Currency.convert(foreignTotal, from: from, to: to, rate: rate!))}',
              style: context.nums.medium,
            )
          : null,
      message: hasRate
          ? null
          : 'No exchange rate yet (you may be offline). Type what your card was charged, '
                'or enter the rate, and every line is converted for you.',
      meta: hasRate ? '1 $from = ${rateText(rate!)} $to · ${fxSourceLabel(source, date)}' : null,
      actions: [
        TextButton.icon(
          onPressed: onSetRate,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(hasRate ? 'Change rate' : 'Set rate'),
        ),
        TextButton(onPressed: onChangeCurrency, child: const Text('Wrong currency?')),
        if (!hasRate) TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
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
          padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Convert ${widget.from} to ${widget.to}', style: context.text.headlineSmall),
              const SizedBox(height: AppSpace.tight),
              Text(
                'Receipt total: ${fromMoney.format(widget.foreignTotal)}',
                style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpace.x4),
              AppSegmented<bool>(
                segments: const {true: 'Amount charged', false: 'Exchange rate'},
                selected: _charged,
                onChanged: (v) => setState(() => _charged = v),
              ),
              const SizedBox(height: AppSpace.x3),
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
              const SizedBox(height: AppSpace.x2),
              if (v != null)
                Text(
                  _charged
                      ? '= 1 ${widget.from} ≈ ${rateText(v)} ${widget.to}'
                      : 'Total ${toMoney.format(Currency.convert(widget.foreignTotal, from: widget.from, to: widget.to, rate: v))}',
                  style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
              if (widget.remembered != null) ...[
                const SizedBox(height: AppSpace.x2),
                AppActionChip(
                  icon: Icons.history_rounded,
                  label:
                      'Use last rate: ${rateText(widget.remembered!.rate)} '
                      '(${DateFormat('d MMM').format(widget.remembered!.date)})',
                  onPressed: () => _done(widget.remembered!.rate, FxSource.remembered),
                ),
              ],
              const SizedBox(height: AppSpace.x5),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: AppTheme.largeButton,
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
  builder: (context) {
    final ctrl = TextEditingController();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Which currency is the receipt in?', style: context.text.headlineSmall),
              const SizedBox(height: AppSpace.x4),
              Wrap(
                spacing: AppSpace.x2,
                runSpacing: AppSpace.x2,
                children: [
                  for (final c in commonCurrencies)
                    AppChoiceChip(label: c, selected: c == current, onSelected: (_) => Navigator.of(context).pop(c)),
                ],
              ),
              const SizedBox(height: AppSpace.x4),
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
  },
);
