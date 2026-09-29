import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';

part 'transaction.g.dart';

/// A committed money movement. Drafts live in [ScanJob].
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime occurredAt;

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

  /// Set when the line was added to stock.
  int? ingredientId;
  String? ingredientKey;

  /// Quantity added to stock, in the ingredient's base unit.
  double? qtyBase;
}
