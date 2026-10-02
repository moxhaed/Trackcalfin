import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/floating_nav.dart';
import '../../app/theme.dart';
import '../../platform/photo_capture.dart';
import 'ate_sheet.dart';
import 'cooked_sheet.dart';
import 'expense_sheet.dart';
import 'say_it_sheet.dart';
import 'scan_flow.dart';

/// The global ⊕: round buttons stacked above it, each with what it does. Say it sits
/// closest to the thumb; the ⊕ turns into ✕ to close.
Future<void> showCaptureMenu(BuildContext context, WidgetRef ref) => showGeneralDialog(
  context: context,
  useRootNavigator: true,
  barrierDismissible: true,
  barrierLabel: 'Close',
  barrierColor: Colors.black.withValues(alpha: 0.4),
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (_, _, _) => CaptureMenu(outer: context, outerRef: ref),
);

class _Option {
  const _Option(this.icon, this.title, this.subtitle, this.run, {this.primary = false});
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function() run;

  /// The main way in: bigger and filled.
  final bool primary;
}

class CaptureMenu extends StatelessWidget {
  const CaptureMenu({super.key, required this.outer, required this.outerRef});

  /// The screen behind the menu, which the chosen flow opens on.
  final BuildContext outer;
  final WidgetRef outerRef;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)!.animation!;
    void go(void Function() run) {
      Navigator.of(context).pop();
      run();
    }

    // Top to bottom; the last one is right above the ⊕.
    final options = [
      _Option(
        Icons.kitchen_outlined,
        'Pantry photo',
        'Count food you already have',
        () => startScan(outer, outerRef, hint: 'pantry'),
      ),
      _Option(
        Icons.photo_library_outlined,
        'Receipt from photos',
        'Screenshots and e-receipts',
        () => startScan(outer, outerRef, hint: 'receipt', camera: false),
      ),
      _Option(Icons.payments_outlined, 'Expense', 'Type an amount, any category', () => showExpenseSheet(outer)),
      _Option(Icons.soup_kitchen_outlined, 'I cooked', 'Uses up your stock', () => showCookedSheet(outer)),
      _Option(Icons.restaurant_outlined, 'I ate', 'From the fridge, or anything', () => showAteSheet(outer)),
      _Option(
        Icons.receipt_long_outlined,
        'Scan receipt',
        PhotoCapture.hasCamera ? 'Camera' : 'Choose a photo',
        () => startScan(outer, outerRef, hint: 'receipt'),
      ),
      _Option(Icons.mic, 'Say it', 'Tell it what you bought, ate or cooked', () => showSayIt(outer), primary: true),
    ];
    // Where FloatingNav puts the ⊕.
    final bottom = math.max(12.0, MediaQuery.paddingOf(context).bottom - 8);
    const size = FloatingNav.height;
    return Stack(
      children: [
        Positioned(
          right: 16 + (size - 56) / 2,
          bottom: bottom + size + 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, o) in options.indexed)
                _Row(
                  option: o,
                  // The one nearest the ⊕ comes first.
                  animation: CurvedAnimation(
                    parent: route,
                    curve: Interval((options.length - 1 - i) * 0.06, 0.55 + (options.length - 1 - i) * 0.06),
                    reverseCurve: Curves.easeIn,
                  ),
                  onTap: () => go(o.run),
                ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: bottom,
          child: Tooltip(
            message: 'Close',
            child: Material(
              color: context.scheme.primary,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox.square(
                  dimension: size,
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.125).animate(CurvedAnimation(parent: route, curve: Curves.easeOut)),
                    child: Icon(Icons.add, size: 30, color: context.scheme.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.option, required this.animation, required this.onTap});
  final _Option option;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = option;
    final scheme = context.scheme;
    final dot = o.primary ? 56.0 : 46.0;
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Semantics(
            button: true,
            label: '${o.title}. ${o.subtitle}',
            excludeSemantics: true,
            onTap: onTap,
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: scheme.surfaceContainerHigh,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(o.title, style: context.text.labelLarge),
                            Text(o.subtitle, style: context.text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    child: Center(
                      child: ScaleTransition(
                        scale: Tween(begin: 0.6, end: 1.0).animate(animation),
                        child: Material(
                          color: o.primary ? scheme.primary : scheme.secondaryContainer,
                          shape: const CircleBorder(),
                          elevation: o.primary ? 4 : 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onTap,
                            child: SizedBox.square(
                              dimension: dot,
                              child: Icon(
                                o.icon,
                                size: o.primary ? 28 : 22,
                                color: o.primary ? scheme.onPrimary : scheme.onSecondaryContainer,
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
          ),
        ),
      ),
    );
  }
}
