import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../platform/photo_capture.dart';
import '../common/widgets.dart';
import 'ate_sheet.dart';
import 'cooked_sheet.dart';
import 'expense_sheet.dart';
import 'scan_flow.dart';

Future<void> showCaptureSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  builder: (_) => CaptureSheet(outer: context, outerRef: ref),
);

typedef _Entry = (IconData, String, String, VoidCallback);

/// The global ⊕: every log starts here in one tap.
class CaptureSheet extends StatelessWidget {
  const CaptureSheet({super.key, required this.outer, required this.outerRef});
  final BuildContext outer;
  final WidgetRef outerRef;

  @override
  Widget build(BuildContext context) {
    void go(Future<void> Function() action) {
      Navigator.of(context).pop();
      action();
    }

    final items = <_Entry>[
      (
        Icons.receipt_long_outlined,
        'Scan receipt',
        PhotoCapture.hasCamera ? 'Camera' : 'Choose photo',
        () => go(() => startScan(outer, outerRef, hint: 'receipt')),
      ),
      (
        Icons.photo_library_outlined,
        'From photos',
        'Screenshots',
        () => go(() => startScan(outer, outerRef, hint: 'receipt', camera: false)),
      ),
      (Icons.kitchen_outlined, 'Pantry', 'Stocktake photo', () => go(() => startScan(outer, outerRef, hint: 'pantry'))),
      (Icons.payments_outlined, 'Expense', 'Non-food too', () => go(() => showExpenseSheet(outer))),
      (Icons.soup_kitchen_outlined, 'I cooked', 'Deducts stock', () => go(() => showCookedSheet(outer))),
      (Icons.restaurant_outlined, 'I ate', 'Fridge or other', () => go(() => showAteSheet(outer))),
    ];

    // Two rows of three. A row is as tall as its tallest tile, so at large text sizes the tiles
    // grow together instead of overflowing (104 at 1.0×).
    Widget row(List<_Entry> tiles) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (icon, title, sub, onTap)) in tiles.indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: CaptureTile(icon: icon, title: title, subtitle: sub, onTap: onTap),
            ),
          ],
        ],
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(header: true, child: Text('Log something', style: context.text.headlineSmall)),
            const SizedBox(height: AppSpace.x4),
            row(items.sublist(0, 3)),
            const SizedBox(height: 10),
            row(items.sublist(3)),
          ],
        ),
      ),
    );
  }
}
