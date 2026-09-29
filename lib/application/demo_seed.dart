import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/nutrition.dart';
import '../domain/stock_index.dart';
import 'profile_service.dart';

/// Realistic sample data for screenshots and trying the app.
/// Only compiled in with `--dart-define=DEMO=true`.
class DemoSeed {
  const DemoSeed._();

  static const enabled = bool.fromEnvironment('DEMO');

  static Future<void> run(Isar isar, {DateTime? now}) async {
    if (await isar.ingredients.count() > 0) return;
    final t = now ?? DateTime.now();
    final profile = ProfileService.defaults()
      ..onboardingDone = true
      ..themeMode = const String.fromEnvironment('THEME', defaultValue: 'system')
      ..monthlyFoodBudgetMinor = 30000
      ..dailyKcalTarget = 2200
      ..dailyProteinTargetG = 140
      ..cuisinesLiked = ['mediterranean', 'indian']
      ..equipment = ['oven', 'air_fryer'];
    final clock = ProfileService.clockFor(profile);

    Ingredient ing(
      String key,
      String name,
      IngredientCategory cat,
      double qty,
      double cost,
      List<double> n, {
      BaseUnit unit = BaseUnit.g,
      double? gpp,
      int shelf = 7,
      int age = 1,
      bool staple = false,
    }) => Ingredient()
      ..key = key
      ..name = name
      ..category = cat
      ..baseUnit = unit
      ..gramsPerPiece = gpp
      ..qtyOnHand = qty
      ..avgCostPerUnitMinor = cost
      ..per100 = Nutrition(kcal: n[0], proteinG: n[1], carbsG: n[2], fatG: n[3], fiberG: n.length > 4 ? n[4] : 0)
      ..shelfLifeDays = shelf
      ..trackingMode = staple ? TrackingMode.staple : TrackingMode.exact
      ..lastPurchasedAt = t.subtract(Duration(days: age))
      ..lastPurchaseQty = qty
      ..expiresAt = staple ? null : t.subtract(Duration(days: age)).add(Duration(days: shelf))
      ..lastVerifiedAt = age > 20 ? null : t.subtract(Duration(days: age))
      ..aliases = [];

    final pantry = [
      ing(
        'chicken_breast',
        'Chicken breast',
        IngredientCategory.meatFish,
        650,
        0.998,
        [110, 23.1, 0, 1.9],
        shelf: 3,
        age: 1,
      ),
      ing('spinach', 'Spinach', IngredientCategory.produce, 210, 0.796, [23, 2.9, 3.6, 0.4, 2.2], shelf: 3, age: 2),
      ing(
        'white_rice',
        'White rice',
        IngredientCategory.grainsPasta,
        1600,
        0.2,
        [360, 7.1, 79, 0.7, 1],
        shelf: 365,
        age: 12,
      ),
      ing(
        'dry_pasta',
        'Spaghetti',
        IngredientCategory.grainsPasta,
        900,
        0.18,
        [360, 12.5, 72, 1.5, 3],
        shelf: 365,
        age: 9,
      ),
      ing(
        'egg',
        'Eggs',
        IngredientCategory.dairyEggs,
        7,
        30,
        [143, 12.6, 0.7, 9.5],
        unit: BaseUnit.pc,
        gpp: 55,
        shelf: 21,
        age: 5,
      ),
      ing(
        'greek_yogurt',
        'Greek-style yogurt',
        IngredientCategory.dairyEggs,
        450,
        0.358,
        [124, 4.5, 4, 10],
        shelf: 14,
        age: 3,
      ),
      ing(
        'canned_chickpeas',
        'Chickpeas (canned)',
        IngredientCategory.cannedJarred,
        800,
        0.3,
        [120, 7, 16, 2.5, 6],
        shelf: 365,
        age: 20,
      ),
      ing(
        'canned_tomatoes',
        'Chopped tomatoes',
        IngredientCategory.cannedJarred,
        1200,
        0.19,
        [21, 1.1, 3.5, 0.2, 1],
        shelf: 365,
        age: 20,
      ),
      ing('onion', 'Onions', IngredientCategory.produce, 600, 0.25, [40, 1.1, 9.3, 0.1, 1.7], shelf: 30, age: 6),
      ing(
        'bell_pepper',
        'Red bell pepper',
        IngredientCategory.produce,
        2,
        70,
        [31, 1, 6, 0.3, 2.1],
        unit: BaseUnit.pc,
        gpp: 150,
        shelf: 7,
        age: 4,
      ),
      ing('grana_padano', 'Grana Padano', IngredientCategory.dairyEggs, 180, 1.6, [398, 33, 0, 29], shelf: 60, age: 10),
      ing('bacon', 'Bacon', IngredientCategory.meatFish, 200, 1.245, [400, 14, 1, 38], shelf: 10, age: 4),
      ing(
        'red_lentils',
        'Red lentils',
        IngredientCategory.legumesNuts,
        700,
        0.35,
        [350, 24, 55, 1.5, 11],
        shelf: 365,
        age: 25,
      ),
      ing(
        'oat_flakes',
        'Oat flakes',
        IngredientCategory.grainsPasta,
        650,
        0.15,
        [370, 13, 59, 7, 10],
        shelf: 300,
        age: 15,
      ),
      ing(
        'banana',
        'Bananas',
        IngredientCategory.produce,
        3,
        25,
        [89, 1.1, 23, 0.3, 2.6],
        unit: BaseUnit.pc,
        gpp: 120,
        shelf: 5,
        age: 3,
      ),
      ing(
        'whole_milk',
        'Whole milk',
        IngredientCategory.dairyEggs,
        150,
        0.109,
        [64, 3.4, 4.8, 3.5],
        unit: BaseUnit.ml,
        shelf: 7,
        age: 5,
      )..lowStockThreshold = 250,
      ing(
        'frozen_peas',
        'Frozen peas',
        IngredientCategory.frozen,
        400,
        0.25,
        [81, 5.4, 14, 0.4, 5],
        shelf: 180,
        age: 30,
      ),
      ing(
        'olive_oil',
        'Olive oil',
        IngredientCategory.oilsFats,
        500,
        0.9,
        [814, 0, 0, 92],
        unit: BaseUnit.ml,
        staple: true,
        shelf: 365,
      ),
      ing('salt', 'Salt', IngredientCategory.spicesCondiments, 0, 0, [0, 0, 0, 0], staple: true, shelf: 365),
      ing(
        'black_pepper',
        'Black pepper',
        IngredientCategory.spicesCondiments,
        0,
        0,
        [251, 10, 64, 3],
        staple: true,
        shelf: 365,
      ),
      ing(
        'garlic_powder',
        'Garlic powder',
        IngredientCategory.spicesCondiments,
        0,
        0,
        [331, 17, 73, 0.7],
        staple: true,
        shelf: 365,
      ),
      ing('cumin', 'Cumin', IngredientCategory.spicesCondiments, 0, 0, [375, 18, 44, 22], staple: true, shelf: 365),
    ];

    RecipeIngredient ri(
      String key,
      String name,
      double q, {
      BaseUnit unit = BaseUnit.g,
      IngredientRole role = IngredientRole.stock,
    }) => RecipeIngredient()
      ..key = key
      ..name = name
      ..qtyPerPortion = q
      ..unit = unit
      ..role = role;

    final todayKey = clock.dateKey(t);
    final recipes = [
      Recipe()
        ..title = 'Garlic chicken & spinach rice bowls'
        ..hook = 'Uses your spinach before it wilts · 51 g protein'
        ..why = 'Spinach has 1 day left and the chicken 2; rice keeps the portion cheap.'
        ..cuisine = 'mediterranean'
        ..origin = RecipeOrigin.dailyAuto
        ..status = RecipeStatus.suggested
        ..suggestedForDateKey = todayKey
        ..defaultPortions = 3
        ..prepMinutes = 10
        ..cookMinutes = 20
        ..activeMinutes = 20
        ..fridgeLifeDays = 4
        ..tags = ['high_protein', 'meal_prep']
        ..ingredients = [
          ri('chicken_breast', 'Chicken breast', 180),
          ri('white_rice', 'White rice', 100),
          ri('spinach', 'Spinach', 70),
          ri('olive_oil', 'Olive oil', 7, unit: BaseUnit.ml, role: IngredientRole.staple),
          ri('garlic_powder', 'Garlic powder', 1, role: IngredientRole.staple),
          ri('salt', 'Salt', 2, role: IngredientRole.staple),
        ]
        ..steps = [
          'Cube the chicken and rinse the rice.',
          'Simmer the rice in 600 ml salted water, covered, for 15 min.',
          'Sear the chicken in the oil with the garlic powder for 8 min, then stir in the spinach until wilted.',
          'Split the rice and chicken into 3 containers and refrigerate for up to 4 days.',
        ],
      Recipe()
        ..title = 'Red lentil & chickpea dal'
        ..hook = 'Pantry-only, €0.90 a bowl'
        ..cuisine = 'indian'
        ..origin = RecipeOrigin.manual
        ..status = RecipeStatus.saved
        ..favorite = true
        ..timesCooked = 4
        ..lastCookedAt = t.subtract(const Duration(days: 9))
        ..lastPortionsCooked = 4
        ..defaultPortions = 4
        ..prepMinutes = 5
        ..cookMinutes = 25
        ..fridgeLifeDays = 4
        ..ingredients = [
          ri('red_lentils', 'Red lentils', 70),
          ri('canned_chickpeas', 'Chickpeas', 100),
          ri('canned_tomatoes', 'Chopped tomatoes', 120),
          ri('onion', 'Onion', 60),
          ri('cumin', 'Cumin', 2, role: IngredientRole.staple),
          ri('olive_oil', 'Olive oil', 5, unit: BaseUnit.ml, role: IngredientRole.staple),
        ]
        ..steps = [
          'Soften the onion in the oil with cumin.',
          'Add lentils, tomatoes and 700 ml water; simmer 20 min.',
          'Stir in chickpeas, season, portion.',
        ],
      Recipe()
        ..title = 'Lighter bacon carbonara'
        ..hook = 'Creamy carbonara in 20 min · 33 g protein'
        ..cuisine = 'italian'
        ..origin = RecipeOrigin.spontaneous
        ..status = RecipeStatus.saved
        ..feasibilityStatus = 'ready_with_swaps'
        ..summary = 'Ready now: bacon stands in for guanciale and yogurt makes it lighter.'
        ..sourceQuery = 'carbonara for two but lighter'
        ..timesCooked = 1
        ..lastCookedAt = t.subtract(const Duration(days: 5))
        ..lastPortionsCooked = 2
        ..defaultPortions = 2
        ..prepMinutes = 5
        ..cookMinutes = 15
        ..fridgeLifeDays = 1
        ..ingredients = [
          ri('dry_pasta', 'Spaghetti', 80),
          ri('bacon', 'Bacon', 40)..substitutesFor = 'guanciale',
          ri('egg', 'Egg', 1.5, unit: BaseUnit.pc),
          ri('greek_yogurt', 'Greek-style yogurt', 40)..substitutesFor = 'egg yolks',
          ri('grana_padano', 'Grana Padano', 15)..substitutesFor = 'pecorino romano',
          ri('black_pepper', 'Black pepper', 1, role: IngredientRole.staple),
        ]
        ..steps = [
          'Whisk eggs, yogurt, cheese and pepper.',
          'Boil pasta 9 min; keep 100 ml water.',
          'Crisp the bacon.',
          'Toss everything off the heat until creamy.',
        ],
      Recipe()
        ..title = 'Salmon traybake'
        ..cuisine = 'nordic'
        ..origin = RecipeOrigin.manual
        ..status = RecipeStatus.saved
        ..timesCooked = 2
        ..lastCookedAt = t.subtract(const Duration(days: 16))
        ..defaultPortions = 2
        ..cookMinutes = 25
        ..ingredients = [
          ri('', 'Salmon fillet', 150, role: IngredientRole.missing)
            ..estCostMinor = 350
            ..estNutritionPerPortion = Nutrition(kcal: 310, proteinG: 30, fatG: 20),
          ri('frozen_peas', 'Frozen peas', 80),
          ri('olive_oil', 'Olive oil', 5, unit: BaseUnit.ml, role: IngredientRole.staple),
        ]
        ..steps = ['Roast salmon and peas at 200 °C for 18 min.'],
    ];

    // Transactions: weekly shops + other spending over ~5 weeks.
    final txs = <Transaction>[];
    Transaction tx(
      int daysAgo,
      int hour,
      String merchant,
      List<(String, SpendCategory, int)> lines, {
      TxSource source = TxSource.receiptScan,
    }) {
      final at = DateTime(t.year, t.month, t.day - daysAgo, hour, 12);
      return Transaction()
        ..occurredAt = at
        ..merchant = merchant
        ..source = source
        ..lines = [
          for (final l in lines)
            LineItem()
              ..name = l.$1
              ..category = l.$2
              ..totalMinor = l.$3,
        ]
        ..totalMinor = lines.fold(0, (a, l) => a + l.$3)
        ..primaryCategory = lines.first.$2;
    }

    for (var w = 0; w < 5; w++) {
      final base = w * 7;
      txs.add(
        tx(base + 2, 18, 'Lidl', [
          ('Groceries', SpendCategory.groceries, 4200 + (w * 370) % 900),
          ('Dish soap', SpendCategory.household, 119),
          ('Bottle deposit', SpendCategory.other, 25),
        ]),
      );
      txs.add(tx(base + 5, 13, 'Rewe', [('Top-up shop', SpendCategory.groceries, 1150 + (w * 210) % 500)]));
      txs.add(tx(base + 3, 13, 'Ramen place', [('Lunch', SpendCategory.eatingOut, 1450)], source: TxSource.manual));
    }
    txs.add(tx(4, 20, 'Cinema', [('Tickets', SpendCategory.entertainment, 1100)], source: TxSource.manual));
    txs.add(tx(11, 16, 'Uniqlo', [('T-shirts', SpendCategory.clothes, 2990)], source: TxSource.manual));
    txs.add(tx(1, 12, 'Café', [('Coffee & cake', SpendCategory.eatingOut, 780)], source: TxSource.quickText));

    await isar.writeTxn(() async {
      await isar.userProfiles.put(profile);
      await isar.ingredients.putAll(pantry);
      final stock = StockIndex(await isar.ingredients.where().findAll());
      for (final r in recipes) {
        for (final x in r.ingredients) {
          final i = stock.resolve(x);
          if (i != null) x.ingredientId = i.id;
        }
        final n = NutritionEngine.compute(r.ingredients, stock);
        r
          ..perPortion = n.perPortion
          ..costPerPortionMinor = n.costPerPortionMinor
          ..createdAt = t.subtract(const Duration(days: 20));
      }
      recipes.first.createdAt = t;
      final ids = await isar.recipes.putAll(recipes);
      await isar.transactions.putAll(txs);

      // A dal batch in the fridge, cooked two days ago.
      final dal = recipes[1];
      final sessionId = await isar.cookSessions.put(
        CookSession()
          ..cookedAt = t.subtract(const Duration(days: 2))
          ..recipeId = ids[1]
          ..recipeTitle = dal.title
          ..portionsCooked = 4
          ..portionsRemaining = 2
          ..perPortion = dal.perPortion
          ..costPerPortionMinor = dal.costPerPortionMinor
          ..fridgeExpiresAt = t.add(const Duration(days: 2)),
      );

      // Intake: last week + this week so far.
      final logs = <DailyLog>[];
      final weekStartKey = clock.dateKey(clock.weekStart(t));
      final pattern = [
        (2150.0, 128.0, 690),
        (2320.0, 118.0, 820),
        (1980.0, 142.0, 540),
        (2250.0, 110.0, 910),
        (2410.0, 96.0, 1480),
        (1890.0, 120.0, 620),
        (2080.0, 131.0, 700),
      ];
      for (var d = -7; d < 7; d++) {
        final key = DayClock.addDaysToKey(weekStartKey, d);
        if (key >= todayKey) break;
        final p = pattern[(d + 7) % 7];
        logs.add(
          DailyLog()
            ..dateKey = key
            ..meals = [
              MealEntry()
                ..entryId = '$key-1'
                ..title = 'Breakfast'
                ..source = MealSource.quickAdd
                ..nutrition = Nutrition(kcal: p.$1 * 0.25, proteinG: p.$2 * 0.2),
              MealEntry()
                ..entryId = '$key-2'
                ..title = dal.title
                ..source = MealSource.fridge
                ..cookSessionId = sessionId
                ..portions = 1
                ..nutrition = Nutrition(kcal: p.$1 * 0.35, proteinG: p.$2 * 0.35)
                ..costMinor = p.$3 ~/ 2,
              MealEntry()
                ..entryId = '$key-3'
                ..title = 'Dinner'
                ..source = MealSource.cookedNow
                ..portions = 1
                ..nutrition = Nutrition(kcal: p.$1 * 0.4, proteinG: p.$2 * 0.45)
                ..costMinor = p.$3 - p.$3 ~/ 2,
            ]
            ..recomputeTotals(),
        );
      }
      logs.add(
        DailyLog()
          ..dateKey = todayKey
          ..meals = [
            MealEntry()
              ..entryId = '$todayKey-1'
              ..title = 'Oats & banana'
              ..source = MealSource.quickAdd
              ..nutrition = Nutrition(kcal: 520, proteinG: 22),
            MealEntry()
              ..entryId = '$todayKey-2'
              ..title = dal.title
              ..source = MealSource.fridge
              ..cookSessionId = sessionId
              ..nutrition = dal.perPortion
              ..costMinor = dal.costPerPortionMinor,
          ]
          ..recomputeTotals(),
      );
      await isar.dailyLogs.putAll(logs);

      // One receipt waiting in the inbox.
      await isar.scanJobs.put(
        ScanJob()
          ..status = ScanStatus.needsReview
          ..kind = ScanKind.receipt
          ..capturedAt = t.subtract(const Duration(hours: 3))
          ..merchant = 'Aldi'
          ..purchasedAt = t.subtract(const Duration(hours: 3))
          ..receiptTotalMinor = 1027
          ..currency = 'EUR'
          ..flags = ['total_mismatch']
          ..lines = [
            DraftLine()
              ..rawText = 'HAEHN.OBERK. 3,49'
              ..name = 'Chicken thighs'
              ..totalMinor = 349
              ..ingredientKey = 'chicken_thigh'
              ..isNewIngredient = true
              ..qty = 600
              ..qtySource = QtySource.inferred
              ..confidence = Confidence.low
              ..profile = (NewIngredientProfile()
                ..name = 'Chicken thigh'
                ..category = IngredientCategory.meatFish
                ..per100 = Nutrition(kcal: 177, proteinG: 18, fatG: 11.5)
                ..shelfLifeDays = 3),
            DraftLine()
              ..rawText = 'BROKKOLI 1,29'
              ..name = 'Broccoli'
              ..totalMinor = 129
              ..ingredientKey = 'broccoli'
              ..isNewIngredient = true
              ..qty = 500
              ..qtySource = QtySource.inferred
              ..profile = (NewIngredientProfile()
                ..name = 'Broccoli'
                ..category = IngredientCategory.produce
                ..per100 = Nutrition(kcal: 34, proteinG: 2.8, carbsG: 7, fatG: 0.4)
                ..shelfLifeDays = 5),
            DraftLine()
              ..rawText = 'H-MILCH 3,5% 1,09'
              ..name = 'UHT whole milk'
              ..totalMinor = 109
              ..ingredientKey = 'whole_milk'
              ..qty = 1000
              ..unit = BaseUnit.ml
              ..qtySource = QtySource.printed,
            DraftLine()
              ..rawText = 'KUECHENROLLE 2,49'
              ..name = 'Kitchen roll'
              ..category = SpendCategory.household
              ..totalMinor = 249,
          ],
      );
    });
  }
}
