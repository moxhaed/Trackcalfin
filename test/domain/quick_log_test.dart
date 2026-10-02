import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/data/ai/dto/quick_log_dto.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/quick_log.dart';

import '../support/fake_gemini.dart';
import 'fixtures.dart';

void main() {
  const clock = DayClock();
  const money = MoneyFormat();
  // Friday 2 Oct 2026, 18:40, as in the prompt's input example.
  final now = DateTime(2026, 10, 2, 18, 40);

  late Ingredient cola;
  late Ingredient beans;
  late CookSession chili;
  late Recipe pasta;

  setUp(() {
    cola = ingredient('cola_zero', qty: 5, unit: BaseUnit.pc, cost: 75, kcal: 0.3, gpp: 340, shelf: 270)
      ..category = IngredientCategory.beverages
      ..nutritionSource = DataSource.aiEstimate;
    beans = ingredient('kidney_beans', qty: 800, cost: 0.4, kcal: 100, protein: 7)
      ..nutritionSource = DataSource.aiEstimate;
    chili = CookSession()
      ..id = 12
      ..recipeTitle = 'Chili con carne'
      ..recipeId = 4
      ..portionsCooked = 4
      ..portionsRemaining = 3
      ..perPortion = Nutrition(kcal: 620, proteinG: 46)
      ..costPerPortionMinor = 210;
    pasta = Recipe()
      ..id = 5
      ..title = 'Bean pasta'
      ..status = RecipeStatus.saved
      ..ingredients = [ri('kidney_beans', 200)];
  });

  QuickLogWorld world({List<DailyLog> logs = const []}) =>
      QuickLogWorld(ingredients: [cola, beans], fridge: [chili], recipes: [pasta], logs: logs, profile: UserProfile());

  QuickLogContext ctx() => QuickLogContext(
    now: now,
    pantry: {'cola_zero': BaseUnit.pc, 'whole_milk': BaseUnit.ml, 'kidney_beans': BaseUnit.g},
    fridge: {12: 3},
    recipes: {4, 5},
  );

  QuickLog read(Object json) {
    final r = QuickLog.parse(jsonDecode(jsonEncode(json)) as Map<String, dynamic>, ctx: ctx());
    expect(r.ok, isTrue, reason: r.errors.join('\n'));
    return r.value!;
  }

  Map<String, dynamic> action(String type, [Map<String, dynamic> fields = const {}]) => {
    'type': type,
    'when': null,
    'source': null,
    'key': null,
    'name': null,
    'qty': null,
    'unit': null,
    'batch_id': null,
    'recipe_id': null,
    'portions': null,
    'ate_portions': null,
    'paid_minor': null,
    'est_price_minor': null,
    'category': null,
    'merchant': null,
    'nutrition': null,
    'new_ingredient': null,
    ...fields,
  };

  Map<String, dynamic> out(List<Map<String, dynamic>> actions, {int? total, String? question}) => {
    'schema_version': 1,
    'actions': actions,
    'total_paid_minor': total,
    'question': question,
  };

  List<QuickStep> plan(QuickLog log, QuickLogWorld w, {Set<int> skip = const {}, Map<int, int> paid = const {}}) =>
      QuickLogPlanner.plan(log, w, now: now, clock: clock, money: money, skip: skip, paid: paid);

  test('"bought a coke zero for 1.29 and drank it": spent, in and out of the pantry, logged at its cost', () {
    final w = world();
    final steps = plan(read(jsonDecode(promptExample('quick_log.v1.md'))), w);
    expect(steps.map((s) => s.title), ['Bought cola zero · 1 pc', 'Drank cola zero · 1 pc']);
    final tx = w.transactions.single;
    expect((tx.totalMinor, tx.primaryCategory, tx.source), (129, SpendCategory.groceries, TxSource.quickText));
    expect(tx.lines.single.qtyBase, 1);
    expect(cola.qtyOnHand, 5, reason: 'one bought, one drunk');
    // The price paid joins the average: (5 x 75 + 129) / 6 = 84.
    expect(cola.avgCostPerUnitMinor, 84);
    final meal = w.logs[20261002]!.meals.single;
    expect((meal.source, meal.ingredientKey, meal.qtyBase, meal.costMinor), (MealSource.pantry, 'cola_zero', 1.0, 84));
    expect(meal.nutrition.kcal, closeTo(0.3 * 3.4, 1e-9), reason: 'Dart works the calories out of the can');
    expect(w.logs[20261002]!.foodCostMinor, 84, reason: 'counts as food eaten');
  });

  test('a total for several items is split by their usual prices; without one the usual price is marked', () {
    final examples = promptExamples('quick_log.v1.md');
    final w = world();
    final steps = plan(read(jsonDecode(examples[2])), w);
    final lines = w.transactions.single.lines;
    expect(lines.map((l) => l.totalMinor).reduce((a, b) => a + b), 950, reason: 'the lines add up to what was paid');
    expect(lines.first.totalMinor, (950 * 714 / (714 + 169)).round());
    expect(steps.where((s) => s.estimatedPrice), isEmpty);
    expect(w.created.map((i) => (i.key, i.baseUnit, i.gramsPerPiece)), [
      ('energy_drink', BaseUnit.pc, 260.0),
      ('banana', BaseUnit.pc, 120.0),
    ]);
    expect(w.created.every((i) => i.id < 0), isTrue, reason: 'stand-in ids until saved');
    expect(w.stock.byKey['banana']!.qtyOnHand, 4, reason: '5 bought, 1 eaten');

    final noTotal = read(
      out([
        action('buy', {'key': 'cola_zero', 'name': 'Cola', 'qty': 6, 'unit': 'pc', 'est_price_minor': 449}),
      ]),
    );
    final guess = plan(noTotal, world());
    expect(guess.single.estimatedPrice, isTrue);
    expect(guess.single.detail, startsWith('~'));
    final fixed = world();
    expect(plan(noTotal, fixed, paid: {0: 399}).single.estimatedPrice, isFalse);
    expect(fixed.transactions.single.totalMinor, 399, reason: 'the price the user typed');
  });

  test('two portions of the chili and a döner at lunch: fridge, eating out at 0 and the expense', () {
    final w = world();
    final steps = plan(read(jsonDecode(promptExamples('quick_log.v1.md')[1])), w);
    expect(chili.portionsRemaining, 1);
    final day = w.logs[20261002]!;
    expect(day.meals.map((m) => (m.source, m.portions, m.costMinor)), [
      (MealSource.fridge, 2.0, 420),
      (MealSource.quickAdd, 1.0, 0),
    ]);
    expect(day.totals.kcal, 2 * 620 + 700);
    expect(day.meals.last.eatenAt, DateTime(2026, 10, 2, 12, 30));
    final tx = w.transactions.single;
    expect(
      (tx.primaryCategory, tx.totalMinor, tx.occurredAt),
      (SpendCategory.eatingOut, 750, DateTime(2026, 10, 2, 12, 30)),
    );
    expect(steps[1].detail, contains('today 12:30'));
  });

  test('more portions than are left: what is there is logged, and the card says so', () {
    final w = world();
    final steps = plan(
      read(
        out([
          action('eat', {'source': 'fridge', 'batch_id': 12, 'portions': 5}),
        ]),
      ),
      w,
    );
    expect(chili.portionsRemaining, 0);
    expect(chili.status, CookStatus.finished);
    expect(w.logs[20261002]!.meals.single.portions, 3);
    expect(steps.single.warning, 'Only 3 portions left in the fridge');
  });

  test('cooking deducts stock, eats what was said and puts the rest in the fridge', () {
    final w = world();
    final steps = plan(
      read(
        out([
          action('cook', {'recipe_id': 5, 'portions': 3, 'ate_portions': 2}),
        ]),
      ),
      w,
    );
    expect(beans.qtyOnHand, 200);
    final s = w.sessions.single;
    expect((s.portionsCooked, s.portionsRemaining, s.costPerPortionMinor), (3, 1, 80));
    expect(s.id, lessThan(0));
    final meal = w.logs[20261002]!.meals.single;
    expect((meal.source, meal.portions, meal.cookSessionId), (MealSource.cookedNow, 2.0, s.id));
    expect(pasta.timesCooked, 1);
    expect(steps.single.title, 'Cooked Bean pasta × 3');
  });

  test('throw away and count', () {
    final w = world();
    plan(
      read(
        out([
          action('throw_away', {'source': 'fridge', 'batch_id': 12}),
          action('count', {'key': 'kidney_beans', 'qty': 0, 'unit': 'g'}),
        ]),
      ),
      w,
    );
    expect((chili.portionsRemaining, chili.portionsDiscarded, chili.status), (0, 3, CookStatus.discarded));
    expect(beans.qtyOnHand, 0);
    expect(beans.lastCountedAt, now);
  });

  test('skipping an action leaves it out, and a target that is gone is left out with a note', () {
    final w = world();
    final log = read(jsonDecode(promptExample('quick_log.v1.md')));
    final steps = plan(log, w, skip: {1});
    expect(steps.single.kind, QuickActionType.buy);
    expect(cola.qtyOnHand, 6);

    final gone = QuickLogWorld(
      ingredients: [cola],
      fridge: const [],
      recipes: const [],
      logs: const [],
      profile: UserProfile(),
    );
    final left = plan(
      read(
        out([
          action('eat', {'source': 'fridge', 'batch_id': 12, 'portions': 1}),
        ]),
      ),
      gone,
    );
    expect(left.single.warning, "It isn't in the app any more");
  });
}
