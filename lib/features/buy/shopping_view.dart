import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/price_book.dart';
import '../../domain/shopping.dart';
import '../common/widgets.dart';

/// Adds [items] to the shopping list (what is already on it is skipped), with Undo.
Future<void> addToShoppingList(BuildContext context, WidgetRef ref, List<ShoppingSuggestion> items) async {
  final shopping = ref.read(shoppingServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  final ids = await shopping.addAll([for (final s in items) (s.name, s.key)]);
  if (ids.isEmpty) {
    messenger.showSnackBar(
      SnackBar(content: Text(items.length == 1 ? 'Already on the list' : 'All on the list already')),
    );
    return;
  }
  showUndoOn(
    messenger,
    ids.length == 1 && items.length == 1 ? '${items.single.name} is on the list' : '${ids.length} added to the list',
    onUndo: () => shopping.removeAll(ids),
  );
}

/// Buy → List: what to buy, by the store it is cheapest at. A receipt with an item ticks it off.
class ShoppingView extends ConsumerWidget {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(shoppingListProvider).value;
    if (list == null) return const Center(child: CircularProgressIndicator());
    final pantry = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
    final book = ref.watch(priceBookProvider);
    final shopping = ref.read(shoppingServiceProvider);
    final open = list.where((l) => l.doneAt == null).toList();
    final done = list.where((l) => l.doneAt != null).toList();
    final suggestions = Shopping.suggestions(pantry, list, now: DateTime.now());
    final groups = Shopping.byStore(open, book);
    final units = {for (final i in pantry) i.key: i.baseUnit};
    final money = ref.watch(moneyProvider);
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);

    Future<void> remove(ShoppingListItem l) async {
      final messenger = ScaffoldMessenger.of(context);
      final gone = await shopping.removeAll([l.id]);
      showUndoOn(messenger, '${l.name} removed', onUndo: () => shopping.restore(gone));
    }

    Widget line(ShoppingListItem l) {
      final ticked = l.doneAt != null;
      final best = l.ingredientKey == null ? null : book.pricesFor(l.ingredientKey!).firstOrNull;
      final unit = units[l.ingredientKey];
      final detail = [
        if (l.amount != null) l.amount!,
        if (best != null && unit != null && !ticked) PriceBook.perUnit(money, best.unitMinor, unit),
      ].join(' · ');
      return Dismissible(
        key: ValueKey('shop-${l.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          color: context.scheme.errorContainer,
          child: Icon(Icons.delete_outline, color: context.scheme.onErrorContainer),
        ),
        onDismissed: (_) => remove(l),
        child: ListTile(
          leading: Checkbox(value: ticked, onChanged: (_) => shopping.toggle(l.id)),
          title: Text(
            l.name,
            style: ticked
                ? TextStyle(decoration: TextDecoration.lineThrough, color: context.scheme.onSurfaceVariant)
                : null,
          ),
          subtitle: detail.isEmpty ? null : Text(detail, style: muted),
          onTap: () => shopping.toggle(l.id),
          onLongPress: () => _edit(context, ref, l),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: _AddField(pantry: pantry),
        ),
        if (suggestions.isNotEmpty) ...[
          const _Header('Running low or out'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in suggestions.take(10))
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text(s.name),
                    tooltip: s.reason,
                    onPressed: () => shopping.add(s.name, key: s.key),
                  ),
              ],
            ),
          ),
        ],
        if (open.isEmpty && done.isEmpty)
          const EmptyState(
            icon: Icons.checklist_outlined,
            title: 'Nothing to buy yet',
            message: 'Add what you need. A receipt with an item ticks it off for you.',
          ),
        for (final (store, items) in groups) ...[
          _Header(store == null ? (groups.length > 1 ? 'Anywhere' : 'To buy') : 'Cheapest at $store'),
          for (final l in items) line(l),
        ],
        if (done.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(child: _Header.text(context, 'In the basket · ${done.length}')),
                TextButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final gone = await shopping.clearDone();
                    showUndoOn(messenger, 'Cleared ${gone.length}', onUndo: () => shopping.restore(gone));
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          for (final l in done) line(l),
        ],
        if (open.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _share(context, Shopping.asText(open, book)),
                icon: const Icon(Icons.ios_share, size: 18),
                label: const Text('Send the list'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _share(BuildContext context, String text) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(ShareParams(text: text, subject: 'Shopping list'));
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) showInfo(context, 'Copied the list');
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, ShoppingListItem l) async {
    final name = TextEditingController(text: l.name);
    final amount = TextEditingController(text: l.amount ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'What'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amount,
              decoration: const InputDecoration(labelText: 'How much (optional)', hintText: '2 l, 6, 500 g'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) await ref.read(shoppingServiceProvider).rename(l.id, name.text, amount: amount.text);
    name.dispose();
    amount.dispose();
  }
}

/// Type anything; picking a pantry item from the matches links it (its store, auto tick-off).
class _AddField extends ConsumerStatefulWidget {
  const _AddField({required this.pantry});
  final List<Ingredient> pantry;

  @override
  ConsumerState<_AddField> createState() => _AddFieldState();
}

class _AddFieldState extends ConsumerState<_AddField> {
  TextEditingController? _text;

  Future<void> _add(String name, {String? key}) async {
    final n = name.trim();
    if (n.isEmpty) return;
    // Typed exactly like a pantry item: it is that item.
    final match = key ?? widget.pantry.where((i) => i.name.toLowerCase() == n.toLowerCase()).firstOrNull?.key;
    final id = await ref.read(shoppingServiceProvider).add(n, key: match);
    _text?.clear();
    if (id == null && mounted) showInfo(context, '$n is already on the list');
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Ingredient>(
      displayStringForOption: (i) => i.name,
      optionsBuilder: (v) {
        final q = v.text.trim().toLowerCase();
        if (q.length < 2) return const Iterable<Ingredient>.empty();
        return widget.pantry.where((i) => i.name.toLowerCase().contains(q)).take(5);
      },
      onSelected: (i) => _add(i.name, key: i.key),
      fieldViewBuilder: (context, controller, focus, onSubmit) {
        _text = controller;
        return TextField(
          controller: controller,
          focusNode: focus,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Add to the list',
            prefixIcon: const Icon(Icons.add),
            suffixIcon: IconButton(
              tooltip: 'Add',
              icon: const Icon(Icons.keyboard_return),
              onPressed: () => _add(controller.text),
            ),
          ),
          onSubmitted: (v) => _add(v),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);
  final String title;

  static Widget text(BuildContext context, String title) => Text(
    title.toUpperCase(),
    style: context.text.labelMedium?.copyWith(letterSpacing: 0.8, color: context.scheme.onSurfaceVariant),
  );

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 6), child: text(context, title));
}
