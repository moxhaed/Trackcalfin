import 'dart:math' as math;

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../core/money.dart';
import '../data/ai/dto/quick_log_dto.dart';
import '../data/isar/collections/cook_session.dart';
import '../data/isar/collections/daily_log.dart';
import '../data/isar/collections/food_use.dart';
import '../data/isar/collections/ingredient.dart';
import '../data/isar/collections/nutrition.dart';
import '../data/isar/collections/recipe.dart';
import '../data/isar/collections/transaction.dart';
import '../data/isar/collections/user_profile.dart';
import 'costing.dart';
import 'depletion.dart';
import 'nutrition.dart';
import 'stock_index.dart';
import 'units.dart';
import 'used_up.dart';

/// What one line of the Say it card shows.
class QuickStep {
  QuickStep(this.action, this.kind, this.title, {this.detail, this.warning, this.estimatedPrice = false});

  /// Index of the action it came from: unticking it plans again without that action.
  final int action;
  final QuickActionType kind;
  final String title;
  final String? detail;

  /// Something the user should look at: a price that is only the usual one, fewer portions
  /// left than said, macros not known yet.
  final String? warning;

  /// A bought item priced at the usual shop price, because the user didn't say what they paid.
  final bool estimatedPrice;

  /// The same step, saying when it happened (the user said "yesterday", "at lunch").
  QuickStep dated(String when) => QuickStep(
    action,
    kind,
    title,
    detail: detail == null ? when : '$detail · $when',
    warning: warning,
    estimatedPrice: estimatedPrice,
  );
}

/// The data a quick log can change, as plain objects. [QuickLogPlanner.plan] changes them in
/// place and records what it touched and created, so the caller can save exactly that.
class QuickLogWorld {
  QuickLogWorld({
    required List<Ingredient> ingredients,
    required List<CookSession> fridge,
    required List<Recipe> recipes,
    required List<DailyLog> logs,
    required this.profile,
  }) : stock = StockIndex(ingredients),
       fridge = {for (final s in fridge) s.id: s},
       recipes = {for (final r in recipes) r.id: r},
       logs = {for (final l in logs) l.dateKey: l};

  final StockIndex stock;
  final Map<int, CookSession> fridge;
  final Map<int, Recipe> recipes;
  final Map<int, DailyLog> logs;
  final UserProfile profile;

  /// New ingredients and cook sessions get negative stand-in ids until they are saved.
  final created = <Ingredient>[];
  final sessions = <CookSession>[];
  final transactions = <Transaction>[];
  final changedIngredients = <Ingredient>{};
  final changedSessions = <CookSession>{};
  final changedLogs = <DailyLog>{};
  final changedRecipes = <Recipe>{};

  /// Food found gone ("we're out of milk") or thrown away: eaten or wasted since the last count.
  final uses = <FoodUse>[];
  var _nextId = -1;

  int takeId() => _nextId--;

  DailyLog logFor(int dateKey) => logs.putIfAbsent(dateKey, () => DailyLog()..dateKey = dateKey);
}

/// Turns what Prompt G read into changes, with every number from the user's own data:
/// calories and cost of their food, stock, portions. The model only says what happened.
class QuickLogPlanner {
  const QuickLogPlanner._();

  /// Applies [log]'s actions to [w] in order (a buy before the eat that follows it) and
  /// returns one step per action. [skip] leaves actions out; [paid] overrides what an
  /// action's item cost (the user corrected an estimated price).
  static List<QuickStep> plan(
    QuickLog log,
    QuickLogWorld w, {
    required DateTime now,
    required DayClock clock,
    required MoneyFormat money,
    Set<int> skip = const {},
    Map<int, int> paid = const {},
  }) {
    final steps = <QuickStep>[];
    final prices = _prices(log, skip, paid);
    Transaction? groceries;
    for (final (i, a) in log.actions.indexed) {
      if (skip.contains(i)) continue;
      final at = a.when ?? now;
      final day = clock.dateKey(at);
      final before = steps.length;
      switch (a.type) {
        case QuickActionType.buy:
          final ing = w.stock.byKey[a.key] ?? _create(a, w, at);
          final qty = UnitConverter.toBase(a.qty!, a.unit!, ing) ?? a.qty!;
          final (price, estimated) = prices[i]!;
          CostingEngine.applyPurchase(ing, qtyAdded: qty, lineTotalMinor: price, at: at);
          w.changedIngredients.add(ing);
          final tx = groceries ??= _transaction(w, at, now, SpendCategory.groceries, merchant: a.merchant);
          tx
            ..merchant ??= a.merchant
            ..totalMinor += price
            ..lines = [
              ...tx.lines,
              LineItem()
                ..name = ing.name
                ..category = SpendCategory.groceries
                ..totalMinor = price
                ..ingredientId = ing.id
                ..ingredientKey = ing.key
                ..qtyBase = qty,
            ];
          steps.add(
            QuickStep(
              i,
              a.type,
              'Bought ${ing.name} · ${UnitConverter.format(qty, ing.baseUnit)}',
              detail: ['${estimated ? '~' : ''}${money.format(price)}', 'Groceries', ?a.merchant].join(' · '),
              warning: estimated ? 'The usual price, not what you paid' : null,
              estimatedPrice: estimated,
            ),
          );
        case QuickActionType.expense:
          final amount = paid[i] ?? a.paidMinor!;
          final tx = _transaction(w, at, now, a.category!, merchant: a.merchant, note: a.name);
          tx
            ..totalMinor = amount
            ..lines = [
              LineItem()
                ..name = a.name ?? a.category!.label
                ..category = a.category!
                ..totalMinor = amount,
            ];
          steps.add(
            QuickStep(
              i,
              a.type,
              '${a.name ?? a.category!.label} · ${money.format(amount)}',
              detail: [a.category!.label, ?a.merchant].join(' · '),
            ),
          );
        case QuickActionType.eat:
          steps.add(switch (a.source!) {
            FoodSource.fridge => _eatFridge(i, a, w, at, day, money),
            FoodSource.pantry => _eatPantry(i, a, w, at, day, money),
            FoodSource.out => _eatOut(i, a, w, at, day),
          });
        case QuickActionType.cook:
          steps.add(_cook(i, a, w, at, day, money));
        case QuickActionType.throwAway:
          steps.add(a.source == FoodSource.fridge ? _throwFridge(i, a, w) : _throwPantry(i, a, w, at));
        case QuickActionType.count:
          final ing = w.stock.byKey[a.key];
          if (ing == null) {
            steps.add(_gone(i, a));
            continue;
          }
          final had = ing.qtyOnHand;
          final qty = UnitConverter.toBase(a.qty!, a.unit!, ing) ?? a.qty!;
          // Less than the pantry had: the rest went since the last count, so it counts as eaten.
          final use = UsedUp.fromCount(ing, before: had, after: qty, at: at);
          if (use != null) w.uses.add(use);
          ExpiryEstimator.onCount(ing, qty, at);
          w.changedIngredients.add(ing);
          steps.add(
            QuickStep(
              i,
              a.type,
              qty == 0 ? '${ing.name}: none left' : '${ing.name}: ${UnitConverter.format(qty, ing.baseUnit)} left',
              detail: 'Was ${UnitConverter.format(had, ing.baseUnit)}',
            ),
          );
      }
      if (a.when != null && steps.length > before) steps.last = steps.last.dated(_when(a.when!, now));
    }
    return steps;
  }

  /// What each buy cost, and whether that is only the usual price. A total the user gave
  /// for several items is split over the unpriced ones by their usual prices.
  static Map<int, (int, bool)> _prices(QuickLog log, Set<int> skip, Map<int, int> paid) {
    final out = <int, (int, bool)>{};
    final open = <int>[];
    var known = 0;
    for (final (i, a) in log.actions.indexed) {
      if (a.type != QuickActionType.buy) continue;
      final p = paid[i] ?? a.paidMinor;
      if (p != null) {
        out[i] = (p, false);
        if (!skip.contains(i)) known += p;
      } else {
        open.add(i);
      }
    }
    final total = log.totalPaidMinor;
    final share = total == null ? 0 : math.max(0, total - known);
    final weights = {for (final i in open) i: log.actions[i].estPriceMinor ?? 1};
    final weightSum = open.where((i) => !skip.contains(i)).fold(0, (a, i) => a + weights[i]!);
    var left = share;
    final counted = open.where((i) => !skip.contains(i)).toList();
    for (final (n, i) in counted.indexed) {
      if (total == null) {
        out[i] = (log.actions[i].estPriceMinor!, true);
        continue;
      }
      // The last one takes the rounding, so the lines add up to the total.
      final part = n == counted.length - 1 ? left : (share * weights[i]! / weightSum).round();
      left -= part;
      out[i] = (part, false);
    }
    for (final i in open.where(skip.contains)) {
      out[i] = (log.actions[i].estPriceMinor ?? 0, total == null);
    }
    return out;
  }

  static Ingredient _create(QuickAction a, QuickLogWorld w, DateTime at) {
    final p = a.newIngredient;
    final unit = p?.unit ?? a.unit ?? BaseUnit.g;
    final ing = Ingredient()
      ..id = w.takeId()
      ..key = a.key!
      ..name = p == null || p.name.isEmpty ? (a.name ?? a.key!) : p.name
      ..category = p?.category ?? IngredientCategory.other
      ..baseUnit = unit
      ..gramsPerPiece = p?.gramsPerPiece ?? (unit == BaseUnit.pc ? 50 : null)
      ..densityGPerMl = p?.densityGPerMl
      ..per100 = p?.per100 ?? Nutrition()
      ..nutritionSource = p == null ? DataSource.none : DataSource.aiEstimate
      ..shelfLifeDays = p?.shelfLifeDays ?? 7
      ..lastVerifiedAt = at
      ..updatedAt = at;
    w.created.add(ing);
    w.stock.byId[ing.id] = ing;
    w.stock.byKey[ing.key] = ing;
    return ing;
  }

  static Transaction _transaction(
    QuickLogWorld w,
    DateTime at,
    DateTime now,
    SpendCategory category, {
    String? merchant,
    String? note,
  }) {
    final tx = Transaction()
      ..occurredAt = at
      ..source = TxSource.quickText
      ..merchant = merchant
      ..note = note
      ..currency = w.profile.currency
      ..primaryCategory = category
      ..createdAt = now;
    w.transactions.add(tx);
    return tx;
  }

  static MealEntry _meal(QuickLogWorld w, int day, DateTime at, MealSource source, String title) {
    final log = w.logFor(day);
    final entry = MealEntry()
      ..entryId = '${at.microsecondsSinceEpoch + log.meals.length}'
      ..eatenAt = at
      ..source = source
      ..title = title;
    log.meals = [...log.meals, entry];
    w.changedLogs.add(log);
    return entry;
  }

  static QuickStep _eatFridge(int i, QuickAction a, QuickLogWorld w, DateTime at, int day, MoneyFormat money) {
    final s = w.fridge[a.batchId];
    if (s == null) return _gone(i, a);
    final eaten = math.min(a.portions!, s.portionsRemaining.toDouble());
    final whole = eaten.floorToDouble();
    // Portions are whole in the fridge: half a portion eaten keeps the rest in it.
    final taken = eaten == whole ? whole.toInt() : whole.toInt() + 1;
    s.portionsRemaining -= math.min(taken, s.portionsRemaining);
    if (s.portionsRemaining <= 0) s.status = CookStatus.finished;
    w.changedSessions.add(s);
    final n = s.perPortion.scale(eaten);
    final cost = (s.costPerPortionMinor * eaten).round();
    _meal(w, day, at, MealSource.fridge, s.recipeTitle)
      ..cookSessionId = s.id
      ..recipeId = s.recipeId
      ..portions = eaten
      ..nutrition = n
      ..costMinor = cost;
    w.logFor(day).recomputeTotals();
    return QuickStep(
      i,
      a.type,
      'Ate ${_portions(eaten)} of ${s.recipeTitle}',
      detail: '${_macros(n)} · ${money.format(cost)}',
      warning: a.portions! > eaten ? 'Only ${_portions(eaten)} left in the fridge' : null,
    );
  }

  static QuickStep _eatPantry(int i, QuickAction a, QuickLogWorld w, DateTime at, int day, MoneyFormat money) {
    final ing = w.stock.byKey[a.key];
    if (ing == null) return _gone(i, a);
    final qty = UnitConverter.toBase(a.qty!, a.unit!, ing) ?? a.qty!;
    final had = ing.qtyOnHand;
    final taken = math.min(qty, had);
    ing.qtyOnHand = had - taken;
    ExpiryEstimator.onDeplete(ing);
    // Eating more than the pantry had means a purchase was missed: check it next time.
    if (qty > had + 1e-9) ing.lastVerifiedAt = null;
    ing.updatedAt = at;
    w.changedIngredients.add(ing);
    final n = ing.needsNutrition ? null : NutritionEngine.nutrientsFor(ing, qty);
    final cost = (qty * ing.avgCostPerUnitMinor).round();
    _meal(w, day, at, MealSource.pantry, ing.name)
      ..portions = 1
      ..nutrition = n ?? Nutrition()
      ..costMinor = cost
      ..ingredientKey = ing.key
      ..qtyBase = taken;
    w.logFor(day).recomputeTotals();
    final drink = ing.category == IngredientCategory.beverages;
    return QuickStep(
      i,
      a.type,
      '${drink ? 'Drank' : 'Ate'} ${ing.name} · ${UnitConverter.format(qty, ing.baseUnit)}',
      detail: [if (n != null) _macros(n), money.format(cost)].join(' · '),
      warning: n == null
          ? "Its macros aren't known yet, so it's logged without them"
          : qty > had + 1e-9
          ? 'The pantry had ${UnitConverter.format(had, ing.baseUnit)}'
          : null,
    );
  }

  static QuickStep _eatOut(int i, QuickAction a, QuickLogWorld w, DateTime at, int day) {
    final n = a.nutrition ?? Nutrition();
    // Its money, if any, is an eating-out expense: the meal costs 0 here so food eaten
    // (groceries) doesn't count it again.
    _meal(w, day, at, MealSource.quickAdd, a.name ?? 'Meal').nutrition = n;
    w.logFor(day).recomputeTotals();
    return QuickStep(i, a.type, 'Ate ${a.name}', detail: '~${_macros(n)} (estimate)');
  }

  static QuickStep _cook(int i, QuickAction a, QuickLogWorld w, DateTime at, int day, MoneyFormat money) {
    final recipe = w.recipes[a.recipeId];
    if (recipe == null) return _gone(i, a);
    final portions = a.portions!.round();
    final ate = a.atePortions ?? (w.profile.autoLogFirstPortion ? 1 : 0);
    final plan = DepletionEngine.plan(recipe.ingredients, portions, w.stock);
    w.changedIngredients.addAll(DepletionEngine.apply(plan, w.stock, at));
    final session = CookSession()
      ..id = w.takeId()
      ..cookedAt = at
      ..recipeId = recipe.id
      ..recipeTitle = recipe.title
      ..portionsCooked = portions
      ..portionsRemaining = portions - ate
      ..perPortion = plan.perPortion
      ..costPerPortionMinor = plan.costPerPortionMinor
      ..deltas = plan.deltas
      ..fridgeExpiresAt = DayClock.addDays(at, recipe.fridgeLifeDays)
      ..status = portions - ate <= 0 ? CookStatus.finished : CookStatus.active;
    w.sessions.add(session);
    if (ate > 0) {
      _meal(w, day, at, MealSource.cookedNow, recipe.title)
        ..cookSessionId = session.id
        ..recipeId = recipe.id
        ..portions = ate.toDouble()
        ..nutrition = plan.perPortion.scale(ate.toDouble())
        ..costMinor = plan.costPerPortionMinor * ate;
      w.logFor(day).recomputeTotals();
    }
    recipe
      ..timesCooked += 1
      ..lastCookedAt = at
      ..lastPortionsCooked = portions
      ..perPortion = plan.perPortion
      ..costPerPortionMinor = plan.costPerPortionMinor;
    if (recipe.status == RecipeStatus.suggested || recipe.status == RecipeStatus.dismissed) {
      recipe.status = RecipeStatus.saved;
    }
    w.changedRecipes.add(recipe);
    final left = portions - ate;
    return QuickStep(
      i,
      a.type,
      'Cooked ${recipe.title} × $portions',
      detail: [
        if (ate > 0) '${_portions(ate.toDouble())} eaten',
        if (left > 0) '$left in the fridge',
        '${money.format(plan.costPerPortionMinor)} a portion',
      ].join(' · '),
      warning: plan.hasShortfall ? 'Some ingredients ran out sooner than the pantry said' : null,
    );
  }

  static QuickStep _throwFridge(int i, QuickAction a, QuickLogWorld w) {
    final s = w.fridge[a.batchId];
    if (s == null) return _gone(i, a);
    final n = math.min((a.portions ?? s.portionsRemaining.toDouble()).ceil(), s.portionsRemaining);
    s
      ..portionsRemaining -= n
      ..portionsDiscarded += n;
    if (s.portionsRemaining <= 0) s.status = CookStatus.discarded;
    w.changedSessions.add(s);
    return QuickStep(i, a.type, 'Threw away ${_portions(n.toDouble())} of ${s.recipeTitle}');
  }

  static QuickStep _throwPantry(int i, QuickAction a, QuickLogWorld w, DateTime at) {
    final ing = w.stock.byKey[a.key];
    if (ing == null) return _gone(i, a);
    final qty = a.qty == null ? ing.qtyOnHand : (UnitConverter.toBase(a.qty!, a.unit!, ing) ?? a.qty!);
    final taken = math.min(qty, ing.qtyOnHand);
    // Recorded as thrown away: it went, but isn't food eaten.
    final use = UsedUp.fromCount(
      ing,
      before: ing.qtyOnHand,
      after: ing.qtyOnHand - taken,
      at: at,
      kind: UseKind.thrownAway,
    );
    if (use != null) w.uses.add(use);
    ing
      ..qtyOnHand = ing.qtyOnHand - taken
      ..updatedAt = at;
    ExpiryEstimator.onDeplete(ing);
    w.changedIngredients.add(ing);
    return QuickStep(i, a.type, 'Threw away ${ing.name} · ${UnitConverter.format(taken, ing.baseUnit)}');
  }

  /// What an action pointed at is gone since it was read (eaten up, deleted): left out.
  static QuickStep _gone(int i, QuickAction a) =>
      QuickStep(i, a.type, 'Left out: ${a.name ?? a.key ?? 'that'}', warning: "It isn't in the app any more");

  static String _portions(double n) {
    final s = n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
    return '$s ${n == 1 ? 'portion' : 'portions'}';
  }

  static String _macros(Nutrition n) => '${n.kcal.round()} kcal · ${n.proteinG.round()} g protein';

  static String _when(DateTime t, DateTime now) {
    final days = DayClock.daysBetween(t, now);
    final hm = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return days == 0 ? 'today $hm' : (days == 1 ? 'yesterday $hm' : '$days days ago');
  }
}
