import 'dart:math' as math;

import '../../core/day_clock.dart';
import '../../core/enums.dart';
import '../isar/collections/cook_session.dart';
import '../isar/collections/ingredient.dart';
import '../isar/collections/recipe.dart';
import '../isar/collections/scan_job.dart';
import '../isar/collections/user_profile.dart';
import '../../domain/costing.dart';
import 'dto/enum_codec.dart';

/// Builds the JSON input envelopes for prompts A, B and C from Isar data.
class ContextBuilders {
  const ContextBuilders._();

  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static double _round(double v, int digits) {
    final f = math.pow(10, digits);
    return (v * f).round() / f;
  }

  static Map<String, dynamic> receipt({
    required UserProfile profile,
    required List<Ingredient> ingredients,
    required DateTime now,
    String? userHint,
  }) {
    final known = [...ingredients]
      ..sort((a, b) => (b.lastPurchasedAt ?? b.updatedAt).compareTo(a.lastPurchasedAt ?? a.updatedAt));
    return {
      'today': _date(now),
      'currency': profile.currency,
      'minor_unit_digits': profile.currencyMinorDigits,
      'country': profile.country,
      'output_language': profile.outputLanguage,
      'user_hint': userHint,
      'known_ingredients': [
        for (final i in known.take(400)) {'key': i.key, 'name': i.name, 'unit': i.baseUnit.label},
      ],
    };
  }

  static bool _inInventory(Ingredient i) => i.qtyOnHand >= (i.baseUnit == BaseUnit.pc ? 1 : 5);

  static Map<String, dynamic> inventoryItem(Ingredient i, DateTime now) => {
    'key': i.key,
    'name': i.name,
    'qty': i.baseUnit == BaseUnit.pc ? _round(i.qtyOnHand, 1) : i.qtyOnHand.roundToDouble(),
    'unit': i.baseUnit.label,
    'g_per_pc': i.baseUnit == BaseUnit.pc ? i.gramsPerPiece : null,
    'cost_per_unit_minor': _round(i.avgCostPerUnitMinor, 3),
    'kcal_100': _round(i.per100.kcal, 1),
    'protein_100': _round(i.per100.proteinG, 1),
    'carbs_100': _round(i.per100.carbsG, 1),
    'fat_100': _round(i.per100.fatG, 1),
    'days_left': ExpiryEstimator.daysLeft(i, now),
  };

  static List<Map<String, dynamic>> inventory(List<Ingredient> all, DateTime now) {
    final items = all.where(_inInventory).toList()
      ..sort((a, b) {
        final da = ExpiryEstimator.daysLeft(a, now);
        final db = ExpiryEstimator.daysLeft(b, now);
        if (da == null && db == null) return a.name.compareTo(b.name);
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    return [for (final i in items.take(250)) inventoryItem(i, now)];
  }

  static Map<String, dynamic> targets(UserProfile p) {
    final meals = math.max(1, p.mealsPerDay);
    return {
      'kcal': (p.dailyKcalTarget / meals).round(),
      'protein_g': (p.dailyProteinTargetG / meals).round(),
      'max_cost_minor': p.targetCostPerPortionMinor,
    };
  }

  static Map<String, dynamic> profileBlock(UserProfile p) => {
    'diet': p.diet,
    'allergies': p.allergies,
    'dislikes': p.dislikes,
    'cuisines_liked': p.cuisinesLiked,
    'equipment': p.equipment,
    'max_active_minutes': p.maxActiveMinutes,
  };

  static Map<String, dynamic> daily({
    required UserProfile profile,
    required List<Ingredient> ingredients,
    required DateTime now,
    required DateTime forDate,
    required List<String> recentTitles,
    List<String> rejectedToday = const [],
    int? portions,
  }) => {
    'today': _date(forDate),
    'weekday': _weekdays[forDate.weekday - 1],
    'output_language': profile.outputLanguage,
    'currency': profile.currency,
    'minor_unit_digits': profile.currencyMinorDigits,
    'portions': portions ?? profile.defaultPortions,
    'targets_per_portion': targets(profile),
    'profile': profileBlock(profile),
    'inventory': inventory(ingredients, now),
    'recent_recipes': recentTitles.take(20).toList(),
    'rejected_today': rejectedToday,
  };

  static Map<String, dynamic> spontaneous({
    required UserProfile profile,
    required List<Ingredient> ingredients,
    required DateTime now,
    required String request,
  }) => {
    'user_request': request,
    'requested_portions': parsePortions(request),
    'default_portions': profile.defaultPortions,
    'today': _date(now),
    'output_language': profile.outputLanguage,
    'currency': profile.currency,
    'minor_unit_digits': profile.currencyMinorDigits,
    'targets_per_portion': targets(profile),
    'profile': profileBlock(profile),
    'inventory': inventory(ingredients, now),
  };

  static Map<String, dynamic> nutritionEstimate({required UserProfile profile, required List<Ingredient> items}) => {
    'country': profile.country,
    'items': [
      for (final i in items)
        {
          'key': i.key,
          'name': i.name,
          'category': EnumCodec.ingredientCategory.entries.firstWhere((e) => e.value == i.category).key,
          'unit': i.baseUnit.label,
        },
    ],
  };

  static Map<String, dynamic> nutritionLabel(Ingredient i) => {'name': i.name, 'unit': i.baseUnit.label};

  /// Prompt F: pantry-photo lines to price, by id.
  static Map<String, dynamic> priceLookup({
    required UserProfile profile,
    required DateTime now,
    required Map<String, DraftLine> items,
  }) => {
    'today': _date(now),
    'country': profile.country,
    'currency': profile.currency,
    'minor_unit_digits': profile.currencyMinorDigits,
    'output_language': profile.outputLanguage,
    'items': [
      for (final MapEntry(key: id, value: l) in items.entries)
        {'id': id, 'product': l.product, 'name': l.name, 'unit': l.unit.label, 'package_qty': l.packageQty},
    ],
  };

  /// Prompt G: what the user said, with the pantry, fridge and recipes it may refer to.
  static Map<String, dynamic> quickLog({
    required UserProfile profile,
    required DateTime now,
    required List<Ingredient> ingredients,
    required List<CookSession> fridge,
    required List<Recipe> recipes,
    required String said,
  }) {
    String two(int v) => v.toString().padLeft(2, '0');
    final pantry = [...ingredients]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return {
      'now': '${_date(now)}T${two(now.hour)}:${two(now.minute)}',
      'weekday': _weekdays[now.weekday - 1],
      'currency': profile.currency,
      'minor_unit_digits': profile.currencyMinorDigits,
      'country': profile.country,
      'output_language': profile.outputLanguage,
      'pantry': [
        for (final i in pantry)
          {'key': i.key, 'name': i.name, 'unit': i.baseUnit.label, 'on_hand': _round(i.qtyOnHand, 1)},
      ],
      'fridge': [
        for (final s in fridge)
          {
            'batch_id': s.id,
            'title': s.recipeTitle,
            'portions_left': s.portionsRemaining,
            'cooked_on': _date(s.cookedAt),
          },
      ],
      'recipes': [
        for (final r in recipes) {'recipe_id': r.id, 'title': r.title},
      ],
      'said': said,
    };
  }

  static const _words = {'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8};

  /// "for 4", "3 portions", "for two" -> portions; null when not stated.
  static int? parsePortions(String text) {
    final t = text.toLowerCase();
    final m =
        RegExp(r'for\s+(\d+)\b').firstMatch(t) ??
        RegExp(r'(\d+)\s*(?:portions?|servings?|people|persons?)').firstMatch(t);
    if (m != null) return int.tryParse(m.group(1)!);
    final w = RegExp(r'for\s+(one|two|three|four|five|six|seven|eight)\b').firstMatch(t);
    if (w != null) return _words[w.group(1)!];
    return null;
  }

  static int todayKeyFor(DateTime now, UserProfile p) =>
      DayClock(rolloverHour: p.dayRolloverHour, weekStartsOn: p.weekStartsOn).dateKey(now);
}
