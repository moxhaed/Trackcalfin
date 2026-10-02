import 'package:isar_community/isar.dart';

import '../data/isar/collections/schemas.dart';
import 'clock.dart';

/// The shopping list: adding, ticking off, removing. Each call is one write transaction.
class ShoppingService {
  ShoppingService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  /// Adds a line, unless the same item is already on the open list. Returns the new line's
  /// id, or null when it was already there.
  Future<int?> add(String name, {String? key, String? amount}) async {
    final ids = await addAll([(name.trim(), key)], amount: amount);
    return ids.firstOrNull;
  }

  /// Adds the lines not on the open list yet. Returns the ids added (Undo: [removeAll]).
  Future<List<int>> addAll(Iterable<(String, String?)> items, {String? amount}) {
    final t = now();
    return isar.writeTxn(() async {
      final open = await isar.shoppingListItems.filter().doneAtIsNull().findAll();
      final keys = {for (final l in open) ?l.ingredientKey};
      final names = {for (final l in open) l.name.trim().toLowerCase()};
      final added = <ShoppingListItem>[];
      for (final (name, key) in items) {
        final n = name.trim();
        if (n.isEmpty || (key != null && keys.contains(key)) || names.contains(n.toLowerCase())) continue;
        added.add(
          ShoppingListItem()
            ..name = n
            ..ingredientKey = key
            ..amount = amount == null || amount.trim().isEmpty ? null : amount.trim()
            ..addedAt = t,
        );
        if (key != null) keys.add(key);
        names.add(n.toLowerCase());
      }
      return isar.shoppingListItems.putAll(added);
    });
  }

  /// Ticks a line off, or back on.
  Future<void> toggle(int id) async {
    final t = now();
    await isar.writeTxn(() async {
      final l = await isar.shoppingListItems.get(id);
      if (l == null) return;
      await isar.shoppingListItems.put(l..doneAt = l.doneAt == null ? t : null);
    });
  }

  Future<void> rename(int id, String name, {String? amount}) async {
    await isar.writeTxn(() async {
      final l = await isar.shoppingListItems.get(id);
      if (l == null || name.trim().isEmpty) return;
      await isar.shoppingListItems.put(
        l
          ..name = name.trim()
          ..amount = amount == null || amount.trim().isEmpty ? null : amount.trim(),
      );
    });
  }

  /// Removes lines; returns them for Undo ([restore]).
  Future<List<ShoppingListItem>> removeAll(List<int> ids) {
    return isar.writeTxn(() async {
      final gone = (await isar.shoppingListItems.getAll(ids)).whereType<ShoppingListItem>().toList();
      await isar.shoppingListItems.deleteAll(ids);
      return gone;
    });
  }

  /// Removes everything ticked off; returns it for Undo.
  Future<List<ShoppingListItem>> clearDone() async {
    final done = await isar.shoppingListItems.filter().doneAtIsNotNull().findAll();
    return removeAll([for (final l in done) l.id]);
  }

  Future<void> restore(List<ShoppingListItem> items) async {
    await isar.writeTxn(() => isar.shoppingListItems.putAll(items));
  }

  /// Inside a write transaction (filing a receipt, a purchase): the open lines for [keys]
  /// are ticked off as bought. Returns their ids, so an undo can put them back.
  static Future<List<int>> tickOff(Isar isar, Iterable<String> keys, DateTime at) async {
    final wanted = keys.toSet();
    if (wanted.isEmpty) return const [];
    final open = await isar.shoppingListItems.filter().doneAtIsNull().ingredientKeyIsNotNull().findAll();
    final hit = [
      for (final l in open)
        if (wanted.contains(l.ingredientKey)) l..doneAt = at,
    ];
    await isar.shoppingListItems.putAll(hit);
    return [for (final l in hit) l.id];
  }

  /// Undo for [tickOff], inside a write transaction.
  static Future<void> untick(Isar isar, List<int> ids) async {
    final lines = (await isar.shoppingListItems.getAll(ids)).whereType<ShoppingListItem>().toList();
    await isar.shoppingListItems.putAll([for (final l in lines) l..doneAt = null]);
  }
}
