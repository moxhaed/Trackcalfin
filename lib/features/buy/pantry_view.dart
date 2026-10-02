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
  bool _filling = false;

  Future<void> _fillMacros() async {
    setState(() => _filling = true);
    final r = await ref.read(nutritionServiceProvider).fillMissing();
    if (!mounted) return;
    setState(() => _filling = false);
    // 0 without an error: a background lookup is already on it.
    showInfo(
      context,
      r.error ??
          (r.filled == 0
              ? 'Already looking them up…'
              : 'Macros added for ${r.filled} ${r.filled == 1 ? 'item' : 'items'}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(ingredientsProvider).value;
    if (all == null) return const Center(child: CircularProgressIndicator());
    final prices = ref.watch(priceBookProvider);
    final now = DateTime.now();
    final q = _query.toLowerCase();
    final matches = all.where((i) => q.isEmpty || i.name.toLowerCase().contains(q) || i.key.contains(q)).toList();
    final inStock = matches.where((i) => i.qtyOnHand > 0).toList();
    final soon = inStock.where((i) => ExpiryEstimator.useSoon(i, now)).toList()
      ..sort((a, b) => (ExpiryEstimator.daysLeft(a, now) ?? 99).compareTo(ExpiryEstimator.daysLeft(b, now) ?? 99));
    final low = inStock.where((i) => i.isLow).toList();
    final empty = matches.where((i) => i.qtyOnHand <= 0).toList();
    final unknownMacros = all.where((i) => i.needsNutrition).length;
    // Unknown first: they're the ones that count as 0 kcal.
    final toReview = all.where((i) => i.nutritionConfirmedAt == null).sorted((a, b) {
      if (a.needsNutrition != b.needsNutrition) return a.needsNutrition ? -1 : 1;
      return a.name.compareTo(b.name);
    });
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
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search pantry'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              IconButton(
                tooltip: 'Add an item',
                onPressed: () => showIngredientSheet(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        if (unknownMacros > 0 && q.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.help_outline, color: context.colors.warning),
                title: Text('$unknownMacros ${unknownMacros == 1 ? 'item has' : 'items have'} no macros'),
                subtitle: const Text('Recipes count them as 0 kcal'),
                trailing: _filling
                    ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton(onPressed: _fillMacros, child: const Text('Fill with AI')),
                onTap: () => reviewMacros(context, toReview),
              ),
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
                    label: Text(
                      [
                        ing.name,
                        qty(ing.qtyOnHand, ing.baseUnit),
                        // Where to buy it next: the store with the lowest last price.
                        if (prices.cheapest(ing.key) case final p?) 'cheapest at ${p.store}',
                      ].join(' · '),
                    ),
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
        if (toReview.isNotEmpty && q.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                label: Text('Review macros · ${toReview.length} unconfirmed'),
                onPressed: () => reviewMacros(context, toReview),
              ),
            ),
          ),
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
            // "~": priced from a pantry photo, not a receipt.
            if (value > 0) '${ing.costIsEstimate ? '~' : ''}${money.compact(value)}',
            if (ing.qtyOnHand > 0 && ing.avgCostPerUnitMinor <= 0) 'no price',
            if (d != null) '${daysLeftLabel(d)} left'.replaceAll('use today left', 'use today'),
            if (unverified) 'not counted yet',
            if (ing.needsNutrition) 'no macros',
          ].join(' · '),
        ),
        trailing: Text(qty(ing.qtyOnHand, ing.baseUnit), style: context.text.titleSmall),
        onTap: () => showIngredientSheet(context, ingredient: ing),
      ),
    );
  }
}
