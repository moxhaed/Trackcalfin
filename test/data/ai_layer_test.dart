import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/ai_runner.dart';
import 'package:trackcalfin/data/ai/context_builders.dart';
import 'package:trackcalfin/data/ai/dto/cookbook_dto.dart';
import 'package:trackcalfin/data/ai/dto/nutrition_dto.dart';
import 'package:trackcalfin/data/ai/dto/price_dto.dart';
import 'package:trackcalfin/data/ai/dto/quick_log_dto.dart';
import 'package:trackcalfin/data/ai/dto/receipt_dto.dart';
import 'package:trackcalfin/data/ai/dto/recipe_dto.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/json_reader.dart';
import 'package:trackcalfin/data/ai/schemas.dart';
import 'package:trackcalfin/data/isar/collections/scan_job.dart';
import 'package:trackcalfin/data/isar/collections/user_profile.dart';
import 'package:trackcalfin/domain/measures.dart';

import '../domain/fixtures.dart';
import '../support/fake_gemini.dart';

void main() {
  setUp(() => GeminiClient.compatLevel = 0);

  group('Prompt examples parse with the app DTOs', () {
    test('Prompt A v5 examples: lines counted the way they are used, pieces with their size', () {
      final examples = promptExamples('receipt_extraction.v5.md');
      expect(examples.length, 2);
      final r = ReceiptExtraction.parse(jsonDecode(examples[0]));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      final soda = r.value!.items[1];
      expect(
        (soda.unit, soda.qty, soda.piece!.name, soda.piece!.size, soda.piece!.unit, soda.isNewIngredient),
        (BaseUnit.pc, 6.0, 'can', 330.0, BaseUnit.ml, false),
      );
      final pita = r.value!.items[2].newIngredient!;
      expect((pita.unit, pita.gramsPerPiece, pita.pieceName), (BaseUnit.pc, 75.0, 'pita'));
      expect(r.value!.items[0].piece, isNull, reason: 'grams have no piece');
      final pantry = ReceiptExtraction.parse(jsonDecode(examples[1]));
      expect(pantry.ok, isTrue, reason: pantry.errors.join('\n'));
      expect(pantry.value!.items[1].shelfPrice!.packageQty, 4, reason: 'a 4-pack is priced per 4 cups');
      expect(pantry.value!.items[2].newIngredient!.unit, BaseUnit.ml);
      expect(pantry.value!.items[2].newIngredient!.densityGPerMl, 0.92);
    });
    test('Prompt A v4 examples still parse: answers in flight when the app updates', () {
      final examples = promptExamples('receipt_extraction.v4.md');
      expect(examples.length, 2);
      final r = ReceiptExtraction.parse(jsonDecode(examples[0]));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.items.length, 4);
      expect(r.value!.items[1].newIngredient!.category, IngredientCategory.dairyEggs);
      expect(r.value!.items[1].product, 'Milbona Greek-style yogurt 10%, 500 g');
      expect(r.value!.items.every((i) => i.shelfPrice == null), isTrue);
      expect(r.value!.purchasedAt, DateTime(2026, 9, 27, 18, 42));
      final pantry = ReceiptExtraction.parse(jsonDecode(examples[1]));
      expect(pantry.ok, isTrue, reason: pantry.errors.join('\n'));
      expect(pantry.value!.imageType, ScanKind.pantry);
      expect(pantry.value!.items[0].shelfPrice!.packageQty, 500);
      expect(pantry.value!.items[0].shelfPrice!.priceMinor, 199);
      expect(pantry.value!.items[1].newIngredient!.unit, BaseUnit.ml);
    });
    test('Prompt B example', () {
      final r = DailyRecipeOutput.parse(jsonDecode(promptExample('daily_recipe.v2.md')));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.recipe!.ingredients.length, 6);
      expect(r.value!.recipe!.ingredients.every((i) => i.role == IngredientRole.stock), isTrue);
    });
    test('Prompt C example', () {
      final r = SpontaneousOutput.parse(jsonDecode(promptExample('spontaneous_recipe.v2.md')));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.recipe!.ingredients.where((i) => i.substitutesFor != null).length, 3);
    });
    test('Prompt D example', () {
      final r = NutritionEstimates.parse(
        jsonDecode(promptExample('nutrition_estimate.v1.md')),
        units: const {'olive_oil': BaseUnit.ml, 'flour': BaseUnit.g, 'salt': BaseUnit.g, 'stock_cube': BaseUnit.pc},
      );
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.items.first.per100g.fatG, 100);
      expect(r.value!.items.first.densityGPerMl, 0.91);
    });
    test('Prompt E example', () {
      final r = LabelReading.parse(jsonDecode(promptExample('nutrition_label.v1.md')));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.basis, LabelBasis.per100g);
      expect(r.value!.energyKcal, 348);
    });
    test('Prompt G v3 examples: amounts as said, measures and pieces', () {
      final ctx = QuickLogContext(
        now: DateTime(2026, 10, 2, 18, 40),
        pantry: const {'cola_zero': BaseUnit.pc, 'whole_milk': BaseUnit.ml},
        fridge: const {12: 3},
        recipes: const {4},
      );
      final examples = promptExamples('quick_log.v3.md');
      expect(examples, hasLength(6));
      final parsed = [for (final e in examples) QuickLog.parse(jsonDecode(e), ctx: ctx)];
      for (final r in parsed) {
        expect(r.ok, isTrue, reason: r.errors.join('\n'));
      }
      expect(
        [for (final a in parsed[1].value!.actions) (a.qty, a.measure)],
        [(2.0, Measure.tbsp), (1.0, Measure.glass)],
      );
      final redBull = parsed[3].value!.actions[0];
      expect((redBull.unit, redBull.piece!.name, redBull.newIngredient!.gramsPerPiece), (BaseUnit.pc, 'can', 260.0));
      expect(parsed[3].value!.totalPaidMinor, 950);
      expect(parsed[5].value!.question, startsWith('Which chili'));
    });
    test(
      'Prompt G v2 examples still parse: buy and drink, fridge and eating out, a split total, prices, a question',
      () {
        final ctx = QuickLogContext(
          now: DateTime(2026, 10, 2, 18, 40),
          pantry: const {'cola_zero': BaseUnit.pc, 'whole_milk': BaseUnit.ml},
          fridge: const {12: 3},
          recipes: const {4},
        );
        final examples = promptExamples('quick_log.v2.md');
        expect(examples, hasLength(5));
        final parsed = [for (final e in examples) QuickLog.parse(jsonDecode(e), ctx: ctx)];
        for (final r in parsed) {
          expect(r.ok, isTrue, reason: r.errors.join('\n'));
        }
        expect(parsed[0].value!.actions.map((a) => a.type), [QuickActionType.buy, QuickActionType.eat]);
        expect(parsed[1].value!.actions[1].category, SpendCategory.eatingOut);
        expect(parsed[1].value!.actions[2].nutrition!.kcal, 700);
        expect(parsed[2].value!.totalPaidMinor, 950);
        expect(parsed[2].value!.actions[0].newIngredient!.gramsPerPiece, 260);
        expect(
          [for (final a in parsed[3].value!.actions) (a.type, a.key, a.name)],
          [(QuickActionType.priceCheck, 'cola_zero', 'Coke Zero'), (QuickActionType.priceCheck, null, 'Oat milk')],
        );
        expect(parsed[4].value!.actions, isEmpty);
        expect(parsed[4].value!.question, startsWith('Which chili'));
      },
    );
    test('Prompt F example', () {
      final r = PriceLookup.parse(
        jsonDecode(promptExample('price_lookup.v1.md')),
        units: const {'0': BaseUnit.g, '1': BaseUnit.g},
      );
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(
        (r.value!.items[0].priceMinor, r.value!.items[0].packageQty, r.value!.items[0].source),
        (199, 500, 'rewe.de'),
      );
      expect(r.value!.items[1].found, isFalse);
      expect(r.value!.items[1].note, 'no shop price online');
    });
  });

  group('Cookbook import (Prompt H)', () {
    test('the examples parse: an index, and a recipe read with one not in the book', () {
      final index = CookbookIndexOutput.parse(jsonDecode(promptExample('cookbook_index.v1.md')));
      expect(index.ok, isTrue, reason: index.errors.join('\n'));
      expect(index.value!.recipes.first, ('Hummus with spiced lamb', 34));
      expect((index.value!.bookTitle, index.value!.nextPage), ('Weeknight Middle Eastern', null));
      final r = CookbookRecipesOutput.parse(jsonDecode(promptExample('cookbook_import.v1.md')), ids: {0, 1});
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      final hummus = r.value!.recipes.first;
      expect((hummus.servings, hummus.ingredients.length), (4, 9));
      expect((hummus.ingredients.first.key, hummus.ingredients.first.qty), ('chickpeas_canned', 480));
      expect(hummus.ingredients.last.optional, isTrue);
      expect(r.value!.recipes.last.found, isFalse);
    });
    test('every id once, amounts above 0 in g, ml or pc, snake_case keys', () {
      final json = jsonDecode(promptExample('cookbook_import.v1.md')) as Map<String, dynamic>;
      final recipes = json['recipes'] as List;
      final lines = (recipes[0] as Map)['ingredients'] as List;
      (lines[7] as Map)['qty'] = 0;
      (lines[1] as Map)['unit'] = 'tbsp';
      (lines[2] as Map)['key'] = 'Lemon juice';
      recipes[1] = {...recipes[1] as Map, 'id': 7};
      final r = CookbookRecipesOutput.parse(json, ids: {0, 1});
      expect(r.ok, isFalse);
      expect(r.errors, contains(startsWith(r'$.recipes[0].ingredients[7].qty must be > 0')));
      expect(r.errors, contains(startsWith(r"$.recipes[0].ingredients[1].unit 'tbsp' is not one of g, ml, pc")));
      expect(r.errors, contains(startsWith(r"$.recipes[0].ingredients[2].key 'Lemon juice' must be")));
      expect(r.errors, contains(startsWith(r'$.recipes[1].id 7 was not asked for')));
      expect(r.errors, contains(startsWith(r'$.recipes has no entry for id 1')));
    });
    test('schemas list every field as required', () {
      final recipe = (AiSchemas.cookbookRecipes['properties']['recipes'] as Map)['items'] as Map;
      expect((recipe['required'] as List).toSet(), (recipe['properties'] as Map).keys.toSet());
      final line = (recipe['properties']['ingredients'] as Map)['items'] as Map;
      expect((line['required'] as List).toSet(), (line['properties'] as Map).keys.toSet());
      expect(
        (AiSchemas.cookbookIndex['required'] as List).toSet(),
        (AiSchemas.cookbookIndex['properties'] as Map).keys.toSet(),
      );
    });
    test('a PDF goes before the text: inline bytes or the uploaded file', () {
      final c = GeminiClient(httpClient: FakeGemini().client, apiKey: () async => 'k');
      final pdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);
      final body = c.buildBody(
        GeminiRequest(
          systemPrompt: 's',
          turns: [
            Turn.user('{}', const [], [
              Attachment.inline('application/pdf', pdf),
              const Attachment.uploaded('application/pdf', 'https://x/files/abc'),
            ]),
          ],
        ),
      );
      expect((body['contents'] as List).single['parts'], [
        {
          'inlineData': {'mimeType': 'application/pdf', 'data': base64Encode(pdf)},
        },
        {
          'fileData': {'mimeType': 'application/pdf', 'fileUri': 'https://x/files/abc'},
        },
        {'text': '{}'},
      ]);
    });
  });

  group('DTO strictness', () {
    test('decimal money, unknown enum and missing profile are path-qualified errors', () {
      final json = jsonDecode(promptExample('receipt_extraction.v4.md')) as Map<String, dynamic>;
      final items = json['items'] as List;
      (items[0] as Map)['total_minor'] = 4.99;
      (items[2] as Map)['spend_category'] = 'toiletries';
      (items[1] as Map)['new_ingredient'] = 'Greek yogurt';
      (items[3] as Map)['shelf_price'] = {'package_qty': 500, 'price_minor': 0};
      final r = ReceiptExtraction.parse(json);
      expect(r.ok, isFalse);
      expect(r.errors, contains(r'$.items[0].total_minor must be an integer'));
      expect(r.errors.any((e) => e.contains(r"$.items[2].spend_category 'toiletries'")), isTrue);
      expect(r.errors, contains(r'$.items[1].new_ingredient must be an object or null'));
      expect(r.errors, contains(r'$.items[3].shelf_price.price_minor must be > 0'));
    });
    test('a recipe ingredient is stock or missing: "staple" no longer exists', () {
      final json = jsonDecode(promptExample('daily_recipe.v2.md')) as Map<String, dynamic>;
      ((json['recipe'] as Map)['ingredients'] as List)[5]['role'] = 'staple';
      final r = DailyRecipeOutput.parse(json);
      expect(r.ok, isFalse);
      expect(r.errors.single, contains("'staple' is not one of stock, missing"));
    });
    test('schemas mirror the prompts', () {
      final action = (AiSchemas.quickLog['properties']['actions'] as Map)['items'] as Map;
      expect(
        (action['required'] as List).toSet(),
        (action['properties'] as Map).keys.toSet(),
        reason: 'every action field is always present',
      );
      expect((action['properties']['category'] as Map)['enum'], isNot(contains('groceries')));
      final item = (AiSchemas.receipt['properties']['items'] as Map)['items'] as Map;
      expect(item['required'], containsAll(['product', 'shelf_price']));
      expect((item['properties']['new_ingredient'] as Map)['properties'], isNot(contains('suggest_staple')));
      List<dynamic> roles(Map<String, dynamic> schema) =>
          ((schema['properties']['recipe']['properties']['ingredients'] as Map)['items']
              as Map)['properties']['role']['enum'];
      expect(roles(AiSchemas.daily), ['stock']);
      expect(roles(AiSchemas.spontaneous), ['stock', 'missing']);
    });
    test('nutrition estimates must cover every requested key with sane values', () {
      final json = jsonDecode(promptExample('nutrition_estimate.v1.md')) as Map<String, dynamic>;
      final items = json['items'] as List;
      (items[0] as Map)['density_g_per_ml'] = null;
      ((items[1] as Map)['per_100g'] as Map)['carbs_g'] = 720;
      (items[2] as Map)['key'] = 'sea_salt';
      final r = NutritionEstimates.parse(
        json,
        units: const {'olive_oil': BaseUnit.ml, 'flour': BaseUnit.g, 'salt': BaseUnit.g, 'stock_cube': BaseUnit.pc},
      );
      expect(r.ok, isFalse);
      expect(r.errors.any((e) => e.startsWith(r'$.items[0].density_g_per_ml is required')), isTrue);
      expect(r.errors, contains(r'$.items[1].per_100g.carbs_g must be between 0 and 100 per 100 g'));
      expect(r.errors, contains(r"$.items[2].key 'sea_salt' was not in the input; copy input keys exactly"));
      expect(r.errors, contains(r'$.items is missing keys: salt'));
    });
    test('a per-serving label needs a serving size', () {
      final json = jsonDecode(promptExample('nutrition_label.v1.md')) as Map<String, dynamic>;
      json['basis'] = 'per_serving';
      expect(LabelReading.parse(json).ok, isFalse);
      json['serving_size_g'] = 30;
      expect(LabelReading.parse(json).ok, isTrue);
    });
    test('a price lookup answers every id once, with one pack at a plausible price', () {
      ParseResult<PriceLookup> parse(List<Object> items) =>
          PriceLookup.parse({'schema_version': 1, 'items': items}, units: const {'0': BaseUnit.g, '1': BaseUnit.pc});
      final ok = {
        'id': '0',
        'found': true,
        'price_minor': 199,
        'package_qty': 500,
        'store': 'REWE',
        'source': 'rewe.de',
        'note': null,
      };
      final none = {
        'id': '1',
        'found': false,
        'price_minor': null,
        'package_qty': null,
        'store': null,
        'source': null,
        'note': ' ',
      };
      expect(parse([ok, none]).ok, isTrue);
      expect(parse([ok, none]).value!.items[1].note, isNull, reason: 'a blank note is no note');
      expect(parse([ok]).errors.single, r'$.items is missing ids: 1');
      expect(parse([ok, ok, none]).errors.single, contains("'0' appears twice"));
      expect(
        parse([
          ok,
          {...none, 'id': '7'},
        ]).errors,
        containsAll([r"$.items[1].id '7' was not in the input; copy input ids exactly", r'$.items is missing ids: 1']),
      );
      expect(
        parse([
          {...ok, 'price_minor': 1.99},
          none,
        ]).errors.single,
        r'$.items[0].price_minor must be an integer',
      );
      expect(
        parse([
          {...ok, 'price_minor': 0},
          none,
        ]).errors.single,
        contains('between 1 and 100000'),
      );
      expect(
        parse([
          ok,
          {...none, 'found': true, 'price_minor': 299, 'package_qty': 100},
        ]).errors.single,
        r'$.items[1].package_qty must be between 0 and 60 pc for one pack',
      );
      expect(
        parse([
          {...ok}..remove('found'),
          none,
        ]).errors.single,
        r'$.items[0].found is required (boolean)',
      );
    });
    test('a quick log may only point at what exists, in its unit, with money and dates that make sense', () {
      final ctx = QuickLogContext(
        now: DateTime(2026, 10, 2, 18, 40),
        pantry: const {'cola_zero': BaseUnit.pc, 'whole_milk': BaseUnit.ml},
        fridge: const {12: 3},
        recipes: const {4},
      );
      Map<String, dynamic> a(String type, Map<String, dynamic> f) => {
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
        ...f,
      };
      List<String> errors(List<Map<String, dynamic>> actions, {String? question}) => QuickLog.parse({
        'schema_version': 1,
        'actions': actions,
        'total_paid_minor': null,
        'question': question,
      }, ctx: ctx).errors;

      expect(
        errors([
          a('eat', {'source': 'fridge', 'batch_id': 99, 'portions': 1}),
        ]),
        [r'$.actions[0].batch_id 99 is not in the fridge'],
      );
      expect(
        errors([
          a('eat', {'source': 'pantry', 'key': 'cola', 'qty': 1, 'unit': 'pc'}),
        ]),
        [r"$.actions[0].key 'cola' is not in the pantry; copy pantry keys exactly"],
      );
      // Amounts come as said; Dart converts what it can (docs/07 §7.4).
      expect(
        errors([
          a('eat', {'source': 'pantry', 'key': 'cola_zero', 'qty': 330, 'unit': 'ml'}),
          a('eat', {'source': 'pantry', 'key': 'whole_milk', 'qty': 2, 'unit': 'tbsp'}),
          a('eat', {'source': 'pantry', 'key': 'cola_zero', 'qty': 1, 'unit': 'glass'}),
        ]),
        isEmpty,
        reason: 'ml and measures convert by the piece size or the density',
      );
      expect(
        errors([
          a('eat', {'source': 'pantry', 'key': 'whole_milk', 'qty': 1, 'unit': 'pc'}),
        ]),
        [
          r"$.actions[0].unit 'whole_milk' is counted in ml: give one piece as its volume "
              '(a can of cola is 330 ml, a tortilla 40 g)',
        ],
        reason: 'an item measured in ml has no piece size',
      );
      expect(
        errors([
          a('eat', {'source': 'pantry', 'key': 'whole_milk', 'qty': 1, 'unit': 'spoon'}),
        ]).single,
        contains("'spoon' is not one of g, ml, pc, tsp, tbsp, cup, glass, pinch, handful"),
      );
      expect(
        errors([
          a('buy', {'key': 'whole_milk', 'qty': 1, 'unit': 'cup', 'paid_minor': 99}),
        ]).single,
        contains("'cup' is not one of g, ml, pc"),
        reason: 'a purchase is counted, not measured with a spoon',
      );
      expect(
        errors([
          a('buy', {'key': 'whole_milk', 'qty': 6, 'unit': 'pc', 'paid_minor': 594}),
        ]).single,
        contains(r"$.actions[0].piece_size is required to count 'whole_milk' in pieces"),
      );
      expect(
        errors([
          a('buy', {
            'key': 'whole_milk',
            'qty': 6,
            'unit': 'pc',
            'piece_name': 'bottle',
            'piece_size': 500,
            'piece_unit': 'ml',
            'paid_minor': 594,
          }),
          a('eat', {'source': 'pantry', 'key': 'whole_milk', 'qty': 1, 'unit': 'pc'}),
        ]),
        isEmpty,
        reason: 'a purchase in pieces switches the item to pieces, so a piece can be eaten after it',
      );
      expect(
        errors([
          a('buy', {'key': 'cola_zero', 'qty': 1, 'unit': 'pc'}),
        ]),
        [r'$.actions[0].est_price_minor is required when paid_minor is null'],
        reason: 'no invented price',
      );
      expect(
        errors([
          a('buy', {'key': 'oat_milk', 'qty': 1000, 'unit': 'ml', 'paid_minor': 199}),
        ]),
        isEmpty,
        reason: 'a new item without its profile is logged; its macros are estimated later, in a batch',
      );
      expect(
        errors([
          a('expense', {'paid_minor': 450, 'category': 'groceries'}),
        ]).single,
        contains("'groceries' is not one of"),
        reason: 'groceries are bought, not an expense',
      );
      expect(
        errors([
          a('cook', {'recipe_id': 4, 'portions': 2, 'ate_portions': 3}),
        ]),
        [r'$.actions[0].ate_portions must be between 0 and the portions cooked'],
      );
      expect(
        errors([
          a('expense', {'paid_minor': 450, 'category': 'other', 'when': '2026-10-03T09:00'}),
        ]).single,
        contains('is after now'),
      );
      expect(
        errors([
          a('expense', {'paid_minor': 450, 'category': 'other', 'when': '2026-09-01T09:00'}),
        ]).single,
        contains('more than 14 days back'),
      );
      expect(errors(const []), [r'$.question is required when there are no actions']);
      expect(errors(const [], question: 'Which chili?'), isEmpty);
      // A key bought earlier in the message can be eaten after it.
      expect(
        errors([
          a('buy', {
            'key': 'banana',
            'qty': 3,
            'unit': 'pc',
            'paid_minor': 99,
            'new_ingredient': {
              'name': 'Banana',
              'ingredient_category': 'produce',
              'unit': 'pc',
              'grams_per_piece': 120,
              'density_g_per_ml': null,
              'per_100': {'kcal': 89, 'protein_g': 1.1, 'carbs_g': 20, 'fat_g': 0.3, 'fiber_g': 2.6},
              'shelf_life_days': 5,
            },
          }),
          a('eat', {'source': 'pantry', 'key': 'banana', 'qty': 1, 'unit': 'pc'}),
        ]),
        isEmpty,
      );
    });
    test('daily recipe may not contain missing items', () {
      final json = jsonDecode(promptExample('daily_recipe.v2.md')) as Map<String, dynamic>;
      ((json['recipe'] as Map)['ingredients'] as List)[0]['role'] = 'missing';
      final r = DailyRecipeOutput.parse(json);
      expect(r.ok, isFalse);
    });
  });

  group('GeminiClient', () {
    test('builds the documented body and skips thought parts', () async {
      final fake = FakeGemini()..reply('{"ok":true}');
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'gemini-3.5-flash-lite');
      final res = await c.generate(
        GeminiRequest(
          systemPrompt: 'sys',
          turns: const [Turn.user('hi')],
          thinkingLevel: 'low',
          highMediaResolution: true,
          responseSchema: {'type': 'object'},
        ),
      );
      expect(res.text, '{"ok":true}');
      expect(res.inputTokens, 1200);
      final body = fake.requests.single;
      expect(body['systemInstruction']['parts'][0]['text'], 'sys');
      expect(body['generationConfig']['responseMimeType'], 'application/json');
      expect(body['generationConfig']['thinkingConfig'], {'thinkingLevel': 'low'});
      expect(body['generationConfig']['responseJsonSchema'], {'type': 'object'});
      expect(body['generationConfig']['mediaResolution'], 'MEDIA_RESOLUTION_HIGH');
    });

    test('retries a 503 then succeeds', () async {
      final fake = FakeGemini()
        ..status(503, 'overloaded')
        ..reply('{}');
      final waits = <Duration>[];
      final c = GeminiClient(
        httpClient: fake.client,
        apiKey: () async => 'k',
        model: 'm',
        delay: (d) async => waits.add(d),
      );
      await c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')]));
      expect(waits, [const Duration(seconds: 2)]);
    });

    test('400 on an unknown field steps down the config and remembers it', () async {
      final fake = FakeGemini()
        ..status(400, 'Invalid JSON payload received. Unknown name "responseJsonSchema"')
        ..reply('{}');
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm');
      await c.generate(
        GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')], responseSchema: {'type': 'object'}),
      );
      expect(fake.requests[1]['generationConfig'].containsKey('responseJsonSchema'), isFalse);
      expect(GeminiClient.compatLevel, 1);
    });

    test('missing key is a clear error', () async {
      final c = GeminiClient(httpClient: FakeGemini().client, apiKey: () async => null, model: 'm');
      expect(
        () => c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')])),
        throwsA(isA<GeminiException>()),
      );
    });

    test('defaults to gemini-3.5-flash-lite primary and gemini-3.8-flash fallback', () async {
      final fake = FakeGemini()..reply('{"ok":true}');
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k');
      expect(c.model, 'gemini-3.5-flash-lite');
      expect(c.fallbackModel, 'gemini-3.8-flash');
      final res = await c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')]));
      expect(res.model, 'gemini-3.5-flash-lite');
      expect(fake.requestedUris.single.path, contains('gemini-3.5-flash-lite'));
    });

    test('falls back to gemini-3.8-flash when primary model fails', () async {
      final fake = FakeGemini()
        ..status(404, 'model not found')
        ..reply('{"fallback":true}');
      final c = GeminiClient(
        httpClient: fake.client,
        apiKey: () async => 'k',
        model: 'gemini-3.5-flash-lite',
        fallbackModel: 'gemini-3.8-flash',
      );
      final res = await c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')]));
      expect(res.text, '{"fallback":true}');
      expect(res.model, 'gemini-3.8-flash');
      expect(fake.requestedUris[0].path, contains('gemini-3.5-flash-lite'));
      expect(fake.requestedUris[1].path, contains('gemini-3.8-flash'));
    });

    test('falls back to gemini-3.8-flash after primary retries are exhausted', () async {
      final fake = FakeGemini()
        ..status(503, 'overloaded')
        ..status(503, 'overloaded')
        ..status(503, 'overloaded')
        ..reply('{"fallback":true}');
      final waits = <Duration>[];
      final c = GeminiClient(
        httpClient: fake.client,
        apiKey: () async => 'k',
        model: 'gemini-3.5-flash-lite',
        fallbackModel: 'gemini-3.8-flash',
        delay: (d) async => waits.add(d),
      );
      final res = await c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')]));
      expect(res.text, '{"fallback":true}');
      expect(res.model, 'gemini-3.8-flash');
      expect(fake.requestedUris.where((u) => u.path.contains('gemini-3.5-flash-lite')).length, 3);
      expect(fake.requestedUris.where((u) => u.path.contains('gemini-3.8-flash')).length, 1);
    });

    test('a 429 goes straight to the fallback without backing off', () async {
      final fake = FakeGemini()
        ..status(429, 'Quota exceeded')
        ..reply('{"fallback":true}');
      final waits = <Duration>[];
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k', delay: (d) async => waits.add(d));
      final res = await c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')]));
      expect(res.model, 'gemini-3.8-flash');
      expect(fake.requestedUris.length, 2);
      expect(waits, isEmpty);
    });

    test('a daily-quota 429 reads as a daily limit, not "retry in 47s"', () async {
      final fake = FakeGemini()
        ..status(
          429,
          'You exceeded your current quota... Please retry in 46.96s.',
          details: [
            {
              '@type': 'type.googleapis.com/google.rpc.QuotaFailure',
              'violations': [
                {
                  'quotaMetric': 'generativelanguage.googleapis.com/generate_content_free_tier_requests',
                  'quotaId': 'GenerateRequestsPerDayPerProjectPerModel-FreeTier',
                  'quotaValue': '500',
                },
              ],
            },
            {'@type': 'type.googleapis.com/google.rpc.RetryInfo', 'retryDelay': '46s'},
          ],
        )
        ..status(503, 'overloaded');
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k', fallbackModel: null);
      expect(
        () => c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')])),
        throwsA(
          isA<GeminiException>()
              .having((e) => e.status, 'status', 429)
              .having(
                (e) => e.message,
                'message',
                'Daily free-tier limit reached for gemini-3.5-flash-lite (500 requests). It resets at midnight Pacific time.',
              ),
        ),
      );
    });

    test('throws when both primary and fallback fail', () async {
      final fake = FakeGemini()
        ..status(404, 'primary missing')
        ..status(404, 'fallback missing');
      final c = GeminiClient(
        httpClient: fake.client,
        apiKey: () async => 'k',
        model: 'gemini-3.5-flash-lite',
        fallbackModel: 'gemini-3.8-flash',
      );
      expect(
        () => c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')])),
        throwsA(
          isA<GeminiException>().having(
            (e) => e.message,
            'message',
            allOf(contains('gemini-3.5-flash-lite'), contains('gemini-3.8-flash')),
          ),
        ),
      );
    });

    test('stripFences', () {
      expect(GeminiClient.stripFences('```json\n{"a":1}\n```'), '{"a":1}');
      expect(GeminiClient.stripFences('Sure! {"a":1}'), '{"a":1}');
      expect(GeminiClient.stripFences('{"a":1}\nPrices from rewe.de.'), '{"a":1}');
    });

    test('a Google Search request turns the tool on, asks for plain-text JSON and reads the grounding', () async {
      final fake = FakeGemini()..reply('{"ok":true}', grounding: groundingMetadata());
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm');
      final res = await c.generate(
        GeminiRequest(
          systemPrompt: 's',
          turns: const [Turn.user('x')],
          thinkingLevel: 'low',
          responseSchema: {'type': 'object'},
          googleSearch: true,
        ),
      );
      final body = fake.requests.single;
      expect(body['tools'], [
        {'google_search': {}},
      ]);
      final config = body['generationConfig'] as Map;
      expect(config.containsKey('responseMimeType'), isFalse, reason: 'JSON mode drops the sources');
      expect(config.containsKey('responseJsonSchema'), isFalse);
      expect(config['thinkingConfig'], {'thinkingLevel': 'low'});
      final g = res.grounding!;
      expect(g.queries, ['Barilla Spaghetti n.5 500 g Preis']);
      expect(g.sources.single.title, 'lidl.de');
      expect(g.sources.single.uri, startsWith('https://vertexaisearch.cloud.google.com/'));
      expect(g.searchEntryHtml, contains('class="chip"'));

      final plain = FakeGemini()..reply('{}');
      final res2 = await GeminiClient(
        httpClient: plain.client,
        apiKey: () async => 'k',
        model: 'm',
      ).generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')]));
      expect(plain.requests.single.containsKey('tools'), isFalse);
      expect(res2.grounding, isNull);
    });

    test("a 400 on a search request goes to the fallback and doesn't step down the config", () async {
      final fake = FakeGemini()
        ..status(400, 'Invalid JSON payload received. Unknown name "google_search"')
        ..status(400, 'Invalid JSON payload received. Unknown name "google_search"');
      final c = GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm', fallbackModel: 'f');
      await expectLater(
        c.generate(GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')], googleSearch: true)),
        throwsA(isA<GeminiException>()),
      );
      expect(fake.requestedUris.map((u) => u.pathSegments.last), ['m:generateContent', 'f:generateContent']);
      expect(GeminiClient.compatLevel, 0, reason: 'other calls keep their JSON schema');
    });
  });

  group('AiRunner', () {
    test('one repair retry sends the errors back and succeeds', () async {
      final bad = jsonDecode(promptExample('daily_recipe.v2.md')) as Map<String, dynamic>;
      bad['status'] = 'great';
      final fake = FakeGemini()
        ..replyJson(bad)
        ..reply(promptExample('daily_recipe.v2.md'));
      final runner = AiRunner(null, GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm'));
      final out = await runner.run(
        task: AiTask.dailyRecipe,
        promptVersion: 'daily_recipe.v2',
        request: GeminiRequest(systemPrompt: 's', turns: const [Turn.user('{}')]),
        parse: DailyRecipeOutput.parse,
      );
      expect(out.ok, isTrue);
      expect(out.repaired, isTrue);
      final second = fake.requests[1]['contents'] as List;
      expect(second.length, 3);
      expect(second[1]['role'], 'model');
      expect(second[2]['parts'][0]['text'], contains("'great' is not one of ok, insufficient_stock"));
    });

    test('gives up after the repair round', () async {
      final fake = FakeGemini()
        ..reply('not json')
        ..reply('still not json');
      final runner = AiRunner(null, GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm'));
      final out = await runner.run(
        task: AiTask.dailyRecipe,
        promptVersion: 'v',
        request: GeminiRequest(systemPrompt: 's', turns: const [Turn.user('{}')]),
        parse: DailyRecipeOutput.parse,
      );
      expect(out.ok, isFalse);
      expect(out.errors.first, startsWith('Response is not valid JSON'));
    });

    test('a repaired search answer keeps the searches of the first round', () async {
      final fake = FakeGemini()
        ..reply('{"schema_version":1,"items":[]}', grounding: groundingMetadata())
        ..reply(promptExample('price_lookup.v1.md'));
      final runner = AiRunner(null, GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm'));
      final out = await runner.run(
        task: AiTask.priceLookup,
        promptVersion: 'price_lookup.v1',
        request: GeminiRequest(systemPrompt: 's', turns: const [Turn.user('{}')], googleSearch: true),
        parse: (m) => PriceLookup.parse(m, units: const {'0': BaseUnit.g, '1': BaseUnit.g}),
      );
      expect(out.ok, isTrue);
      expect(out.repaired, isTrue);
      expect(out.grounding!.queries, ['Barilla Spaghetti n.5 500 g Preis']);
    });

    test('AiRunner uses fallback model when primary fails', () async {
      final fake = FakeGemini()
        ..status(404, 'primary unavailable')
        ..reply(promptExample('daily_recipe.v2.md'));
      final client = GeminiClient(
        httpClient: fake.client,
        apiKey: () async => 'k',
        model: 'gemini-3.5-flash-lite',
        fallbackModel: 'gemini-3.8-flash',
      );
      final runner = AiRunner(null, client);
      final out = await runner.run(
        task: AiTask.dailyRecipe,
        promptVersion: 'daily_recipe.v2',
        request: GeminiRequest(systemPrompt: 's', turns: const [Turn.user('{}')]),
        parse: DailyRecipeOutput.parse,
      );
      expect(out.ok, isTrue);
      expect(fake.requestedUris[0].path, contains('gemini-3.5-flash-lite'));
      expect(fake.requestedUris[1].path, contains('gemini-3.8-flash'));
    });
  });

  group('ContextBuilders', () {
    final now = DateTime(2026, 9, 28, 20);
    final p = UserProfile()
      ..dailyKcalTarget = 2100
      ..dailyProteinTargetG = 135
      ..allergies = ['peanut'];
    final items = [
      ingredient('pasta', qty: 500, shelf: 365, cost: 0.3),
      ingredient('spinach', qty: 210, shelf: 5, expiresAt: DateTime(2026, 9, 29, 20), cost: 0.8, kcal: 23),
      ingredient('egg', qty: 6, unit: BaseUnit.pc, gpp: 55),
      ingredient('salt', qty: 450, shelf: 1825, cost: 0.098),
      ingredient('pepper'),
      ingredient('crumbs', qty: 2),
    ];

    test('inventory is sorted by days_left; seasonings are in it, used-up items and traces are not', () {
      final inv = ContextBuilders.inventory(items, now);
      expect(inv.map((e) => e['key']), ['spinach', 'egg', 'pasta', 'salt']);
      expect(inv.first['days_left'], 1);
      expect(inv[1]['g_per_pc'], 55);
      expect(inv.last['days_left'], isNull);
    });

    test('daily envelope has targets per portion and no staples', () {
      final ctx = ContextBuilders.daily(
        profile: p,
        ingredients: items,
        now: now,
        forDate: DateTime(2026, 9, 29),
        recentTitles: const ['Chili'],
      );
      expect(ctx['today'], '2026-09-29');
      expect(ctx['weekday'], 'Tuesday');
      expect(ctx['targets_per_portion'], {'kcal': 700, 'protein_g': 45, 'max_cost_minor': 300});
      expect(ctx.containsKey('staples'), isFalse);
      expect((ctx['inventory'] as List).map((e) => e['key']), contains('salt'));
      expect(ctx['profile']['allergies'], ['peanut']);
    });

    test('price lookup input: ids, the product and the unit to price in', () {
      final m = ContextBuilders.priceLookup(
        profile: UserProfile()
          ..country = 'DE'
          ..currency = 'EUR',
        now: DateTime(2026, 10, 2, 9),
        items: {
          '3': DraftLine()
            ..name = 'Eggs'
            ..unit = BaseUnit.pc
            ..product = 'Bio eggs, 10 pcs'
            ..packageQty = 10,
        },
      );
      expect(m['today'], '2026-10-02');
      expect((m['country'], m['currency'], m['minor_unit_digits']), ('DE', 'EUR', 2));
      expect(m['items'], [
        {'id': '3', 'product': 'Bio eggs, 10 pcs', 'name': 'Eggs', 'unit': 'pc', 'package_qty': 10.0},
      ]);
    });

    test('portion parsing', () {
      expect(ContextBuilders.parsePortions('carbonara for two'), 2);
      expect(ContextBuilders.parsePortions('chili for 4 days'), 4);
      expect(ContextBuilders.parsePortions('3 portions of curry'), 3);
      expect(ContextBuilders.parsePortions('something with salmon'), isNull);
    });
  });
}
