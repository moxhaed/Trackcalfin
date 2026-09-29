import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/costing.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'ingredient_sheet.dart';

class PantryView extends ConsumerStatefulWidget {
  const PantryView({super.key});

  @override
  ConsumerState<PantryView> createState() => _PantryViewState();
}

class _PantryViewState extends ConsumerState<PantryView> {
  String _query = '';
  bool _showEmpty = false;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(ingredientsProvider).value;
    if (all == null) return const Center(child: CircularProgressIndicator());
    final now = DateTime.now();
    final q = _query.toLowerCase();
    final matches = all.where((i) => q.isEmpty || i.name.toLowerCase().contains(q) || i.key.contains(q)).toList();
    final exact = matches.where((i) => !i.isStaple).toList();
    final inStock = exact.where((i) => i.qtyOnHand > 0).toList();
    final soon = inStock.where((i) => ExpiryEstimator.useSoon(i, now)).toList()
      ..sort((a, b) => (ExpiryEstimator.daysLeft(a, now) ?? 99).compareTo(ExpiryEstimator.daysLeft(b, now) ?? 99));
    final low = inStock.where((i) => i.isLow).toList();
    final empty = exact.where((i) => i.qtyOnHand <= 0).toList();
    final staples = matches.where((i) => i.isStaple).toList();
    final groups = groupBy(inStock, (Ingredient i) => i.category);
    final cats = groups.keys.toList()..sort((a, b) => a.index.compareTo(b.index));

    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.kitchen_outlined,
        title: 'Your pantry is empty',
        message: 'Scan a receipt or snap your fridge and cupboard: the AI fills this in.',
        action: FilledButton.tonal(onPressed: () => showIngredientSheet(context), child: const Text('Add an item')),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search pantry'),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (soon.isNotEmpty && q.isEmpty) ...[
          const _Header('Use soon'),
          SizedBox(
            height: 76,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: soon.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final ing = soon[i];
                final d = ExpiryEstimator.daysLeft(ing, now);
                return ActionChip(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  avatar: Icon(Icons.schedule, size: 18, color: context.colors.serious),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ing.name, style: context.text.labelLarge),
                      Text('${qty(ing.qtyOnHand, ing.baseUnit)} · ${daysLeftLabel(d)}', style: context.text.labelSmall),
                    ],
                  ),
                  onPressed: () => showIngredientSheet(context, ingredient: ing),
                );
              },
            ),
          ),
        ],
        if (low.isNotEmpty && q.isEmpty) ...[
          const _Header('Running low'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ing in low)
                  InputChip(
                    avatar: Icon(Icons.trending_down, size: 16, color: context.colors.warning),
                    label: Text('${ing.name} · ${qty(ing.qtyOnHand, ing.baseUnit)}'),
                    onPressed: () => showIngredientSheet(context, ingredient: ing),
                  ),
              ],
            ),
          ),
        ],
        for (final c in cats) ...[_Header(c.label), for (final ing in groups[c]!) _IngredientTile(ing: ing, now: now)],
        if (empty.isNotEmpty) ...[
          ListTile(
            title: Text('Out of stock (${empty.length})', style: context.text.titleSmall),
            trailing: Icon(_showEmpty ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _showEmpty = !_showEmpty),
          ),
          if (_showEmpty)
            for (final ing in empty) _IngredientTile(ing: ing, now: now),
        ],
        if (staples.isNotEmpty) ...[
          const _Header('Staples · always assumed'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in staples)
                  ActionChip(
                    label: Text(s.name),
                    onPressed: () => showIngredientSheet(context, ingredient: s),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Text(
      text.toUpperCase(),
      style: context.text.labelMedium?.copyWith(letterSpacing: 0.8, color: context.scheme.onSurfaceVariant),
    ),
  );
}

class _IngredientTile extends ConsumerWidget {
  const _IngredientTile({required this.ing, required this.now});
  final Ingredient ing;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ExpiryEstimator.daysLeft(ing, now);
    final money = ref.watch(moneyProvider);
    final value = (ing.qtyOnHand * ing.avgCostPerUnitMinor).round();
    final unverified = ing.lastVerifiedAt == null && ing.qtyOnHand > 0;
    return Dismissible(
      key: ValueKey('ing-${ing.id}-${ing.qtyOnHand}'),
      direction: ing.qtyOnHand > 0 ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: context.scheme.errorContainer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Out', style: TextStyle(color: context.scheme.onErrorContainer)),
            const SizedBox(width: 6),
            Icon(Icons.remove_shopping_cart_outlined, color: context.scheme.onErrorContainer),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final pantry = ref.read(pantryServiceProvider);
        final before = ing.qtyOnHand;
        await pantry.markOut(ing.id);
        tick();
        if (context.mounted) {
          showUndo(context, '${ing.name} marked as out', onUndo: () => pantry.setQuantity(ing.id, before));
        }
        return false;
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.scheme.secondaryContainer,
          child: Icon(ingredientIcon(ing.category), size: 20, color: context.scheme.onSecondaryContainer),
        ),
        title: Text(ing.name),
        subtitle: Text(
          [
            if (value > 0) money.compact(value),
            if (d != null) '${daysLeftLabel(d)} left'.replaceAll('use today left', 'use today'),
            if (unverified) 'check',
          ].join(' · '),
        ),
        trailing: Text(qty(ing.qtyOnHand, ing.baseUnit), style: context.text.titleSmall),
        onTap: () => showIngredientSheet(context, ingredient: ing),
      ),
    );
  }
}
