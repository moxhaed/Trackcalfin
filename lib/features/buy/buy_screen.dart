import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../capture/expense_sheet.dart';
import '../capture/scan_flow.dart';
import '../common/widgets.dart';
import 'ingredient_sheet.dart';
import 'ledger_view.dart';
import 'pantry_view.dart';

/// Tab 2: Inventory & Ledger.
class BuyScreen extends ConsumerStatefulWidget {
  const BuyScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends ConsumerState<BuyScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(inboxCountProvider);
    final jobs = ref.watch(scanJobsProvider).value ?? const [];
    final working = jobs.where((j) => j.status == ScanStatus.processing || j.status == ScanStatus.queued).length;
    return Scaffold(
      appBar: TabHeader(
        title: 'Buy',
        hairline: false,
        actions: [
          IconButton(
            tooltip: 'Inbox',
            onPressed: () => context.push('/inbox'),
            icon: Badge(isLabelVisible: inbox > 0, label: Text('$inbox'), child: const Icon(Icons.inbox_outlined)),
          ),
          // The four ways to add something (the old action row), one tap away in a menu.
          PopupMenuButton<_Add>(
            tooltip: 'Add',
            icon: const Icon(Icons.add_rounded),
            constraints: const BoxConstraints(minWidth: 200),
            onSelected: (a) => switch (a) {
              _Add.receipt => startScan(context, ref, hint: 'receipt'),
              _Add.pantryPhoto => startScan(context, ref, hint: 'pantry'),
              _Add.expense => showExpenseSheet(context),
              _Add.item => showIngredientSheet(context),
            },
            itemBuilder: (context) => [
              for (final a in _Add.values)
                PopupMenuItem(
                  value: a,
                  child: Row(
                    children: [
                      Icon(a.icon, size: 20, color: context.scheme.onSurfaceVariant),
                      const SizedBox(width: AppSpace.x3),
                      Text(a.label),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // The pinned block: the Pantry/Ledger switch (and a scan in progress) with its 12 of
          // padding. Pantry's content clips at its bottom edge, so the scrolled-under hairline
          // is drawn there (Ledger draws it under its own pinned chip strip).
          ScrollEdge(
            enabled: _tab == 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
                  child: AppSegmented<int>(
                    segments: const {0: 'Pantry', 1: 'Ledger'},
                    selected: _tab,
                    onChanged: (v) => setState(() => _tab = v),
                  ),
                ),
                if (working > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.x1, AppSpace.x1, 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: Text(
                            working == 1 ? 'Reading 1 scan…' : 'Reading $working scans…',
                            style: context.text.bodySmall,
                          ),
                        ),
                        TextButton(onPressed: () => context.push('/inbox'), child: const Text('Inbox')),
                      ],
                    ),
                  ),
                // Pantry: 12 to the search field. Ledger: its 48 chip strip starts 6 below the
                // switch, so the chips themselves (36 tall, centered) start 12 below, on the
                // same line as the search field.
                SizedBox(height: _tab == 0 ? AppSpace.x3 : 6),
              ],
            ),
          ),
          Expanded(child: _tab == 0 ? const PantryView() : const LedgerView()),
        ],
      ),
    );
  }
}

enum _Add {
  receipt('Scan receipt', Icons.receipt_long_outlined),
  pantryPhoto('Pantry photo', Icons.kitchen_outlined),
  expense('Log expense', Icons.payments_outlined),
  item('Add pantry item', Icons.add_box_outlined);

  const _Add(this.label, this.icon);
  final String label;
  final IconData icon;
}
