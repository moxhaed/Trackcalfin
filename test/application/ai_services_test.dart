import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/ask_service.dart';
import 'package:trackcalfin/application/daily_pick_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/recipe_service.dart';
import 'package:trackcalfin/application/scan_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

void main() {
  late Isar isar;
  late FakeGemini fake;
  late AiGateway ai;
  late Directory tmp;
  final now = DateTime(2026, 9, 27, 19);

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
    tmp = await Directory.systemTemp.createTemp('scan_');
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  Future<String> photo() async {
    final f = File('${tmp.path}/p${DateTime.now().microsecondsSinceEpoch}.jpg');
    await f.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);
    return f.path;
  }

  group('ScanService', () {
    ScanService service() =>
        ScanService(isar: isar, images: ImageStore('${tmp.path}/store'), ai: ai, now: () => now);

    test('clean receipt auto-commits: ledger, stock, WAC, new ingredient, aliases', () async {
      await PantryService(isar).upsert(Ingredient()
        ..name = 'Chicken breast'
        ..key = 'chicken_breast');
      fake.reply(promptExample('receipt_extraction.v1.md'));
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'receipt');
      final results = await s.processQueue();
      expect(results.single.autoCommitted, isTrue);

      final req = fake.requests.single;
      expect((req['contents'][0]['parts'] as List).length, 2, reason: 'context JSON + 1 image');
      final ctx = jsonDecode(req['contents'][0]['parts'][0]['text']);
      expect((ctx['known_ingredients'] as List).single['key'], 'chicken_breast');

      final job = (await isar.scanJobs.get(id))!;
      expect(job.status, ScanStatus.committed);
      final tx = (await isar.transactions.get(job.transactionId!))!;
      expect(tx.totalMinor, 822);
      expect(tx.merchant, 'Lidl');
      expect(tx.occurredAt, DateTime(2026, 9, 27, 18, 42));
      expect(tx.lines.where((l) => l.category == SpendCategory.household).single.totalMinor, 119);

      final chicken = (await isar.ingredients.getByKey('chicken_breast'))!;
      expect(chicken.qtyOnHand, 500);
      expect(chicken.avgCostPerUnitMinor, closeTo(499 / 500, 1e-9));
      expect(chicken.aliases, ['HOCHL BRUSTFILET']);
      final yogurt = (await isar.ingredients.getByKey('greek_yogurt'))!;
      expect(yogurt.per100.kcal, 124);
      expect(yogurt.shelfLifeDays, 14);
      expect(yogurt.expiresAt, DateTime(2026, 10, 11, 18, 42));
    });

    test('messy receipt waits for review; commit is idempotent', () async {
      final json = jsonDecode(promptExample('receipt_extraction.v1.md')) as Map<String, dynamic>;
      json['receipt_total_minor'] = 999;
      fake.replyJson(json);
      final s = service();
      final id = await s.enqueue([await photo()]);
      final r = (await s.processQueue()).single;
      expect(r.autoCommitted, isFalse);
      expect(r.job.status, ScanStatus.needsReview);
      expect(r.job.flags, contains('total_mismatch'));
      final tx1 = await s.commit(id);
      final tx2 = await s.commit(id);
      expect(tx1, tx2);
      expect(await isar.transactions.count(), 1);
    });

    test('no key keeps the job queued; unreadable photo fails with a reason', () async {
      final noKey = ScanService(
        isar: isar,
        images: ImageStore('${tmp.path}/store'),
        ai: AiGateway(isar: isar, secrets: MemorySecretStore(), prompts: PromptRepository(loadPromptAsset)),
      );
      final id = await noKey.enqueue([await photo()]);
      await noKey.processQueue();
      expect((await isar.scanJobs.get(id))!.status, ScanStatus.queued);

      fake.replyJson({
        'schema_version': 1, 'image_type': 'unreadable', 'stock_mode': 'none', 'merchant': null,
        'purchased_at': null, 'purchased_time': null, 'currency': 'EUR', 'receipt_total_minor': null,
        'items': [], 'warnings': ['too_blurry'],
      });
      await service().processQueue();
      final job = (await isar.scanJobs.get(id))!;
      expect(job.status, ScanStatus.failed);
      expect(job.lastError, contains('too_blurry'));
    });

    test('pantry photo sets quantities and verifies', () async {
      final pantry = PantryService(isar);
      await pantry.upsert(Ingredient()
        ..name = 'Egg'
        ..key = 'egg'
        ..baseUnit = BaseUnit.pc
        ..gramsPerPiece = 55
        ..qtyOnHand = 2);
      fake.replyJson({
        'schema_version': 1, 'image_type': 'pantry', 'stock_mode': 'set', 'merchant': null,
        'purchased_at': null, 'purchased_time': null, 'currency': 'EUR', 'receipt_total_minor': null,
        'items': [
          {
            'raw_text': '', 'name': 'Eggs', 'line_type': 'product', 'spend_category': 'groceries',
            'total_minor': 0, 'ingredient_key': 'egg', 'is_new_ingredient': false, 'qty': 10, 'unit': 'pc',
            'qty_source': 'estimated', 'confidence': 'high', 'new_ingredient': null,
          },
        ],
        'warnings': [],
      });
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'pantry');
      final r = (await s.processQueue()).single;
      expect(r.job.kind, ScanKind.pantry);
      expect(r.autoCommitted, isFalse);
      await s.commit(id);
      final egg = (await isar.ingredients.getByKey('egg'))!;
      expect(egg.qtyOnHand, 10);
      expect(await isar.transactions.count(), 0);
    });
  });

  group('DailyPickService + AskService', () {
    Future<void> seedPantry() async {
      final p = PantryService(isar, now: () => now);
      Future<void> add(String key, double qty, double cost, double kcal, double protein, double carbs, double fat,
          {BaseUnit unit = BaseUnit.g, bool staple = false, int shelf = 7}) async {
        await p.upsert(Ingredient()
          ..key = key
          ..name = key.replaceAll('_', ' ')
          ..qtyOnHand = qty
          ..avgCostPerUnitMinor = cost
          ..baseUnit = unit
          ..shelfLifeDays = shelf
          ..trackingMode = staple ? TrackingMode.staple : TrackingMode.exact
          ..per100 = Nutrition(kcal: kcal, proteinG: protein, carbsG: carbs, fatG: fat));
      }

      await add('chicken_breast', 650, 0.998, 110, 23.1, 0, 1.9, shelf: 2);
      await add('white_rice', 1000, 0.2, 360, 7.1, 79, 0.7, shelf: 365);
      await add('spinach', 210, 0.796, 23, 2.9, 3.6, 0.4, shelf: 1);
      await add('olive_oil', 0, 0, 814, 0, 0, 92, unit: BaseUnit.ml, staple: true);
      await add('garlic_powder', 0, 0, 331, 17, 73, 0.7, staple: true);
      await add('salt', 0, 0, 0, 0, 0, 0, staple: true);
    }

    test('generate stores a validated pick with Dart numbers; ensure reuses it', () async {
      await seedPantry();
      fake.reply(promptExample('daily_recipe.v1.md'));
      final svc = DailyPickService(isar: isar, ai: ai, now: () => now);
      final out = await svc.ensure();
      expect(out.fromAi, isTrue);
      final r = out.recipe!;
      expect(r.suggestedForDateKey, 20260927);
      expect(r.costPerPortionMinor, closeTo(255, 2));
      final ctx = jsonDecode(fake.requests.single['contents'][0]['parts'][0]['text']);
      expect((ctx['inventory'] as List).first['key'], 'spinach');
      final again = await svc.ensure();
      expect(again.recipe!.id, r.id);
      expect(fake.requests.length, 1);
    });

    test('no key falls back to the best ready saved recipe', () async {
      await seedPantry();
      await RecipeService(isar).save(Recipe()
        ..title = 'Plain rice'
        ..status = RecipeStatus.saved
        ..ingredients = [
          RecipeIngredient()
            ..key = 'white_rice'
            ..qtyPerPortion = 100,
        ]);
      final svc = DailyPickService(
        isar: isar,
        ai: AiGateway(isar: isar, secrets: MemorySecretStore(), prompts: PromptRepository(loadPromptAsset)),
        now: () => now,
      );
      final out = await svc.ensure();
      expect(out.isFallback, isTrue);
      expect(out.recipe!.title, 'Plain rice');
    });

    test('swap is limited to 2 per day', () async {
      await seedPantry();
      final svc = DailyPickService(isar: isar, ai: ai, now: () => now);
      for (var i = 0; i < 3; i++) {
        final json = jsonDecode(promptExample('daily_recipe.v1.md')) as Map<String, dynamic>;
        (json['recipe'] as Map)['title'] = 'Pick $i';
        fake.replyJson(json);
      }
      await svc.ensure();
      expect((await svc.swap()).recipe!.title, 'Pick 1');
      expect((await svc.swap()).recipe!.title, 'Pick 2');
      final third = await svc.swap();
      expect(third.error, contains('limit'));
      expect(third.recipe!.title, 'Pick 2');
      final req = fake.requests.last['contents'][0]['parts'][0]['text'];
      expect(jsonDecode(req)['rejected_today'], ['Pick 0', 'Pick 1']);
    });

    test('ask: Dart verdict overrides the model when stock is short', () async {
      await seedPantry();
      final json = jsonDecode(promptExample('daily_recipe.v1.md'))['recipe'] as Map<String, dynamic>;
      json['portions'] = 5; // needs 900 g chicken, only 650 g on hand
      fake.replyJson({
        'schema_version': 1,
        'status': 'ready',
        'request_type': 'dish',
        'interpreted_request': 'Chicken rice bowls, 5 portions',
        'summary': 'Ready now!',
        'max_portions_now': 5,
        'recipe': json,
        'omitted': [],
        'shopping_list': [],
      });
      final out = await AskService(isar: isar, ai: ai, now: () => now).ask('chicken rice bowls for 5');
      expect(out.recipe!.feasibilityStatus, 'missing_items');
      expect(out.summary, contains('short on chicken breast'));
      expect(out.recipe!.shoppingList.map((s) => s.name), containsAll(['chicken breast', 'spinach']));
      expect(out.recipe!.shoppingList.every((s) => s.reason == 'short'), isTrue);
      final ctx = jsonDecode(fake.requests.single['contents'][0]['parts'][0]['text']);
      expect(ctx['requested_portions'], 5);
    });

    test('ask: not a recipe', () async {
      fake.replyJson({
        'schema_version': 1, 'status': 'not_a_recipe', 'request_type': 'not_a_recipe',
        'interpreted_request': 'weather', 'summary': 'I can only help with cooking.', 'max_portions_now': 0,
        'recipe': null, 'omitted': [], 'shopping_list': [],
      });
      final out = await AskService(isar: isar, ai: ai, now: () => now).ask("what's the weather");
      expect(out.notARecipe, isTrue);
      expect(out.summary, 'I can only help with cooking.');
    });
  });
}
