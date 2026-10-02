import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/messenger.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/price_book.dart';
import 'format.dart';
import 'widgets.dart';

/// The biggest saving, in one line: "Chicken breast: 27% cheaper at Lidl (and 2 more)".
String tipLine(List<PriceTip> tips) {
  final t = tips.first;
  final more = tips.length > 1 ? ' (and ${tips.length - 1} more)' : '';
  return '${t.name}: ${(t.share * 100).round()}% cheaper at ${t.cheaper.store}$more.';
}

/// Says a receipt was filed, with the biggest saving elsewhere when there is one; "See"
/// lists them all.
void notifyFiled(String message, List<PriceTip> tips) {
  if (tips.isEmpty) return notifyApp(message);
  notifyApp(
    '$message\n${tipLine(tips)}',
    actionLabel: 'See',
    duration: const Duration(seconds: 8),
    onAction: () {
      final c = rootNavigatorKey.currentContext;
      if (c != null) showPriceTips(c, tips);
    },
  );
}

/// Every tip for a receipt just filed: what was paid here, what the other store charged.
Future<void> showPriceTips(BuildContext context, List<PriceTip> tips) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => _TipsSheet(tips: tips),
);

class _TipsSheet extends ConsumerWidget {
  const _TipsSheet({required this.tips});
  final List<PriceTip> tips;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final units = {for (final i in ref.watch(ingredientsProvider).value ?? const <Ingredient>[]) i.key: i.baseUnit};
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cheaper elsewhere', style: context.text.titleLarge),
            const SizedBox(height: 4),
            Text('From your own receipts of the last 3 months.', style: muted),
            const SizedBox(height: 12),
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.storefront_outlined, size: 20, color: context.scheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: context.text.titleSmall),
                          Text(
                            '${PriceBook.perUnit(money, t.cheaper.unitMinor, units[t.key] ?? t.cheaper.unit ?? BaseUnit.g)} '
                            'at ${t.cheaper.store} (${dateLabel(t.cheaper.at, DateTime.now())}), '
                            '${PriceBook.perUnit(money, t.paid.unitMinor, units[t.key] ?? t.paid.unit ?? BaseUnit.g)} '
                            'at ${t.paid.store}',
                            style: context.text.bodyMedium,
                          ),
                          if (t.cheaper.product != null) Text(t.cheaper.product!, style: muted),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      label: 'saves ${money.compact(t.savingMinor)}',
                      color: context.colors.good,
                      icon: Icons.south_east,
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

/// Ingredient sheet: what each store charged for [ing] last time, cheapest first.
class StorePricesCard extends ConsumerWidget {
  const StorePricesCard({super.key, required this.ing});
  final Ingredient ing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(priceBookProvider).pricesFor(ing.key);
    if (prices.isEmpty) return const SizedBox.shrink();
    final money = ref.watch(moneyProvider);
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    final numbers = context.text.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final best = prices.first.unitMinor;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SectionCard(
        title: prices.length > 1 ? 'Where it\'s cheapest' : 'Where you bought it',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, p) in prices.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.store, style: context.text.titleSmall),
                          Text(
                            [
                              dateLabel(p.at, DateTime.now()),
                              '${money.format(p.totalMinor)} for ${qty(p.qty, ing.baseUnit)}',
                              ?p.product,
                            ].join(' · '),
                            style: muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(PriceBook.perUnit(money, p.unitMinor, ing.baseUnit), style: numbers),
                        if (prices.length > 1)
                          i == 0
                              ? StatusPill(label: 'cheapest', color: context.colors.good, icon: Icons.check)
                              : Text('+${((p.unitMinor / best - 1) * 100).round()}%', style: muted),
                      ],
                    ),
                  ],
                ),
              ),
            Text(
              prices.length > 1
                  ? 'Each store\'s last price, from your receipts of the last 4 months.'
                  : 'Buy it at another store and its price shows up here to compare.',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}
