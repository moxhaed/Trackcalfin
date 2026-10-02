import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../buy/ingredient_sheet.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/widgets.dart';

/// Swipe deck: right = still have it, left = out, "Adjust" = fix the amount.
class QuickCheckScreen extends ConsumerStatefulWidget {
  const QuickCheckScreen({super.key});

  @override
  ConsumerState<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends ConsumerState<QuickCheckScreen> {
  List<Ingredient>? _deck;
  int _i = 0;
  int _fixed = 0;
  final _timer = LogTimer();

  @override
  Widget build(BuildContext context) {
    _deck ??= ref.read(quickCheckProvider);
    final deck = _deck!;
    final done = _i >= deck.length;
    return Scaffold(
      appBar: AppBar(title: Text(done ? 'Quick check' : 'Quick check · ${_i + 1} / ${deck.length}')),
      body: done ? _done(context, deck.length) : _card(context, deck[_i]),
    );
  }

  Widget _done(BuildContext context, int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 56, color: context.colors.good),
            const SizedBox(height: 12),
            Text(total == 0 ? 'Nothing to check' : 'Pantry verified', style: context.text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              total == 0
                  ? 'Every item was confirmed recently.'
                  : '$total items checked, $_fixed corrected, in ${_timer.elapsed.inSeconds} s.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  Future<void> _answer(Ingredient ing, bool have) async {
    final pantry = ref.read(pantryServiceProvider);
    if (have) {
      await pantry.verify(ing.id);
    } else {
      // Gone without a logged meal: it counts as eaten since it was last counted or bought.
      final use = await pantry.markOut(ing.id);
      _fixed++;
      if (use != null && mounted) {
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${ing.name} counts as eaten'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(label: 'Thrown away', onPressed: () => pantry.setUseKind(use, UseKind.thrownAway)),
          ),
        );
      }
    }
    tick();
    setState(() => _i++);
    if (_i >= _deck!.length) unawaited(ref.read(metricsServiceProvider).record('quick_check', _timer.elapsed));
  }

  Widget _card(BuildContext context, Ingredient ing) {
    final c = context.colors;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Dismissible(
              key: ValueKey('qc-${ing.id}'),
              onDismissed: (d) => _answer(ing, d == DismissDirection.startToEnd),
              background: _swipeBg(context, c.good, Icons.check, 'Still have it', Alignment.centerLeft),
              secondaryBackground: _swipeBg(context, c.critical, Icons.close, "It's gone", Alignment.centerRight),
              child: Card(
                color: context.scheme.surfaceContainerHigh,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(ingredientIcon(ing.category), size: 48, color: context.scheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Still have ${ing.name.toLowerCase()}?',
                          style: context.text.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The app thinks ~${qty(ing.qtyOnHand, ing.baseUnit)}',
                          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                        ),
                        if (ing.lastVerifiedAt == null) ...[
                          const SizedBox(height: 12),
                          StatusPill(label: 'Not checked in a while', color: c.warning, icon: Icons.history),
                        ],
                        const SizedBox(height: 24),
                        Text('Swipe right if yes, left if it\'s gone', style: context.text.labelMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _answer(ing, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Gone'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await showIngredientSheet(context, ingredient: ing);
                      _fixed++;
                      setState(() => _i++);
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('Adjust'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _answer(ing, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Yes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _swipeBg(BuildContext context, Color color, IconData icon, String label, Alignment align) => Container(
    alignment: align,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 36),
        Text(label),
      ],
    ),
  );
}
