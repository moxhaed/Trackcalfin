import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../capture/scan_flow.dart';
import 'ledger_view.dart';
import 'pantry_view.dart';
import 'shopping_view.dart';

/// Tab 2: what you have (Pantry), what to buy (List) and what you spent (Ledger).
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
    final toBuy = (ref.watch(shoppingListProvider).value ?? const []).where((l) => l.doneAt == null).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy'),
        actions: [
          IconButton(
            tooltip: 'Inbox',
            onPressed: () => context.push('/inbox'),
            icon: Badge(isLabelVisible: inbox > 0, label: Text('$inbox'), child: const Icon(Icons.inbox_outlined)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                // Pantry photos and expenses are in the ⊕ menu; a receipt is the Buy tab's job.
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => startScan(context, ref, hint: 'receipt'),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Scan receipt'),
                  ),
                ),
              ],
            ),
          ),
          if (working > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: [
                  const ButtonSegment(value: 0, label: Text('Pantry'), icon: Icon(Icons.kitchen_outlined)),
                  ButtonSegment(
                    value: 1,
                    label: Text(toBuy > 0 ? 'List · $toBuy' : 'List'),
                    icon: const Icon(Icons.checklist_outlined),
                  ),
                  const ButtonSegment(value: 2, label: Text('Ledger'), icon: Icon(Icons.receipt_outlined)),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_tab) {
              0 => const PantryView(),
              1 => const ShoppingView(),
              _ => const LedgerView(),
            },
          ),
        ],
      ),
    );
  }
}
