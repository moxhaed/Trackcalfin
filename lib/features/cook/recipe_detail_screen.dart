import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/feasibility.dart';
import '../../domain/stock_index.dart';
import '../../domain/units.dart';
import '../buy/ingredient_sheet.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'cook_actions.dart';

final recipeProvider = StreamProvider.family<Recipe?, int>(
  (ref, id) => ref.watch(isarProvider).recipes.watchObject(id, fireImmediately: true),
);

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  int? _portions;
  final _timer = LogTimer();

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(recipeProvider(widget.id)).value;
    if (r == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final money = ref.watch(moneyProvider);
    final ingredients = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
    final stock = StockIndex(ingredients);
    final portions = _portions ?? (r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions);
    final f = FeasibilityChecker.check(r.ingredients, portions, stock);
    final c = context.colors;
    final recipes = ref.read(recipeServiceProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: r.favorite ? 'Remove favorite' : 'Favorite',
            onPressed: () => recipes.setFavorite(r.id, !r.favorite),
            icon: Icon(r.favorite ? Icons.star : Icons.star_border, color: r.favorite ? c.warning : null),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                await context.push('/recipe/${r.id}/edit');
              } else if (v == 'save') {
                await recipes.setStatus(r.id, RecipeStatus.saved);
                if (context.mounted) showInfo(context, 'Saved to Cook again');
              } else if (v == 'delete') {
                final nav = GoRouter.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final removed = await recipes.delete(r.id);
                nav.pop();
                if (removed != null) showUndoOn(messenger, 'Recipe deleted', onUndo: () => recipes.restore(removed));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              if (r.status == RecipeStatus.suggested)
                const PopupMenuItem(value: 'save', child: Text('Save to Cook again')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (r.feasibilityStatus != null) _Verdict(recipe: r, feasibility: f),
          Text(r.title, style: context.text.headlineSmall),
          if (r.hook.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(r.hook, style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurfaceVariant)),
          ],
          if (r.why.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(r.why, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 14),
          SectionCard(
            title: 'Per portion',
            child: Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                Metric(value: money.format(r.costPerPortionMinor), label: 'cost'),
                Metric(value: '${r.perPortion.kcal.round()}', label: 'kcal', dotColor: c.kcal),
                Metric(value: '${r.perPortion.proteinG.round()} g', label: 'protein', dotColor: c.protein),
                Metric(value: '${r.perPortion.carbsG.round()} g', label: 'carbs'),
                Metric(value: '${r.perPortion.fatG.round()} g', label: 'fat'),
                if (r.totalMinutes > 0)
                  Metric(
                    value: minutesLabel(r.totalMinutes),
                    label: r.activeMinutes > 0 ? '${r.activeMinutes} min active' : 'total',
                  ),
                if (r.fridgeLifeDays > 0) Metric(value: '${r.fridgeLifeDays} d', label: 'keeps in fridge'),
              ],
            ),
          ),
          if (r.validationFlags.any((f) => f.startsWith('estimate_divergence')))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'The AI estimate differed a lot; these numbers come from your pantry data.',
                style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Ingredients · $portions ${portions == 1 ? 'portion' : 'portions'}',
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Column(
              children: [
                for (final ri in r.ingredients)
                  _IngredientRow(ri: ri, portions: portions, stock: stock, feasibility: f),
                if (r.omitted.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 4),
                    child: Text('Left out: ${r.omitted.join(', ')}', style: context.text.bodySmall),
                  ),
              ],
            ),
          ),
          if (r.shoppingList.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'To buy',
              child: Column(
                children: [
                  for (final s in r.shoppingList)
                    Row(
                      children: [
                        Icon(s.reason == 'short' ? Icons.trending_down : Icons.shopping_cart_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${s.name}${s.packageDesc.isNotEmpty ? ' · ${s.packageDesc}' : ''}')),
                        if (s.estCostMinor > 0) Text('~${money.compact(s.estCostMinor)}'),
                      ],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SectionCard(
            title: 'Steps',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, s) in r.steps.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 12, child: Text('${i + 1}', style: context.text.labelSmall)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s, style: context.text.bodyMedium)),
                      ],
                    ),
                  ),
                if (r.steps.isEmpty) const Text('No steps written.'),
              ],
            ),
          ),
          if (r.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, children: [for (final t in r.tags) Chip(label: Text(t.replaceAll('_', ' ')))]),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              PortionStepper(
                value: portions,
                onChanged: (v) => setState(() => _portions = v),
                hint: f.maxPortionsNow < 99 ? 'max ${f.maxPortionsNow}' : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () => cookNow(context, ref, r, portions, timer: _timer),
                  icon: const Icon(Icons.soup_kitchen_outlined),
                  label: const Text('I cooked this'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.recipe, required this.feasibility});
  final Recipe recipe;
  final FeasibilityResult feasibility;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = feasibility.ready
        ? (recipe.feasibilityStatus == 'ready_with_swaps' ? 'ready_with_swaps' : 'ready')
        : 'missing_items';
    final (label, color, icon) = switch (status) {
      'ready' => ('Ready now', c.good, Icons.check_circle),
      'ready_with_swaps' => ('Ready with swaps', c.good, Icons.swap_horiz),
      _ => ('Needs shopping', c.warning, Icons.shopping_cart_outlined),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.titleSmall),
                if ((recipe.summary ?? '').isNotEmpty) Text(recipe.summary!, style: context.text.bodyMedium),
                if (recipe.sourceQuery != null)
                  Text(
                    'You asked: "${recipe.sourceQuery}"',
                    style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends ConsumerWidget {
  const _IngredientRow({required this.ri, required this.portions, required this.stock, required this.feasibility});
  final RecipeIngredient ri;
  final int portions;
  final StockIndex stock;
  final FeasibilityResult feasibility;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final ing = stock.resolve(ri);
    final total = ri.qtyPerPortion * portions;
    final short = feasibility.shortfalls.where((s) => s.item == ri).firstOrNull;
    final (IconData icon, Color color, String status) = switch (ri.role) {
      IngredientRole.staple => (Icons.inventory_2_outlined, context.scheme.onSurfaceVariant, 'staple'),
      IngredientRole.missing => (Icons.shopping_cart_outlined, c.warning, 'to buy'),
      IngredientRole.stock when ing == null => (Icons.help_outline, c.warning, 'not in pantry'),
      IngredientRole.stock when short != null => (
        Icons.trending_down,
        c.serious,
        'have ${UnitConverter.format(short.have, short.unit)}',
      ),
      IngredientRole.stock => (Icons.check, c.good, 'have ${UnitConverter.format(ing!.qtyOnHand, ing.baseUnit)}'),
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text([ri.name, if ((ri.prepNote ?? '').isNotEmpty) ri.prepNote].join(', ')),
      subtitle: Text([status, if ((ri.substitutesFor ?? '').isNotEmpty) 'instead of ${ri.substitutesFor}'].join(' · ')),
      trailing: Text(UnitConverter.format(total, ri.unit), style: context.text.titleSmall),
      onLongPress: ing == null || ing.isStaple
          ? null
          : () => showModalBottomSheet<void>(
              context: context,
              useRootNavigator: true,
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.remove_shopping_cart_outlined),
                      title: Text("I'm out of ${ing.name}"),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await ref.read(pantryServiceProvider).markOut(ing.id);
                        if (ref.read(todayPickProvider).value?.recipe?.ingredients.any((x) => x.key == ing.key) ??
                            false) {
                          await ref.read(todayPickProvider.notifier).refresh(force: true);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: const Text('Adjust quantity'),
                      onTap: () {
                        Navigator.of(context).pop();
                        showIngredientSheet(context, ingredient: ing);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
