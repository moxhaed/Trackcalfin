import 'dart:math' as math;

import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/costing.dart';
import '../domain/quick_text_parser.dart';
import 'clock.dart';
import 'recipe_service.dart';
import 'shopping_service.dart';

/// A deleted transaction, with the used-up food its old receipt recorded, for undo.
class DeletedTransaction {
  DeletedTransaction(this.transaction, this.uses, {this.taken = const {}, this.before = const {}});
  final Transaction transaction;
  final List<FoodUse> uses;

  /// What the delete took out of each ingredient's stock (by id): less than the line added
  /// when some of it was used since.
  final Map<int, double> taken;

  /// Each ingredient's price and expiry before the delete, put back by undo.
  final Map<int, ({double avgCost, bool estimate, DateTime? expiresAt})> before;

  int get totalMinor => transaction.totalMinor;
}

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
      await ShoppingService.tickOff(isar, [ing.key], now());
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
            ..qtyBase = qty
            ..qtyBought = qty
            ..unit = ing.baseUnit,
        ];
      return isar.transactions.put(tx);
    });
  }

  /// Deletes a transaction, takes back the stock it added and drops the used-up food its old
  /// receipt recorded. Returns it all for undo.
  Future<DeletedTransaction?> delete(int id) async {
    return isar.writeTxn(() async {
      final tx = await isar.transactions.get(id);
      if (tx == null) return null;
      final uses = await isar.foodUses.filter().transactionIdEqualTo(id).findAll();
      await isar.foodUses.deleteAll([for (final u in uses) u.id]);
      final taken = <int, double>{};
      final before = <int, ({double avgCost, bool estimate, DateTime? expiresAt})>{};
      for (final l in tx.lines) {
        if (l.ingredientId == null || l.qtyBase == null) continue;
        final ing = await isar.ingredients.get(l.ingredientId!);
        if (ing == null) continue;
        before[ing.id] ??= (avgCost: ing.avgCostPerUnitMinor, estimate: ing.costIsEstimate, expiresAt: ing.expiresAt);
        final had = ing.qtyOnHand;
        final out = math.min(had, l.qtyBase!);
        final left = had - out;
        // What is left no longer carries this purchase's price (§3.3 in reverse). Down to
        // nothing, the average stays as the last known price.
        if (l.totalMinor > 0 && l.qtyBase! > 0 && left > 1e-9 && !ing.costIsEstimate) {
          final avg = (had * ing.avgCostPerUnitMinor - out * l.totalMinor / l.qtyBase!) / left;
          if (avg > 0) ing.avgCostPerUnitMinor = avg;
        }
        ing.qtyOnHand = left < 0 ? 0 : left;
        ExpiryEstimator.onDeplete(ing);
        taken[ing.id] = (taken[ing.id] ?? 0) + out;
        await isar.ingredients.put(ing);
      }
      await isar.transactions.delete(id);
      await RecipeService.refreshUsing(isar, taken.keys.toSet());
      return DeletedTransaction(tx, uses, taken: taken, before: before);
    });
  }

  /// Undo for [delete]: puts the transaction, its stock and its used-up food back.
  Future<void> restore(DeletedTransaction deleted) async {
    final tx = deleted.transaction;
    await isar.writeTxn(() async {
      await isar.foodUses.putAll(deleted.uses);
      for (final MapEntry(key: id, value: qty) in deleted.taken.entries) {
        final ing = await isar.ingredients.get(id);
        if (ing == null) continue;
        ing.qtyOnHand += qty;
        final was = deleted.before[id];
        if (was != null) {
          ing
            ..avgCostPerUnitMinor = was.avgCost
            ..costIsEstimate = was.estimate
            ..expiresAt = was.expiresAt;
        }
        await isar.ingredients.put(ing);
      }
      await isar.transactions.put(tx);
      await RecipeService.refreshUsing(isar, deleted.taken.keys.toSet());
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
