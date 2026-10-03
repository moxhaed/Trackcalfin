import 'dart:math' as math;

import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../data/isar/collections/schemas.dart';
import '../core/enums.dart';
import '../domain/costing.dart';
import '../domain/used_up.dart';
import 'clock.dart';
import 'recipe_service.dart';

/// Hand edits to the pantry.
class PantryService {
  PantryService(this.isar, {Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final Now now;

  /// "Greek yogurt 10%" -> "greek_yogurt".
  static String slugify(String name) {
    final s = name
        .toLowerCase()
        .replaceAll(RegExp(r'[äàáâ]'), 'a')
        .replaceAll(RegExp(r'[öòóô]'), 'o')
        .replaceAll(RegExp(r'[üùúû]'), 'u')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final words = s.split('_').where((w) => w.isNotEmpty && !RegExp(r'^\d+$').hasMatch(w)).take(4);
    final out = words.join('_');
    if (out.isEmpty) return 'item';
    return RegExp(r'^[a-z]').hasMatch(out) ? out : 'i_$out';
  }

  Future<String> uniqueKey(String base) async {
    var key = base;
    var n = 2;
    while (await isar.ingredients.getByKey(key) != null) {
      key = '${base}_$n';
      n++;
    }
    return key;
  }

  /// Creates or updates an ingredient. New ones get a unique key and count as verified
  /// (and as counted, when they come with a quantity). Updates refresh the numbers of
  /// recipes that use it.
  Future<int> upsert(Ingredient ing) async {
    final t = now();
    return isar.writeTxn(() async {
      final isNew = ing.id == Isar.autoIncrement || ing.key.isEmpty;
      if (isNew) {
        ing.key = await uniqueKey(ing.key.isEmpty ? slugify(ing.name) : ing.key);
        ing.lastVerifiedAt ??= t;
        if (ing.qtyOnHand > 0) ing.lastCountedAt ??= t;
        if (ing.qtyOnHand > 0 && ing.expiresAt == null && ing.shelfLifeDays > 0) {
          ing.lastPurchasedAt ??= t;
          ing.lastPurchaseQty = ing.qtyOnHand;
          ing.expiresAt = t.add(Duration(days: ing.shelfLifeDays));
        }
      }
      ing.updatedAt = t;
      final id = await isar.ingredients.put(ing);
      if (!isNew) await RecipeService.refreshUsing(isar, {id});
      return id;
    });
  }

  /// A count that goes back up this soon after one that found less (Undo, a mis-tap on −)
  /// takes back what that count recorded as used.
  static const undoWindow = Duration(minutes: 2);

  /// Sets the on-hand quantity (Quick Check, adjust). Counts as verified and counted. Less
  /// than the pantry had means the rest was used up without a logged meal: it is recorded
  /// as eaten (or [kind]) since the last count or purchase. Returns that use's id.
  Future<int?> setQuantity(int id, double qty, {UseKind kind = UseKind.eaten}) async {
    final t = now();
    return isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing == null) return null;
      final before = ing.qtyOnHand;
      if (qty > before) await _takeBack(ing.key, qty - before, t);
      final use = UsedUp.fromCount(ing, before: before, after: qty, at: t, kind: kind);
      ExpiryEstimator.onCount(ing, qty, t);
      await isar.ingredients.put(ing);
      return use == null ? null : isar.foodUses.put(use);
    });
  }

  /// Shrinks the uses counts of [key] recorded in the last [undoWindow] by [qty], newest
  /// first, deleting those that reach nothing.
  Future<void> _takeBack(String key, double qty, DateTime t) async {
    final recent = await isar.foodUses
        .filter()
        .ingredientKeyEqualTo(key)
        .transactionIdIsNull()
        .createdAtGreaterThan(t.subtract(undoWindow))
        .findAll();
    recent.sort((a, b) => b.createdAt == a.createdAt ? b.id.compareTo(a.id) : b.createdAt.compareTo(a.createdAt));
    var left = qty;
    for (final u in recent) {
      if (left <= 1e-9) break;
      if (u.qtyBase <= left + 1e-9) {
        left -= u.qtyBase;
        await isar.foodUses.delete(u.id);
      } else {
        final keep = u.qtyBase - left;
        u
          ..costMinor = (u.costMinor * keep / u.qtyBase).round()
          ..qtyBase = keep;
        left = 0;
        await isar.foodUses.put(u);
      }
    }
  }

  Future<int?> markOut(int id, {UseKind kind = UseKind.eaten}) => setQuantity(id, 0, kind: kind);

  /// What the last count of item [id] found gone, while it can be taken back (its sheet shows it).
  Future<CountedUse?> lastCount(int id) async {
    final ing = await isar.ingredients.get(id);
    if (ing == null) return null;
    final uses = await isar.foodUses
        .filter()
        .ingredientKeyEqualTo(ing.key)
        .transactionIdIsNull()
        .createdAtGreaterThan(DayClock.addDays(now(), -UsedUp.takeBackDays))
        .findAll();
    return UsedUp.lastCount(ing, uses, now());
  }

  /// "I'm not out after all", at any time later: the use count [useId] recorded is deleted, so
  /// it no longer counts as eaten anywhere. When the item wasn't counted since, what the count
  /// found gone is back on hand as it was ([UsedUp.putBack]); otherwise the later count holds
  /// the amount. Returns what [redoCount] needs for Undo.
  Future<UndoneCount?> undoCount(int useId) async {
    final t = now();
    return isar.writeTxn(() async {
      final use = await isar.foodUses.get(useId);
      if (use == null || use.transactionId != null) return null;
      final ing = await isar.ingredients.getByKey(use.ingredientKey);
      final putsBack = ing != null && !UsedUp.countedSince(ing, use);
      final undone = UndoneCount(
        use,
        ingredientId: ing?.id,
        putBack: putsBack,
        expiresAt: ing?.expiresAt,
        lastCountedAt: ing?.lastCountedAt,
        updatedAt: ing?.updatedAt ?? t,
      );
      if (putsBack) {
        UsedUp.putBack(ing, use, t);
        await isar.ingredients.put(ing);
      }
      await isar.foodUses.delete(useId);
      return undone;
    });
  }

  /// Undo for [undoCount]: the use is back, and the item as it was before.
  Future<void> redoCount(UndoneCount undone) async {
    await isar.writeTxn(() async {
      final use = undone.use;
      await isar.foodUses.put(use);
      final id = undone.ingredientId;
      final ing = id == null ? null : await isar.ingredients.get(id);
      if (ing == null || !undone.putBack) return;
      ing
        ..qtyOnHand = math.max(0.0, ing.qtyOnHand - use.qtyBase)
        ..expiresAt = undone.expiresAt
        ..lastCountedAt = undone.lastCountedAt
        ..updatedAt = undone.updatedAt;
      await isar.ingredients.put(ing);
    });
  }

  /// "Thrown away, not eaten" after a count: the use stops counting as eaten.
  Future<void> setUseKind(int useId, UseKind kind) async {
    await isar.writeTxn(() async {
      final u = await isar.foodUses.get(useId);
      if (u == null) return;
      await isar.foodUses.put(u..kind = kind);
    });
  }

  /// "Looks right" / "Still have it": the quantity was checked by looking.
  Future<void> verify(int id) async {
    final t = now();
    await isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing == null) return;
      ing
        ..lastVerifiedAt = t
        ..lastCountedAt = t;
      await isar.ingredients.put(ing);
    });
  }

  Future<Ingredient?> delete(int id) async {
    return isar.writeTxn(() async {
      final ing = await isar.ingredients.get(id);
      if (ing != null) await isar.ingredients.delete(id);
      return ing;
    });
  }

  Future<void> restore(Ingredient ing) async {
    await isar.writeTxn(() => isar.ingredients.put(ing));
  }
}

/// What [PantryService.undoCount] took back, to put it back on Undo.
class UndoneCount {
  UndoneCount(
    this.use, {
    required this.ingredientId,
    required this.putBack,
    required this.expiresAt,
    required this.lastCountedAt,
    required this.updatedAt,
  });

  /// The deleted use, with its id.
  final FoodUse use;
  final int? ingredientId;

  /// The amount went back on hand.
  final bool putBack;

  /// The item before it was undone (its amount goes back down by the use).
  final DateTime? expiresAt;
  final DateTime? lastCountedAt;
  final DateTime updatedAt;
}
