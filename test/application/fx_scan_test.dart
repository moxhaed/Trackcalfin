import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/fx_service.dart';
import 'package:trackcalfin/application/pantry_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/scan_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/fx/fx_rate_client.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/fx.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

void main() {
  group('FxRateClient', () {
    test('dated request for past receipts, latest for today; parses the rate', () async {
      final seen = <Uri>[];
      final client = FxRateClient(
        MockClient((req) async {
          seen.add(req.url);
          return http.Response(
            jsonEncode({
              'amount': 1,
              'base': 'CHF',
              'date': '2026-09-25',
              'rates': {'EUR': 1.0712},
            }),
            200,
          );
        }),
      );
      final now = DateTime(2026, 9, 29, 10);
      final q = await client.fetch('chf', 'EUR', DateTime(2026, 9, 27, 18), now: now);
      expect(seen.single.toString(), 'https://api.frankfurter.dev/v1/2026-09-27?base=CHF&symbols=EUR');
      expect(q!.rate, 1.0712);
      expect(q.date, DateTime(2026, 9, 25));
      expect(q.source, FxSource.ecb);
      await client.fetch('CHF', 'EUR', now, now: now);
      expect(seen.last.path, '/v1/latest');
    });

    test('errors, unknown currencies and garbage give null', () async {
      Future<FxQuote?> with_(http.Response r) =>
          FxRateClient(MockClient((_) async => r))
              .fetch('XYZ', 'EUR', DateTime(2026, 9, 1), now: DateTime(2026, 9, 29));
      expect(await with_(http.Response('not found', 404)), isNull);
      expect(await with_(http.Response('{"rates":{}}', 200)), isNull);
      expect(await with_(http.Response('<html>', 200)), isNull);
      expect(await with_(http.Response('{"rates":{"EUR":0}}', 200)), isNull);
      final thrower = FxRateClient(MockClient((_) async => throw const SocketException('offline')));
      expect(await thrower.fetch('CHF', 'EUR', DateTime(2026, 9, 1)), isNull);
    });
  });

  group('FxService + ScanService', () {
    late Isar isar;
    late Directory tmp;
    late FakeGemini fake;
    var rateAvailable = true;
    final now = DateTime(2026, 9, 29, 10);

    setUp(() async {
      GeminiClient.compatLevel = 0;
      rateAvailable = true;
      isar = await openTestDb();
      await ProfileService(isar).load();
      tmp = await Directory.systemTemp.createTemp('fx_');
      fake = FakeGemini();
    });
    tearDown(() async {
      await closeTestDb(isar);
      await tmp.delete(recursive: true);
    });

    FxService fxService() => FxService(
      isar,
      now: () => now,
      client: FxRateClient(
        MockClient(
          (req) async => rateAvailable
              ? http.Response(
                  jsonEncode({
                    'base': 'CHF',
                    'date': '2026-09-25',
                    'rates': {'EUR': 1.0712},
                  }),
                  200,
                )
              : http.Response('down', 503),
        ),
      ),
    );

    ScanService scans(FxService fx) => ScanService(
      isar: isar,
      images: ImageStore('${tmp.path}/store'),
      ai: AiGateway(
        isar: isar,
        secrets: MemorySecretStore('k'),
        prompts: PromptRepository(loadPromptAsset),
        httpClient: fake.client,
      ),
      fx: fx,
      now: () => now,
    );

    Future<int> scanSwissReceipt(ScanService s) async {
      final json = jsonDecode(promptExample('receipt_extraction.v2.md')) as Map<String, dynamic>;
      json['currency'] = 'CHF';
      json['merchant'] = 'Migros';
      json['warnings'] = ['foreign_currency'];
      fake.replyJson(json);
      final photo = File('${tmp.path}/r.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xD9]);
      final id = await s.enqueue([photo.path], hint: 'receipt');
      await s.processQueue();
      return id;
    }

    test('foreign receipt gets the ECB rate, waits for review, and files converted amounts', () async {
      await PantryService(isar).upsert(
        Ingredient()
          ..name = 'Chicken breast'
          ..key = 'chicken_breast',
      );
      final s = scans(fxService());
      final id = await scanSwissReceipt(s);
      final job = (await isar.scanJobs.get(id))!;
      expect(job.status, ScanStatus.needsReview, reason: 'foreign receipts are always reviewed');
      expect(job.flags, contains('foreign_currency'));
      expect(job.fxRate, 1.0712);
      expect(job.fxSource, 'ecb');

      final txId = await s.commit(id);
      final tx = (await isar.transactions.get(txId!))!;
      expect(tx.currency, 'EUR');
      expect(tx.originalCurrency, 'CHF');
      expect(tx.originalTotalMinor, 822);
      expect(tx.totalMinor, 881); // 8.22 CHF x 1.0712
      expect(tx.lines.fold(0, (a, l) => a + l.totalMinor), tx.totalMinor);
      final chicken = (await isar.ingredients.getByKey('chicken_breast'))!;
      expect(
        chicken.avgCostPerUnitMinor,
        closeTo(tx.lines.first.totalMinor / 500, 1e-9),
        reason: 'stock is costed in the home currency',
      );
      final memo = (await isar.userProfiles.get(1))!.fxMemory.single;
      expect(memo.rate, 1.0712, reason: 'fetched rates are remembered for offline use');
    });

    test('offline: no rate means no filing until you set one; your rate is remembered', () async {
      rateAvailable = false;
      final fx = fxService();
      final s = scans(fx);
      final id = await scanSwissReceipt(s);
      expect((await isar.scanJobs.get(id))!.fxRate, isNull);
      expect(() => s.commit(id), throwsA(isA<MissingExchangeRate>()));

      // "My card was charged €9.05" -> rate 9.05 / 8.22
      await s.applyRate(id, FxQuote(from: 'CHF', to: 'EUR', rate: 9.05 / 8.22, date: now, source: FxSource.charged));
      final tx = (await isar.transactions.get((await s.commit(id))!))!;
      expect(tx.totalMinor, 905, reason: 'the ledger matches the bank statement');
      final remembered = await fx.remembered('CHF', 'EUR');
      expect(remembered!.rate, closeTo(9.05 / 8.22, 1e-9));
      expect(remembered.source, FxSource.remembered);
    });

    test('offline with a remembered rate uses it automatically', () async {
      final fx = fxService();
      await fx.remember(FxQuote(from: 'CHF', to: 'EUR', rate: 1.05, date: now, source: FxSource.manual));
      rateAvailable = false;
      final s = scans(fx);
      final id = await scanSwissReceipt(s);
      final job = (await isar.scanJobs.get(id))!;
      expect(job.fxRate, 1.05);
      expect(job.fxSource, 'remembered');
    });

    test('same currency needs no rate', () async {
      final q = await fxService().quote('EUR', 'eur', now);
      expect(q!.rate, 1);
    });
  });
}
