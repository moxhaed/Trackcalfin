import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/daily_pick_service.dart';
import '../../core/enums.dart';
import '../../domain/feasibility.dart';
import '../../domain/shopping.dart';
import '../../domain/stock_index.dart';
import '../../platform/speech.dart';
import '../buy/shopping_view.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'cook_actions.dart';
import 'cookbook_import_screen.dart';
import 'cookbooks_screen.dart';

/// Tab 3: Recipe & Meal Prep.
class CookScreen extends ConsumerWidget {
  const CookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook'),
        actions: [
          IconButton(
            tooltip: 'Import cookbook (PDF)',
            onPressed: () => importCookbook(context, ref),
            icon: const Icon(Icons.auto_stories_outlined),
          ),
          IconButton(
            tooltip: 'Write a recipe',
            onPressed: () => context.push('/recipe/new'),
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      body: Column(
        children: [
          const _AskBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(todayPickProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
                    sliver: const SliverMainAxisGroup(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate.fixed([
                            _TodayPickCard(),
                            SizedBox(height: 12),
                            _FridgeStrip(),
                          ]),
                        ),
                        _CookAgain(),
                        SliverToBoxAdapter(child: CookbookShelf()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPickCard extends ConsumerStatefulWidget {
  const _TodayPickCard();

  @override
  ConsumerState<_TodayPickCard> createState() => _TodayPickCardState();
}

class _TodayPickCardState extends ConsumerState<_TodayPickCard> {
  int? _portions;
  final _timer = LogTimer();

  @override
  Widget build(BuildContext context) {
    final pick = ref.watch(todayPickProvider);
    final hasKey = ref.watch(hasApiKeyProvider).value ?? false;
    return pick.when(
      loading: () => const _PickSkeleton(),
      error: (e, _) => SectionCard(title: "Today's pick", child: Text('Could not load: $e')),
      data: (out) => _content(context, out, hasKey),
    );
  }

  Widget _content(BuildContext context, PickOutcome out, bool hasKey) {
    final money = ref.watch(moneyProvider);
    final r = out.recipe;
    if (r == null) {
      return SectionCard(
        title: "Today's pick",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (out.shopping.isNotEmpty) ...[
              Text('Not enough in the pantry for a proper meal yet.', style: context.text.titleSmall),
              const SizedBox(height: 6),
              Text('These would unlock the most meals:', style: context.text.bodySmall),
              const SizedBox(height: 6),
              for (final s in out.shopping)
                Text('• ${s.name}${s.estCostMinor > 0 ? ' (~${money.compact(s.estCostMinor)})' : ''}'),
            ] else if (!hasKey)
              Text(
                'Add a Gemini API key in Settings for a daily recipe built from your pantry. '
                'Until then, saved recipes you can cook show up here.',
              )
            else
              Text(out.error ?? 'Scan a receipt or snap your pantry so there is something to cook with.'),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!hasKey) FilledButton.tonal(onPressed: () => context.go('/settings'), child: const Text('Add key')),
                if (hasKey)
                  FilledButton.tonal(
                    onPressed: () => ref.read(todayPickProvider.notifier).refresh(force: true),
                    child: const Text('Try again'),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    final portions = _portions ?? (r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions);
    final stock = StockIndex(ref.watch(ingredientsProvider).value ?? const []);
    final f = FeasibilityChecker.check(r.ingredients, portions, stock);
    final cookedToday =
        r.lastCookedAt != null &&
        ref.read(dayClockProvider).dateKey(r.lastCookedAt!) == ref.read(dayClockProvider).dateKey(DateTime.now());
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/recipe/${r.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, size: 16, color: context.scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      out.isFallback ? 'FROM YOUR RECIPES' : "TODAY'S PICK",
                      style: context.text.labelMedium?.copyWith(letterSpacing: 0.8, color: context.scheme.primary),
                    ),
                  ),
                  if (out.fromAi && hasKey && !cookedToday)
                    TextButton.icon(
                      onPressed: () async {
                        final err = await ref.read(todayPickProvider.notifier).swap();
                        if (err != null && context.mounted) showInfo(context, err);
                      },
                      icon: const Icon(Icons.shuffle, size: 18),
                      label: const Text('Swap'),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: context.text.headlineSmall),
                    if (r.hook.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(r.hook, style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Metric(value: money.format(r.costPerPortionMinor), label: 'per portion'),
                        Metric(value: '${r.perPortion.kcal.round()}', label: 'kcal', dotColor: context.colors.kcal),
                        Metric(
                          value: '${r.perPortion.proteinG.round()} g',
                          label: 'protein',
                          dotColor: context.colors.protein,
                        ),
                        if (r.totalMinutes > 0) Metric(value: minutesLabel(r.totalMinutes), label: 'total'),
                      ],
                    ),
                    if (!f.ready) ...[
                      const SizedBox(height: 8),
                      StatusPill(
                        label: f.maxPortionsNow > 0
                            ? 'Stock for ${f.maxPortionsNow} portions'
                            : 'Missing ${f.missing.isNotEmpty ? f.missing.first : f.shortfalls.first.item.name}',
                        color: context.colors.warning,
                        icon: Icons.info_outline,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _StepperAndButton(
                      stepper: PortionStepper(
                        value: portions,
                        onChanged: (v) => setState(() => _portions = v),
                        hint: f.maxPortionsNow < 99 ? 'max ${f.maxPortionsNow}' : null,
                      ),
                      icon: cookedToday ? Icons.check : Icons.soup_kitchen_outlined,
                      label: cookedToday ? 'Cooked · again?' : 'I cooked this',
                      onPressed: () => cookNow(context, ref, r, portions, timer: _timer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The portion stepper with the button beside it while the button's label fits on one line;
/// on a narrow phone or with large text the button goes full width under the stepper.
class _StepperAndButton extends StatelessWidget {
  const _StepperAndButton({required this.stepper, required this.icon, required this.label, required this.onPressed});
  final Widget stepper;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final text = TextPainter(
      text: TextSpan(text: label, style: context.text.labelLarge),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    // About 112 for the stepper, 12 between, and the button's icon and padding around its label.
    final needed = scaler.scale(112) + 12 + 66 + text.width;
    text.dispose();
    final button = FilledButton.icon(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= needed
          ? Row(
              children: [
                stepper,
                const SizedBox(width: 12),
                Expanded(child: button),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft, child: stepper),
                const SizedBox(height: 10),
                button,
              ],
            ),
    );
  }
}

class _PickSkeleton extends StatelessWidget {
  const _PickSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: context.colors.track, borderRadius: BorderRadius.circular(8)),
    );
    return SectionCard(
      title: "Today's pick",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(220, 22),
          bar(260, 14),
          const SizedBox(height: 6),
          Row(children: [bar(60, 30), const SizedBox(width: 12), bar(60, 30), const SizedBox(width: 12), bar(60, 30)]),
          Text('Planning from your pantry…', style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class _FridgeStrip extends ConsumerWidget {
  const _FridgeStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridge = ref.watch(fridgeProvider).value ?? const [];
    if (fridge.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: 'In the fridge',
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          children: [
            for (final s in fridge)
              Builder(
                builder: (context) {
                  final left = s.fridgeExpiresAt == null ? null : s.fridgeExpiresAt!.difference(now).inHours / 24;
                  final expired = left != null && left < 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.recipeTitle),
                    subtitle: Text(
                      [
                        '${s.portionsRemaining} left',
                        if (left != null) expired ? 'past its fridge date' : '${left.ceil()} d',
                        '${s.perPortion.proteinG.round()} g protein',
                      ].join(' · '),
                    ),
                    leading: Icon(
                      expired ? Icons.warning_amber_rounded : Icons.kitchen_outlined,
                      color: expired ? context.colors.serious : null,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton.tonal(onPressed: () => eatFromFridge(context, ref, s), child: const Text('Eat 1')),
                        PopupMenuButton<String>(
                          onSelected: (v) async {
                            final cook = ref.read(cookServiceProvider);
                            if (v == 'toss') {
                              await cook.discardPortions(s.id);
                              if (context.mounted) showInfo(context, 'Tossed ${s.recipeTitle}');
                            } else if (v == 'extend') {
                              await cook.extendFridge(s.id, 2);
                            } else if (v == 'undo') {
                              await cook.undoCook(s.id);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'extend', child: Text('Still good (+2 days)')),
                            PopupMenuItem(value: 'toss', child: Text('Toss the rest')),
                            PopupMenuItem(value: 'undo', child: Text('Undo this cook')),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CookAgain extends ConsumerWidget {
  const _CookAgain();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).value ?? const [];
    final pickId = ref.watch(todayPickProvider).value?.recipe?.id;
    final stock = StockIndex(ref.watch(ingredientsProvider).value ?? const []);
    final saved =
        recipes
            .where((r) => r.id != pickId && r.status != RecipeStatus.archived && r.status != RecipeStatus.dismissed)
            // A cookbook's recipes live under Cookbooks until one is cooked or starred.
            .where((r) => r.origin != RecipeOrigin.cookbook || r.favorite || r.timesCooked > 0)
            .where(
              (r) =>
                  r.favorite ||
                  r.timesCooked > 0 ||
                  r.status == RecipeStatus.saved ||
                  r.origin == RecipeOrigin.spontaneous,
            )
            .map(
              (r) => (
                r,
                FeasibilityChecker.check(
                  r.ingredients,
                  r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions,
                  stock,
                ),
              ),
            )
            .toList()
          ..sort((a, b) {
            if (a.$2.ready != b.$2.ready) return a.$2.ready ? -1 : 1;
            if (a.$1.favorite != b.$1.favorite) return a.$1.favorite ? -1 : 1;
            return b.$2.readiness.compareTo(a.$2.readiness);
          });
    if (saved.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.menu_book_outlined,
          title: 'Your recipe rotation lives here',
          message: 'Recipes you cook, save or ask for come back here with "ready now" badges.',
        ),
      );
    }
    // A card like SectionCard, but a lazy list: a long rotation builds only the rows on screen.
    final card = CardTheme.of(context);
    return DecoratedSliver(
      decoration: ShapeDecoration(
        color: card.color ?? context.scheme.surfaceContainerLow,
        shape: card.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'COOK AGAIN',
                  style: context.text.labelMedium?.copyWith(letterSpacing: 0.8, color: context.scheme.onSurfaceVariant),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: saved.length,
              itemBuilder: (context, i) {
                final (r, f) = saved[i];
                // Ink shows on the row's own Material, over the card's color.
                return Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      r.favorite ? Icons.star : Icons.restaurant_menu,
                      color: r.favorite ? context.colors.warning : null,
                    ),
                    title: Text(r.title),
                    subtitle: Text(
                      f.ready
                          ? 'Ready · up to ${f.maxPortionsNow >= 99 ? 'many' : f.maxPortionsNow} portions'
                          : (f.missing.isNotEmpty
                                ? 'Missing ${f.missing.take(2).join(', ')}'
                                : 'Short on ${f.shortfalls.first.item.name}'),
                    ),
                    trailing: f.ready
                        ? Icon(Icons.check_circle, color: context.colors.good, semanticLabel: 'Ready')
                        : IconButton(
                            tooltip: 'Add what is missing to the shopping list',
                            onPressed: () => addToShoppingList(context, ref, Shopping.forRecipe(r, f)),
                            icon: Icon(Icons.add_shopping_cart, color: context.scheme.onSurfaceVariant),
                          ),
                    onTap: () => context.push('/recipe/${r.id}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Type or hold-to-talk: "carbonara for two but lighter".
class _AskBar extends ConsumerStatefulWidget {
  const _AskBar();

  @override
  ConsumerState<_AskBar> createState() => _AskBarState();
}

class _AskBarState extends ConsumerState<_AskBar> {
  final _text = TextEditingController();
  bool _busy = false;
  bool _listening = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final q = _text.text.trim();
    if (q.isEmpty || _busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final timer = LogTimer();
    final metrics = ref.read(metricsServiceProvider);
    final out = await ref.read(askServiceProvider).ask(q);
    unawaited(metrics.record('ask', timer.elapsed));
    if (!mounted) return;
    setState(() => _busy = false);
    if (out.recipe != null) {
      _text.clear();
      unawaited(context.push('/recipe/${out.recipe!.id}'));
    } else {
      showInfo(context, out.error ?? out.summary ?? 'No recipe');
    }
  }

  Future<void> _startListening() async {
    final ok = await Speech.instance.start((words, isFinal) {
      if (!mounted) return;
      setState(() => _text.text = words);
      if (isFinal) {
        setState(() => _listening = false);
        _ask();
      }
    });
    if (!mounted) return;
    if (!ok) {
      showInfo(context, 'Voice input is not available on this device.');
      return;
    }
    setState(() => _listening = true);
  }

  Future<void> _stopListening() async {
    await Speech.instance.stop();
    if (mounted) setState(() => _listening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  enabled: !_busy,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _ask(),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _listening ? 'Listening…' : 'What do you want to cook?',
                    prefixIcon: _busy
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : const Icon(Icons.auto_awesome_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onLongPressStart: (_) => _startListening(),
                onLongPressEnd: (_) => _stopListening(),
                child: IconButton.filled(
                  tooltip: 'Hold to talk, or tap to send',
                  onPressed: _busy ? null : (_text.text.trim().isEmpty ? _startListening : _ask),
                  icon: Icon(_listening ? Icons.graphic_eq : (_text.text.trim().isEmpty ? Icons.mic_none : Icons.send)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
