import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';

part 'user_profile.g.dart';

/// Singleton (id = 1): goals, cooking profile and habit settings.
@collection
class UserProfile {
  Id id = 1;

  // Locale & money
  String currency = 'EUR';
  int currencyMinorDigits = 2;
  String country = 'DE';
  String outputLanguage = 'en';
  int weekStartsOn = DateTime.monday;
  int dayRolloverHour = 4;

  // Goals (Vibe Check)
  int monthlyFoodBudgetMinor = 30000;
  List<CategoryLimit> monthlyCategoryLimits = [];
  double dailyKcalTarget = 2200;
  double dailyProteinTargetG = 140;

  /// Per-portion target = daily / mealsPerDay.
  int mealsPerDay = 3;
  int targetCostPerPortionMinor = 300;

  // Cooking profile, injected into prompts B and C
  List<String> diet = [];
  List<String> allergies = [];
  List<String> dislikes = [];
  List<String> cuisinesLiked = [];
  List<String> equipment = [];
  int maxActiveMinutes = 30;
  int defaultPortions = 3;
  bool autoLogFirstPortion = true;

  // Habit loop
  int dailyPickMinuteOfDay = 450;
  List<int> mealReminderMinutes = [750, 1140];
  bool notificationsEnabled = true;
  bool weeklyRecapEnabled = true;
  bool autoCommitCleanScans = true;

  /// Pantry photos: look shop prices up with Google Search. The user confirms each one.
  bool lookUpPrices = true;

  /// The dashboard's food card: what was eaten, or what was spent. A stored profile without
  /// it reads [FoodBasis.eaten], the first value.
  @Enumerated(EnumType.name)
  FoodBasis foodBasis = FoodBasis.eaten;

  /// Fallback for "saved vs eating out".
  int eatingOutAvgMealMinor = 1500;

  // Parser memory
  List<KeywordCategory> learnedKeywords = [];

  /// Last exchange rate used per foreign currency (offline fallback).
  List<FxMemo> fxMemory = [];

  // AI
  String geminiModel = 'gemini-3.8-flash';

  bool onboardingDone = false;

  /// "system", "light" or "dark".
  String themeMode = 'system';

  /// For data migrations (see Migrations). New profiles start at the current version.
  int schemaVersion = 4;

  int limitFor(SpendCategory c) => monthlyCategoryLimits.where((l) => l.category == c).firstOrNull?.limitMinor ?? 0;
}

@embedded
class CategoryLimit {
  @Enumerated(EnumType.name)
  SpendCategory category = SpendCategory.other;
  int limitMinor = 0;
}

@embedded
class KeywordCategory {
  String keyword = '';

  @Enumerated(EnumType.name)
  SpendCategory category = SpendCategory.other;
}

@embedded
class FxMemo {
  String from = '';
  String to = '';
  double rate = 0;
  DateTime updatedAt = DateTime.now();
}
