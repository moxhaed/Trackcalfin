import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/capture_sheet.dart';
import 'floating_nav.dart';
import 'providers.dart';

/// Floating tab pill with the global capture ⊕ beside it. Tab bodies scroll
/// behind the bar, so their lists pad by `MediaQuery.paddingOf(context).bottom`.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell, required this.popupOpen});
  final StatefulNavigationShell shell;
  final ValueListenable<bool> popupOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxCountProvider);
    return Scaffold(
      extendBody: true,
      // The tab pages scroll behind the bar; a short canvas fade under it keeps their content from
      // looking sliced in the gap between the pill and the ⊕.
      body: Stack(fit: StackFit.expand, children: [shell, const _NavFade()]),
      bottomNavigationBar: FloatingNav(
        index: shell.currentIndex,
        onSelect: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
        onCapture: () => showCaptureSheet(context, ref),
        captureLabel: 'Log something',
        popupOpen: popupOpen,
        tabs: [
          const NavTab(
            'Dashboard',
            Icons.insights_outlined,
            Icons.insights_rounded,
            'chart.xyaxis.line',
            'chart.xyaxis.line',
          ),
          NavTab(
            'Buy',
            Icons.shopping_basket_outlined,
            Icons.shopping_basket_rounded,
            'basket',
            'basket.fill',
            badge: inbox,
          ),
          const NavTab(
            'Cook',
            Icons.soup_kitchen_outlined,
            Icons.soup_kitchen_rounded,
            'frying.pan',
            'frying.pan.fill',
          ),
          const NavTab(
            'Settings',
            Icons.tune_rounded,
            Icons.tune_rounded,
            'slider.horizontal.3',
            'slider.horizontal.3',
          ),
        ],
      ),
    );
  }
}

/// A canvas-colored gradient over the bottom edge of the tab pages, behind the pill and ⊕: it
/// starts 24 above the pill, is ~85% opaque at the pill's center and 95% at the screen edge.
/// It ignores pointers, so the content underneath stays scrollable and tappable.
class _NavFade extends StatelessWidget {
  const _NavFade();

  @override
  Widget build(BuildContext context) {
    // Inside an extended-body Scaffold the bottom padding is the bar's height plus its inset.
    final bar = MediaQuery.paddingOf(context).bottom;
    const lead = 24.0;
    final canvas = Theme.of(context).scaffoldBackgroundColor;
    final height = bar + lead;
    // The pill is the top 60 of the bar, so its center is 30 below the gradient's 24 lead.
    final pillCenter = ((lead + FloatingNav.height / 2) / height).clamp(0.0, 1.0);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [canvas.withValues(alpha: 0), canvas.withValues(alpha: 0.85), canvas.withValues(alpha: 0.95)],
              stops: [0, pillCenter, 1],
            ),
          ),
        ),
      ),
    );
  }
}
