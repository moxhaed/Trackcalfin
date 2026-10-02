import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/ask_service.dart';
import 'package:trackcalfin/application/cook_service.dart';
import 'package:trackcalfin/application/daily_pick_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/quick_log_service.dart';
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

    Future<void> lookUpPrices(bool on) async {
      final p = (await isar.userProfiles.get(1))!..lookUpPrices = on;
      await isar.writeTxn(() => isar.userProfiles.put(p));
    }

    Map<String, dynamic> receipt([void Function(Map<String, dynamic>)? edit]) {
      final json = jsonDecode(promptExample('receipt_extraction.v4.md')) as Map<String, dynamic>;
      edit?.call(json);
      return json;
    }

    test('clean receipt auto-commits: ledger, stock, WAC, new ingredient, aliases', () async {
      await addChicken();
      fake.reply(promptExample('receipt_extraction.v4.md'));
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'receipt');
      final results = await s.processQueue();
      expect(results.single.autoCommitted, isTrue);
      expect(results.single.clean, isTrue);
      expect(fake.requests, hasLength(1), reason: 'a receipt has its prices; nothing is looked up');

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
      await lookUpPrices(false);
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
      await lookUpPrices(false);
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
      fake.reply(promptExamples('receipt_extraction.v4.md')[1]);
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
      fake.reply(promptExample('receipt_extraction.v4.md'));
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
      fake.reply(promptExample('receipt_extraction.v4.md'));
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
      fake.reply(promptExample('receipt_extraction.v4.md'));
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
      // A line known by its key alone is still looked up.
      await s.updateJob(r.job..lines[0].matchedIngredientId = null);
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
  group('Price lookup (Prompt F)', () {
    ScanService service() => ScanService(isar: isar, images: ImageStore('${tmp.path}/store'), ai: ai, now: () => now);
    Map<String, dynamic> prices(List<Map<String, dynamic>> items) => {'schema_version': 1, 'items': items};
    Map<String, dynamic> found(String id, int price, double size, String store, String site) => {
      'id': id,
      'found': true,
      'price_minor': price,
      'package_qty': size,
      'store': store,
      'source': site,
      'note': null,
    };
    Map<String, dynamic> input(int request) =>
        jsonDecode(fake.requests[request]['contents'][0]['parts'][0]['text'] as String) as Map<String, dynamic>;

    test('a pantry photo looks prices up on Google; a confirmed one counts, the rest stay estimates', () async {
      final pasta = await PantryService(isar).upsert(
        Ingredient()
          ..name = 'Spaghetti'
          ..key = 'dry_pasta'
          ..qtyOnHand = 900,
      );
      fake
        ..reply(promptExamples('receipt_extraction.v4.md')[1])
        ..replyJson(
          prices([
            found('0', 179, 500, 'Lidl', 'lidl.de'),
            {
              'id': '1',
              'found': false,
              'price_minor': null,
              'package_qty': null,
              'store': null,
              'source': null,
              'note': 'no shop price online',
            },
          ]),
          grounding: groundingMetadata(),
        );
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'pantry');
      final job = (await s.processQueue()).single.job;

      final ask = fake.requests[1];
      expect(ask['tools'], [
        {'google_search': {}},
      ]);
      expect(
        (ask['generationConfig'] as Map).containsKey('responseMimeType'),
        isFalse,
        reason: 'JSON mode would drop the sources',
      );
      expect(
        [for (final i in input(1)['items'] as List) (i as Map)['product']],
        ['Barilla Spaghetti n.5, 500 g', 'Bertolli extra virgin olive oil, 750 ml'],
      );
      expect(input(1)['currency'], 'EUR');

      final spaghetti = job.lines[0];
      expect(spaghetti.priceSource, PriceSource.web);
      expect((spaghetti.packagePriceMinor, spaghetti.packageQty, spaghetti.priceStore), (179, 500.0, 'Lidl'));
      expect(spaghetti.priceLinks.single.title, 'lidl.de');
      expect(spaghetti.priceToConfirm, isTrue);
      expect(spaghetti.needsAttention, isTrue);
      final oil = job.lines[1];
      expect(oil.priceSource, PriceSource.estimate, reason: 'nothing found online: the photo estimate stands');
      expect(oil.packagePriceMinor, 899);
      expect(oil.priceNote, 'no shop price online');
      expect(job.priceSearchHtml.single, contains('class="chip"'));
      expect(job.priceQueries, ['Barilla Spaghetti n.5 500 g Preis']);
      expect(job.priceLookupError, isNull);

      spaghetti.priceConfirmed = true;
      await s.updateJob(job);
      await s.commit(id);
      final p = (await isar.ingredients.get(pasta))!;
      expect(p.avgCostPerUnitMinor, closeTo(179 / 500, 1e-9));
      expect(p.costIsEstimate, isFalse, reason: 'the user said the price is right');
      final o = (await isar.ingredients.getByKey('olive_oil'))!;
      expect(o.avgCostPerUnitMinor, closeTo(899 / 750, 1e-9));
      expect(o.costIsEstimate, isTrue, reason: 'never confirmed, so still an estimate');
    });

    test('items with a price paid are skipped; a failed lookup keeps the estimates and can run again', () async {
      await PantryService(isar).upsert(
        Ingredient()
          ..name = 'Spaghetti'
          ..key = 'dry_pasta'
          ..qtyOnHand = 900
          ..avgCostPerUnitMinor = 0.3,
      );
      fake
        ..reply(promptExamples('receipt_extraction.v4.md')[1])
        ..status(400, 'Search Grounding is not supported.')
        ..status(400, 'Search Grounding is not supported.');
      final s = service();
      final id = await s.enqueue([await photo()], hint: 'pantry');
      final job = (await s.processQueue()).single.job;
      expect(fake.requests, hasLength(3), reason: 'the photo, then the lookup on both models');
      expect(
        [for (final i in input(1)['items'] as List) (i as Map)['id']],
        ['1'],
        reason: 'spaghetti has a price paid',
      );
      expect(GeminiClient.compatLevel, 0, reason: "a search request's 400 says nothing about other calls");
      expect(job.status, ScanStatus.needsReview);
      expect(job.priceLookupError, contains('not supported'));
      expect(job.lines[0].priceSource, isNull, reason: 'its shelf price is not used, so not asked about');
      expect(job.lines[1].priceSource, PriceSource.estimate);
      expect(job.lines[1].packagePriceMinor, 899);

      fake.replyJson(
        prices([found('1', 949, 750, 'REWE', 'shop.rewe.de')]),
        grounding: groundingMetadata(pages: {'rewe.de': 'https://example.com/oil'}),
      );
      await s.retryPrices(id);
      final again = (await isar.scanJobs.get(id))!;
      expect(again.priceLookupError, isNull);
      expect(again.lines[1].priceSource, PriceSource.web);
      expect(again.lines[1].packagePriceMinor, 949);
      expect(again.lines[1].priceLinks.single.uri, 'https://example.com/oil', reason: 'shop.rewe.de is rewe.de');
    });

    test('Settings can turn the lookup off; the photo estimate is still asked about', () async {
      final p = (await isar.userProfiles.get(1))!..lookUpPrices = false;
      await isar.writeTxn(() => isar.userProfiles.put(p));
      fake.reply(promptExamples('receipt_extraction.v4.md')[1]);
      final s = service();
      await s.enqueue([await photo()], hint: 'pantry');
      final oil = (await s.processQueue()).single.job.lines[1];
      expect(fake.requests, hasLength(1));
      expect(oil.priceSource, PriceSource.estimate);
      expect(oil.priceToConfirm, isTrue);
    });
  });
  group('Say it (Prompt G)', () {
    final at = DateTime(2026, 10, 2, 18, 40);
    QuickLogService service({AiGateway? gateway}) => QuickLogService(isar: isar, ai: gateway ?? ai, now: () => at);

    Future<int> addCola() => PantryService(isar).upsert(
      Ingredient()
        ..name = 'Cola Zero'
        ..key = 'cola_zero'
        ..category = IngredientCategory.beverages
        ..baseUnit = BaseUnit.pc
        ..gramsPerPiece = 340
        ..qtyOnHand = 5
        ..avgCostPerUnitMinor = 75
        ..per100 = Nutrition(kcal: 0.3)
        ..nutritionSource = DataSource.aiEstimate,
    );

    test('shows what it understood, saves it all on Log it, and Undo puts every bit back', () async {
      final cola = await addCola();
      fake.reply(promptExample('quick_log.v1.md'));
      final s = service();
      final draft = await s.interpret('just bought a coke zero for 1.29 and drank it');
      expect(draft.error, isNull);
      expect(draft.steps.map((x) => x.title), ['Bought Cola Zero · 1 pc', 'Drank Cola Zero · 1 pc']);
      final input = jsonDecode(fake.requests.single['contents'][0]['parts'][0]['text'] as String) as Map;
      expect(input['said'], 'just bought a coke zero for 1.29 and drank it');
      expect(input['pantry'], [
        {'key': 'cola_zero', 'name': 'Cola Zero', 'unit': 'pc', 'on_hand': 5.0},
      ]);
      expect(await isar.transactions.count(), 0, reason: 'nothing is saved before Log it');

      final receipt = await s.apply(draft.log!);
      final tx = (await isar.transactions.where().findFirst())!;
      expect((tx.totalMinor, tx.primaryCategory, tx.lines.single.ingredientId), (129, SpendCategory.groceries, cola));
      final after = (await isar.ingredients.get(cola))!;
      expect((after.qtyOnHand, after.avgCostPerUnitMinor), (5.0, 84.0));
      final day = (await isar.dailyLogs.getByDateKey(20261002))!;
      expect((day.mealsCount, day.foodCostMinor), (1, 84));

      await s.undo(receipt);
      expect(await isar.transactions.count(), 0);
      expect(await isar.dailyLogs.count(), 0);
      final back = (await isar.ingredients.get(cola))!;
      expect((back.qtyOnHand, back.avgCostPerUnitMinor), (5.0, 75.0));
    });

    test('new items and a cooked batch get real ids; Undo removes them and puts the stock back', () async {
      final beans = await PantryService(isar).upsert(
        Ingredient()
          ..name = 'Kidney beans'
          ..key = 'kidney_beans'
          ..qtyOnHand = 800
          ..avgCostPerUnitMinor = 0.4,
      );
      final recipe = await RecipeService(isar).save(
        Recipe()
          ..title = 'Bean pasta'
          ..ingredients = [
            RecipeIngredient()
              ..key = 'kidney_beans'
              ..qtyPerPortion = 200,
          ],
      );
      final example = jsonDecode(promptExamples('quick_log.v1.md')[2]) as Map<String, dynamic>;
      final banana = (example['actions'] as List)[1] as Map<String, dynamic>;
      fake.replyJson({
        'schema_version': 1,
        'actions': [
          {...banana, 'qty': 3, 'paid_minor': 99, 'est_price_minor': null, 'merchant': null},
          {
            ...banana,
            'type': 'cook',
            'key': null,
            'name': null,
            'qty': null,
            'unit': null,
            'recipe_id': recipe,
            'portions': 3,
            'ate_portions': 1,
            'paid_minor': null,
            'est_price_minor': null,
            'merchant': null,
            'new_ingredient': null,
          },
        ],
        'total_paid_minor': null,
        'question': null,
      });
      final s = service();
      final draft = await s.interpret('bought 3 bananas for 99 cents, cooked bean pasta for 3 and ate one');
      expect(draft.error, isNull);
      final r = await s.apply(draft.log!);

      final made = (await isar.ingredients.getByKey('banana'))!;
      expect((made.qtyOnHand, made.baseUnit, made.nutritionSource), (3.0, BaseUnit.pc, DataSource.aiEstimate));
      expect((await isar.transactions.where().findFirst())!.lines.single.ingredientId, made.id);
      expect((await isar.ingredients.get(beans))!.qtyOnHand, 200);
      final batch = (await isar.cookSessions.where().findFirst())!;
      expect((batch.portionsRemaining, batch.status), (2, CookStatus.active));
      final meal = (await isar.dailyLogs.getByDateKey(20261002))!.meals.single;
      expect(meal.cookSessionId, batch.id, reason: 'the stand-in id became the real one');
      expect((await isar.recipes.get(recipe))!.timesCooked, 1);

      await s.undo(r);
      expect(await isar.ingredients.getByKey('banana'), isNull);
      expect(await isar.cookSessions.count(), 0);
      expect((await isar.ingredients.get(beans))!.qtyOnHand, 800);
      expect((await isar.recipes.get(recipe))!.timesCooked, 0);
    });

    test('deleting a meal eaten from the pantry puts it back in stock', () async {
      final cola = await addCola();
      fake.reply(promptExample('quick_log.v1.md'));
      final s = service();
      await s.apply((await s.interpret('a coke zero for 1.29, drank it')).log!);
      final meal = (await isar.dailyLogs.getByDateKey(20261002))!.meals.single;
      await CookService(isar, now: () => at).deleteMeal(20261002, meal.entryId);
      expect((await isar.ingredients.get(cola))!.qtyOnHand, 6, reason: 'bought one, and it is no longer drunk');
    });

    test('a question comes back as a question, and no key says so', () async {
      fake.reply(promptExamples('quick_log.v1.md')[3]);
      final asked = await service().interpret('ate the chili');
      expect(asked.question, 'Which chili: the one from Monday or the one from Wednesday?');
      expect(asked.steps, isEmpty);
      final noKey = await service(
        gateway: AiGateway(isar: isar, secrets: MemorySecretStore(), prompts: PromptRepository(loadPromptAsset)),
      ).interpret('ate the chili');
      expect(noKey.error, 'Add a Gemini API key in Settings to use Say it.');
    });
  });
}
