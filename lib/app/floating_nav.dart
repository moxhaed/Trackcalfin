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

/// Floating bottom navigation: a pill of tabs with a round capture button beside it.
/// On iOS 26+ both are native Liquid Glass (`ios/Runner/GlassNav.swift`); elsewhere
/// the pill is drawn in Flutter over a light backdrop blur.
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

class _BlurPill extends StatelessWidget {
  const _BlurPill({required this.tabs, required this.index, required this.onSelect});
  final List<NavTab> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final n = tabs.length;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        shadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: StadiumBorder()),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: scheme.surfaceContainer.withValues(alpha: 0.72),
              shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      alignment: Alignment(n > 1 ? -1 + 2 * index / (n - 1) : 0, 0),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: FractionallySizedBox(
                        widthFactor: 1 / n,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(color: scheme.secondaryContainer, shape: const StadiumBorder()),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: _PillTab(tab: tabs[i], selected: i == index, onTap: () => onSelect(i)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({required this.tab, required this.selected, required this.onTap});
  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.scheme.onSecondaryContainer : context.scheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: tab.badge > 0,
              label: Text('${tab.badge}'),
              child: Icon(selected ? tab.activeIcon : tab.icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: context.text.labelSmall?.copyWith(color: color, fontWeight: selected ? FontWeight.w700 : null),
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
