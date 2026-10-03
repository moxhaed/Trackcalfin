import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/migrations.dart';
import 'package:trackcalfin/application/nutrition_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/recipe_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

void main() {
  late Isar isar;
  late FakeGemini fake;
  late AiGateway ai;
  late NutritionService svc;
  final now = DateTime(2026, 9, 30, 12);
  final photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  setUp(() async {
    GeminiClient.compatLevel = 0;
    isar = await openTestDb();
    await ProfileService(isar).load();
    fake = FakeGemini();
    ai = AiGateway(
      isar: isar,
      secrets: MemorySecretStore('test-key'),
      prompts: PromptRepository(loadPromptAsset),
      httpClient: fake.client,
    );
    svc = NutritionService(isar: isar, ai: ai, now: () => now);
  });
  tearDown(() => closeTestDb(isar));

  Future<Ingredient> byKey(String key) async => (await isar.ingredients.getByKey(key))!;

  Future<int> addChicken() => PantryService(isar).upsert(
    Ingredient()
      ..key = 'chicken_breast'
      ..name = 'Chicken breast'
      ..qtyOnHand = 500
      ..per100 = Nutrition(kcal: 110, proteinG: 23)
      ..nutritionSource = DataSource.aiEstimate,
  );

  RecipeIngredient line(String key, double qty, BaseUnit unit) => RecipeIngredient()
    ..key = key
    ..name = key
    ..qtyPerPortion = qty
    ..unit = unit;

  /// An item added by hand with empty nutrition fields.
  Future<int> addUnknown(String key, String name, {BaseUnit unit = BaseUnit.g}) => PantryService(isar).upsert(
    Ingredient()
      ..key = key
      ..name = name
      ..baseUnit = unit,
  );

  test('items without macros get AI macros, ml per 100 ml, and saved recipes count them', () async {
    await addUnknown('olive_oil', 'Olive oil', unit: BaseUnit.ml);
    await addUnknown('flour', 'Flour');
    await addUnknown('salt', 'Salt');
    await addUnknown('stock_cube', 'Stock cube', unit: BaseUnit.pc);
    await addChicken();
    expect((await byKey('flour')).needsNutrition, isTrue);
    final recipeId = await RecipeService(isar).save(
      Recipe()
        ..title = 'Schnitzel'
        ..ingredients = [
          line('chicken_breast', 150, BaseUnit.g),
          line('flour', 20, BaseUnit.g),
          line('olive_oil', 10, BaseUnit.ml),
        ],
    );
    expect((await isar.recipes.get(recipeId))!.perPortion.kcal, closeTo(165, 0.01), reason: 'unknown macros count 0');

    fake.reply(promptExample('nutrition_estimate.v1.md'));
    final r = await svc.fillMissing();
    expect(r.error, isNull);
    expect(r.filled, 4);

    final ctx = jsonDecode(fake.requests.single['contents'][0]['parts'][0]['text']);
    expect((ctx['items'] as List).map((i) => i['key']), containsAll(['olive_oil', 'flour', 'salt', 'stock_cube']));
    expect((ctx['items'] as List).firstWhere((i) => i['key'] == 'olive_oil')['unit'], 'ml');

    final oil = await byKey('olive_oil');
    expect(oil.per100.kcal, 804.4);
    expect(oil.densityGPerMl, 0.91);
    expect(oil.nutritionSource, DataSource.aiEstimate);
    expect(oil.nutritionConfirmedAt, isNull);
    expect((await byKey('salt')).needsNutrition, isFalse, reason: 'zeros from the AI are an answer');
    expect((await byKey('stock_cube')).gramsPerPiece, 10);

    // 150 g chicken + 20 g flour + 10 ml oil.
    expect((await isar.recipes.get(recipeId))!.perPortion.kcal, closeTo(165 + 69.6 + 80.44, 0.01));

    expect((await svc.fillMissing()).filled, 0);
    expect(fake.requests.length, 1, reason: 'nothing left to ask');
  });

  group('asking again', () {
    Map<String, dynamic> estimate(String key, {double? density}) => {
      'key': key,
      'per_100g': {'kcal': 348, 'protein_g': 10, 'carbs_g': 72, 'fat_g': 1, 'fiber_g': 4},
      'density_g_per_ml': density,
      'grams_per_piece': null,
    };
    Map<String, dynamic> answer(List<Map<String, dynamic>> items) => {'schema_version': 1, 'items': items};
    Set<String> asked(int i) => {
      for (final it in jsonDecode(fake.requests[i]['contents'][0]['parts'][0]['text'])['items'] as List)
        it['key'] as String,
    };

    test('a batch that fails its repair round keeps what checked out; the rest waits to be asked again', () async {
      var t = now;
      final s = NutritionService(isar: isar, ai: ai, now: () => t);
      await addUnknown('flour', 'Flour');
      await addUnknown('salt', 'Salt');
      await addUnknown('olive_oil', 'Olive oil', unit: BaseUnit.ml);
      final noDensity = answer([estimate('flour'), estimate('salt'), estimate('olive_oil')]);
      fake
        ..replyJson(noDensity)
        ..replyJson(noDensity);
      final r = await s.fillMissing();
      expect(r.filled, 2);
      expect(r.error, contains('density_g_per_ml'));
      expect(fake.requests, hasLength(2), reason: 'the answer and its repair round');
      expect((await byKey('flour')).needsNutrition, isFalse);
      expect((await byKey('olive_oil')).needsNutrition, isTrue);

      expect((await s.fillMissing()).filled, 0);
      expect(fake.requests, hasLength(2), reason: 'olive oil failed a moment ago: app resumes ask nothing');

      t = t.add(NutritionService.backoff.first);
      fake.replyJson(answer([estimate('olive_oil', density: 0.91)]));
      expect((await s.fillMissing()).filled, 1);
      expect(asked(2), {'olive_oil'});
    });

    test('calls while one runs share its request', () async {
      await addUnknown('flour', 'Flour');
      fake.replyJson(answer([estimate('flour')]));
      final results = await Future.wait([svc.fillMissing(), svc.fillMissing(), svc.fillMissingNow()]);
      expect([for (final r in results) r.filled], [1, 1, 1]);
      expect(fake.requests, hasLength(1));
    });

    test('a quota error pauses background runs; Fill with AI still asks, on the fallback if it must', () async {
      await addUnknown('flour', 'Flour');
      fake.status(429, 'Quota exceeded', details: quotaDetails(perDay: true, limit: '500'));
      expect((await svc.fillMissing()).error, startsWith('Daily free-tier limit reached'));
      expect((await svc.fillMissing()).error, isNull);
      expect(fake.requests, hasLength(1), reason: 'background runs pause, and never spend the fallback');
      fake.replyJson(answer([estimate('flour')]));
      expect((await svc.fillMissingNow()).filled, 1);
      expect(fake.requestedUris.last.path, contains(GeminiClient.defaultFallbackModel));
      expect(fake.requests, hasLength(2), reason: 'the spent model is not asked again today');
    });
  });

  test('without a key nothing is asked and items stay unknown', () async {
    await addUnknown('flour', 'Flour');
    final noKey = NutritionService(
      isar: isar,
      ai: AiGateway(isar: isar, secrets: MemorySecretStore(), prompts: PromptRepository(loadPromptAsset)),
    );
    final r = await noKey.fillMissing();
    expect(r.error, contains('API key'));
    expect((await byKey('flour')).needsNutrition, isTrue);
  });

  test('a label is read and converted but only saved once the user keeps it', () async {
    await addUnknown('flour', 'Flour');
    final flour = await byKey('flour');
    fake.reply(promptExample('nutrition_label.v1.md'));
    final draft = await svc.readLabel(flour.id, [photo]);
    expect(draft.ok, isTrue, reason: draft.error);
    expect(draft.productName, 'Aurora Weizenmehl Type 405');
    expect(draft.numbers!.per100.carbsG, 72);
    final parts = fake.requests.single['contents'][0]['parts'] as List;
    expect(parts.length, 2, reason: 'context JSON + photo');
    expect((await byKey('flour')).needsNutrition, isTrue, reason: 'readLabel saves nothing');

    await svc.setNutrition(flour.id, draft.numbers!.per100, DataSource.label);
    final saved = await byKey('flour');
    expect(saved.per100.kcal, 348);
    expect(saved.nutritionSource, DataSource.label);
    expect(saved.nutritionConfirmedAt, now);
  });

  test('an unreadable label explains itself; confirm marks an estimate as checked', () async {
    final id = await addChicken();
    fake.replyJson({
      'schema_version': 1,
      'image_type': 'unreadable',
      'product_name': null,
      'basis': null,
      'serving_size_g': null,
      'serving_size_ml': null,
      'energy_kcal': null,
      'energy_kj': null,
      'protein_g': null,
      'carbs_g': null,
      'fat_g': null,
      'fiber_g': null,
      'carbs_include_fiber': false,
      'warnings': ['no_nutrition_table'],
    });
    final draft = await svc.readLabel(id, [photo]);
    expect(draft.ok, isFalse);
    expect(draft.error, contains('no_nutrition_table'));

    expect((await byKey('chicken_breast')).nutritionSource, DataSource.aiEstimate, reason: 'unchanged');
  });

  test('migration v2 marks all-zero macros as unknown, once', () async {
    await PantryService(isar).upsert(
      Ingredient()
        ..key = 'olive_oil'
        ..name = 'Olive oil'
        ..nutritionSource = DataSource.aiEstimate,
    );
    await PantryService(isar).upsert(
      Ingredient()
        ..key = 'water'
        ..name = 'Water'
        ..nutritionSource = DataSource.label,
    );
    await addChicken();
    final p = (await isar.userProfiles.get(1))!..schemaVersion = 1;
    await isar.writeTxn(() => isar.userProfiles.put(p));

    await Migrations.run(isar);
    expect((await byKey('olive_oil')).needsNutrition, isTrue);
    expect((await byKey('water')).nutritionSource, DataSource.label);
    expect((await byKey('chicken_breast')).nutritionSource, DataSource.aiEstimate);
    expect((await isar.userProfiles.get(1))!.schemaVersion, Migrations.current);

    // Once the AI has answered "0 kcal" (salt), a later start leaves it alone.
    await isar.writeTxn(() async {
      final oil = (await isar.ingredients.getByKey('olive_oil'))!..nutritionSource = DataSource.aiEstimate;
      await isar.ingredients.put(oil);
    });
    await Migrations.run(isar);
    expect((await byKey('olive_oil')).nutritionSource, DataSource.aiEstimate);
  });
}
