import 'package:isar_community/isar.dart';

part 'shopping_list_item.g.dart';

/// One line of the shopping list: a pantry item ([ingredientKey]) or anything typed.
@collection
class ShoppingListItem {
  Id id = Isar.autoIncrement;

  String name = '';

  /// The pantry item, when it is one: its cheapest store shows, and a filed receipt with
  /// it ticks the line off.
  @Index()
  String? ingredientKey;

  /// How much, as said: "2 l", "6", "500 g". Optional.
  String? amount;

  /// Ticked off: bought by hand, or found on a filed receipt.
  DateTime? doneAt;

  DateTime addedAt = DateTime.now();
}
