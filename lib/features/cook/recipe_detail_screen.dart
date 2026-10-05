import 'dart:ui' show ImageFilter;

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
    if (r == null) return const Scaffold(appBar: PageBar(), body: _DetailSkeleton());
    final money = ref.watch(moneyProvider);
    final ingredients = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
    final stock = StockIndex(ingredients);
    final portions = _portions ?? (r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions);
    final f = FeasibilityChecker.check(r.ingredients, portions, stock);
    final c = context.colors;
    final secondary = context.scheme.onSurfaceVariant;
    final recipes = ref.read(recipeServiceProvider);
    Widget slot(Widget? metric) => Expanded(child: metric ?? const SizedBox.shrink());

    return Scaffold(
      // The list scrolls under the translucent cook bar.
      extendBody: true,
      appBar: PageBar(
        actions: [
          IconButton(
            tooltip: r.favorite ? 'Remove favorite' : 'Favorite',
            onPressed: () => recipes.setFavorite(r.id, !r.favorite),
            icon: Icon(r.favorite ? Icons.star_rounded : Icons.star_outline_rounded),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
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
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: c.criticalInk)),
              ),
            ],
          ),
        ],
      ),
      // Built inside the Scaffold, so the bottom padding includes the cook bar's height.
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpace.screen,
            AppSpace.headerGap,
            AppSpace.screen,
            MediaQuery.paddingOf(context).bottom + AppSpace.x6,
          ),
          children: [
            if (r.feasibilityStatus != null) ...[
              _Verdict(recipe: r, feasibility: f),
              const SizedBox(height: AppSpace.x3),
            ],
            NoWidowText(r.title, style: context.text.headlineMedium),
            if (r.hook.isNotEmpty) ...[
              const SizedBox(height: AppSpace.tight),
              SeparatedText(r.hook, style: context.text.bodyLarge?.copyWith(color: secondary)),
            ],
            if (r.why.isNotEmpty) ...[
              const SizedBox(height: AppSpace.tight),
              Text(noOrphans(r.why), style: context.text.bodySmall),
            ],
            const SizedBox(height: AppSpace.x4),
            SectionCard(
              title: 'Per portion',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      slot(Metric(value: '${r.perPortion.kcal.round()}', label: 'kcal', dotColor: c.kcal)),
                      slot(Metric(value: '${r.perPortion.proteinG.round()} g', label: 'protein', dotColor: c.protein)),
                      slot(Metric(value: '${r.perPortion.carbsG.round()} g', label: 'carbs')),
                      slot(Metric(value: '${r.perPortion.fatG.round()} g', label: 'fat')),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    child: Divider(height: 0.5, thickness: 0.5),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      slot(Metric(value: money.format(r.costPerPortionMinor), label: 'cost')),
                      slot(r.totalMinutes > 0 ? Metric(value: minutesLabel(r.totalMinutes), label: 'total') : null),
                      slot(r.activeMinutes > 0 ? Metric(value: minutesLabel(r.activeMinutes), label: 'active') : null),
                      slot(r.fridgeLifeDays > 0 ? Metric(value: '${r.fridgeLifeDays} d', label: 'in fridge') : null),
                    ],
                  ),
                ],
              ),
            ),
            if (r.validationFlags.any((f) => f.startsWith('estimate_divergence'))) ...[
              const SizedBox(height: AppSpace.x2),
              Text(
                'The AI estimate differed a lot; these numbers come from your pantry data.',
                style: context.text.bodySmall,
              ),
            ],
            SectionTitle('Ingredients · $portions ${portions == 1 ? 'portion' : 'portions'}'),
            AppGroup(
              separatorIndent: AppGroup.indentIcon,
              children: [
                for (final ri in r.ingredients)
                  _IngredientRow(ri: ri, portions: portions, stock: stock, feasibility: f),
              ],
            ),
            if (r.omitted.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x2, AppSpace.x4, 0),
                child: Text('Left out: ${r.omitted.join(', ')}', style: context.text.bodySmall),
              ),
            if (r.shoppingList.isNotEmpty) ...[
              const SectionTitle('To buy'),
              AppGroup(
                separatorIndent: AppGroup.indentIcon,
                children: [
                  for (final s in r.shoppingList)
                    AppRow(
                      leading: Icon(
                        s.reason == 'short' ? Icons.trending_down_rounded : Icons.shopping_cart_outlined,
                        size: 20,
                      ),
                      title: '${s.name}${s.packageDesc.isNotEmpty ? ' · ${s.packageDesc}' : ''}',
                      value: s.estCostMinor > 0 ? '~${money.compact(s.estCostMinor)}' : null,
                    ),
                ],
              ),
            ],
            const SectionTitle('Steps'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.card),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (i, s) in r.steps.indexed) ...[
                      if (i > 0) const SizedBox(height: AppSpace.x4),
                      _Step(number: i + 1, text: s),
                    ],
                    if (r.steps.isEmpty)
                      Text('No steps written.', style: context.text.bodyMedium?.copyWith(color: secondary)),
                  ],
                ),
              ),
            ),
            if (r.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpace.x4),
              Wrap(
                spacing: AppSpace.x2,
                runSpacing: AppSpace.x2,
                children: [for (final t in r.tags) Tag(t.replaceAll('_', ' '))],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _CookBar(
        child: Row(
          children: [
            PortionStepper(
              value: portions,
              onChanged: (v) => setState(() => _portions = v),
              hint: f.maxPortionsNow < 99 ? 'max ${f.maxPortionsNow}' : null,
            ),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: FilledButton.icon(
                style: AppTheme.largeButton,
                onPressed: () => cookNow(context, ref, r, portions, timer: _timer),
                icon: const Icon(Icons.soup_kitchen_outlined),
                label: const Text('I cooked this'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The always-visible bottom bar: canvas at 94 % over a blur, with a top hairline (§6).
class _CookBar extends StatelessWidget {
  const _CookBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.scheme.surface.withValues(alpha: 0.94),
            border: Border(top: BorderSide(color: context.colors.separator, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.x3, AppSpace.screen, AppSpace.x3),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// One numbered step: a 24 circle on the neutral fill, then the text at reading size 16/24.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: context.colors.fill, shape: BoxShape.circle),
          child: Text(
            '$number',
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: AppSpace.x3),
        Expanded(
          child: Text(noOrphans(text), style: context.text.bodyLarge?.copyWith(height: 24 / 16)),
        ),
      ],
    );
  }
}

/// Before the recipe arrives: the title and the first card as placeholders.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
        children: [
          SkeletonLine(width: 260, style: context.text.headlineMedium),
          const SizedBox(height: AppSpace.tight),
          SkeletonLine(width: 220, style: context.text.bodyLarge),
          const SizedBox(height: AppSpace.x4),
          const SkeletonBlock(height: 160, radius: AppRadius.card),
        ],
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
    final status = feasibility.ready
        ? (recipe.feasibilityStatus == 'ready_with_swaps' ? 'ready_with_swaps' : 'ready')
        : 'missing_items';
    final (label, kind, icon) = switch (status) {
      'ready' => ('Ready now', NoticeKind.success, Icons.check_circle_outline_rounded),
      'ready_with_swaps' => ('Ready with swaps', NoticeKind.success, Icons.swap_horiz_rounded),
      _ => ('Needs shopping', NoticeKind.warning, Icons.shopping_cart_outlined),
    };
    final summary = recipe.summary ?? '';
    return AppNotice(
      kind: kind,
      icon: icon,
      title: label,
      message: summary.isEmpty ? null : summary,
      meta: recipe.sourceQuery == null ? null : 'You asked: "${recipe.sourceQuery}"',
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
      IngredientRole.stock when ing == null => (Icons.help_outline_rounded, c.warning, 'not in pantry'),
      IngredientRole.stock when short != null => (
        Icons.trending_down_rounded,
        c.serious,
        'have ${UnitConverter.format(short.have, short.unit)}',
      ),
      IngredientRole.stock => (
        Icons.check_rounded,
        c.good,
        'have ${UnitConverter.format(ing!.qtyOnHand, ing.baseUnit)}',
      ),
    };
    return AppRow(
      leading: Icon(icon, color: color, size: 20),
      title: [ri.name, if ((ri.prepNote ?? '').isNotEmpty) ri.prepNote].join(', '),
      subtitle: [status, if ((ri.substitutesFor ?? '').isNotEmpty) 'instead of ${ri.substitutesFor}'].join(' · '),
      value: UnitConverter.format(total, ri.unit),
      onLongPress: ing == null || ing.isStaple
          ? null
          : () => showModalBottomSheet<void>(
              context: context,
              useRootNavigator: true,
              builder: (_) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.x2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppRow(
                        leading: const Icon(Icons.remove_shopping_cart_outlined),
                        title: "I'm out of ${ing.name}",
                        onTap: () async {
                          Navigator.of(context).pop();
                          await ref.read(pantryServiceProvider).markOut(ing.id);
                          if (ref.read(todayPickProvider).value?.recipe?.ingredients.any((x) => x.key == ing.key) ??
                              false) {
                            await ref.read(todayPickProvider.notifier).refresh(force: true);
                          }
                        },
                      ),
                      const Divider(height: 0.5, thickness: 0.5, indent: AppGroup.indentIcon),
                      AppRow(
                        leading: const Icon(Icons.tune_rounded),
                        title: 'Adjust quantity',
                        onTap: () {
                          Navigator.of(context).pop();
                          showIngredientSheet(context, ingredient: ing);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
