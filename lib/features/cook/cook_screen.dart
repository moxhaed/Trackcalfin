import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/daily_pick_service.dart';
import '../../core/enums.dart';
import '../../domain/feasibility.dart';
import '../../domain/stock_index.dart';
import '../../platform/speech.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'cook_actions.dart';

/// Tab 3: Recipe & Meal Prep.
class CookScreen extends ConsumerWidget {
  const CookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: TabHeader(
        title: 'Cook',
        actions: [
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
              color: context.scheme.primary,
              onRefresh: () => ref.read(todayPickProvider.notifier).refresh(),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  0,
                  AppSpace.screen,
                  MediaQuery.paddingOf(context).bottom + AppSpace.x6,
                ),
                children: const [_TodayPickCard(), _FridgeSection(), _CookAgain()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The eyebrow line of the pick card: sun icon + "Today's pick" in the accent (16 tall).
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;
    return Row(
      children: [
        Icon(Icons.wb_sunny_outlined, size: 16, color: primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: primary),
          ),
        ),
      ],
    );
  }
}

/// The hero card: white, 20 padding, the eyebrow on its first line. An [action] (Swap) is
/// centered on the eyebrow line in its own 48 tap target that reaches 16 above and below the
/// line, so the title can sit 8 under the eyebrow; its label ends on the card's padding.
class _PickCard extends StatelessWidget {
  const _PickCard({required this.children, this.onTap, this.action});
  final List<Widget> children;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpace.hero),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
            if (action != null)
              Positioned(
                top: AppSpace.hero + 8 - 24,
                right: AppSpace.hero - 12,
                child: SizedBox(height: 48, child: Center(child: action)),
              ),
          ],
        ),
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
      error: (e, _) => AppNotice(kind: NoticeKind.critical, message: "Couldn't plan today's pick.", meta: '$e'),
      data: (out) => _content(context, out, hasKey),
    );
  }

  Widget _content(BuildContext context, PickOutcome out, bool hasKey) {
    final money = ref.watch(moneyProvider);
    final r = out.recipe;
    final secondary = context.scheme.onSurfaceVariant;
    if (r == null) {
      return _PickCard(
        children: [
          const _Eyebrow(label: "Today's pick"),
          const SizedBox(height: AppSpace.x2),
          if (out.shopping.isNotEmpty) ...[
            Text('Not enough in the pantry for a proper meal yet.', style: context.text.titleSmall),
            const SizedBox(height: AppSpace.tight),
            Text('These would unlock the most meals:', style: context.text.bodyMedium?.copyWith(color: secondary)),
            const SizedBox(height: AppSpace.x2),
            for (final s in out.shopping)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 28),
                child: Row(
                  children: [
                    Expanded(child: Text(s.name, style: context.text.bodyLarge)),
                    if (s.estCostMinor > 0)
                      Text('~${money.compact(s.estCostMinor)}', style: context.nums.body.copyWith(color: secondary)),
                  ],
                ),
              ),
          ] else if (!hasKey)
            Text(
              'Add a Gemini API key in Settings for a daily recipe built from your pantry. '
              'Until then, saved recipes you can cook show up here.',
              style: context.text.bodyMedium,
            )
          else
            Text(
              out.error ?? 'Scan a receipt or snap your pantry so there is something to cook with.',
              style: context.text.bodyMedium,
            ),
          const SizedBox(height: AppSpace.x4),
          if (!hasKey)
            FilledButton.tonal(
              style: AppTheme.tonalButton(context),
              onPressed: () => context.go('/settings'),
              child: const Text('Add key'),
            ),
          if (hasKey)
            FilledButton.tonal(
              style: AppTheme.tonalButton(context),
              onPressed: () => ref.read(todayPickProvider.notifier).refresh(force: true),
              child: const Text('Try again'),
            ),
        ],
      );
    }
    final portions = _portions ?? (r.lastPortionsCooked > 0 ? r.lastPortionsCooked : r.defaultPortions);
    final stock = StockIndex(ref.watch(ingredientsProvider).value ?? const []);
    final f = FeasibilityChecker.check(r.ingredients, portions, stock);
    final cookedToday =
        r.lastCookedAt != null &&
        ref.read(dayClockProvider).dateKey(r.lastCookedAt!) == ref.read(dayClockProvider).dateKey(DateTime.now());
    final c = context.colors;
    return _PickCard(
      onTap: () => context.push('/recipe/${r.id}'),
      action: out.fromAi && hasKey && !cookedToday
          ? TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(48, 36)),
              onPressed: () async {
                final err = await ref.read(todayPickProvider.notifier).swap();
                if (err != null && context.mounted) showInfo(context, err);
              },
              icon: const Icon(Icons.shuffle_rounded, size: 18),
              label: const Text('Swap'),
            )
          : null,
      children: [
        _Eyebrow(label: out.isFallback ? 'From your recipes' : "Today's pick"),
        const SizedBox(height: AppSpace.x2),
        NoWidowText(r.title, style: context.text.headlineSmall),
        if (r.hook.isNotEmpty) ...[
          const SizedBox(height: AppSpace.tight),
          SeparatedText(r.hook, style: context.text.bodyMedium?.copyWith(color: secondary)),
        ],
        const SizedBox(height: AppSpace.x4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Metric(value: money.format(r.costPerPortionMinor), label: 'per portion'),
            ),
            Expanded(
              child: Metric(value: '${r.perPortion.kcal.round()}', label: 'kcal', dotColor: c.kcal),
            ),
            Expanded(
              child: Metric(value: '${r.perPortion.proteinG.round()} g', label: 'protein', dotColor: c.protein),
            ),
            Expanded(
              child: r.totalMinutes > 0
                  ? Metric(value: minutesLabel(r.totalMinutes), label: 'total')
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        if (!f.ready) ...[
          const SizedBox(height: AppSpace.x3),
          StatusPill(
            label: f.maxPortionsNow > 0
                ? 'Stock for ${f.maxPortionsNow} portions'
                : 'Missing ${f.missing.isNotEmpty ? f.missing.first : f.shortfalls.first.item.name}',
            color: c.warning,
            ink: c.warningInk,
            icon: Icons.info_outline_rounded,
          ),
        ],
        const SizedBox(height: AppSpace.x4),
        Row(
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
                icon: Icon(cookedToday ? Icons.check_rounded : Icons.soup_kitchen_outlined),
                label: Text(cookedToday ? 'Cooked · again?' : 'I cooked this'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The pick card while the day's recipe is planned: the real eyebrow and caption, the rest
/// as pulsing blocks in the card's real layout.
class _PickSkeleton extends StatelessWidget {
  const _PickSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget metric() => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLine(width: 48, style: context.nums.medium),
          const SizedBox(height: AppSpace.tight),
          SkeletonLine(width: 40, style: context.text.bodySmall),
        ],
      ),
    );
    return _PickCard(
      children: [
        const _Eyebrow(label: "Today's pick"),
        const SizedBox(height: AppSpace.x2),
        AppSkeleton(
          child: LayoutBuilder(
            builder: (context, c) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: c.maxWidth * 0.7, style: context.text.headlineSmall),
                const SizedBox(height: AppSpace.tight),
                SkeletonLine(width: c.maxWidth * 0.9, style: context.text.bodyMedium),
                const SizedBox(height: AppSpace.x4),
                Row(children: [metric(), metric(), metric(), metric()]),
                const SizedBox(height: AppSpace.x4),
                const Row(
                  children: [
                    SkeletonBlock(width: 136, height: 48, radius: 24),
                    SizedBox(width: AppSpace.x3),
                    Expanded(child: SkeletonBlock(height: 52, radius: 26)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.x3),
        Text('Planning from your pantry…', style: context.text.bodySmall),
      ],
    );
  }
}

class _FridgeSection extends ConsumerWidget {
  const _FridgeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridge = ref.watch(fridgeProvider).value ?? const [];
    if (fridge.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('In the fridge'),
        AppGroup(
          children: [
            for (final s in fridge)
              Builder(
                builder: (context) {
                  final left = s.fridgeExpiresAt == null ? null : s.fridgeExpiresAt!.difference(now).inHours / 24;
                  final expired = left != null && left < 0;
                  return AppRow(
                    title: s.recipeTitle,
                    // Only an expired portion gets a leading mark; the section already says "fridge".
                    leading: expired ? Icon(Icons.warning_amber_rounded, size: 20, color: c.warning) : null,
                    subtitleSpan: TextSpan(
                      children: [
                        TextSpan(text: '${s.portionsRemaining} left'),
                        if (left != null) ...[
                          const TextSpan(text: ' · '),
                          expired
                              ? TextSpan(
                                  text: 'past its fridge date',
                                  style: TextStyle(color: c.warningInk),
                                )
                              : TextSpan(text: '${left.ceil()} d'),
                        ],
                        TextSpan(text: ' · ${s.perPortion.proteinG.round()} g protein'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton.tonal(
                          style: AppTheme.tonalButton(context, small: true),
                          onPressed: () => eatFromFridge(context, ref, s),
                          child: const Text('Eat 1'),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz_rounded),
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
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'extend', child: Text('Still good (+2 days)')),
                            PopupMenuItem(
                              value: 'toss',
                              child: Text('Toss the rest', style: TextStyle(color: c.criticalInk)),
                            ),
                            const PopupMenuItem(value: 'undo', child: Text('Undo this cook')),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ],
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
      return const Padding(
        padding: EdgeInsets.only(top: AppSpace.x4),
        child: EmptyState(
          icon: Icons.menu_book_outlined,
          title: 'Your recipe rotation lives here',
          message: 'Recipes you cook, save or ask for come back here with "ready now" badges.',
        ),
      );
    }
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Cook again'),
        AppGroup(
          separatorIndent: AppGroup.indentIcon,
          children: [
            for (final (r, f) in saved)
              AppRow(
                leading: f.ready
                    ? Icon(Icons.check_circle_rounded, size: 20, color: c.good, semanticLabel: 'Ready')
                    : Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                        color: context.scheme.onSurfaceVariant,
                        semanticLabel: 'Needs shopping',
                      ),
                title: r.title,
                titleTrailing: r.favorite
                    ? Icon(Icons.star_rounded, size: 16, color: context.scheme.onSurface, semanticLabel: 'Favorite')
                    : null,
                subtitle: f.ready
                    ? 'Ready · up to ${f.maxPortionsNow >= 99 ? 'many' : f.maxPortionsNow} portions'
                    : (f.missing.isNotEmpty
                          ? 'Missing ${f.missing.take(2).join(', ')}'
                          : 'Short on ${f.shortfalls.first.item.name}'),
                chevron: true,
                onTap: () => context.push('/recipe/${r.id}'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Type or hold-to-talk: "carbonara for two but lighter". The mic (or send) button sits
/// inside the field.
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
    final out = await ref.read(askServiceProvider).ask(q);
    unawaited(ref.read(metricsServiceProvider).record('ask', timer.elapsed));
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
    final primary = context.scheme.primary;
    final empty = _text.text.trim().isEmpty;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, AppSpace.x3),
          child: TextField(
            controller: _text,
            enabled: !_busy,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _ask(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: _listening ? 'Listening…' : 'What do you want to cook?',
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              prefixIcon: _busy
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                      ),
                    )
                  : Icon(Icons.auto_awesome_outlined, size: 20, color: primary),
              suffixIcon: GestureDetector(
                onLongPressStart: (_) => _startListening(),
                onLongPressEnd: (_) => _stopListening(),
                child: IconButton(
                  tooltip: 'Hold to talk, or tap to send',
                  color: primary,
                  style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
                  onPressed: _busy ? null : (empty ? _startListening : _ask),
                  icon: Icon(
                    _listening ? Icons.graphic_eq_rounded : (empty ? Icons.mic_none_rounded : Icons.send_rounded),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
