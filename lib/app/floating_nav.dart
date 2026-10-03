import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

/// One destination in [FloatingNav]. The symbols are SF Symbols for the native iOS bar.
class NavTab {
  const NavTab(this.label, this.icon, this.activeIcon, this.symbol, this.activeSymbol, {this.badge = 0});
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String symbol;
  final String activeSymbol;
  final int badge;
}

/// Tracks popups (sheets, dialogs, pickers) on the navigator it observes, from push
/// until their exit animation ends. [FloatingNav] reads it: Flutter can't draw cleanly
/// over the native glass (its rims show through), so popups cover a Flutter pill instead.
class PopupObserver extends NavigatorObserver {
  final open = ValueNotifier(false);
  final _routes = <Route<dynamic>>{};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is! PopupRoute) return;
    _routes.add(route);
    route.animation?.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) _close(route);
    });
    open.value = true;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _close(route);

  void _close(Route<dynamic> route) {
    if (_routes.remove(route)) open.value = _routes.isNotEmpty;
  }
}

/// Liquid Glass shipped with iOS 26. Dart reports the iOS version as "Version 26.0 (Build …)".
final bool _nativeGlass =
    !kIsWeb &&
    Platform.isIOS &&
    (int.tryParse(RegExp(r'Version (\d+)').firstMatch(Platform.operatingSystemVersion)?.group(1) ?? '') ?? 0) >= 26;

/// A backdrop blur has to blur what scrolls under the pill again on every frame. iOS takes that
/// in stride (and iOS users expect glass); on Android it breaks the GPU's render pass and blurs
/// a fresh copy of the screen behind the pill each frame while scrolling, a classic jank source
/// there. So outside iOS the pill is solid, in the color the glass shows over the page.
final bool _blurBackdrop = !kIsWeb && Platform.isIOS;

/// Floating bottom navigation: a pill of tabs with a round capture button beside it.
/// On iOS 26+ both are native Liquid Glass (`ios/Runner/GlassNav.swift`); elsewhere
/// the pill is drawn in Flutter, over a light backdrop blur on iOS and solid elsewhere.
///
/// Use it with `Scaffold(extendBody: true)` so content scrolls behind it; the
/// Scaffold then reports the bar's height as bottom `MediaQuery` padding.
class FloatingNav extends StatelessWidget {
  const FloatingNav({
    super.key,
    required this.tabs,
    required this.index,
    required this.onSelect,
    required this.onCapture,
    required this.captureLabel,
    required this.popupOpen,
  });

  final List<NavTab> tabs;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onCapture;
  final String captureLabel;

  /// From a [PopupObserver] on the navigator that shows sheets and dialogs.
  final ValueListenable<bool> popupOpen;

  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final pill = Row(
      children: [
        Expanded(
          child: _BlurPill(tabs: tabs, index: index, onSelect: onSelect),
        ),
        const SizedBox(width: 10),
        _CaptureButton(label: captureLabel, onPressed: onCapture),
      ],
    );
    // Sit a little into the home-indicator inset, like the system tab bar does.
    final bottom = math.max(12.0, MediaQuery.paddingOf(context).bottom - 8);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      child: SizedBox(
        height: height,
        child: !_nativeGlass
            ? pill
            : ValueListenableBuilder(
                valueListenable: popupOpen,
                // The native view stays alive offstage while a popup covers the pill.
                builder: (context, open, glass) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Offstage(offstage: open, child: glass),
                    if (open) pill,
                  ],
                ),
                child: _GlassNav(
                  tabs: tabs,
                  index: index,
                  onSelect: onSelect,
                  onCapture: onCapture,
                  captureLabel: captureLabel,
                ),
              ),
      ),
    );
  }
}

/// The Flutter pill. One animated position drives the indicator and every tab's highlight:
/// a tab lights up as much as the indicator covers it, so the highlight travels with the
/// indicator instead of jumping to the new tab before the indicator gets there.
class _BlurPill extends StatefulWidget {
  const _BlurPill({required this.tabs, required this.index, required this.onSelect});
  final List<NavTab> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  State<_BlurPill> createState() => _BlurPillState();
}

class _BlurPillState extends State<_BlurPill> with SingleTickerProviderStateMixin {
  late final _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late double _from = widget.index.toDouble();
  late double _to = widget.index.toDouble();

  /// Where the indicator is, in tabs (1.5 is halfway between the second and third).
  double get _at => _from + (_to - _from) * Curves.easeOutCubic.transform(_move.value);

  @override
  void didUpdateWidget(_BlurPill old) {
    super.didUpdateWidget(old);
    if (widget.index != _to) {
      // Start from wherever it is now, so a quick second tap doesn't jump.
      _from = _at;
      _to = widget.index.toDouble();
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  /// The indicator for one frame, as a span of tabs: it stretches a little in flight, like a
  /// drop of liquid, and is one tab wide at rest.
  (double, double) _span() {
    final flight = math.min(1.0, (_to - _from).abs());
    final width = 1 + 0.28 * flight * math.sin(math.pi * _move.value);
    final n = widget.tabs.length.toDouble();
    final left = (_at + (1 - width) / 2).clamp(0.0, n - width);
    return (left, left + width);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final n = widget.tabs.length;
    final border = StadiumBorder(side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5), width: 0.5));
    final content = Padding(
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _move,
          builder: (context, _) {
            final (left, right) = _span();
            final w = box.maxWidth / n;
            return Stack(
              children: [
                Positioned(
                  left: left * w,
                  width: (right - left) * w,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(color: scheme.secondaryContainer, shape: const StadiumBorder()),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < n; i++)
                      Expanded(
                        child: _PillTab(
                          tab: widget.tabs[i],
                          // How much of this tab the indicator covers right now.
                          glow: (math.min(right, i + 1.0) - math.max(left, i.toDouble())).clamp(0.0, 1.0),
                          current: i == widget.index,
                          onTap: () => widget.onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        shadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: _blurBackdrop
          ? ClipPath(
              clipper: const ShapeBorderClipper(shape: StadiumBorder()),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: DecoratedBox(
                  decoration: ShapeDecoration(color: scheme.surfaceContainer.withValues(alpha: 0.72), shape: border),
                  child: content,
                ),
              ),
            )
          : DecoratedBox(
              decoration: ShapeDecoration(
                color: Color.alphaBlend(scheme.surfaceContainer.withValues(alpha: 0.72), scheme.surface),
                shape: border,
              ),
              child: content,
            ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({required this.tab, required this.glow, required this.current, required this.onTap});
  final NavTab tab;

  /// 0 = plain, 1 = fully selected look (filled icon, strong color, bold label).
  final double glow;

  /// The tab that is selected, for screen readers; [glow] is only the look.
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(context.scheme.onSurfaceVariant, context.scheme.onSecondaryContainer, glow)!;
    return Semantics(
      selected: current,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: tab.badge > 0,
              label: Text('${tab.badge}'),
              // The filled icon fades in over the outline one as the indicator arrives.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(tab.icon, color: color.withValues(alpha: 1 - glow), size: 22),
                  Icon(tab.activeIcon, color: color.withValues(alpha: glow), size: 22),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: context.text.labelSmall?.copyWith(color: color, fontWeight: glow > 0.5 ? FontWeight.w700 : null),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: context.scheme.primary,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: FloatingNav.height,
            child: Icon(Icons.add, size: 30, color: context.scheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

/// Hosts `GlassNavView` and keeps it in sync with the Flutter state and theme.
class _GlassNav extends StatefulWidget {
  const _GlassNav({
    required this.tabs,
    required this.index,
    required this.onSelect,
    required this.onCapture,
    required this.captureLabel,
  });

  final List<NavTab> tabs;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onCapture;
  final String captureLabel;

  @override
  State<_GlassNav> createState() => _GlassNavState();
}

class _GlassNavState extends State<_GlassNav> {
  static const _viewType = 'trackcalfin/glass-nav';
  MethodChannel? _channel;
  Map<String, Object>? _sent;

  Map<String, Object> _state() => {
    'index': widget.index,
    'badges': [for (final t in widget.tabs) t.badge],
    'dark': Theme.of(context).brightness == Brightness.dark,
    'tint': context.scheme.primary.toARGB32(),
    'onTint': context.scheme.onPrimary.toARGB32(),
  };

  void _sync() {
    final state = _state();
    if (_channel == null || const DeepCollectionEquality().equals(state, _sent)) return;
    _sent = state;
    _channel!.invokeMethod('update', state);
  }

  Future<void> _onCall(MethodCall call) async {
    switch (call.method) {
      case 'select':
        widget.onSelect(call.arguments as int);
      case 'capture':
        widget.onCapture();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_GlassNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: _viewType,
      creationParams: {
        'tabs': [
          for (final t in widget.tabs) {'label': t.label, 'symbol': t.symbol, 'activeSymbol': t.activeSymbol},
        ],
        'captureLabel': widget.captureLabel,
        ..._state(),
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (id) {
        _channel = MethodChannel('$_viewType/$id')..setMethodCallHandler(_onCall);
        // State may have moved on since the creation params were built.
        if (mounted) _sync();
      },
    );
  }
}
