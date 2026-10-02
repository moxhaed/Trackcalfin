import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';

part 'food_use.g.dart';

/// Food used up without a logged meal: what a count, or an old receipt's "What's left?",
/// found gone. It counts as eaten (unless thrown away), spread evenly over the days between
/// [from] and [to], so the weeks it went in show it.
@collection
class FoodUse {
  Id id = Isar.autoIncrement;

  /// The purchase, or the last time the item was counted.
  DateTime from = DateTime.now();

  /// When it was found gone.
  @Index()
  DateTime to = DateTime.now();

  String ingredientKey = '';
  String name = '';

  /// In the ingredient's base unit.
  double qtyBase = 0;

  /// What it cost, at the price paid (or the average cost).
  int costMinor = 0;

  @Enumerated(EnumType.name)
  UseKind kind = UseKind.eaten;

  /// The old receipt it came from: deleting the receipt deletes this too.
  @Index()
  int? transactionId;

  DateTime createdAt = DateTime.now();
}
