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
import '../../domain/vibe.dart';
import '../capture/ate_sheet.dart';
import '../common/category_style.dart';
import '../common/widgets.dart';

/// Tab 1: read-only, 100% algorithmic.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dashboardProvider);
    final checks = ref.watch(quickCheckProvider.select((l) => l.length));
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEE d MMM').format(DateTime.now())),
        actions: [
          if (checks > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.fact_check_outlined, size: 18),
                label: Text('Quick check · $checks'),
                onPressed: () => context.push('/quick-check'),
              ),
            ),
        ],
      ),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
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
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        _StatusCard(vibe: view.vibe),
        const SizedBox(height: 12),
        _TodayCard(state: s, kcalTarget: view.profile.dailyKcalTarget, proteinTarget: view.profile.dailyProteinTargetG),
        const SizedBox(height: 12),
        _FoodCard(state: s, money: money),
        const SizedBox(height: 12),
        _OtherSpendCard(state: s, money: money),
        const SizedBox(height: 12),
        _WeekCard(state: s, kcalTarget: view.profile.dailyKcalTarget),
      ],
    );
  }
}

/// How things are going, without a score: a circle in the status color with an icon (never
/// color alone), a plain word and one line on what matters most. Tap for what goes into it.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.vibe});
  final VibeResult vibe;

  static (Color, IconData) look(BuildContext context, VibeLevel level) => switch (level) {
    VibeLevel.good => (context.colors.good, Icons.check),
    VibeLevel.watch => (context.colors.warning, Icons.trending_down),
    VibeLevel.off => (context.colors.critical, Icons.priority_high),
    VibeLevel.none => (context.scheme.onSurfaceVariant, Icons.hourglass_empty),
  };

  @override
  Widget build(BuildContext context) {
    final on = context.scheme.onPrimaryContainer;
    return Card(
      color: context.scheme.primaryContainer.withValues(alpha: 0.55),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: vibe.components.isEmpty ? null : () => _explain(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Semantics(
                label: 'Status: ${vibe.label}',
                child: StatusCircle(level: vibe.level, size: 64),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vibe.label, style: context.text.titleMedium?.copyWith(color: on)),
                    const SizedBox(height: 4),
                    Text(vibe.insight, style: context.text.bodyMedium?.copyWith(color: on)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _explain(BuildContext context) {
    const names = {
      'food': 'Food budget',
      'nonfood': 'Other spending',
      'protein': 'Protein',
      'kcal': 'Calories',
      'logging': 'Days logged',
    };
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What goes into it', style: context.text.titleLarge),
              const SizedBox(height: 4),
              Text(
                'This week and month so far. Parts without a goal are left out.',
                style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              for (final e in vibe.components.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      StatusCircle(level: VibeScorer.levelFor(e.value), size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Text(names[e.key] ?? e.key, style: context.text.bodyLarge)),
                      Text(VibeScorer.labelFor(e.value.round()), style: context.text.titleSmall),
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

/// A status as a circle: the status color, with an icon so it never relies on color alone.
class StatusCircle extends StatelessWidget {
  const StatusCircle({super.key, required this.level, this.size = 64});
  final VibeLevel level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _StatusCard.look(context, level);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color, width: size / 12),
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
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
    Widget ring(String label, double v, double target, Color color, String unit) => Expanded(
      child: Row(
        children: [
          RingGauge(
            fraction: target <= 0 ? 0 : v / target,
            color: color,
            size: 58,
            stroke: 7,
            center: Text('${target <= 0 ? 0 : (v / target * 100).round()}%', style: context.text.labelMedium),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Metric(value: '${v.round()}$unit', label: '$label / ${target.round()}$unit', dotColor: color),
          ),
        ],
      ),
    );
    return SectionCard(
      title: 'Today',
      trailing: TextButton.icon(
        onPressed: () => showAteSheet(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Meal'),
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ring('kcal', t.kcal, kcalTarget, c.kcal, ''),
              const SizedBox(width: 8),
              ring('protein', t.proteinG, proteinTarget, c.protein, '\u00a0g'),
            ],
          ),
          if (state.todayMeals == 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Nothing logged yet today.',
                style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

/// The food budget, by what was eaten (default) or what was spent. A big shop that lasts two
/// weeks makes spending jumpy; what was eaten shows the real weekly cost of food.
class _FoodCard extends ConsumerWidget {
  const _FoodCard({required this.state, required this.money});
  final DashboardState state;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = state;
    final f = s.food;
    final eaten = s.basis == FoodBasis.eaten;
    final c = context.colors;
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    Widget row(String label, int amount, int budget, double? pace, double marker, {String? extra}) {
      final color = c.forPace(pace);
      final over = pace != null && pace > 1.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label, style: context.text.titleSmall),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    budget > 0 ? '${money.compact(amount)} / ${money.compact(budget)}' : money.compact(amount),
                    style: context.text.bodyMedium,
                  ),
                ),
                if (budget > 0)
                  StatusPill(
                    label: over ? '${((pace - 1) * 100).round()}% ahead' : 'on pace',
                    color: color,
                    icon: over ? Icons.north_east : Icons.check,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            PaceBar(fraction: budget > 0 ? amount / budget : 0, marker: budget > 0 ? marker : null, color: color),
            if (extra != null) ...[const SizedBox(height: 4), Text(extra, style: muted)],
          ],
        ),
      );
    }

    final projection = [
      // A month from payday to payday says when it began.
      if (s.customMonth) 'Since ${DateFormat('EEE d MMM').format(s.monthStart)}',
      f.collecting
          ? 'A month estimate after a week of data'
          : 'Heading for ${money.compact(f.projectedMonth ?? 0)} this month',
    ].join(' · ');
    return SectionCard(
      title: 'Food',
      trailing: SegmentedButton<FoodBasis>(
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: context.text.labelMedium,
        ),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: FoodBasis.eaten, label: Text('Eaten')),
          ButtonSegment(value: FoodBasis.spent, label: Text('Spent')),
        ],
        selected: {s.basis},
        onSelectionChanged: (v) => ref.read(profileServiceProvider).update((p) => p.foodBasis = v.first),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              eaten ? 'Groceries count when you eat them.' : 'Groceries count on the day you pay.',
              style: muted,
            ),
          ),
          row('Week', f.week, s.weeklyBudget, f.weekPace, s.weekElapsedFraction),
          row('Month', f.month, s.monthlyBudget, f.monthPace, s.monthElapsedFraction, extra: projection),
          Row(
            children: [
              // The other way of counting, so both stay one glance away.
              Expanded(
                child: eaten
                    ? Metric(value: money.compact(s.spent.week), label: 'spent this week')
                    : Metric(value: money.compact(s.eaten.week), label: 'eaten this week'),
              ),
              Expanded(
                child: Metric(
                  value: s.costPerMeal == null ? '–' : money.compact(s.costPerMeal!),
                  label: 'per home meal',
                ),
              ),
              // Only once it is worked out from the user's own meals out (3 or more).
              if ((s.savedVsOut ?? 0) > 0)
                Expanded(
                  child: Metric(value: money.compact(s.savedVsOut!), label: 'saved vs eating out'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => context.push('/food-history'),
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: const Text('Past months: eaten and spent'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
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
    final rows = state.nonFood.where((c) => c.limitMinor > 0 || c.spentMinor > 0).toList();
    return SectionCard(
      title: state.customMonth
          ? 'Other spend · since ${DateFormat('d MMM').format(state.monthStart)}'
          : 'Other spend · month',
      child: rows.isEmpty
          ? Text('No other spending this month.', style: context.text.bodyMedium)
          : Column(
              children: [
                for (final c in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(categoryIcon(c.category), size: 18, color: context.scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 116,
                          child: Text(
                            c.category.label,
                            style: context.text.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: c.limitMinor > 0
                              ? PaceBar(
                                  fraction: c.spentMinor / c.limitMinor,
                                  marker: state.monthElapsedFraction,
                                  color: context.colors.forPace(c.pace),
                                  height: 6,
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 78,
                          child: Text(
                            c.limitMinor > 0
                                ? '${money.format(c.spentMinor, whole: true)} / ${money.format(c.limitMinor, whole: true)}'
                                : money.format(c.spentMinor, whole: true),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: context.text.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          child: c.pace != null && c.pace! > 1.15
                              ? Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: context.colors.serious,
                                  semanticLabel: 'Over pace',
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.state, required this.kcalTarget});
  final DashboardState state;
  final double kcalTarget;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final bars = s.weekBars;
    final todayIndex = bars.indexWhere((b) => b.isToday);
    final avgLabel = s.avgKcal == null
        ? 'No completed days logged yet'
        : '${s.avgIsLastWeek ? 'Last week' : 'Avg'} ${NumberFormat.decimalPattern().format(s.avgKcal!.round())} kcal · '
              '${s.avgProtein!.round()} g protein';
    return SectionCard(
      title: 'Calories this week',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(avgLabel, style: context.text.titleSmall),
          if (s.coverage != null)
            Text(
              '${s.completedDays} of ${s.elapsedDays} days logged',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          const SizedBox(height: 8),
          WeekBars(
            values: [for (final b in bars) b.kcal],
            labels: [for (final b in bars) DateFormat.E().format(DayClock.dateOfKey(b.dateKey)).substring(0, 2)],
            target: kcalTarget,
            color: context.colors.kcal,
            highlight: todayIndex < 0 ? null : todayIndex,
            muted: {
              for (var i = 0; i < bars.length; i++)
                if (bars[i].isToday) i,
            },
            format: (v) => '${NumberFormat.decimalPattern().format(v.round())} kcal',
          ),
          const SizedBox(height: 4),
          Text(
            'Dashed line: your daily target.',
            style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
