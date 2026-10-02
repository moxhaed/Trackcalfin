import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../core/money.dart';
import '../../domain/food_history.dart';
import '../common/widgets.dart';

/// Dashboard → Food → Past months: what was paid for groceries next to what the food eaten
/// was worth, month by month (budget months: they start on the user's month start day).
class FoodHistoryScreen extends ConsumerWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(foodHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Food by month')),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (v) => _HistoryBody(view: v),
      ),
    );
  }
}

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody({required this.view});
  final FoodHistoryView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final months = view.months;
    final calendar = view.profile.monthStartDay == 1;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        if (months.length >= 2)
          _ChartCard(
            months: months.sublist(math.max(0, months.length - 6)),
            budget: view.profile.monthlyFoodBudgetMinor,
            calendar: calendar,
            money: money,
          )
        else
          SectionCard(
            child: Text(
              'Each month gets a bar here, eaten next to spent. The first one is still going: '
              'it ends on ${DateFormat('d MMM').format(months.last.lastDay)}.',
              style: context.text.bodyMedium,
            ),
          ),
        const SizedBox(height: 12),
        if (view.profile.monthlyFoodBudgetMinor > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              view.profile.foodBasis == FoodBasis.eaten
                  ? 'Over or under budget by what you ate, as on the Food card.'
                  : 'Over or under budget by what you spent, as on the Food card.',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          ),
        for (final m in months.reversed) ...[
          _MonthCard(month: m, view: view, calendar: calendar, money: money),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

String _monthTitle(FoodPeriod m, {required bool calendar}) {
  if (!calendar) return '${DateFormat('d MMM').format(m.start)} – ${DateFormat('d MMM').format(m.lastDay)}';
  return m.start.year == DateTime.now().year
      ? DateFormat('MMMM').format(m.start)
      : DateFormat('MMMM y').format(m.start);
}

String _monthShort(FoodPeriod m, {required bool calendar}) =>
    calendar ? DateFormat('MMM').format(m.start) : DateFormat('d MMM').format(m.start);

String _weekTitle(FoodPeriod w) {
  final a = w.start;
  final b = w.lastDay;
  if (a.year == b.year && a.month == b.month) {
    return a.day == b.day ? DateFormat('d MMM').format(a) : '${a.day}–${DateFormat('d MMM').format(b)}';
  }
  return '${DateFormat('d MMM').format(a)} – ${DateFormat('d MMM').format(b)}';
}

class _ChartCard extends StatefulWidget {
  const _ChartCard({required this.months, required this.budget, required this.calendar, required this.money});
  final List<FoodPeriod> months;
  final int budget;
  final bool calendar;
  final MoneyFormat money;

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final months = widget.months;
    // The last month that has ended, when there is one: the one worth a look.
    final selected = (_selected ?? (months.last.current ? months.length - 2 : months.length - 1)).clamp(
      0,
      months.length - 1,
    );
    final m = months[selected];
    final money = widget.money;
    final c = context.colors;
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return SectionCard(
      title: 'Eaten and spent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Key(color: c.eaten, label: 'Eaten'),
              _Key(color: c.spent, label: 'Spent'),
              if (widget.budget > 0)
                _Key(
                  color: context.scheme.onSurfaceVariant,
                  label: 'Budget ${money.compact(widget.budget)}',
                  line: true,
                ),
            ],
          ),
          const SizedBox(height: 10),
          // The selected month's numbers: values first, the month after.
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: money.compact(m.eatenMinor), style: context.text.titleSmall),
                const TextSpan(text: ' eaten · '),
                TextSpan(text: money.compact(m.spentMinor), style: context.text.titleSmall),
                const TextSpan(text: ' spent · '),
                TextSpan(
                  text: m.current
                      ? '${_monthTitle(m, calendar: widget.calendar)} so far'
                      : _monthTitle(m, calendar: widget.calendar),
                ),
              ],
            ),
            style: muted,
          ),
          const SizedBox(height: 8),
          FoodHistoryChart(
            labels: [for (final m in months) _monthShort(m, calendar: widget.calendar)],
            eaten: [for (final m in months) m.eatenMinor],
            spent: [for (final m in months) m.spentMinor],
            budget: widget.budget,
            inProgress: months.last.current ? months.length - 1 : null,
            selected: selected,
            onSelect: (i) => setState(() => _selected = i),
            format: money.compact,
          ),
          if (months.last.current) ...[
            const SizedBox(height: 4),
            Text(
              'The faded pair is this month so far.',
              style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// A legend key: a swatch shaped like the mark (a bar, or a line for the budget).
class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label, this.line = false});
  final Color color;
  final String label;
  final bool line;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line
            ? CustomPaint(size: const Size(14, 10), painter: _DashKeyPainter(color))
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
        const SizedBox(width: 6),
        Text(label, style: context.text.labelMedium?.copyWith(color: context.scheme.onSurfaceVariant)),
      ],
    );
  }
}

class _DashKeyPainter extends CustomPainter {
  _DashKeyPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(5, y), p);
    canvas.drawLine(Offset(9, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_DashKeyPainter old) => old.color != color;
}

/// Grouped columns: eaten next to spent for each month, on one money axis, with the
/// monthly budget as a dashed line. Tap a month to read its numbers.
class FoodHistoryChart extends StatelessWidget {
  const FoodHistoryChart({
    super.key,
    required this.labels,
    required this.eaten,
    required this.spent,
    required this.budget,
    required this.selected,
    required this.onSelect,
    required this.format,
    this.inProgress,
    this.height = 184,
  });

  final List<String> labels;
  final List<int> eaten;
  final List<int> spent;
  final int budget;
  final int selected;
  final ValueChanged<int> onSelect;
  final String Function(int minor) format;

  /// The month still going, drawn faded.
  final int? inProgress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tickStyle = context.text.labelSmall!.copyWith(
      color: context.scheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final ticks = _ticks([...eaten, ...spent, budget].reduce(math.max));
    final gutter = ticks.map((t) => _width(format(t), tickStyle)).reduce(math.max) + 8;
    return Semantics(
      label: 'Chart: food eaten and spent by month. The months are listed below.',
      child: LayoutBuilder(
        builder: (context, box) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            final w = (box.maxWidth - gutter) / labels.length;
            final i = ((d.localPosition.dx - gutter) / w).floor();
            if (i >= 0 && i < labels.length) onSelect(i);
          },
          child: CustomPaint(
            size: Size(box.maxWidth, height),
            painter: _ChartPainter(
              labels: labels,
              eaten: eaten,
              spent: spent,
              budget: budget,
              ticks: ticks,
              gutter: gutter,
              selected: selected,
              inProgress: inProgress,
              format: format,
              eatenColor: c.eaten,
              spentColor: c.spent,
              gridColor: c.gridLine,
              budgetColor: context.scheme.onSurfaceVariant,
              selectedColor: context.scheme.onSurface.withValues(alpha: 0.06),
              tickStyle: tickStyle,
              labelStyle: context.text.labelSmall!.copyWith(color: context.scheme.onSurfaceVariant),
              selectedLabelStyle: context.text.labelSmall!.copyWith(
                color: context.scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Round steps from 0 to at least [max]: 0, 100, 200, 300 (in minor units).
  static List<int> _ticks(int max) {
    if (max <= 0) return const [0];
    final raw = max / 3;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final step = [1, 2, 2.5, 5, 10].map((f) => f * mag).firstWhere((s) => s >= raw);
    final top = (max / step).ceil();
    return [for (var i = 0; i <= top; i++) (i * step).round()];
  }

  static double _width(String text, TextStyle style) => (TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout()).width;
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.labels,
    required this.eaten,
    required this.spent,
    required this.budget,
    required this.ticks,
    required this.gutter,
    required this.selected,
    required this.inProgress,
    required this.format,
    required this.eatenColor,
    required this.spentColor,
    required this.gridColor,
    required this.budgetColor,
    required this.selectedColor,
    required this.tickStyle,
    required this.labelStyle,
    required this.selectedLabelStyle,
  });

  final List<String> labels;
  final List<int> eaten;
  final List<int> spent;
  final int budget;
  final List<int> ticks;
  final double gutter;
  final int selected;
  final int? inProgress;
  final String Function(int minor) format;
  final Color eatenColor;
  final Color spentColor;
  final Color gridColor;
  final Color budgetColor;
  final Color selectedColor;
  final TextStyle tickStyle;
  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;

  static const _top = 8.0;
  static const _labelBand = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bottom = size.height - _labelBand;
    final plotH = bottom - _top;
    final maxV = ticks.last <= 0 ? 1 : ticks.last;
    double y(int v) => bottom - plotH * v / maxV;
    final n = labels.length;
    final w = (size.width - gutter) / n;

    // Selected month: a faint band behind its pair.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(gutter + w * selected + 2, _top - 4, w - 4, plotH + 4),
        const Radius.circular(8),
      ),
      Paint()..color = selectedColor,
    );

    // Hairline grid, solid, with round money ticks.
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final t in ticks) {
      final ty = y(t).roundToDouble() + 0.5;
      canvas.drawLine(Offset(gutter, ty), Offset(size.width, ty), grid);
      _text(canvas, format(t), tickStyle, Offset(gutter - 8, ty), align: _Align.rightMiddle);
    }

    // Bars: eaten then spent, ≤ 20 px, a 2 px gap between, rounded at the data end only.
    final bw = math.min(20.0, math.max(4.0, (w - 18) / 2));
    for (var i = 0; i < n; i++) {
      final cx = gutter + w * (i + 0.5);
      final faded = i == inProgress;
      _bar(canvas, cx - 1 - bw, bw, eaten[i], y, bottom, faded ? eatenColor.withValues(alpha: 0.45) : eatenColor);
      _bar(canvas, cx + 1, bw, spent[i], y, bottom, faded ? spentColor.withValues(alpha: 0.45) : spentColor);
      _text(
        canvas,
        labels[i],
        i == selected ? selectedLabelStyle : labelStyle,
        Offset(cx, bottom + 6),
        align: _Align.topCenter,
      );
    }

    // The monthly budget: a threshold, so dashed.
    if (budget > 0) {
      final by = y(budget).roundToDouble() + 0.5;
      final p = Paint()
        ..color = budgetColor
        ..strokeWidth = 1.5;
      for (var x = gutter; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, by), Offset(math.min(x + 4, size.width), by), p);
      }
    }
  }

  void _bar(Canvas canvas, double left, double width, int value, double Function(int) y, double bottom, Color color) {
    if (value <= 0) return;
    final top = math.min(y(value), bottom - 2);
    final r = Radius.circular(math.min(4, width / 2));
    canvas.drawRRect(
      RRect.fromRectAndCorners(Rect.fromLTRB(left, top, left + width, bottom), topLeft: r, topRight: r),
      Paint()..color = color,
    );
  }

  void _text(Canvas canvas, String text, TextStyle style, Offset at, {required _Align align}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final o = switch (align) {
      _Align.rightMiddle => Offset(at.dx - tp.width, at.dy - tp.height / 2),
      _Align.topCenter => Offset(at.dx - tp.width / 2, at.dy),
    };
    tp.paint(canvas, o);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.selected != selected ||
      old.eaten != eaten ||
      old.spent != spent ||
      old.budget != budget ||
      old.eatenColor != eatenColor ||
      old.gutter != gutter;
}

enum _Align { rightMiddle, topCenter }

/// One month: its numbers, how it went against the budget, and its weeks.
class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month, required this.view, required this.calendar, required this.money});
  final FoodPeriod month;
  final FoodHistoryView view;
  final bool calendar;
  final MoneyFormat money;

  @override
  Widget build(BuildContext context) {
    final m = month;
    final p = view.profile;
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    final numbers = context.text.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final title = _monthTitle(m, calendar: calendar);

    // Against the budget, by the way the Food card counts (eaten or spent). Only for a
    // whole month: a month still going or a first half month says nothing yet.
    Widget? pill;
    final budget = p.monthlyFoodBudgetMinor;
    if (budget > 0 && !m.current && m.dataFrom == null) {
      final used = p.foodBasis == FoodBasis.eaten ? m.eatenMinor : m.spentMinor;
      final over = used - budget;
      pill = over > 0
          ? StatusPill(label: '${money.compact(over)} over', color: context.colors.critical, icon: Icons.north_east)
          : StatusPill(label: '${money.compact(-over)} under', color: context.colors.good, icon: Icons.check);
    }

    final notes = <String>[
      if (m.dataFrom != null) 'Your data starts on ${DateFormat('d MMM').format(m.dataFrom!)}.',
      ?_stockNote(m),
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(m.current ? '$title · so far' : title, style: context.text.titleSmall),
        subtitle: Text('${money.compact(m.eatenMinor)} eaten · ${money.compact(m.spentMinor)} spent', style: muted),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [?pill, const SizedBox(width: 4), const Icon(Icons.expand_more)],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(), 2: FlexColumnWidth()},
            children: [
              TableRow(
                children: [
                  Text('Week', style: muted),
                  Text('Eaten', style: muted, textAlign: TextAlign.right),
                  Text('Spent', style: muted, textAlign: TextAlign.right),
                ],
              ),
              for (final w in m.weeks)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        w.current ? '${_weekTitle(w)} · so far' : _weekTitle(w),
                        style: context.text.bodyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(money.format(w.eatenMinor), style: numbers, textAlign: TextAlign.right),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(money.format(w.spentMinor), style: numbers, textAlign: TextAlign.right),
                    ),
                  ],
                ),
            ],
          ),
          if (m.thrownMinor > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.delete_outline, size: 16, color: context.scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('${money.compact(m.thrownMinor)} thrown away', style: context.text.bodyMedium),
              ],
            ),
          ],
          for (final n in notes) ...[const SizedBox(height: 8), Text(n, style: muted)],
        ],
      ),
    );
  }

  /// What the gap between spent and eaten means, when it is big enough to matter.
  String? _stockNote(FoodPeriod m) {
    final gap = m.stockedMinor;
    final big = math.max(500, (math.max(m.spentMinor, m.eatenMinor) * 0.1).round());
    if (gap.abs() < big) return null;
    return gap > 0
        ? '${money.compact(gap)} more bought than eaten: it went into the pantry, or wasn\'t logged as eaten.'
        : '${money.compact(-gap)} more eaten than bought: meals came from food bought before.';
  }
}
