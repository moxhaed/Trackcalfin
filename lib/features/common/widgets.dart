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

// ---------------------------------------------------------------------------
// Containers (DESIGN_SYSTEM §5, §7.2, §7.3)
// ---------------------------------------------------------------------------

/// The white rounded card: a self-contained module with an optional sentence-case title
/// (17/22 w600) and a trailing slot centered on the title line (§7.2).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding,
    this.onTap,
    this.hero = false,
  });

  final String? title;

  /// A text button, a status label or a meta text. Text buttons are pulled 12 to the right
  /// so their label (not their padding) aligns with the card's right padding.
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Hero cards (Today's pick) use 20 inner padding instead of 16.
  final bool hero;

  /// A trailing control keeps its 48 tap target, centered on the 22 title line.
  static const _row = 48.0, _line = 22.0;

  @override
  Widget build(BuildContext context) {
    final pad = (padding ?? EdgeInsets.all(hero ? AppSpace.hero : AppSpace.card)).resolve(Directionality.of(context));
    final lift = trailing == null ? 0.0 : (_row - _line) / 2;
    final textButton = trailing is TextButton;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  pad.left,
                  math.max(0, pad.top - lift),
                  textButton ? math.max(0, pad.right - 12) : pad.right,
                  0,
                ),
                child: SizedBox(
                  height: trailing == null ? null : _row,
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(header: true, child: Text(title!, style: context.text.titleMedium)),
                      ),
                      if (trailing != null) ...[const SizedBox(width: AppSpace.x3), trailing!],
                    ],
                  ),
                ),
              ),
            Padding(
              padding: title == null
                  ? pad
                  : EdgeInsets.fromLTRB(pad.left, math.max(0, AppSpace.x3 - lift), pad.right, pad.bottom),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// A grouped list section: one white rounded surface whose rows are split by 0.5 hairlines
/// that start at the rows' text (§7.3). It clips its rows, so pressed overlays and swipe
/// backgrounds follow the corners.
class AppGroup extends StatelessWidget {
  const AppGroup({super.key, required this.children, this.separatorIndent = indentPlain});
  final List<Widget> children;

  /// Where each hairline starts inside the group: on the rows' text.
  final double separatorIndent;

  /// Hairline indents (§7.3): plain rows (16), rows with a 24 leading icon (16 + 24 + 12),
  /// rows with a 36 glyph circle (16 + 36 + 12).
  static const indentPlain = 16.0, indentIcon = 52.0, indentGlyph = 64.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 0.5, thickness: 0.5, indent: separatorIndent),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A row inside an [AppGroup] or a sheet (§7.3): leading 24 icon or glyph circle, a 16 w500
/// title (2 lines), a 13 secondary subtitle (2 lines), and a trailing value, chevron or
/// control. Min height 52, or 64 with a subtitle.
class AppRow extends StatelessWidget {
  const AppRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.value,
    this.valueMuted = false,
    this.chevron = false,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// A switch, a small tonal button or an icon button. Wins over [value] and [chevron].
  final Widget? trailing;

  /// A trailing number in `nums.body`; settings values pass [valueMuted] (secondary, w400).
  final String? value;
  final bool valueMuted;

  /// A trailing `chevron_right_rounded` for rows that navigate.
  final bool chevron;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final secondary = context.scheme.onSurfaceVariant;
    final nums = context.nums;
    final control = trailing != null;
    final end =
        trailing ??
        (value == null && !chevron
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null)
                    Text(
                      value!,
                      style: valueMuted ? nums.body.copyWith(color: secondary, fontWeight: FontWeight.w400) : nums.body,
                    ),
                  if (value != null && chevron) const SizedBox(width: AppSpace.x2),
                  if (chevron) Icon(Icons.chevron_right_rounded, size: 20, color: context.colors.textTertiary),
                ],
              ));
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ConstrainedBox(
        // A trailing control lays out at its 48 tap target, so the row pads it by 4 only: one
        // line is 56 and two lines are 64 (review 02), and the text column stays centered.
        constraints: BoxConstraints(minHeight: subtitle == null ? (control ? 56 : 52) : 64),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: control ? AppSpace.x1 : AppSpace.x3),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: secondary, size: 24),
                  child: leading!,
                ),
                const SizedBox(width: AppSpace.x3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                    ],
                  ],
                ),
              ),
              if (end != null) ...[const SizedBox(width: AppSpace.x3), end],
            ],
          ),
        ),
      ),
    );
  }
}

/// A neutral circle behind an icon: 36 with a 20 icon in mixed-category rows, 56 with a 28
/// icon in empty states (§7.3, §7.18).
class GlyphCircle extends StatelessWidget {
  const GlyphCircle(this.icon, {super.key, this.size = 36, this.color});
  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: context.colors.fill, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: size >= 56 ? 28 : 20, color: color ?? context.scheme.onSurfaceVariant),
    );
  }
}

// ---------------------------------------------------------------------------
// Titles (§7.4)
// ---------------------------------------------------------------------------

/// A section title on the canvas: 20/26 w600, 28 above and 8 below (8 above when it comes
/// first), with an optional trailing text button or meta on the right.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.first = false});
  final String title;
  final Widget? trailing;
  final bool first;

  @override
  Widget build(BuildContext context) {
    // A trailing control keeps its 48 tap target, centered on the 26 title line.
    final lift = trailing == null ? 0.0 : (48 - 26) / 2;
    final top = first ? AppSpace.headerGap : AppSpace.section;
    final end = trailing is TextButton ? Transform.translate(offset: const Offset(12, 0), child: trailing) : trailing;
    return Padding(
      padding: EdgeInsets.only(top: math.max(0, top - lift), bottom: math.max(0, AppSpace.headerGap - lift)),
      child: SizedBox(
        height: trailing == null ? null : 48,
        child: Row(
          children: [
            Expanded(
              child: Semantics(header: true, child: Text(title, style: context.text.titleLarge)),
            ),
            if (end != null) ...[const SizedBox(width: AppSpace.x3), end],
          ],
        ),
      ),
    );
  }
}

/// A group header above an [AppGroup] (or a block of rows): 15/20 w600 in the secondary
/// color, 24 above (8 when first) and 8 below, with an optional 16 leading icon and a
/// trailing value (§7.4). [inset] puts the text on the rows' text line: placed in a list
/// with 16 page margins, the default 16 lands it at x = 32.
class GroupHeader extends StatelessWidget {
  const GroupHeader(this.title, {super.key, this.icon, this.value, this.first = false, this.inset = AppSpace.x4});
  final String title;
  final IconData? icon;
  final String? value;
  final bool first;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final secondary = context.scheme.onSurfaceVariant;
    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(inset, first ? AppSpace.headerGap : AppSpace.x6, inset, AppSpace.headerGap),
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: secondary), const SizedBox(width: 6)],
            Expanded(
              child: Text(title, style: context.text.titleSmall?.copyWith(color: secondary)),
            ),
            if (value != null) ...[
              const SizedBox(width: AppSpace.x3),
              Text(
                value!,
                style: context.nums.body.copyWith(fontWeight: FontWeight.w600, color: secondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notices (§7.13)
// ---------------------------------------------------------------------------

enum NoticeKind { info, warning, critical, success }

/// A banner for exceptional, actionable information: a tinted rounded block (no border)
/// with a 20 leading icon, an optional title, the message, an optional meta line, and text
/// actions underneath (or the whole notice tappable with a chevron).
class AppNotice extends StatelessWidget {
  const AppNotice({
    super.key,
    this.kind = NoticeKind.info,
    required this.message,
    this.title,
    this.meta,
    this.icon,
    this.actions = const [],
    this.onTap,
    this.trailing,
  });

  final NoticeKind kind;
  final String message;
  final String? title;
  final String? meta;

  /// Defaults per kind: info, warning, error, check.
  final IconData? icon;

  /// Text buttons; the first one's label lines up with the text.
  final List<Widget> actions;

  /// Makes the whole notice tappable and adds a chevron.
  final VoidCallback? onTap;

  /// A small control at the end of the first line (e.g. a spinner while busy).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = context.scheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (Color tint, Color bg, IconData glyph) = switch (kind) {
      NoticeKind.info => (s.primary, c.fill, Icons.info_outline_rounded),
      NoticeKind.warning => (c.warning, c.warning.withValues(alpha: dark ? 0.16 : 0.12), Icons.warning_amber_rounded),
      NoticeKind.critical => (
        c.critical,
        c.critical.withValues(alpha: dark ? 0.16 : 0.10),
        Icons.error_outline_rounded,
      ),
      NoticeKind.success => (c.good, c.good.withValues(alpha: dark ? 0.14 : 0.10), Icons.check_circle_outline_rounded),
    };
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[Text(title!, style: context.text.titleSmall), const SizedBox(height: 2)],
        Text(message, style: context.text.bodyMedium),
        if (meta != null) ...[const SizedBox(height: 2), Text(meta!, style: context.text.bodySmall)],
        if (actions.isNotEmpty)
          Transform.translate(
            offset: const Offset(-12, 0),
            child: Wrap(spacing: AppSpace.x1, children: actions),
          ),
      ],
    );
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, actions.isEmpty ? 14 : 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 20 icon centered on the first 20/21 text line.
              SizedBox(height: 20, child: Icon(icon ?? glyph, size: 20, color: tint)),
              const SizedBox(width: AppSpace.x3),
              Expanded(child: body),
              ?trailing,
              if (onTap != null) ...[
                const SizedBox(width: AppSpace.x2),
                Icon(Icons.chevron_right_rounded, size: 20, color: c.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented control (§7.6)
// ---------------------------------------------------------------------------

/// A neutral segmented switch: fill track, a sliding white (dark: raised) thumb, labels only.
/// Each label is a `Text`, and each segment is a selectable button for screen readers.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = true,
  });

  /// Values and their labels, in display order.
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Full width (a page's main switch) or hugging its labels (inside forms).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = context.scheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final values = segments.keys.toList();
    final n = values.length;
    final index = math.max(0, values.indexOf(selected));
    final reduce = MediaQuery.disableAnimationsOf(context);
    final track = Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(AppRadius.segmentTrack)),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(n > 1 ? -1 + 2 * index / (n - 1) : 0, 0),
            duration: reduce ? Duration.zero : const Duration(milliseconds: 220),
            curve: AppMotion.standard,
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF3A3C38) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(AppRadius.segmentThumb),
                  boxShadow: dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), spreadRadius: 0.5),
                        ],
                ),
              ),
            ),
          ),
          // Transparent Material so the pressed overlay paints above the thumb.
          Material(
            type: MaterialType.transparency,
            child: Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == index,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.segmentThumb),
                        // Like SegmentedButton, the selected segment stays tappable and does nothing.
                        onTap: () {
                          if (i == index) return;
                          tick();
                          onChanged(values[i]);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
                            child: Text(
                              segments[values[i]]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge?.copyWith(
                                color: i == index ? s.onSurface : s.onSurfaceVariant,
                                fontWeight: i == index ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (expand) return track;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 64.0 * n + 6),
      child: IntrinsicWidth(child: track),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeletons (§7.18)
// ---------------------------------------------------------------------------

/// Pulses its subtree's opacity 1 → 0.55 → 1 every 1200 ms while content loads (static
/// under reduced motion). Fill it with [SkeletonBlock]s and [SkeletonLine]s plus the real
/// labels that are already known.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, required this.child});
  final Widget child;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final Animation<double> _opacity = _pulse.drive(
    TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.55), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 1.0), weight: 1),
    ]).chain(CurveTween(curve: Curves.easeInOut)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ExcludeSemantics(
        child: FadeTransition(opacity: _opacity, child: widget.child),
      ),
    );
  }
}

/// A skeleton stand-in for a block of content (a value, a bar, a card body).
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.width, required this.height, this.radius = 12});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: context.colors.fillStrong, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// A skeleton stand-in for one line of text in [style]: a 0.7 × font-size bar, centered in
/// the line's real height so the layout doesn't jump when the text arrives.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.width, this.style});
  final double? width;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final st = style ?? context.text.bodyMedium!;
    final size = st.fontSize ?? 15;
    return SizedBox(
      height: size * (st.height ?? 1.4),
      width: width,
      child: Center(
        child: SkeletonBlock(width: width, height: size * 0.7, radius: 4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chips (§7.8). The theme's default chip is neutral with an accent selected state; these
// are the four variants screens should use.
// ---------------------------------------------------------------------------

/// Single-select chip: accent fill and a w600 label when selected, no checkmark. An
/// optional category icon turns from secondary to on-accent with the selection.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({super.key, required this.label, required this.selected, this.onSelected, this.icon});
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final s = context.scheme;
    return ChoiceChip(
      showCheckmark: false,
      avatar: icon == null ? null : Icon(icon, size: 16, color: selected ? s.onPrimary : s.onSurfaceVariant),
      label: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

/// Multi-select chip: accent-container fill, a w600 label and a leading check when on.
class AppToggleChip extends StatelessWidget {
  const AppToggleChip({super.key, required this.label, required this.selected, this.onSelected});
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final s = context.scheme;
    final c = context.colors;
    return FilterChip(
      showCheckmark: true,
      checkmarkColor: s.onPrimaryContainer,
      color: WidgetStateProperty.resolveWith((st) {
        if (st.contains(WidgetState.selected)) return s.primaryContainer;
        if (st.contains(WidgetState.disabled)) return c.fill.withValues(alpha: c.fill.a * 0.5);
        return c.fill;
      }),
      labelStyle: TextStyle(color: selected ? s.onPrimaryContainer : s.onSurface),
      label: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

/// A one-shot action ("Add", "Scan label", "I'm out"): neutral fill, accent leading icon.
class AppActionChip extends StatelessWidget {
  const AppActionChip({super.key, required this.label, required this.onPressed, this.icon, this.iconColor});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Overrides the accent, e.g. the warning `help_outline_rounded` on a staple without macros.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon == null ? null : Icon(icon, size: 16, color: iconColor ?? context.scheme.primary),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

/// A removable value (an allergy, a reminder time): neutral fill, trailing 16 close icon.
class AppInputChip extends StatelessWidget {
  const AppInputChip({super.key, required this.label, required this.onDeleted, this.onPressed});
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onPressed: onPressed,
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
    );
  }
}

/// A non-interactive label such as a recipe tag ("high protein").
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: context.colors.fill, borderRadius: BorderRadius.circular(AppRadius.tag)),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: context.text.labelMedium?.copyWith(color: context.scheme.onSurfaceVariant)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tiles (§7.19)
// ---------------------------------------------------------------------------

/// A pantry item in the "Use soon" / "Running low" strip: white, radius 16, 72 tall, the
/// name over a meta line. The days note is amber, or red when [urgent].
class PantryTile extends StatelessWidget {
  const PantryTile({
    super.key,
    required this.name,
    required this.quantity,
    this.note,
    this.urgent = false,
    this.runningLow = false,
    this.onTap,
  });

  final String name;

  /// "210 g".
  final String quantity;

  /// "1 day", "use today".
  final String? note;
  final bool urgent;

  /// Running-low tiles lead the meta with a falling-trend icon instead of a days note.
  final bool runningLow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final meta = context.text.bodySmall!;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 180),
      child: SizedBox(
        height: 72,
        child: Material(
          color: context.scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.tile)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (runningLow) ...[
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.trending_down_rounded, size: 14, color: c.warning),
                          ),
                          const TextSpan(text: ' '),
                        ],
                        TextSpan(text: quantity),
                        if (note != null && !runningLow) ...[
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: note,
                            style: TextStyle(color: urgent ? c.criticalInk : c.warningInk),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: meta,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A capture option in the ⊕ sheet: fill, radius 16, 104 tall, accent icon over a title and
/// a one-line hint.
class CaptureTile extends StatelessWidget {
  const CaptureTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: Material(
        color: context.colors.fill,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // Three tiles share a phone's width (about 110 each): the text gets 8 side padding
          // and shrinks a little rather than truncating when a label is long.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: context.scheme.primary),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title, maxLines: 1, textAlign: TextAlign.center, style: context.text.titleSmall),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress (§7.10)
// ---------------------------------------------------------------------------

/// The app's one linear progress bar: a rounded track, a colored fill that tweens, and an
/// optional "expected by now" marker that stands 4 above and below the bar.
class PaceBar extends StatelessWidget {
  const PaceBar({
    super.key,
    required this.fraction,
    this.marker,
    required this.color,
    this.height = 6,
    this.semanticsLabel,
  });

  /// value / limit (may exceed 1).
  final double fraction;

  /// Where the budget-so-far marker sits (0..1).
  final double? marker;
  final Color color;

  /// 6 in cards, 4 in dense rows.
  final double height;

  /// "Week €54 of €69, on pace": the label, value and target, plus the status if any.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final track = context.colors.track;
    final ink = context.scheme.onSurface;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final h = height;
    final bar = SizedBox(
      height: marker == null ? h : h + 8,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final f = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0);
          final radius = BorderRadius.circular(h / 2);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: h,
                decoration: BoxDecoration(color: track, borderRadius: radius),
              ),
              AnimatedContainer(
                duration: reduce ? Duration.zero : AppMotion.long,
                curve: AppMotion.standard,
                height: h,
                width: f == 0 ? 0 : math.max(h, w * f),
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
              if (marker != null)
                Positioned(
                  left: (w * marker!.clamp(0.0, 1.0) - 1).clamp(0, math.max(0, w - 2)),
                  top: 0,
                  child: Container(
                    width: 2,
                    height: h + 8,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
    if (semanticsLabel == null) return bar;
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(child: bar),
    );
  }
}

/// The ring reserved for the Vibe score: 72, stroke 7, round cap from 12 o'clock on the
/// neutral track. It tweens from 0 when first shown.
class RingGauge extends StatelessWidget {
  const RingGauge({
    super.key,
    required this.fraction,
    required this.color,
    this.size = 72,
    this.stroke = 7,
    this.center,
    this.semanticsLabel,
  });

  final double fraction;
  final Color color;
  final double size;
  final double stroke;
  final Widget? center;

  /// e.g. "Vibe 97 of 100, Locked in".
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final ring = SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction.isNaN ? 0 : fraction.clamp(0, 1)),
        duration: reduce ? Duration.zero : AppMotion.ring,
        curve: AppMotion.standard,
        builder: (context, v, child) =>
            CustomPaint(painter: _RingPainter(v, color, context.colors.track, stroke), child: child),
        child: Center(child: center),
      ),
    );
    if (semanticsLabel == null) return ring;
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(child: ring),
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
    final r = (Offset.zero & size).deflate(stroke / 2);
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
  bool shouldRepaint(_RingPainter old) =>
      old.f != f || old.color != color || old.track != track || old.stroke != stroke;
}

/// Seven vertical bars over a dashed target line. Tap a column to read its value above
/// the chart; tap it again to clear.
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
    this.height = 112,
    this.dayNames,
  });

  final List<double> values;

  /// Short day labels under the bars ("Mo").
  final List<String> labels;
  final double target;
  final Color color;

  /// Today: its label is emphasized, and it's the default selection.
  final int? highlight;

  /// Days still in progress, drawn at 25 % unless selected.
  final Set<int> muted;
  final String Function(double v)? format;
  final double height;

  /// Full day names for screen readers ("Sunday"); defaults to [labels].
  final List<String>? dayNames;

  @override
  State<WeekBars> createState() => _WeekBarsState();
}

class _WeekBarsState extends State<WeekBars> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final n = w.values.length;
    final maxV = [w.target * 1.15, ...w.values].reduce(math.max);
    final sel = _selected ?? w.highlight;
    final fmt = w.format ?? (v) => v.round().toString();
    final reduce = MediaQuery.disableAnimationsOf(context);
    final secondary = context.scheme.onSurfaceVariant;
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: sel == null || w.values[sel] <= 0
              ? null
              : CustomSingleChildLayout(
                  delegate: _CenterAt((sel + 0.5) / n),
                  child: Text(
                    '${w.labels[sel]} · ${fmt(w.values[sel])}',
                    maxLines: 1,
                    style: context.nums.small.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
        ),
        const SizedBox(height: AppSpace.x1),
        SizedBox(
          height: w.height,
          child: LayoutBuilder(
            builder: (context, c) {
              final slot = c.maxWidth / n;
              final barWidth = (slot - 12).clamp(12.0, 28.0);
              final targetY = maxV <= 0 ? 0.0 : w.height * (1 - w.target / maxV);
              return Stack(
                children: [
                  if (w.target > 0)
                    Positioned(
                      top: targetY,
                      left: 0,
                      right: 0,
                      child: CustomPaint(size: Size(c.maxWidth, 1), painter: _DashPainter(context.colors.gridLine)),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < n; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: sel == i,
                            label:
                                '${(w.dayNames ?? w.labels)[i]}, ${fmt(w.values[i])}'
                                '${w.muted.contains(i) ? ', in progress' : ''}',
                            excludeSemantics: true,
                            onTap: () => setState(() => _selected = _selected == i ? null : i),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _selected = _selected == i ? null : i),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: reduce ? Duration.zero : AppMotion.long,
                                  curve: AppMotion.standard,
                                  width: barWidth,
                                  height: maxV <= 0
                                      ? 0
                                      : math.max(w.values[i] > 0 ? 4 : 0, w.height * w.values[i] / maxV),
                                  decoration: BoxDecoration(
                                    // The selected day at full strength, the rest quiet (review 03).
                                    color: sel == i
                                        ? w.color
                                        : w.color.withValues(alpha: w.muted.contains(i) ? 0.25 : 0.45),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                      bottom: Radius.circular(2),
                                    ),
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
            for (var i = 0; i < w.labels.length; i++)
              Expanded(
                child: Text(
                  w.labels[i],
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: i == w.highlight ? context.scheme.onSurface : secondary,
                    fontWeight: i == w.highlight ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Centers its child on a fraction of the parent's width, kept inside the parent.
class _CenterAt extends SingleChildLayoutDelegate {
  const _CenterAt(this.fraction);
  final double fraction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = (size.width * fraction - childSize.width / 2).clamp(0.0, math.max(0.0, size.width - childSize.width));
    return Offset(x.toDouble(), (size.height - childSize.height) / 2);
  }

  @override
  bool shouldRelayout(_CenterAt old) => old.fraction != fraction;
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

// ---------------------------------------------------------------------------
// Status, numbers, steppers (§7.9, §7.11, §7.12)
// ---------------------------------------------------------------------------

/// A status label: a 14 icon and a 13 w600 label, no container (§7.11). Pass [ink] (e.g.
/// `goodInk`, `inkForPace`) to color both; without it the label is ink and the icon [color].
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, required this.icon, this.ink});
  final String label;
  final Color color;
  final IconData icon;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ink ?? color),
        const SizedBox(width: AppSpace.x1),
        Text(
          label,
          style: context.text.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ink ?? context.scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// A number and its trailing unit as one span: the value in [style] (tabular), then a
/// no-break space and the unit in a smaller secondary body style. "51 g" → 51 + g;
/// values without a separate unit ("€2.62", "634") stay whole.
InlineSpan valueSpan(BuildContext context, String value, TextStyle style) {
  final m = RegExp(r'^(.*\d)\s+([^\d\s]+)$').firstMatch(value);
  if (m == null) return TextSpan(text: value, style: style);
  final unitBase = (style.fontSize ?? 16) > 16 ? context.text.bodyMedium : context.text.bodySmall;
  return TextSpan(
    style: style,
    children: [
      TextSpan(text: m.group(1)),
      TextSpan(
        text: '\u00A0${m.group(2)}',
        style: unitBase?.copyWith(color: context.scheme.onSurfaceVariant),
      ),
    ],
  );
}

/// − n + stepper: a 48 capsule on the neutral fill with two 44 buttons and the value
/// (17 w600, tabular) over an optional hint ("max 3", "portions").
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
    final style = IconButton.styleFrom(minimumSize: const Size(44, 44), iconSize: 20);
    void change(int v) {
      tick();
      onChanged(v);
    }

    return Container(
      height: 48,
      decoration: ShapeDecoration(color: context.colors.fill, shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            style: style,
            tooltip: 'Fewer portions',
            onPressed: value > min ? () => change(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$value', style: context.nums.title.copyWith(height: 20 / 17)),
                if (hint != null)
                  Text(hint!, style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            style: style,
            tooltip: 'More portions',
            onPressed: value < max ? () => change(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

/// An empty region: a 56 glyph circle, a 17 title and a secondary message, centered, with
/// an optional tonal action (§7.18).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x8, horizontal: AppSpace.x6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlyphCircle(icon, size: 56),
              const SizedBox(height: AppSpace.x4),
              Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const SizedBox(height: AppSpace.x4), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// A value over its caption (§7.12): the value in tabular `nums.medium` (or [style]) with its
/// unit set smaller, 4 above a 13 secondary caption with an optional 8 color dot. The
/// caption wraps when space is tight; keep a number and its unit together with a no-break
/// space.
class Metric extends StatelessWidget {
  const Metric({super.key, required this.value, required this.label, this.dotColor, this.style});
  final String value;
  final String label;
  final Color? dotColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(valueSpan(context, value, style ?? context.nums.medium)),
        const SizedBox(height: AppSpace.x1),
        Text.rich(
          TextSpan(
            children: [
              if (dotColor != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                ),
              TextSpan(text: label),
            ],
          ),
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Snackbars (§7.15)
// ---------------------------------------------------------------------------

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
      content: _SnackContent(message: message, detail: detail),
      action: onUndo == null ? null : SnackBarAction(label: 'Undo', onPressed: onUndo),
    ),
  );
}

void showInfo(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      content: _SnackContent(message: message),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// What happened (15 w500, up to 2 lines), then the number on its own 13 line.
class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.message, this.detail});
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(
            detail!,
            style: context.text.bodySmall?.copyWith(color: context.scheme.onInverseSurface.withValues(alpha: 0.7)),
          ),
        ],
      ],
    );
  }
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
