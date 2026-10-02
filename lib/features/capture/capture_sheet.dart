import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../platform/photo_capture.dart';
import 'ate_sheet.dart';
import 'cooked_sheet.dart';
import 'expense_sheet.dart';
import 'scan_flow.dart';

Future<void> showCaptureSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  builder: (_) => CaptureSheet(outer: context, outerRef: ref),
);

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

    final items = <(IconData, String, String, VoidCallback)>[
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
      (Icons.kitchen_outlined, 'Pantry', 'Food you have', () => go(() => startScan(outer, outerRef, hint: 'pantry'))),
      (Icons.payments_outlined, 'Expense', 'Non-food too', () => go(() => showExpenseSheet(outer))),
      (Icons.soup_kitchen_outlined, 'I cooked', 'Deducts stock', () => go(() => showCookedSheet(outer))),
      (Icons.restaurant_outlined, 'I ate', 'Fridge or other', () => go(() => showAteSheet(outer))),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.88,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final (icon, title, sub, onTap) in items)
              Material(
                color: context.scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 30, color: context.scheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: context.text.labelLarge,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
