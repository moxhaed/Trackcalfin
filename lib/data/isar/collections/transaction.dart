import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';

part 'transaction.g.dart';

/// A committed money movement. Drafts live in [ScanJob].
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime occurredAt = DateTime.now();

  @Enumerated(EnumType.name)
  TxSource source = TxSource.manual;

  String? merchant;

  /// Grand total paid (== sum of lines after adjustment allocation).
  int totalMinor = 0;

  String currency = 'EUR';

  /// Largest category by amount, for list icons and filters.
  @Index()
  @Enumerated(EnumType.name)
  SpendCategory primaryCategory = SpendCategory.groceries;

  /// Every transaction has at least one line; dashboards sum lines.
  List<LineItem> lines = [];

  int? scanJobId;
  String? note;

  /// Set when the receipt was in another currency. [totalMinor] and the lines
  /// are always in the home currency; these keep what was printed.
  String? originalCurrency;
  int? originalTotalMinor;
  double? fxRate;
  DateTime createdAt = DateTime.now();
}

@embedded
class LineItem {
  String rawText = '';
  String name = '';

  @Enumerated(EnumType.name)
  LineType lineType = LineType.product;

  @Enumerated(EnumType.name)
  SpendCategory category = SpendCategory.groceries;

  /// Net of discounts, including allocated basket adjustments.
  int totalMinor = 0;

  /// Set when the line added to stock: deleting the transaction takes [qtyBase] back out.
  int? ingredientId;

  /// The pantry item the line is, set for every grocery line that maps to one (stocked or
  /// not), so prices can be compared between stores.
  String? ingredientKey;

  /// Quantity added to stock, in the ingredient's base unit.
  double? qtyBase;

  /// Quantity on the line, in the ingredient's base unit, whether or not it was stocked.
  /// Prices per unit are worked out from it; older lines only have [qtyBase].
  double? qtyBought;

  /// The unit of [qtyBought]: the item's base unit when it was bought. A price in another
  /// unit (the item was switched from ml to cans since) isn't compared.
  @Enumerated(EnumType.name)
  BaseUnit? unit;

  /// The exact product: brand, name, variant and pack size ("Barilla Spaghetti n.5, 500 g").
  String? product;
}
