import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/used_up.dart';
import '../common/format.dart';
import '../common/widgets.dart';

/// "I'm out" wherever it is said (an item's sheet, a pantry swipe, Quick Check, a recipe),
/// and taking a mistaken count back later from the item's sheet.

/// What the last count of an item found gone, while its sheet can take it back.
final lastCountProvider = StreamProvider.autoDispose.family<CountedUse?, int>((ref, id) {
  final isar = ref.watch(isarProvider);
  final pantry = ref.watch(pantryServiceProvider);
  return StreamGroup.merge<void>([
    isar.foodUses.watchLazy(fireImmediately: true),
    isar.ingredients.watchObjectLazy(id),
  ]).asyncMap((_) => pantry.lastCount(id));
});

/// Marks [ing] out: it commits on the tap and the message offers Undo, which takes the count
/// back as if it never happened. [thrownAway] adds Quick Check's "Thrown away". Reads [ref]
/// before anything else, so the caller may close right after.
Future<void> markOutWithUndo(
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  Ingredient ing, {
  bool thrownAway = false,
}) async {
  final pantry = ref.read(pantryServiceProvider);
  final money = ref.read(moneyProvider);
  final before = ing.qtyOnHand;
  final useId = await pantry.markOut(ing.id);
  final use = useId == null ? null : (await pantry.lastCount(ing.id))?.use;
  // Without a price nothing counts as eaten: Undo only sets the amount back.
  Future<void> undo() async => useId == null ? pantry.setQuantity(ing.id, before) : pantry.undoCount(useId);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${ing.name} marked as out'),
                  if (use != null)
                    Text(
                      '${qtyOf(use.qtyBase, ing)} counts as eaten, ${money.compact(use.costMinor)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            if (thrownAway && useId != null)
              Builder(
                builder: (context) => TextButton(
                  style: TextButton.styleFrom(foregroundColor: context.scheme.inversePrimary),
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    pantry.setUseKind(useId, UseKind.thrownAway);
                  },
                  child: const Text('Thrown away'),
                ),
              ),
          ],
        ),
        action: SnackBarAction(label: 'Undo', onPressed: undo),
        persist: false,
      ),
    );
}

/// An item's sheet: what its last count found gone ("Marked out on Fri 2 Oct · 455 g counted
/// as eaten, €1.19"), with Undo. [onTakenBack] closes the sheet so the message shows.
class LastCountLine extends ConsumerWidget {
  const LastCountLine({super.key, required this.ingredient, this.onTakenBack});
  final Ingredient ingredient;
  final VoidCallback? onTakenBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastCountProvider(ingredient.id)).value;
    if (last == null) return const SizedBox.shrink();
    final money = ref.watch(moneyProvider);
    final u = last.use;
    final eaten = u.kind == UseKind.eaten;
    final amount = qtyOf(u.qtyBase, ingredient);
    final text = [
      '${last.markedOut ? 'Marked out' : 'Counted less'} on ${dateLabel(u.createdAt, DateTime.now())}',
      '$amount ${eaten ? 'counted as eaten' : 'thrown away'}, ${money.compact(u.costMinor)}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.history, size: 18, color: context.scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => _takeBack(context, ref, last, amount),
            // Counted since: that count holds the amount, so only "eaten" is taken back.
            child: Text(last.putsBack ? 'Undo' : 'Not eaten'),
          ),
        ],
      ),
    );
  }

  Future<void> _takeBack(BuildContext context, WidgetRef ref, CountedUse last, String amount) async {
    final pantry = ref.read(pantryServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final undone = await pantry.undoCount(last.use.id);
    if (undone == null) return;
    tick();
    onTakenBack?.call();
    final name = ingredient.name;
    showUndoOn(
      messenger,
      undone.putBack ? '$name put back · $amount' : '$name: $amount no longer counts as eaten',
      detail: undone.putBack && last.use.kind == UseKind.eaten ? 'No longer counts as eaten' : null,
      onUndo: () => pantry.redoCount(undone),
    );
  }
}
