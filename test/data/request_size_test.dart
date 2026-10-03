// What each AI task sends, built by the app's own services from the demo data, and how big it
// is. Run it to see the table:
//
//   flutter test test/data/request_size_test.dart --reporter expanded
//
// Tokens are estimated as characters / 4; each image adds about 1120 tokens at
// MEDIA_RESOLUTION_HIGH on Gemini 3. The upper bounds guard against a context that grows by
// accident (the whole history in every call), with a pantry of 220 items.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/ask_service.dart';
import 'package:trackcalfin/application/daily_pick_service.dart';
import 'package:trackcalfin/application/demo_seed.dart';
import 'package:trackcalfin/application/nutrition_service.dart';
import 'package:trackcalfin/application/quick_log_service.dart';
import 'package:trackcalfin/application/scan_service.dart';
import 'package:trackcalfin/core/day_clock.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/context_builders.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

const imageTokens = 1120;

class _Size {
  _Size(this.task, Map<String, dynamic> body) {
    system = '${body['systemInstruction']['parts'][0]['text']}'.length;
    final parts = [for (final c in body['contents'] as List) ...(c['parts'] as List)];
    input = parts.where((p) => p['text'] != null).fold(0, (a, p) => a + '${p['text']}'.length);
    images = parts.where((p) => p['inlineData'] != null).length;
    final schema = body['generationConfig']['responseJsonSchema'];
    this.schema = schema == null ? 0 : jsonEncode(schema).length;
  }
  final String task;
  late final int system, input, schema, images;
  int get tokens => ((system + input + schema) / 4).round() + images * imageTokens;
  String row() =>
      '| $task | ${(system / 4).round()} | ${(input / 4).round()} | ${(schema / 4).round()} | $images | ~$tokens |';
}

void main() {
  late Isar isar;
  late Directory tmp;
  final now = DateTime(2026, 10, 3, 12);
  final photo = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  setUp(() async {
    isar = await openTestDb();
    tmp = await Directory.systemTemp.createTemp('sizes_');
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  /// Runs every task once against a stand-in that records the request and refuses it.
  Future<List<_Size>> measure() async {
    final bodies = <Map<String, dynamic>>[];
    final stop = MockClient((r) async {
      bodies.add(jsonDecode(r.body) as Map<String, dynamic>);
      return http.Response('{"error":{"code":400,"message":"measured"}}', 400);
    });
    final ai = AiGateway(
      isar: isar,
      secrets: MemorySecretStore('k'),
      prompts: PromptRepository(loadPromptAsset),
      httpClient: stop,
      fallbackModel: null,
      gate: GeminiGate(minSpacing: Duration.zero),
    );
    final sizes = <_Size>[];
    Future<void> task(String name, Future<void> Function() run) async {
      await run();
      sizes.add(_Size(name, bodies.last));
    }

    final file = File('${tmp.path}/receipt.jpg')..writeAsBytesSync(photo);
    final scans = ScanService(isar: isar, images: ImageStore('${tmp.path}/store'), ai: ai, now: () => now);
    await task('A receipt (1 photo)', () async => scans.process(await scans.enqueue([file.path], hint: 'receipt')));
    await task('B Today\'s Pick', () => DailyPickService(isar: isar, ai: ai, now: () => now).generate(20261003));
    await task('C Ask', () => AskService(isar: isar, ai: ai, now: () => now).ask('chicken rice bowls for 2'));
    final macros = NutritionService(isar: isar, ai: ai, now: () => now);
    await task('D macros (40 items)', () async {
      final unknown = [
        for (var i = 0; i < 40; i++)
          Ingredient()
            ..key = 'unknown_item_$i'
            ..name = 'Unknown item $i'
            ..category = IngredientCategory.other,
      ];
      await isar.writeTxn(() => isar.ingredients.putAll(unknown));
      await macros.fillMissing();
      await isar.writeTxn(() => isar.ingredients.deleteAllByKey([for (final i in unknown) i.key]));
    });
    final first = (await isar.ingredients.where().findFirst())!;
    await task('E label (1 photo)', () => macros.readLabel(first.id, [photo]));
    await task('F price lookup (20 items)', () async {
      final profile = (await isar.userProfiles.get(1))!;
      final lines = {
        for (var i = 0; i < 20; i++)
          '$i': DraftLine()
            ..name = 'Item $i'
            ..product = 'Brand product $i, 500 g'
            ..unit = BaseUnit.g
            ..packageQty = 500,
      };
      await GeminiClient(httpClient: stop, apiKey: () async => 'k', fallbackModel: null, gate: ai.gate)
          .generate(
            GeminiRequest(
              systemPrompt: await ai.prompts.load(PromptRepository.priceLookup),
              turns: [Turn.user(jsonEncode(ContextBuilders.priceLookup(profile: profile, now: now, items: lines)))],
              thinkingLevel: 'low',
              googleSearch: true,
              maxOutputTokens: 4096,
            ),
          )
          .catchError((Object _) => GeminiResponse(text: '', finishReason: null, latencyMs: 0));
    });
    await task(
      'G Say it',
      () => QuickLogService(isar: isar, ai: ai, now: () => now).interpret('bought a coke zero for 1.29 and drank it'),
    );
    return sizes;
  }

  void report(String title, List<_Size> sizes) {
    print(
      '\n$title\n| Task | System prompt | Input | Schema | Images | Total tokens |\n|---|---|---|---|---|---|\n'
      '${sizes.map((s) => s.row()).join('\n')}',
    );
  }

  test('request sizes: demo pantry, and a pantry grown to 220 items', () async {
    await DemoSeed.run(isar, now: now);
    final demoItems = await isar.ingredients.count();
    final demo = await measure();
    report('Demo data ($demoItems pantry items)', demo);

    final grown = [
      for (var i = 0; i < 220 - demoItems; i++)
        Ingredient()
          ..key = 'pantry_item_$i'
          ..name = 'Pantry item number $i'
          ..qtyOnHand = 250
          ..avgCostPerUnitMinor = 0.5
          ..shelfLifeDays = 30
          ..lastPurchasedAt = DayClock.addDays(now, -(i % 60))
          ..nutritionSource = DataSource.aiEstimate,
    ];
    await isar.writeTxn(() => isar.ingredients.putAll(grown));
    final big = await measure();
    report('Pantry grown to 220 items', big);

    for (final s in big) {
      expect(s.tokens, lessThan(30000), reason: '${s.task} sends ~${s.tokens} tokens');
    }
    // What grows with the pantry: B and C send items in stock, A and G every item.
    final perItem = {
      for (var i = 0; i < demo.length; i++) demo[i].task: (big[i].input - demo[i].input) / 4 / (220 - demoItems),
    };
    print('\nInput tokens per extra pantry item: ${perItem.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}');
  });
}
