import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/cookbook_import_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/cookbook.dart';
import 'package:trackcalfin/domain/stock_index.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

/// A two-page PDF as far as the page count is concerned, padded to [size] bytes.
Uint8List fakePdf({int pages = 2, int size = 0}) {
  final head = StringBuffer('%PDF-1.4\n1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n')
    ..write('2 0 obj << /Type /Pages /Kids [3 0 R] /Count $pages >> endobj\n');
  for (var i = 0; i < pages; i++) {
    head.write('${3 + i} 0 obj << /Type /Page /Parent 2 0 R >> endobj\n');
  }
  final bytes = utf8.encode(head.toString());
  final out = Uint8List(size > bytes.length ? size : bytes.length + 6)..setAll(0, bytes);
  out.setAll(out.length - 6, utf8.encode('%%EOF\n'));
  return out;
}

Map<String, dynamic> indexReply({List<(String, int)>? recipes, int? next}) => {
  'schema_version': 1,
  'is_cookbook': true,
  'book_title': 'Weeknight Middle Eastern',
  'page_count': 212,
  'recipes': [
    for (final (t, p)
        in recipes ??
            const [('Hummus with spiced lamb', 34), ('Sumac onions', 35), ('Roast cauliflower with tahini', 38)])
      {'title': t, 'page': p},
  ],
  'next_page': next,
};

Map<String, dynamic> cauliflower(int id) => {
  'id': id,
  'found': true,
  'title': 'Roast cauliflower with tahini',
  'page': 38,
  'servings': 2,
  'prep_minutes': 10,
  'cook_minutes': 30,
  'ingredients': [
    {
      'as_written': '1 cauliflower',
      'name': 'Cauliflower',
      'key': 'cauliflower',
      'qty': 1,
      'unit': 'pc',
      'optional': false,
    },
    {
      'as_written': '3 tbsp olive oil',
      'name': 'Olive oil',
      'key': 'olive_oil',
      'qty': 45,
      'unit': 'ml',
      'optional': false,
    },
  ],
  'steps': ['Roast the florets with the oil at 220 °C for 30 min.'],
  'tags': ['vegan'],
};

void main() {
  late Isar isar;
  late FakeGemini fake;
  late Directory tmp;
  late List<http.Request> uploads;
  var now = DateTime(2026, 9, 27, 19);

  /// Files API requests are answered here; generateContent goes to [fake].
  http.Client withFiles() => MockClient((req) async {
    if (req.url.path.startsWith('/upload/')) {
      uploads.add(req);
      return http.Response('', 200, headers: {'x-goog-upload-url': 'https://upload.test/session/${uploads.length}'});
    }
    if (req.url.host == 'upload.test') {
      uploads.add(req);
      return http.Response(
        jsonEncode({
          'file': {
            'name': 'files/abc${uploads.length}',
            'uri': 'https://generativelanguage.googleapis.com/v1beta/files/abc${uploads.length}',
            'mimeType': 'application/pdf',
            'state': 'ACTIVE',
            'expirationTime': now.add(const Duration(hours: 48)).toUtc().toIso8601String(),
          },
        }),
        200,
      );
    }
    return fake.client.post(req.url, headers: req.headers, body: req.body);
  });

  CookbookImportService service({String? key = 'test-key', int batchSize = 2, GeminiGate? gate}) =>
      CookbookImportService(
        isar: isar,
        ai: AiGateway(
          isar: isar,
          secrets: MemorySecretStore(key),
          prompts: PromptRepository(loadPromptAsset),
          httpClient: withFiles(),
          gate: gate,
        ),
        dir: () async => '${tmp.path}/cookbooks',
        now: () => now,
        batchSize: batchSize,
        delay: (_) async {},
      );

  Future<void> pantry() => isar.writeTxn(() async {
    Ingredient ing(String key, String name, BaseUnit unit, double qty, double cost, {double? gpp}) => Ingredient()
      ..key = key
      ..name = name
      ..baseUnit = unit
      ..qtyOnHand = qty
      ..avgCostPerUnitMinor = cost
      ..gramsPerPiece = gpp;
    await isar.ingredients.putAll([
      ing('chickpeas_canned', 'Chickpeas (canned)', BaseUnit.g, 800, 0.3),
      ing('lemon', 'Lemon', BaseUnit.pc, 2, 40, gpp: 100),
      ing('garlic', 'Garlic', BaseUnit.pc, 5, 8, gpp: 5),
      ing('olive_oil', 'Olive oil', BaseUnit.ml, 500, 0.9),
      ing('salt', 'Salt', BaseUnit.g, 400, 0.05),
    ]);
  });

  Map<String, dynamic> userJson(Map<String, dynamic> req) =>
      jsonDecode(((req['contents'] as List).first['parts'] as List).last['text'] as String) as Map<String, dynamic>;

  setUp(() async {
    GeminiClient.compatLevel = 0;
    isar = await openTestDb();
    await ProfileService(isar).load();
    fake = FakeGemini();
    uploads = [];
    now = DateTime(2026, 9, 27, 19);
    tmp = await Directory.systemTemp.createTemp('cookbook_');
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  test('keeps a copy of the PDF with its page count; refuses what Gemini cannot read', () async {
    final s = service();
    final id = await s.create(fileName: 'weeknight-middle-eastern.pdf', bytes: fakePdf(pages: 2));
    final job = (await s.get(id))!;
    expect((job.pageCount, job.bookTitle, File(job.filePath).existsSync()), (2, 'weeknight middle eastern', true));
    expect(job.hasWork, isTrue);
    await expectLater(
      s.create(fileName: 'notes.pdf', bytes: Uint8List.fromList(utf8.encode('hello'))),
      throwsA(isA<CookbookException>().having((e) => e.message, 'message', 'That file is not a PDF.')),
    );
    await expectLater(
      s.create(fileName: 'huge.pdf', bytes: fakePdf(pages: 1200)),
      throwsA(isA<CookbookException>().having((e) => e.message, 'message', contains('1200 pages'))),
    );
  });

  test('reads the index, then a few recipes per call, each pass saved; a small PDF goes inline', () async {
    await pantry();
    fake
      ..replyJson(indexReply())
      ..reply(promptExample('cookbook_import.v1.md'))
      ..replyJson({
        'schema_version': 1,
        'recipes': [cauliflower(2)],
      });
    final s = service();
    final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());

    expect(s.nextLabel((await s.get(id))!), 'Finding the recipes');
    var p = await s.step(id);
    expect((p.more, p.error), (true, null));
    var job = (await s.get(id))!;
    expect(job.bookTitle, 'Weeknight Middle Eastern');
    expect(
      [for (final e in job.entries) (e.title, e.page)],
      [('Hummus with spiced lamb', 34), ('Sumac onions', 35), ('Roast cauliflower with tahini', 38)],
    );
    final first = fake.requests.first;
    final parts = (first['contents'] as List).first['parts'] as List;
    expect(parts.first['inlineData']['mimeType'], 'application/pdf', reason: 'the PDF comes first, then the prompt');
    expect(userJson(first)['from_page'], 1);
    expect(uploads, isEmpty);
    expect(s.nextLabel(job), 'Reading pages 34–35');

    p = await s.step(id);
    job = (await s.get(id))!;
    final ask = userJson(fake.requests[1]);
    expect([for (final r in ask['recipes_to_extract']) r['id']], [0, 1]);
    expect((ask['pantry'] as List).map((i) => i['key']), contains('chickpeas_canned'));
    expect(job.entries.map((e) => e.state), [
      CookbookEntryState.done,
      CookbookEntryState.notFound,
      CookbookEntryState.pending,
    ]);
    expect(job.drafts.single.title, 'Hummus with spiced lamb');
    expect(p.more, isTrue);

    p = await s.step(id);
    job = (await s.get(id))!;
    expect(p.more, isFalse);
    expect(job.hasWork, isFalse);
    expect(job.drafts.map((d) => d.title), ['Hummus with spiced lamb', 'Roast cauliflower with tahini']);
    final logs = await isar.aiCallLogs.where().findAll();
    expect(logs.map((l) => (l.task, l.promptVersion)), [
      (AiTask.cookbookImport, PromptRepository.cookbookIndex),
      (AiTask.cookbookImport, PromptRepository.cookbookImport),
      (AiTask.cookbookImport, PromptRepository.cookbookImport),
    ]);
  });

  test('a long index comes in passes; the next one starts where the last stopped', () async {
    fake
      ..replyJson(indexReply(recipes: const [('Hummus with spiced lamb', 34)], next: 35))
      ..replyJson(indexReply(recipes: const [('Hummus with spiced lamb', 34), ('Sumac onions', 35)]));
    final s = service();
    final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());
    await s.step(id);
    expect((await s.get(id))!.indexDone, isFalse);
    expect(s.nextLabel((await s.get(id))!), 'Finding more recipes from page 35');
    await s.step(id);
    final job = (await s.get(id))!;
    expect(userJson(fake.requests[1])['from_page'], 35);
    expect((job.indexDone, job.entries.length), (true, 2), reason: 'a title listed twice is kept once');
  });

  test('a daily limit mid-import keeps what was read; Continue reads the rest', () async {
    final daily = [
      {
        '@type': 'type.googleapis.com/google.rpc.QuotaFailure',
        'violations': [
          {'quotaId': 'GenerateRequestsPerDayPerProjectPerModel-FreeTier', 'quotaValue': '500'},
        ],
      },
    ];
    fake
      ..replyJson(indexReply())
      ..reply(promptExample('cookbook_import.v1.md'))
      ..status(429, 'quota', details: daily)
      ..status(429, 'quota', details: daily);
    // The gate keeps both models off for the rest of Google's day; Continue comes the day after.
    var later = Duration.zero;
    final s = service(gate: GeminiGate(clock: () => DateTime.now().add(later)));
    final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());
    await s.step(id);
    await s.step(id);
    final p = await s.step(id);
    expect((p.transient, p.more), (true, true));
    var job = (await s.get(id))!;
    expect(job.lastError, contains('Daily limits reached'));
    expect(job.drafts, hasLength(1), reason: 'what was read stays');
    expect(job.entries[2].state, CookbookEntryState.pending);
    expect(job.entries[2].attempts, 0, reason: 'a limit is not the answer failing');

    later = const Duration(days: 1);
    fake.replyJson({
      'schema_version': 1,
      'recipes': [cauliflower(2)],
    });
    expect((await s.step(id)).more, isFalse);
    job = (await s.get(id))!;
    expect((job.lastError, job.drafts.length, job.hasWork), (null, 2, false));
  });

  test(
    'an answer that fails its checks is read again in halves, then set aside; Try again reads it once more',
    () async {
      fake
        ..replyJson(indexReply())
        ..reply('not json')
        ..reply('still not json');
      final s = service();
      final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());
      await s.step(id);
      final p = await s.step(id);
      expect((p.more, p.transient), (true, false));
      expect(p.error, startsWith("Couldn't read pages 34–35"));
      var job = (await s.get(id))!;
      expect(job.entries.map((e) => e.attempts), [1, 1, 0]);
      expect(CookbookPlanner.nextBatch(job.entries, size: 2), [0], reason: 'half the batch');

      // Entry 0 reads fine on its own; entry 1 keeps failing until it is set aside.
      fake.replyJson({
        'schema_version': 1,
        'recipes': [
          {...jsonDecode(promptExample('cookbook_import.v1.md'))['recipes'][0] as Map<String, dynamic>},
        ],
      });
      await s.step(id);
      for (var i = 0; i < 4; i++) {
        fake.reply('{}');
      }
      await s.step(id);
      await s.step(id);
      job = (await s.get(id))!;
      expect(job.entries.map((e) => e.state), [
        CookbookEntryState.done,
        CookbookEntryState.failed,
        CookbookEntryState.pending,
      ]);
      fake.replyJson({
        'schema_version': 1,
        'recipes': [cauliflower(2)],
      });
      await s.step(id);
      job = (await s.get(id))!;
      expect(job.hasWork, isFalse);

      await s.retryFailed(id);
      fake.replyJson({
        'schema_version': 1,
        'recipes': [
          {
            'id': 1,
            'found': false,
            'title': 'Sumac onions',
            'page': null,
            'servings': null,
            'prep_minutes': null,
            'cook_minutes': null,
            'ingredients': [],
            'steps': [],
            'tags': [],
          },
        ],
      });
      await s.step(id);
      job = (await s.get(id))!;
      expect(job.entries[1].state, CookbookEntryState.notFound);
    },
  );

  test('a large PDF is uploaded once and every pass points at it; an expired upload is sent again', () async {
    fake
      ..replyJson(indexReply())
      ..reply(promptExample('cookbook_import.v1.md'))
      ..replyJson({
        'schema_version': 1,
        'recipes': [cauliflower(2)],
      });
    final s = service();
    final bytes = fakePdf(size: CookbookImportService.inlineMaxBytes + 1000);
    final id = await s.create(fileName: 'big.pdf', bytes: bytes);
    expect(s.nextLabel((await s.get(id))!), 'Sending the PDF to Gemini');
    await s.step(id);
    expect(uploads, hasLength(2), reason: 'start, then upload and finalize');
    final start = uploads[0];
    expect(start.url.toString(), 'https://generativelanguage.googleapis.com/upload/v1beta/files');
    expect(start.headers['x-goog-upload-protocol'], 'resumable');
    expect(start.headers['x-goog-upload-command'], 'start');
    expect(start.headers['x-goog-upload-header-content-length'], '${bytes.length}');
    expect(start.headers['x-goog-upload-header-content-type'], 'application/pdf');
    expect(jsonDecode(start.body)['file']['display_name'], 'big.pdf');
    expect(uploads[1].headers['x-goog-upload-command'], 'upload, finalize');
    expect(uploads[1].bodyBytes.length, bytes.length);

    Map<String, dynamic> filePart(int i) =>
        ((fake.requests[i]['contents'] as List).first['parts'] as List).first['fileData'] as Map<String, dynamic>;
    expect(filePart(0), {
      'mimeType': 'application/pdf',
      'fileUri': 'https://generativelanguage.googleapis.com/v1beta/files/abc2',
    });
    await s.step(id);
    expect(uploads, hasLength(2), reason: 'the upload is reused');
    expect(filePart(1)['fileUri'], endsWith('/abc2'));

    now = now.add(const Duration(hours: 48));
    await s.step(id);
    expect(uploads, hasLength(4), reason: 'expired: uploaded again');
    expect(filePart(2)['fileUri'], endsWith('/abc4'));
  });

  test('no key: nothing is read and the import says why', () async {
    final s = service(key: null);
    final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());
    final p = await s.step(id);
    expect((p.transient, fake.requests.length), (true, 0));
    expect((await s.get(id))!.lastError, contains('API key'));
  });

  group('saving', () {
    Future<int> readBook(CookbookImportService s) async {
      fake
        ..replyJson(indexReply())
        ..reply(promptExample('cookbook_import.v1.md'))
        ..replyJson({
          'schema_version': 1,
          'recipes': [cauliflower(2)],
        });
      final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());
      for (var i = 0; i < 3; i++) {
        await s.step(id);
      }
      return id;
    }

    test('matches every ingredient to the pantry and costs it at the user\'s prices, in one write; Undo', () async {
      await pantry();
      final s = service();
      final id = await readBook(s);
      final ids = await s.save(id, {0});
      final r = (await isar.recipes.get(ids.single))!;
      expect(
        (r.origin, r.status, r.sourceBook, r.sourcePage),
        (RecipeOrigin.cookbook, RecipeStatus.saved, 'Weeknight Middle Eastern', 34),
      );
      expect(r.defaultPortions, 4);
      expect(r.omitted, ['Parsley'], reason: 'optional lines are left out');
      final chickpeas = r.ingredients.firstWhere((i) => i.key == 'chickpeas_canned');
      expect((chickpeas.qtyPerPortion, chickpeas.ingredientId != null), (120, true), reason: '480 g for 4');
      final tahini = r.ingredients.firstWhere((i) => i.name == 'Tahini');
      expect((tahini.key, tahini.ingredientId, tahini.role), ('tahini', null, IngredientRole.stock));
      // 120 g × 0.3 + 0.25 lemon × 40 + 0.25 clove × 8 + 7.5 ml × 0.9 + 1 g × 0.05: the model gave no price.
      expect(r.costPerPortionMinor, (36 + 10 + 2 + 6.75 + 0.05).round());
      final stock = StockIndex(await isar.ingredients.where().findAll());
      final fit = CookbookReview.fit(r, stock);
      expect(fit.summary, 'You have 5 of 8 · missing tahini, minced lamb, ground cumin');
      expect(fit.ready, isFalse);
      var job = (await s.get(id))!;
      expect(job.status, CookbookStatus.open, reason: 'the cauliflower is still to review');

      final more = await s.save(id, {2});
      job = (await s.get(id))!;
      expect(job.status, CookbookStatus.done);
      await s.unsave(id, more);
      job = (await s.get(id))!;
      expect(await isar.recipes.get(more.single), isNull);
      expect((job.status, job.unsaved.single.title), (CookbookStatus.open, 'Roast cauliflower with tahini'));
    });

    test('an item bought later is matched to the saved recipe', () async {
      await pantry();
      final s = service();
      final id = await readBook(s);
      final rid = (await s.save(id, {0})).single;
      await isar.writeTxn(
        () => isar.ingredients.put(
          Ingredient()
            ..key = 'tahini_paste'
            ..name = 'Tahini'
            ..qtyOnHand = 300
            ..avgCostPerUnitMinor = 1.2,
        ),
      );
      expect(await s.relink(), 1);
      final r = (await isar.recipes.get(rid))!;
      final tahini = r.ingredients.firstWhere((i) => i.name == 'Tahini');
      expect((tahini.key, tahini.ingredientId != null), ('tahini_paste', true));
      expect(r.costPerPortionMinor, (36 + 10 + 2 + 6.75 + 0.05 + 25 * 1.2).round());
      expect(await s.relink(), 0);
    });

    test('discard sets an import aside; Undo brings it back; the next import clears it out', () async {
      final s = service();
      final id = await s.create(fileName: 'book.pdf', bytes: fakePdf());
      final path = (await s.get(id))!.filePath;
      await s.discard(id);
      expect((await s.get(id))!.status, CookbookStatus.discarded);
      await s.restore(id);
      expect((await s.get(id))!.status, CookbookStatus.open);
      await s.discard(id);
      await s.create(fileName: 'other.pdf', bytes: fakePdf());
      expect(await s.get(id), isNull);
      expect(File(path).existsSync(), isFalse);
    });
  });
}
