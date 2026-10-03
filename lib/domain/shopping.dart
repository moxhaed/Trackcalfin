import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/recipe.dart';
import '../data/isar/collections/shopping_list_item.dart';
import 'feasibility.dart';
import 'price_book.dart';

/// Something the list could use, one tap to add.
class ShoppingSuggestion {
  const ShoppingSuggestion(this.name, this.key, this.reason);
  final String name;
  final String? key;

  /// "running low", "out": why it is suggested.
  final String reason;
}

/// The shopping list's logic, pure Dart: what to suggest, where to buy, how to share it.
class Shopping {
  const Shopping._();

  /// An item out of stock is suggested for this long after it was last bought.
  static const outForDays = 30;

  /// Pantry items to buy again: running low, or out after being bought lately. Items already
  /// on the open list are left out.
  static List<ShoppingSuggestion> suggestions(
    List<Ingredient> pantry,
    List<ShoppingListItem> list, {
    required DateTime now,
  }) {
    final open = list.where((l) => l.doneAt == null);
    final keys = {for (final l in open) ?l.ingredientKey};
    final names = {for (final l in open) l.name.trim().toLowerCase()};
    bool listed(Ingredient i) => keys.contains(i.key) || names.contains(i.name.trim().toLowerCase());
    final out = <ShoppingSuggestion>[];
    for (final i in pantry) {
      if (listed(i)) continue;
      if (i.qtyOnHand <= 0) {
        final bought = i.lastPurchasedAt;
        if (bought != null && now.difference(bought).inDays <= outForDays) {
          out.add(ShoppingSuggestion(i.name, i.key, 'out'));
        }
      } else if (i.isLow) {
        out.add(ShoppingSuggestion(i.name, i.key, 'running low'));
      }
    }
    out.sort((a, b) => a.reason == b.reason ? a.name.compareTo(b.name) : (a.reason == 'out' ? -1 : 1));
    return out;
  }

  /// What [recipe] needs that isn't in the pantry for [f]'s portions: missing items, items
  /// short, and the recipe's own "To buy" list. One line per item.
  static List<ShoppingSuggestion> forRecipe(Recipe recipe, FeasibilityResult f) {
    final out = <ShoppingSuggestion>[];
    final seen = <String>{};
    void add(String name, String? key, String reason) {
      final id = (key ?? name).trim().toLowerCase();
      if (id.isEmpty || !seen.add(id)) return;
      out.add(ShoppingSuggestion(name, key, reason));
    }

    for (final s in f.shortfalls) {
      add(s.ingredient?.name ?? s.item.name, s.ingredient?.key ?? s.item.key, 'short');
    }
    // Missing rows, and rows the pantry doesn't have (a cookbook recipe's tahini).
    for (final name in f.missing) {
      add(name, null, 'missing');
    }
    for (final s in recipe.shoppingList) {
      add(s.name, null, s.reason);
    }
    return out;
  }

  /// The store to buy [key] at: the cheapest one with a price, or the only one known.
  static String? storeFor(String? key, PriceBook book) => key == null ? null : book.pricesFor(key).firstOrNull?.store;

  /// Open lines grouped by the store to buy them at, stores by name, "anywhere" (null) last.
  /// Within a store, in the order they were added.
  static List<(String?, List<ShoppingListItem>)> byStore(Iterable<ShoppingListItem> open, PriceBook book) {
    final groups = <String?, List<ShoppingListItem>>{};
    for (final l in open) {
      groups.putIfAbsent(storeFor(l.ingredientKey, book), () => []).add(l);
    }
    final stores = groups.keys.whereType<String>().toList()..sort();
    return [
      for (final s in stores) (s, groups[s]!..sort((a, b) => a.addedAt.compareTo(b.addedAt))),
      if (groups.containsKey(null)) (null, groups[null]!..sort((a, b) => a.addedAt.compareTo(b.addedAt))),
    ];
  }

  /// The list as plain text, to send: by store, with amounts.
  static String asText(Iterable<ShoppingListItem> open, PriceBook book) {
    final groups = byStore(open, book);
    final lines = <String>['Shopping list'];
    for (final (store, items) in groups) {
      if (groups.length > 1 || store != null) lines.add('\n${store ?? 'Anywhere'}');
      for (final l in items) {
        lines.add('- ${l.name}${l.amount == null || l.amount!.isEmpty ? '' : ' (${l.amount})'}');
      }
    }
    return lines.join('\n');
  }
}
