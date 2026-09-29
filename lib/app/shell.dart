import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/capture_sheet.dart';
import 'providers.dart';
import 'theme.dart';

/// Bottom bar with the global capture ⊕ in the middle.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxCountProvider);
    Widget item(int index, IconData icon, IconData active, String label, {int badge = 0}) {
      final selected = shell.currentIndex == index;
      final color = selected ? context.scheme.primary : context.scheme.onSurfaceVariant;
      return Expanded(
        child: InkResponse(
          onTap: () => shell.goBranch(index, initialLocation: index == shell.currentIndex),
          child: Semantics(
            selected: selected,
            button: true,
            label: label,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  isLabelVisible: badge > 0,
                  label: Text('$badge'),
                  child: Icon(selected ? active : icon, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(color: color, fontWeight: selected ? FontWeight.w700 : null),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: shell,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Log something',
        shape: const CircleBorder(),
        onPressed: () => showCaptureSheet(context, ref),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          children: [
            item(0, Icons.insights_outlined, Icons.insights, 'Dashboard'),
            item(1, Icons.shopping_basket_outlined, Icons.shopping_basket, 'Buy', badge: inbox),
            const SizedBox(width: 64),
            item(2, Icons.soup_kitchen_outlined, Icons.soup_kitchen, 'Cook'),
            item(3, Icons.tune_outlined, Icons.tune, 'Settings'),
          ],
        ),
      ),
    );
  }
}
