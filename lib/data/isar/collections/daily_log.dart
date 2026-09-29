import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';
import 'nutrition.dart';

part 'daily_log.g.dart';

/// Intake for one day. One document per dateKey.
@collection
class DailyLog {
  Id id = Isar.autoIncrement;

  /// yyyymmdd in local time with the rollover hour applied (DayClock.dateKey).
  @Index(unique: true, replace: false)
  late int dateKey;

  List<MealEntry> meals = [];

  // Denormalized: ALWAYS recomputed from [meals] in the same write txn.
  Nutrition totals = Nutrition();
  int foodCostMinor = 0;
  int mealsCount = 0;

  DateTime updatedAt = DateTime.now();

  void recomputeTotals() {
    totals = Nutrition.sum(meals.map((m) => m.nutrition));
    foodCostMinor = meals.fold(0, (a, m) => a + m.costMinor);
    mealsCount = meals.length;
    updatedAt = DateTime.now();
  }
}

@embedded
class MealEntry {
  /// microsecondsSinceEpoch as string; for undo / delete.
  String entryId = '';
  DateTime eatenAt = DateTime.now();

  @Enumerated(EnumType.name)
  MealSource source = MealSource.fridge;

  int? cookSessionId;
  int? recipeId;
  String title = '';
  double portions = 1;

  /// Snapshot for [portions].
  Nutrition nutrition = Nutrition();
  int costMinor = 0;
}
