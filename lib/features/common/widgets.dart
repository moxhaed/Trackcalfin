import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Page header of a tab root (Dashboard, Buy, Cook, Settings): a 30/36 large title at
/// x = 16 on the canvas, 60 tall, actions on the right with the last one 8 from the edge
/// (DESIGN_SYSTEM §7.5). It stays put while the content scrolls beneath it, and shows a
/// hairline at its bottom edge only while content is scrolled under it.
class TabHeader extends StatefulWidget implements PreferredSizeWidget {
  const TabHeader({super.key, required this.title, this.actions = const []});
  final String title;
  final List<Widget> actions;

  static const height = 60.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  State<TabHeader> createState() => _TabHeaderState();
}

class _TabHeaderState extends State<TabHeader> with _ScrolledUnder {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: TabHeader.height,
      titleSpacing: AppSpace.screen,
      titleTextStyle: context.text.headlineLarge,
      shape: edge,
      title: Semantics(header: true, child: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      actions: widget.actions,
    );
  }
}

/// Compact bar of a pushed screen (inbox, review, recipe, editor, stats, quick check): 52
/// tall, the platform back button (tooltip "Back") and a 17/22 w600 title right beside it
/// (DESIGN_SYSTEM §7.5). Opened without a page below (a cold deep link) there's no back
/// button, and the title keeps the 16 page margin instead. Same scrolled-under hairline.
class PageBar extends StatefulWidget implements PreferredSizeWidget {
  const PageBar({super.key, this.title, this.actions = const []});
  final String? title;
  final List<Widget> actions;

  static const height = 52.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  State<PageBar> createState() => _PageBarState();
}

class _PageBarState extends State<PageBar> with _ScrolledUnder {
  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final back = (route?.canPop ?? false) || (route?.impliesAppBarDismissal ?? false);
    final title = widget.title;
    return AppBar(
      toolbarHeight: PageBar.height,
      titleSpacing: back ? 0 : AppSpace.screen,
      shape: edge,
      title: title == null ? null : Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: widget.actions,
    );
  }
}

/// Follows the page's main vertical scroller the way [AppBar] does internally, so a header
/// can draw a 0.5 separator at its bottom edge once content scrolls beneath it (§7.5, §6).
mixin _ScrolledUnder<T extends StatefulWidget> on State<T> {
  ScrollNotificationObserverState? _observer;
  bool _under = false;

  /// The header's shape: a bottom hairline while scrolled under, nothing at rest.
  ShapeBorder? get edge => _under ? Border(bottom: BorderSide(color: context.colors.separator, width: 0.5)) : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_onScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    _observer = null;
    super.dispose();
  }

  void _onScroll(ScrollNotification n) {
    if (n is! ScrollUpdateNotification || n.depth != 0) return;
    final m = n.metrics;
    final under = switch (m.axisDirection) {
      AxisDirection.down => m.extentBefore > 0,
      AxisDirection.up => m.extentAfter > 0,
      AxisDirection.left || AxisDirection.right => _under,
    };
    if (under != _under && mounted) setState(() => _under = under);
  }
}

/// The one compact capsule a page header may carry: 36 tall on the neutral fill, an 18
/// accent icon and a 14/18 w600 label in ink (DESIGN_SYSTEM §7.5), e.g. "Quick check · 2".
/// It ends flush with the cards (x = screen − 16): 8 of its own on top of the bar's 8.
class HeaderButton extends StatelessWidget {
  const HeaderButton({super.key, required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final button = FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.fill,
        foregroundColor: scheme.onSurface,
        iconColor: scheme.primary,
        iconSize: 18,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.fromLTRB(12, 0, 14, 0),
        textStyle: context.text.labelLarge?.copyWith(fontSize: 14, height: 18 / 14),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      icon: Icon(icon),
      label: Text(label),
    );
    return Padding(
      padding: const EdgeInsets.only(right: AppSpace.x2),
      child: button,
    );
  }
}

/// Rounded card with an optional title row.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, this.trailing, required this.child, this.padding, this.onTap});

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!.toUpperCase(),
                        style: context.text.labelMedium?.copyWith(
                          letterSpacing: 0.8,
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 10),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal progress bar with an optional "expected by now" tick.
class PaceBar extends StatelessWidget {
  const PaceBar({super.key, required this.fraction, this.marker, required this.color, this.height = 8});

  /// value / limit (may exceed 1).
  final double fraction;

  /// Where the budget-so-far tick sits (0..1).
  final double? marker;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final track = context.colors.track;
    final ink = context.scheme.onSurface;
    return SizedBox(
      height: height + 6,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final f = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(height)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                height: height,
                width: f == 0 ? 0 : math.max(height, w * f),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
              ),
              if (marker != null)
                Positioned(
                  left: (w * marker!.clamp(0.0, 1.0) - 1).clamp(0, w - 2),
                  child: Container(width: 2, height: height + 6, color: ink.withValues(alpha: 0.7)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Ring gauge: value / max with a label in the middle.
class RingGauge extends StatelessWidget {
  const RingGauge({
    super.key,
    required this.fraction,
    required this.color,
    this.size = 64,
    this.stroke = 7,
    this.center,
  });

  final double fraction;
  final Color color;
  final double size;
  final double stroke;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction.isNaN ? 0 : fraction.clamp(0, 1)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(v, color, context.colors.track, stroke),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.f, this.color, this.track, this.stroke);
  final double f;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(r, 0, math.pi * 2, false, bg);
    if (f <= 0) return;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * f, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.f != f || old.color != color || old.track != track;
}

/// Seven vertical bars with a dashed target line. Tap a bar to read its value.
class WeekBars extends StatefulWidget {
  const WeekBars({
    super.key,
    required this.values,
    required this.labels,
    required this.target,
    required this.color,
    this.highlight,
    this.muted = const {},
    this.format,
    this.height = 96,
  });

  final List<double> values;
  final List<String> labels;
  final double target;
  final Color color;
  final int? highlight;
  final Set<int> muted;
  final String Function(double v)? format;
  final double height;

  @override
  State<WeekBars> createState() => _WeekBarsState();
}

class _WeekBarsState extends State<WeekBars> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final maxV = [widget.target * 1.15, ...widget.values].reduce(math.max);
    final sel = _selected ?? widget.highlight;
    final fmt = widget.format ?? (v) => v.round().toString();
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: sel == null || widget.values[sel] <= 0
              ? null
              : Text(
                  '${widget.labels[sel]} · ${fmt(widget.values[sel])}',
                  style: context.text.labelMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, c) {
              final targetY = maxV <= 0 ? 0.0 : widget.height * (1 - widget.target / maxV);
              return Stack(
                children: [
                  if (widget.target > 0)
                    Positioned(
                      top: targetY,
                      left: 0,
                      right: 0,
                      child: CustomPaint(size: Size(c.maxWidth, 1), painter: _DashPainter(context.colors.gridLine)),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < widget.values.length; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _selected = _selected == i ? null : i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 450),
                                  curve: Curves.easeOutCubic,
                                  height: maxV <= 0
                                      ? 0
                                      : math.max(widget.values[i] > 0 ? 4 : 0, widget.height * widget.values[i] / maxV),
                                  decoration: BoxDecoration(
                                    color: widget.muted.contains(i)
                                        ? widget.color.withValues(alpha: 0.35)
                                        : (sel == i ? widget.color : widget.color.withValues(alpha: 0.8)),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < widget.labels.length; i++)
              Expanded(
                child: Text(
                  widget.labels[i],
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: i == widget.highlight ? context.scheme.onSurface : context.scheme.onSurfaceVariant,
                    fontWeight: i == widget.highlight ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + 4, size.width), 0), p);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// Status pill: icon + label + color (never color alone).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, required this.icon});
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: context.text.labelSmall?.copyWith(color: context.scheme.onSurface)),
        ],
      ),
    );
  }
}

/// − n + stepper.
class PortionStepper extends StatelessWidget {
  const PortionStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 12,
    this.hint,
  });
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(28)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Fewer portions',
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value', style: context.text.titleMedium),
              if (hint != null) Text(hint!, style: context.text.labelSmall),
            ],
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'More portions',
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: context.scheme.onSurfaceVariant.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

/// Small label/value pair used in stat rows. The label wraps when space is tight;
/// keep a number and its unit together with a non-breaking space.
class Metric extends StatelessWidget {
  const Metric({super.key, required this.value, required this.label, this.dotColor});
  final String value;
  final String label;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: context.text.titleMedium),
        Text.rich(
          TextSpan(
            children: [
              if (dotColor != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                ),
              TextSpan(text: label),
            ],
          ),
          style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Instant commit + 5 s undo (rule R1: undo, never confirm).
void showUndo(BuildContext context, String message, {VoidCallback? onUndo, String? detail}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  showUndoOn(messenger, message, onUndo: onUndo, detail: detail);
}

void showUndoOn(ScaffoldMessengerState messenger, String message, {VoidCallback? onUndo, String? detail}) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (detail != null) Text(detail, style: const TextStyle(fontSize: 12)),
        ],
      ),
      action: onUndo == null ? null : SnackBarAction(label: 'Undo', onPressed: onUndo),
    ),
  );
}

void showInfo(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3)));
}

/// The "celebration" moment after a log (Fogg's Shine).
void celebrate() => HapticFeedback.mediumImpact();
void tick() => HapticFeedback.selectionClick();

/// Measures time-to-log from the moment a flow opens.
class LogTimer {
  LogTimer() : _start = DateTime.now();
  final DateTime _start;
  Duration get elapsed => DateTime.now().difference(_start);
}
