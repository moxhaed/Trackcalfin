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
    ScanService service({DateTime? at}) =>
        ScanService(isar: isar, images: ImageStore('${tmp.path}/store'), ai: ai, now: () => at ?? now);

    Future<int> addChicken({double qty = 0, int shelf = 7, DateTime? counted}) => PantryService(isar).upsert(
      Ingredient()
        ..name = 'Chicken breast'
        ..key = 'chicken_breast'
        ..qtyOnHand = qty
        ..shelfLifeDays = shelf
        ..lastCountedAt = counted,
    );

    Map<String, dynamic> receipt([void Function(Map<String, dynamic>)? edit]) {
      final json = jsonDecode(promptExample('receipt_extraction.v3.md')) as Map<String, dynamic>;
      edit?.call(json);
      return json;
    }

    test('clean receipt auto-commits: ledger, stock, WAC, new ingredient, aliases', () async {
      await addChicken();
      fake.reply(promptExample('receipt_extraction.v3.md'));
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'receipt');
      final results = await s.processQueue();
      expect(results.single.autoCommitted, isTrue);
      expect(results.single.clean, isTrue);

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
      fake.replyJson(receipt((j) => j['receipt_total_minor'] = 999));
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
        'schema_version': 1,
        'image_type': 'unreadable',
        'stock_mode': 'none',
        'merchant': null,
        'purchased_at': null,
        'purchased_time': null,
        'currency': 'EUR',
        'receipt_total_minor': null,
        'items': [],
        'warnings': ['too_blurry'],
      });
      await service().processQueue();
      final job = (await isar.scanJobs.get(id))!;
      expect(job.status, ScanStatus.failed);
      expect(job.lastError, contains('too_blurry'));
    });

    test('pantry photo sets quantities and verifies', () async {
      final pantry = PantryService(isar);
      await pantry.upsert(
        Ingredient()
          ..name = 'Egg'
          ..key = 'egg'
          ..baseUnit = BaseUnit.pc
          ..gramsPerPiece = 55
          ..qtyOnHand = 2,
      );
      fake.replyJson({
        'schema_version': 1,
        'image_type': 'pantry',
        'stock_mode': 'set',
        'merchant': null,
        'purchased_at': null,
        'purchased_time': null,
        'currency': 'EUR',
        'receipt_total_minor': null,
        'items': [
          {
            'raw_text': '',
            'name': 'Eggs',
            'line_type': 'product',
            'spend_category': 'groceries',
            'total_minor': 0,
            'ingredient_key': 'egg',
            'is_new_ingredient': false,
            'qty': 10,
            'unit': 'pc',
            'qty_source': 'estimated',
            'confidence': 'high',
            'new_ingredient': null,
          },
        ],
        'warnings': [],
      });
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'pantry');
      final r = (await s.processQueue()).single;
      expect(r.job.kind, ScanKind.pantry);
      expect(r.autoCommitted, isFalse);
      expect(r.job.lines.single.stockCheck, StockCheck.onHand, reason: '2 eggs on hand: same ones or more?');
      await s.commit(id);
      final egg = (await isar.ingredients.getByKey('egg'))!;
      expect(egg.qtyOnHand, 10, reason: 'by default the photo counts them');
      expect(egg.lastCountedAt, now);
      expect(await isar.transactions.count(), 0);
    });

    test('pantry photo: "extra" adds to what is there and the shop price prices it', () async {
      final pasta = await PantryService(isar).upsert(
        Ingredient()
          ..name = 'Spaghetti'
          ..key = 'dry_pasta'
          ..qtyOnHand = 900,
      );
      await RecipeService(isar).save(
        Recipe()
          ..title = 'Pasta'
          ..ingredients = [
            RecipeIngredient()
              ..key = 'dry_pasta'
              ..qtyPerPortion = 100,
          ],
      );
      fake.reply(promptExamples('receipt_extraction.v3.md')[1]);
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'pantry');
      final job = (await s.processQueue()).single.job;
      expect(job.lines[0].product, 'Barilla Spaghetti n.5, 500 g');
      job.lines[0].stock = StockEffect.add;
      await s.updateJob(job);
      await s.commit(id);

      final spaghetti = (await isar.ingredients.get(pasta))!;
      expect(spaghetti.qtyOnHand, 900 + 350);
      expect(spaghetti.avgCostPerUnitMinor, closeTo(199 / 500, 1e-9));
      expect(spaghetti.costIsEstimate, isTrue);
      final oil = (await isar.ingredients.getByKey('olive_oil'))!;
      expect(oil.qtyOnHand, 600);
      expect(oil.avgCostPerUnitMinor, closeTo(899 / 750, 1e-9));
      expect(oil.lastCountedAt, now);
      final recipe = (await isar.recipes.where().findFirst())!;
      expect(recipe.costPerPortionMinor, 40, reason: 'recipes are re-costed with the new price');

      // The next shop's receipt replaces the estimate with what was paid.
      fake.replyJson(
        receipt((j) {
          j['purchased_at'] = '2026-09-28';
          j['items'] = [
            {
              ...(j['items'] as List)[0] as Map,
              'raw_text': 'SPAGHETTI 1,49',
              'name': 'Spaghetti',
              'ingredient_key': 'dry_pasta',
              'total_minor': 149,
              'product': 'Store-brand spaghetti, 500 g',
            },
          ];
          j['receipt_total_minor'] = 149;
        }),
      );
      final nextDay = service(at: DateTime(2026, 9, 28, 20));
      await nextDay.enqueue([await photo()], hint: 'receipt');
      expect((await nextDay.processQueue()).single.autoCommitted, isTrue);
      final after = (await isar.ingredients.get(pasta))!;
      expect(after.avgCostPerUnitMinor, closeTo(149 / 500, 1e-9));
      expect(after.costIsEstimate, isFalse);
    });

    test('an old receipt files the money on its own day; what has spoiled since stays out of the pantry', () async {
      final chicken = await addChicken(shelf: 2);
      fake.reply(promptExample('receipt_extraction.v3.md'));
      final s = service(at: DateTime(2026, 10, 2, 9));
      final id = await s.enqueue([await photo()], hint: 'receipt');
      final r = (await s.processQueue()).single;
      expect(r.autoCommitted, isFalse, reason: 'the user confirms what is used up');
      expect(r.clean, isTrue);
      expect(r.job.purchasedAt, DateTime(2026, 9, 27, 18, 42));
      expect(r.job.lines[0].stockCheck, StockCheck.usedUp);

      final tx = (await isar.transactions.get((await s.commit(id))!))!;
      expect(tx.occurredAt, DateTime(2026, 9, 27, 18, 42));
      expect(tx.totalMinor, 822, reason: 'the money counts in full');
      expect(tx.lines[0].ingredientId, isNull, reason: 'nothing was stocked from this line');
      final c = (await isar.ingredients.get(chicken))!;
      expect(c.qtyOnHand, 0);
      expect(c.avgCostPerUnitMinor, closeTo(499 / 500, 1e-9), reason: 'the price is still learned');
      final yogurt = (await isar.ingredients.getByKey('greek_yogurt'))!;
      expect(yogurt.qtyOnHand, 500, reason: 'keeps 14 days');
      expect(yogurt.expiresAt, DateTime(2026, 10, 11, 18, 42), reason: 'freshness counts from the receipt');
    });

    test('a receipt from before a pantry count asks first; "already counted" adds nothing', () async {
      final chicken = await addChicken(qty: 400, counted: DateTime(2026, 9, 27, 18, 55));
      fake.reply(promptExample('receipt_extraction.v3.md'));
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'receipt');
      final r = (await s.processQueue()).single;
      expect(r.autoCommitted, isFalse);
      expect(r.job.lines[0].stockCheck, StockCheck.counted);
      await s.commit(id);
      final c = (await isar.ingredients.get(chicken))!;
      expect(c.qtyOnHand, 400);
      expect(c.avgCostPerUnitMinor, closeTo(499 / 500, 1e-9));
    });

    test('the same receipt twice: filed or still in the Inbox, the second one is flagged', () async {
      await addChicken();
      final s = service();
      fake.reply(promptExample('receipt_extraction.v3.md'));
      await s.enqueue([await photo()], hint: 'receipt');
      final first = (await s.processQueue()).single;
      expect(first.autoCommitted, isTrue);

      // The AI reads the copy slightly differently; same store, day and total.
      fake.replyJson(receipt((j) => j['merchant'] = 'LIDL'));
      await s.enqueue([await photo()], hint: 'receipt');
      final copy = (await s.processQueue()).single;
      expect(copy.autoCommitted, isFalse);
      expect(copy.job.duplicateOfTxId, first.transactionId);
      expect(await isar.transactions.count(), 1);

      fake.replyJson(receipt((j) => j['merchant'] = 'Lidl Berlin'));
      await s.enqueue([await photo()], hint: 'receipt');
      final third = (await s.processQueue()).single;
      expect(third.job.duplicateOfTxId, first.transactionId);

      fake.replyJson(receipt((j) => j['receipt_total_minor'] = 821));
      await s.enqueue([await photo()], hint: 'receipt');
      final other = (await s.processQueue()).single;
      expect(other.job.maybeDuplicate, isTrue, reason: 'the lines still add up to the same total');
      expect(other.job.duplicateOfTxId, first.transactionId);
    });

    test('a scan matching one still waiting in the Inbox points at it', () async {
      final s = service();
      fake.replyJson(receipt((j) => j['purchased_at'] = '2026-09-25'));
      final firstId = await s.enqueue([await photo()], hint: 'receipt');
      expect((await s.processQueue()).single.autoCommitted, isTrue);
      await isar.writeTxn(() async => isar.transactions.clear());
      await isar.writeTxn(() async {
        final j = (await isar.scanJobs.get(firstId))!;
        await isar.scanJobs.put(
          j
            ..status = ScanStatus.needsReview
            ..transactionId = null,
        );
      });
      fake.replyJson(receipt((j) => j['purchased_at'] = '2026-09-25'));
      await s.enqueue([await photo()], hint: 'receipt');
      expect((await s.processQueue()).single.job.duplicateOfJobId, firstId);
    });

    test('changing the date in review re-asks the pantry questions and clears the date flag', () async {
      await addChicken(shelf: 2);
      fake.replyJson(receipt((j) => j['purchased_at'] = null));
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'receipt');
      final r = (await s.processQueue()).single;
      expect(r.job.flags, contains('date_missing'));
      expect(r.job.lines[0].stockCheck, isNull);
      await s.setPurchaseDate(id, DateTime(2026, 9, 20, 18, 42));
      final job = (await isar.scanJobs.get(id))!;
      expect(job.purchasedAt, DateTime(2026, 9, 20, 18, 42));
      expect(job.flags, isNot(contains('date_missing')));
      expect(job.lines[0].stockCheck, StockCheck.usedUp);
      expect(job.lines[1].stockCheck, isNull, reason: 'the yogurt keeps 14 days');
    });
  });

  group('DailyPickService + AskService', () {
    Future<void> seedPantry() async {
      final p = PantryService(isar, now: () => now);
      Future<void> add(
        String key,
        double qty,
        double cost,
        double kcal,
        double protein,
        double carbs,
        double fat, {
        BaseUnit unit = BaseUnit.g,
        int shelf = 7,
      }) async {
        await p.upsert(
          Ingredient()
            ..key = key
            ..name = key.replaceAll('_', ' ')
            ..qtyOnHand = qty
            ..avgCostPerUnitMinor = cost
            ..baseUnit = unit
            ..shelfLifeDays = shelf
            ..per100 = Nutrition(kcal: kcal, proteinG: protein, carbsG: carbs, fatG: fat),
        );
      }

      await add('chicken_breast', 650, 0.998, 110, 23.1, 0, 1.9, shelf: 2);
      await add('white_rice', 1000, 0.2, 360, 7.1, 79, 0.7, shelf: 365);
      await add('spinach', 210, 0.796, 23, 2.9, 3.6, 0.4, shelf: 1);
      await add('olive_oil', 450, 0.9, 814, 0, 0, 92, unit: BaseUnit.ml, shelf: 540);
      await add('garlic_powder', 55, 2.48, 331, 17, 73, 0.7, shelf: 730);
      await add('salt', 450, 0.098, 0, 0, 0, 0, shelf: 1825);
    }

    test('generate stores a validated pick with Dart numbers; ensure reuses it', () async {
      await seedPantry();
      fake.reply(promptExample('daily_recipe.v2.md'));
      final svc = DailyPickService(isar: isar, ai: ai, now: () => now);
      final out = await svc.ensure();
      expect(out.fromAi, isTrue);
      final r = out.recipe!;
      expect(r.suggestedForDateKey, 20260927);
      expect(r.costPerPortionMinor, 264, reason: 'oil, garlic powder and salt are costed too');
      final ctx = jsonDecode(fake.requests.single['contents'][0]['parts'][0]['text']);
      expect((ctx['inventory'] as List).first['key'], 'spinach');
      expect((ctx['inventory'] as List).map((i) => i['key']), contains('olive_oil'));
      expect(ctx.containsKey('staples'), isFalse);
      final again = await svc.ensure();
      expect(again.recipe!.id, r.id);
      expect(fake.requests.length, 1);
    });

    test('no key falls back to the best ready saved recipe', () async {
      await seedPantry();
      await RecipeService(isar).save(
        Recipe()
          ..title = 'Plain rice'
          ..status = RecipeStatus.saved
          ..ingredients = [
            RecipeIngredient()
              ..key = 'white_rice'
              ..qtyPerPortion = 100,
          ],
      );
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
        final json = jsonDecode(promptExample('daily_recipe.v2.md')) as Map<String, dynamic>;
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
      final json = jsonDecode(promptExample('daily_recipe.v2.md'))['recipe'] as Map<String, dynamic>;
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
        'schema_version': 1,
        'status': 'not_a_recipe',
        'request_type': 'not_a_recipe',
        'interpreted_request': 'weather',
        'summary': 'I can only help with cooking.',
        'max_portions_now': 0,
        'recipe': null,
        'omitted': [],
        'shopping_list': [],
      });
      final out = await AskService(isar: isar, ai: ai, now: () => now).ask("what's the weather");
      expect(out.notARecipe, isTrue);
      expect(out.summary, 'I can only help with cooking.');
    });
  });
}
