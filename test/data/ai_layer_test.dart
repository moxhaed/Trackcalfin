import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/ai_runner.dart';
import 'package:trackcalfin/data/ai/context_builders.dart';
import 'package:trackcalfin/data/ai/dto/nutrition_dto.dart';
import 'package:trackcalfin/data/ai/dto/receipt_dto.dart';
import 'package:trackcalfin/data/ai/dto/recipe_dto.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/isar/collections/user_profile.dart';

import '../domain/fixtures.dart';
import '../support/fake_gemini.dart';

void main() {
  setUp(() => GeminiClient.compatLevel = 0);

  group('Prompt examples parse with the app DTOs', () {
    test('Prompt A example', () {
      final r = ReceiptExtraction.parse(jsonDecode(promptExample('receipt_extraction.v2.md')));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.items.length, 4);
      expect(r.value!.items[1].newIngredient!.category, IngredientCategory.dairyEggs);
      expect(r.value!.purchasedAt, DateTime(2026, 9, 27, 18, 42));
    });
    test('Prompt B example', () {
      final r = DailyRecipeOutput.parse(jsonDecode(promptExample('daily_recipe.v1.md')));
      expect(r.ok, isTrue, reason: r.errors.join('\n'));
      expect(r.value!.recipe!.ingredients.length, 6);
    });
    test('Prompt C example', () {
      final r = SpontaneousOutput.parse(jsonDecode(promptExample('spontaneous_recipe.v1.md')));
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
  });

  group('DTO strictness', () {
    test('decimal money, unknown enum and missing profile are path-qualified errors', () {
      final json = jsonDecode(promptExample('receipt_extraction.v2.md')) as Map<String, dynamic>;
      final items = json['items'] as List;
      (items[0] as Map)['total_minor'] = 4.99;
      (items[2] as Map)['spend_category'] = 'toiletries';
      (items[1] as Map)['new_ingredient'] = null;
      final r = ReceiptExtraction.parse(json);
      expect(r.ok, isFalse);
      expect(r.errors, contains(r'$.items[0].total_minor must be an integer'));
      expect(r.errors.any((e) => e.contains(r"$.items[2].spend_category 'toiletries'")), isTrue);
      expect(r.errors, contains(r'$.items[1].new_ingredient is required when is_new_ingredient is true'));
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
    test('daily recipe may not contain missing items', () {
      final json = jsonDecode(promptExample('daily_recipe.v1.md')) as Map<String, dynamic>;
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
    });
  });

  group('AiRunner', () {
    test('one repair retry sends the errors back and succeeds', () async {
      final bad = jsonDecode(promptExample('daily_recipe.v1.md')) as Map<String, dynamic>;
      bad['status'] = 'great';
      final fake = FakeGemini()
        ..replyJson(bad)
        ..reply(promptExample('daily_recipe.v1.md'));
      final runner = AiRunner(null, GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'm'));
      final out = await runner.run(
        task: AiTask.dailyRecipe,
        promptVersion: 'daily_recipe.v1',
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

    test('AiRunner uses fallback model when primary fails', () async {
      final fake = FakeGemini()
        ..status(404, 'primary unavailable')
        ..reply(promptExample('daily_recipe.v1.md'));
      final client = GeminiClient(
        httpClient: fake.client,
        apiKey: () async => 'k',
        model: 'gemini-3.5-flash-lite',
        fallbackModel: 'gemini-3.8-flash',
      );
      final runner = AiRunner(null, client);
      final out = await runner.run(
        task: AiTask.dailyRecipe,
        promptVersion: 'daily_recipe.v1',
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
      ingredient('salt', staple: true),
      ingredient('crumbs', qty: 2),
    ];

    test('inventory is sorted by days_left, excludes staples and trace amounts', () {
      final inv = ContextBuilders.inventory(items, now);
      expect(inv.map((e) => e['key']), ['spinach', 'egg', 'pasta']);
      expect(inv.first['days_left'], 1);
      expect(inv[1]['g_per_pc'], 55);
      expect(inv.last['days_left'], isNull);
    });

    test('daily envelope has targets per portion and staples', () {
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
      expect(ctx['staples'], ['salt']);
      expect(ctx['profile']['allergies'], ['peanut']);
    });

    test('portion parsing', () {
      expect(ContextBuilders.parsePortions('carbonara for two'), 2);
      expect(ContextBuilders.parsePortions('chili for 4 days'), 4);
      expect(ContextBuilders.parsePortions('3 portions of curry'), 3);
      expect(ContextBuilders.parsePortions('something with salmon'), isNull);
    });
  });
}
