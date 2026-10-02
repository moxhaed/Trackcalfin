import 'package:isar_community/isar.dart';

import 'ai_call_log.dart';
import 'cook_session.dart';
import 'daily_log.dart';
import 'food_use.dart';
import 'ingredient.dart';
import 'metric_event.dart';
import 'recipe.dart';
import 'scan_job.dart';
import 'shopping_list_item.dart';
import 'transaction.dart';
import 'user_profile.dart';

export 'ai_call_log.dart';
export 'cook_session.dart';
export 'daily_log.dart';
export 'food_use.dart';
export 'ingredient.dart';
export 'metric_event.dart';
export 'nutrition.dart';
export 'recipe.dart';
export 'scan_job.dart';
export 'shopping_list_item.dart';
export 'transaction.dart';
export 'user_profile.dart';

const List<CollectionSchema<dynamic>> allSchemas = [
  IngredientSchema,
  TransactionSchema,
  RecipeSchema,
  DailyLogSchema,
  CookSessionSchema,
  ScanJobSchema,
  UserProfileSchema,
  AiCallLogSchema,
  MetricEventSchema,
  FoodUseSchema,
  ShoppingListItemSchema,
];
