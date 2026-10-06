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
    if (all == null) return const _PantrySkeleton();
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
        action: FilledButton.tonal(
          style: AppTheme.tonalButton(context),
          onPressed: () => showIngredientSheet(context),
          child: const Text('Add an item'),
        ),
      );
    }

    // The list has no side padding so the tile strips run to the screen edge; everything else
    // sits on the 16 margins.
    Widget pad(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: child,
    );
    Widget strip(List<Widget> tiles) => SizedBox(
      height: PantryTile.heightOf(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.x2),
        itemBuilder: (_, i) => tiles[i],
      ),
    );
    final c = context.colors;
    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + AppSpace.x6),
      children: [
        pad(
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              hintText: 'Search pantry',
              contentPadding: EdgeInsets.symmetric(vertical: 11),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        if (unknownMacros > 0 && q.isEmpty) ...[
          const SizedBox(height: AppSpace.x3),
          pad(
            AppNotice(
              kind: NoticeKind.warning,
              icon: Icons.help_outline_rounded,
              title: '$unknownMacros ${unknownMacros == 1 ? 'item has' : 'items have'} no macros',
              message: 'Recipes count them as 0 kcal',
              onTap: () => reviewMacros(context, toReview),
              actions: [
                if (_filling)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  TextButton(onPressed: _fillMacros, child: const Text('Fill with AI')),
              ],
            ),
          ),
        ],
        if (q.isNotEmpty && matches.isEmpty) const EmptyState(icon: Icons.search_off_rounded, title: 'No items match'),
        if (soon.isNotEmpty && q.isEmpty) ...[
          pad(const GroupHeader('Use soon')),
          strip([
            for (final ing in soon)
              Builder(
                builder: (context) {
                  final d = ExpiryEstimator.daysLeft(ing, now);
                  return PantryTile(
                    name: ing.name,
                    quantity: qty(ing.qtyOnHand, ing.baseUnit),
                    note: daysLeftLabel(d),
                    urgent: d != null && d <= 1,
                    onTap: () => showIngredientSheet(context, ingredient: ing),
                  );
                },
              ),
          ]),
        ],
        if (low.isNotEmpty && q.isEmpty) ...[
          pad(const GroupHeader('Running low')),
          strip([
            for (final ing in low)
              PantryTile(
                name: ing.name,
                quantity: qty(ing.qtyOnHand, ing.baseUnit),
                runningLow: true,
                onTap: () => showIngredientSheet(context, ingredient: ing),
              ),
          ]),
        ],
        for (final cat in cats) ...[
          pad(GroupHeader(cat.label, icon: ingredientIcon(cat))),
          pad(
            AppGroup(
              children: [for (final ing in groups[cat]!) _IngredientTile(ing: ing, now: now)],
            ),
          ),
        ],
        if (empty.isNotEmpty) ...[
          const SizedBox(height: AppSpace.x6),
          pad(
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : AppMotion.medium,
              curve: AppMotion.move,
              alignment: Alignment.topCenter,
              child: AppGroup(
                children: [
                  AppRow(
                    title: 'Out of stock (${empty.length})',
                    trailing: AnimatedRotation(
                      turns: _showEmpty ? 0.5 : 0,
                      duration: AppMotion.short,
                      child: Icon(Icons.expand_more_rounded, size: 20, color: c.textTertiary),
                    ),
                    onTap: () => setState(() => _showEmpty = !_showEmpty),
                  ),
                  if (_showEmpty)
                    for (final ing in empty) _IngredientTile(ing: ing, now: now),
                ],
              ),
            ),
          ),
        ],
        if (staples.isNotEmpty) ...[
          pad(const GroupHeader('Staples · always assumed')),
          pad(
            Wrap(
              spacing: AppSpace.x2,
              runSpacing: AppSpace.x2,
              children: [
                for (final s in staples)
                  AppActionChip(
                    label: s.name,
                    icon: s.needsNutrition ? Icons.help_outline_rounded : null,
                    iconColor: c.warning,
                    onPressed: () => showIngredientSheet(context, ingredient: s),
                  ),
              ],
            ),
          ),
        ],
        if (toReview.isNotEmpty && q.isEmpty) ...[
          const SizedBox(height: AppSpace.x6),
          pad(
            AppGroup(
              children: [
                AppRow(
                  leading: const Icon(Icons.fact_check_outlined, size: 20),
                  title: 'Review macros · ${toReview.length} unconfirmed',
                  chevron: true,
                  onTap: () => reviewMacros(context, toReview),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// First load: the search field, a tile strip and a few rows as placeholders.
class _PantrySkeleton extends StatelessWidget {
  const _PantrySkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
        children: [
          const SkeletonBlock(height: 44, radius: AppRadius.input),
          const SizedBox(height: AppSpace.x6),
          const Row(
            children: [
              Expanded(child: SkeletonBlock(height: 72, radius: AppRadius.tile)),
              SizedBox(width: AppSpace.x2),
              Expanded(child: SkeletonBlock(height: 72, radius: AppRadius.tile)),
              SizedBox(width: AppSpace.x2),
              Expanded(child: SkeletonBlock(height: 72, radius: AppRadius.tile)),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          for (var i = 0; i < 6; i++) ...[
            SkeletonLine(width: 160, style: context.text.bodyLarge),
            SkeletonLine(width: 110, style: context.text.bodySmall),
            const SizedBox(height: AppSpace.x3),
          ],
        ],
      ),
    );
  }
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
    final c = context.colors;
    final meta = [
      if (value > 0) money.compact(value),
      if (d != null) '${daysLeftLabel(d)} left'.replaceAll('use today left', 'use today'),
      if (unverified) 'check',
    ];
    return Dismissible(
      key: ValueKey('ing-${ing.id}-${ing.qtyOnHand}'),
      direction: ing.qtyOnHand > 0 ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpace.x6),
        color: c.critical,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 6),
            Icon(Icons.remove_shopping_cart_outlined, color: Colors.white, size: 20),
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
      child: AppRow(
        title: ing.name,
        subtitleSpan: meta.isEmpty && !ing.needsNutrition
            ? null
            : TextSpan(
                children: [
                  TextSpan(text: meta.join(' · ')),
                  if (ing.needsNutrition) ...[
                    if (meta.isNotEmpty) const TextSpan(text: ' · '),
                    TextSpan(
                      text: 'no macros',
                      style: TextStyle(color: c.warningInk),
                    ),
                  ],
                ],
              ),
        value: qty(ing.qtyOnHand, ing.baseUnit),
        onTap: () => showIngredientSheet(context, ingredient: ing),
      ),
    );
  }
}
