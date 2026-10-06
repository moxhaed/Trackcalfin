import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_clock.dart';
import '../../core/enums.dart';
import '../../core/money.dart';
import '../../domain/dashboard.dart';
import '../../domain/streak.dart';
import '../../domain/vibe.dart';
import '../capture/ate_sheet.dart';
import '../common/category_style.dart';
import '../common/widgets.dart';

final _grouped = NumberFormat.decimalPattern();

/// Tab 1: read-only, 100% algorithmic.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dashboardProvider);
    final checks = ref.watch(quickCheckProvider).length;
    return Scaffold(
      appBar: TabHeader(
        title: DateFormat('EEE d MMM').format(DateTime.now()),
        actions: [
          if (checks > 0)
            HeaderButton(
              icon: Icons.fact_check_outlined,
              label: 'Quick check · $checks',
              shortLabel: '$checks',
              onPressed: () => context.push('/quick-check'),
            ),
        ],
      ),
      body: view.when(
        loading: () => const _DashboardSkeleton(),
        error: (e, _) => ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
          children: [AppNotice(kind: NoticeKind.critical, message: "Couldn't load your dashboard.", meta: '$e')],
        ),
        data: (v) => _DashboardBody(view: v),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.view});
  final DashboardView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final s = view.state;
    Widget card(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: child,
    );
    // Cards sit on the 16 margins; the Vibe hero's tap area reaches 8 past them (§7.4).
    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + AppSpace.x6),
      children: [
        _VibeHero(vibe: view.vibe),
        const SizedBox(height: AppSpace.x3),
        card(
          _TodayCard(
            state: s,
            kcalTarget: view.profile.dailyKcalTarget,
            proteinTarget: view.profile.dailyProteinTargetG,
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),
        card(_FoodSpendCard(state: s, money: money)),
        const SizedBox(height: AppSpace.cardGap),
        card(_OtherSpendCard(state: s, money: money)),
        const SizedBox(height: AppSpace.cardGap),
        card(_WeekCard(state: s, kcalTarget: view.profile.dailyKcalTarget, streak: view.streak)),
      ],
    );
  }
}

Color _vibeColor(AppColors c, int? score) {
  if (score == null) return c.track;
  if (score >= 70) return c.good;
  if (score >= 50) return c.warning;
  return c.critical;
}

Color _partColor(AppColors c, double value) => value >= 70 ? c.good : (value >= 50 ? c.warning : c.critical);

/// The Vibe score on the canvas: ring, "Vibe · label", the insight and a chevron. The whole
/// hero opens the explanation sheet; its pressed area is inset 8 from the screen edges and
/// pads its content by 8, so the ring still starts at x = 16.
class _VibeHero extends StatelessWidget {
  const _VibeHero({required this.vibe});
  final VibeResult vibe;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final score = vibe.score;
    final tappable = vibe.components.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: tappable ? () => _explainVibe(context, vibe) : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x2),
          child: Row(
            children: [
              RingGauge(
                fraction: (score ?? 0) / 100,
                color: _vibeColor(c, score),
                semanticsLabel: score == null
                    ? 'Vibe not scored yet, ${vibe.label}'
                    : 'Vibe $score of 100, ${vibe.label}',
                center: ValueFade(
                  id: score ?? '–',
                  alignment: Alignment.center,
                  child: Text(
                    score?.toString() ?? '–',
                    style: context.nums.large.copyWith(fontSize: 24, height: 28 / 24, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.x4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ValueFade(
                            id: vibe.label,
                            child: Text('Vibe · ${vibe.label}', style: context.text.titleMedium),
                          ),
                        ),
                        if (tappable) Icon(Icons.chevron_right_rounded, size: 20, color: c.textTertiary),
                      ],
                    ),
                    const SizedBox(height: AppSpace.tight),
                    NoWidowText(
                      vibe.insight,
                      maxLines: 3,
                      style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
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

/// "How the vibe is scored": one row per part with its 0–100 value and a bar (§7.14).
void _explainVibe(BuildContext context, VibeResult vibe) {
  const names = {
    'food': 'Food spend pace',
    'nonfood': 'Other spend, all categories',
    'protein': 'Protein vs target',
    'kcal': 'Calories vs target',
    'logging': 'Days logged',
  };
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How the vibe is scored', style: context.text.headlineSmall),
            const SizedBox(height: AppSpace.tight),
            Text(
              'Each part is scored 0–100.\nParts without a goal are left out.',
              style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
            for (final e in vibe.components.entries) ...[
              const SizedBox(height: AppSpace.x4),
              Row(
                children: [
                  Expanded(child: Text(names[e.key] ?? e.key, style: context.text.bodyLarge)),
                  Text('${e.value.round()}', style: context.nums.body.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: AppSpace.x2),
              PaceBar(fraction: e.value / 100, color: _partColor(context.colors, e.value)),
            ],
          ],
        ),
      ),
    ),
  );
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.state, required this.kcalTarget, required this.proteinTarget});
  final DashboardState state;
  final double kcalTarget;
  final double proteinTarget;

  @override
  Widget build(BuildContext context) {
    final t = state.today;
    final c = context.colors;
    // Value + unit, "● of 2,200 kcal · 45%" and a bar: kcal left, protein right.
    // [name] reads the column aloud and, for protein, names the nutrient after the target
    // (color is never the only cue).
    Widget column(String name, double v, double target, String unit, Color color, {String? noun}) {
      final pct = target <= 0 ? 0 : (v / target * 100).round();
      final value = '${_grouped.format(v.round())} $unit';
      final of = '${_grouped.format(target.round())}\u00A0$unit';
      return Semantics(
        container: true,
        excludeSemantics: true,
        label: unit == 'kcal'
            ? '$name ${_grouped.format(v.round())} of ${_grouped.format(target.round())}, $pct%'
            : '$name $value of $of, $pct%',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Metric(
              value: value,
              label: 'of $of${noun == null ? '' : ' $noun'} · $pct%',
              dotColor: color,
              style: context.nums.large,
              fadeValue: true,
            ),
            const SizedBox(height: AppSpace.x2),
            PaceBar(fraction: target <= 0 ? 0 : v / target, color: color),
          ],
        ),
      );
    }

    return SectionCard(
      title: 'Today',
      trailing: TextButton.icon(
        onPressed: () => showAteSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Meal'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: column('Calories', t.kcal, kcalTarget, 'kcal', c.kcal)),
              const SizedBox(width: AppSpace.x6),
              Expanded(child: column('Protein', t.proteinG, proteinTarget, 'g', c.protein, noun: 'protein')),
            ],
          ),
          if (state.todayMeals == 0) ...[
            const SizedBox(height: AppSpace.x3),
            Text('Nothing logged yet today.', style: context.text.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _FoodSpendCard extends StatelessWidget {
  const _FoodSpendCard({required this.state, required this.money});
  final DashboardState state;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final c = context.colors;
    final secondary = context.scheme.onSurfaceVariant;
    // "Week", then "€54 / €69" with the status label on the right, then the bar and marker.
    Widget pace(String label, int spent, int budget, double? pace, double marker) {
      final over = pace != null && pace > 1.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.labelMedium?.copyWith(color: secondary)),
          const SizedBox(height: AppSpace.tight),
          Row(
            children: [
              Expanded(
                child: ValueFade(
                  id: '$spent/$budget',
                  child: Text.rich(
                    TextSpan(
                      style: context.nums.medium,
                      children: [
                        TextSpan(text: money.compact(spent)),
                        if (budget > 0)
                          TextSpan(
                            text: ' / ${money.compact(budget)}',
                            style: context.text.bodyMedium?.copyWith(color: secondary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (budget > 0)
                StatusPill(
                  label: over ? '${((pace - 1) * 100).round()}% ahead' : 'On pace',
                  color: c.forPace(pace),
                  ink: c.inkForPace(pace),
                  icon: over ? Icons.north_east_rounded : Icons.check_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          PaceBar(
            fraction: budget > 0 ? spent / budget : 0,
            marker: budget > 0 ? marker : null,
            color: c.forPace(pace),
            semanticsLabel: budget > 0
                ? '$label spend ${money.compact(spent)} of ${money.compact(budget)}, '
                      '${over ? '${((pace - 1) * 100).round()}% ahead' : 'on pace'}'
                : '$label spend ${money.compact(spent)}',
          ),
        ],
      );
    }

    final projection = s.collectingData
        ? 'Projection after 7 days of data'
        : 'Projected month: ${money.compact(s.projectedMonth ?? 0)} (trailing week × 4.33)';
    // Key–value lines under the hairline: label left, value right on the card's padding.
    Widget line(String label, String value) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: context.text.bodyMedium?.copyWith(color: secondary)),
          ),
          Text(value, style: context.nums.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return SectionCard(
      title: 'Food spend',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pace('Week', s.weekFood, s.weeklyBudget, s.weekPace, s.weekElapsedFraction),
          const SizedBox(height: AppSpace.block),
          pace('Month', s.monthFood, s.monthlyBudget, s.monthPace, s.monthElapsedFraction),
          const SizedBox(height: AppSpace.x2),
          Text(projection, style: context.text.bodySmall),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
            child: Divider(height: 0.5, thickness: 0.5),
          ),
          line('Eaten this week', money.compact(s.eatenWeek)),
          const SizedBox(height: AppSpace.tight),
          line('Per home meal', s.costPerMeal == null ? '–' : money.compact(s.costPerMeal!)),
          const SizedBox(height: AppSpace.tight),
          line('Saved vs eating out', (s.savedVsOut ?? 0) > 0 ? money.compact(s.savedVsOut!) : '–'),
        ],
      ),
    );
  }
}

class _OtherSpendCard extends StatelessWidget {
  const _OtherSpendCard({required this.state, required this.money});
  final DashboardState state;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final secondary = context.scheme.onSurfaceVariant;
    final rows = state.nonFood.where((c) => c.limitMinor > 0 || c.spentMinor > 0).toList();
    // Line 1: icon, label, amount (amber with a warning icon when well over pace).
    // Line 2: a full-width bar with the month marker, when there's a limit.
    Widget row(CategorySpend s) {
      final over = s.pace != null && s.pace! > 1.15;
      // One status hue per row: icon, amount and bar all follow the pace.
      final amount = context.nums.body.copyWith(color: over ? c.inkForPace(s.pace) : null);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(categoryIcon(s.category), size: 16, color: secondary),
              const SizedBox(width: AppSpace.x2),
              Expanded(
                child: Text(
                  s.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              if (over) ...[
                Icon(Icons.warning_amber_rounded, size: 16, color: c.forPace(s.pace), semanticLabel: 'Over pace'),
                const SizedBox(width: AppSpace.x1),
              ],
              Text.rich(
                TextSpan(
                  style: amount,
                  children: [
                    TextSpan(text: money.format(s.spentMinor, whole: true)),
                    if (s.limitMinor > 0)
                      TextSpan(
                        text: ' / ${money.format(s.limitMinor, whole: true)}',
                        style: TextStyle(color: secondary, fontWeight: FontWeight.w400),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (s.limitMinor > 0) ...[
            const SizedBox(height: 6),
            PaceBar(
              fraction: s.spentMinor / s.limitMinor,
              marker: state.monthElapsedFraction,
              color: c.forPace(s.pace),
              height: 4,
            ),
          ],
        ],
      );
    }

    return SectionCard(
      title: 'Other spend',
      trailing: Text('This month', style: context.text.bodySmall),
      child: rows.isEmpty
          ? Text('No other spending this month.', style: context.text.bodyMedium?.copyWith(color: secondary))
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: AppSpace.x3), row(rows[i])],
              ],
            ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.state, required this.kcalTarget, required this.streak});
  final DashboardState state;
  final double kcalTarget;
  final StreakResult streak;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final secondary = context.scheme.onSurfaceVariant;
    final bars = s.weekBars;
    final todayIndex = bars.indexWhere((b) => b.isToday);
    final avgLabel = s.avgKcal == null
        ? 'No completed days logged yet'
        : '${s.avgIsLastWeek ? 'Last week' : 'Avg'} ${_grouped.format(s.avgKcal!.round())} kcal · '
              '${s.avgProtein!.round()} g protein';
    final days = [for (final b in bars) DayClock.dateOfKey(b.dateKey)];
    return SectionCard(
      title: 'Calories this week',
      trailing: streak.days >= 2
          ? Tooltip(
              message: streak.freezesUsed > 0
                  ? '${streak.freezesUsed} missed ${streak.freezesUsed == 1 ? 'day was' : 'days were'} covered by the weekly freeze'
                  : 'Days in a row with something logged',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_outlined, size: 16, color: secondary),
                  const SizedBox(width: AppSpace.x1),
                  Text(
                    '${streak.days}-day streak',
                    style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: secondary),
                  ),
                ],
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(avgLabel, style: context.text.titleSmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          if (s.coverage != null) ...[
            const SizedBox(height: 2),
            Text('${s.completedDays} of ${s.elapsedDays} days logged', style: context.text.bodySmall),
          ],
          const SizedBox(height: AppSpace.x3),
          WeekBars(
            values: [for (final b in bars) b.kcal],
            labels: [for (final d in days) DateFormat.E().format(d).substring(0, 2)],
            dayNames: [for (final d in days) DateFormat.EEEE().format(d)],
            target: kcalTarget,
            color: context.colors.kcal,
            highlight: todayIndex < 0 ? null : todayIndex,
            muted: {
              for (var i = 0; i < bars.length; i++)
                if (bars[i].isToday) i,
            },
            format: (v) => '${_grouped.format(v.round())} kcal',
          ),
          const SizedBox(height: AppSpace.x2),
          Text('Dashed line: daily target. Today is in progress.', style: context.text.bodySmall),
        ],
      ),
    );
  }
}

/// First load: the real header, a hero placeholder and two card placeholders (§7.18).
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget card(String title) => Padding(
      padding: const EdgeInsets.only(top: AppSpace.cardGap),
      child: SectionCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: SkeletonLine(width: 96, style: context.nums.large)),
                const SizedBox(width: AppSpace.x6),
                Expanded(child: SkeletonLine(width: 72, style: context.nums.large)),
              ],
            ),
            const SizedBox(height: AppSpace.x2),
            const SkeletonBlock(height: 6, radius: 3),
          ],
        ),
      ),
    );
    return AppSkeleton(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
        children: [
          Row(
            children: [
              const SkeletonBlock(width: 72, height: 72, radius: 36),
              const SizedBox(width: AppSpace.x4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(width: 160, style: context.text.titleMedium),
                    const SizedBox(height: AppSpace.tight),
                    SkeletonLine(width: 220, style: context.text.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          card('Today'),
          card('Food spend'),
        ],
      ),
    );
  }
}
