import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/costing.dart';
import '../domain/quick_text_parser.dart';
import 'clock.dart';

/// Writes money movements.
class LedgerService {
  LedgerService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  Future<int> logQuickExpense({
    required int amountMinor,
    required SpendCategory category,
    String? note,
    String? merchant,
    TxSource source = TxSource.manual,
    DateTime? at,
    String currency = 'EUR',
    String? learnKeyword,
  }) async {
    final when = at ?? now();
    final tx = Transaction()
      ..occurredAt = when
      ..source = source
      ..merchant = merchant
      ..note = note
      ..currency = currency
      ..totalMinor = amountMinor
      ..primaryCategory = category
      ..createdAt = now()
      ..lines = [
        LineItem()
          ..name = (note?.isNotEmpty ?? false) ? note! : category.label
          ..category = category
          ..totalMinor = amountMinor,
      ];
    return isar.writeTxn(() async {
      final id = await isar.transactions.put(tx);
      if (learnKeyword != null && learnKeyword.isNotEmpty) {
        final p = await isar.userProfiles.get(1);
        if (p != null) {
          p.learnedKeywords = QuickTextParser.learn(p.learnedKeywords, learnKeyword, category);
          await isar.userProfiles.put(p);
        }
      }
      return id;
    });
  }

  /// Buys [qty] of an existing ingredient by hand: ledger + stock in one txn.
  Future<int> applyManualPurchase({
    required int ingredientId,
    required double qty,
    required int totalMinor,
    String? merchant,
    DateTime? at,
    String currency = 'EUR',
  }) async {
    final when = at ?? now();
    return isar.writeTxn(() async {
      final ing = await isar.ingredients.get(ingredientId);
      if (ing == null) throw StateError('Ingredient $ingredientId not found');
      CostingEngine.applyPurchase(ing, qtyAdded: qty, lineTotalMinor: totalMinor, at: when);
      await isar.ingredients.put(ing);
      final tx = Transaction()
        ..occurredAt = when
        ..source = TxSource.manual
        ..merchant = merchant
        ..currency = currency
        ..totalMinor = totalMinor
        ..primaryCategory = SpendCategory.groceries
        ..lines = [
          LineItem()
            ..name = ing.name
            ..category = SpendCategory.groceries
            ..totalMinor = totalMinor
            ..ingredientId = ing.id
            ..ingredientKey = ing.key
            ..qtyBase = qty,
        ];
      return isar.transactions.put(tx);
    });
  }

  /// Deletes a transaction and takes back the stock it added. Returns it for undo.
  Future<Transaction?> delete(int id) async {
    return isar.writeTxn(() async {
      final tx = await isar.transactions.get(id);
      if (tx == null) return null;
      for (final l in tx.lines) {
        if (l.ingredientId == null || l.qtyBase == null) continue;
        final ing = await isar.ingredients.get(l.ingredientId!);
        if (ing == null) continue;
        ing.qtyOnHand = (ing.qtyOnHand - l.qtyBase!).clamp(0, double.infinity).toDouble();
        ExpiryEstimator.onDeplete(ing);
        await isar.ingredients.put(ing);
      }
      await isar.transactions.delete(id);
      return tx;
    });
  }

  /// Undo for [delete]: puts the transaction and its stock back.
  Future<void> restore(Transaction tx) async {
    await isar.writeTxn(() async {
      for (final l in tx.lines) {
        if (l.ingredientId == null || l.qtyBase == null) continue;
        final ing = await isar.ingredients.get(l.ingredientId!);
        if (ing == null) continue;
        ing.qtyOnHand += l.qtyBase!;
        await isar.ingredients.put(ing);
      }
      await isar.transactions.put(tx);
    });
  }

  /// Edits the header fields of a transaction (amount only for single-line ones).
  Future<void> update(
    int id, {
    int? amountMinor,
    SpendCategory? category,
    String? merchant,
    String? note,
    DateTime? at,
  }) async {
    await isar.writeTxn(() async {
      final tx = await isar.transactions.get(id);
      if (tx == null) return;
      if (at != null) tx.occurredAt = at;
      if (merchant != null) tx.merchant = merchant.isEmpty ? null : merchant;
      if (note != null) tx.note = note.isEmpty ? null : note;
      if (tx.lines.length == 1) {
        final line = tx.lines.first;
        if (amountMinor != null) {
          line.totalMinor = amountMinor;
          tx.totalMinor = amountMinor;
        }
        if (category != null) {
          line.category = category;
          tx.primaryCategory = category;
        }
        if (note != null && note.isNotEmpty) line.name = note;
        tx.lines = [line];
      } else if (category != null) {
        tx.primaryCategory = category;
      }
      await isar.transactions.put(tx);
    });
  }
}
