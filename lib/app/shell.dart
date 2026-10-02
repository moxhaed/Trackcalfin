import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/capture_menu.dart';
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
      body: shell,
      bottomNavigationBar: FloatingNav(
        index: shell.currentIndex,
        onSelect: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
        onCapture: () => showCaptureMenu(context, ref),
        captureLabel: 'Log something',
        popupOpen: popupOpen,
        tabs: [
          const NavTab('Dashboard', Icons.insights_outlined, Icons.insights, 'chart.xyaxis.line', 'chart.xyaxis.line'),
          NavTab('Buy', Icons.shopping_basket_outlined, Icons.shopping_basket, 'basket', 'basket.fill', badge: inbox),
          const NavTab('Cook', Icons.soup_kitchen_outlined, Icons.soup_kitchen, 'frying.pan', 'frying.pan.fill'),
          const NavTab('Settings', Icons.tune_outlined, Icons.tune, 'slider.horizontal.3', 'slider.horizontal.3'),
        ],
      ),
    );
  }
}
