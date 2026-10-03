import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/scan_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../support/fake_gemini.dart';
import '../support/test_db.dart';

/// The scan queue is started from app start, resume, every connectivity change, the Inbox and
/// each new scan: a job is read once at a time, nothing is left "Reading…", and failures show.
void main() {
  late Isar isar;
  late FakeGemini fake;
  late Directory tmp;
  final now = DateTime(2026, 9, 27, 19);

  setUp(() async {
    GeminiClient.compatLevel = 0;
    isar = await openTestDb();
    await ProfileService(isar).load();
    fake = FakeGemini();
    tmp = await Directory.systemTemp.createTemp('queue_');
  });
  tearDown(() async {
    await closeTestDb(isar);
    await tmp.delete(recursive: true);
  });

  ScanService service() => ScanService(
    isar: isar,
    images: ImageStore('${tmp.path}/store'),
    ai: AiGateway(
      isar: isar,
      secrets: MemorySecretStore('test-key'),
      prompts: PromptRepository(loadPromptAsset),
      httpClient: fake.client,
    ),
    now: () => now,
  );

  Future<String> photo() async {
    final f = File('${tmp.path}/p${DateTime.now().microsecondsSinceEpoch}.jpg');
    await f.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);
    return f.path;
  }

  Future<ScanJob> job(int id) async => (await isar.scanJobs.get(id))!;

  test('one run at a time, across services: a second call returns at once, the run reads what was queued', () async {
    fake
      ..reply(promptExample('receipt_extraction.v4.md'))
      ..reply(promptExamples('receipt_extraction.v4.md')[1]);
    final p = (await isar.userProfiles.get(1))!..lookUpPrices = false;
    await isar.writeTxn(() => isar.userProfiles.put(p));
    final s = service();
    final first = await s.enqueue([await photo()], hint: 'receipt');
    final running = s.processQueue();
    // Resume, a connectivity change and the new scan each start the queue meanwhile.
    expect(await s.processQueue(), isEmpty);
    expect(await service().processQueue(), isEmpty, reason: 'another service on the same database');
    final second = await s.enqueue([await photo()], hint: 'pantry');
    expect(await s.processQueue(), isEmpty);

    final results = await running;
    expect([for (final r in results) r.job.id], [first, second], reason: 'the queued one is not left waiting');
    expect(fake.requests, hasLength(2), reason: 'each job read once');
    expect((await job(first)).status, isNot(ScanStatus.queued));
    expect((await job(second)).status, ScanStatus.needsReview);
  });

  test('a job left "Reading…" by a killed app is read again, but not forever', () async {
    final s = service();
    final again = await s.enqueue([await photo()]);
    final given = await s.enqueue([await photo()]);
    await isar.writeTxn(() async {
      await isar.scanJobs.put(
        (await job(again))
          ..status = ScanStatus.processing
          ..attempts = 1,
      );
      await isar.scanJobs.put(
        (await job(given))
          ..status = ScanStatus.processing
          ..attempts = ScanService.maxAttempts,
      );
    });
    fake.reply(promptExample('receipt_extraction.v4.md'));

    final results = await s.processQueue();
    expect(results.single.job.id, again);
    expect(fake.requests, hasLength(1));
    final stuck = await job(given);
    expect(stuck.status, ScanStatus.failed, reason: 'it took the app down each time: the user decides');
    expect(stuck.lastError, startsWith(ScanService.closedWhileReading));

    await s.retry(given);
    expect((await job(given)).status, ScanStatus.queued, reason: 'Try again in the Inbox');
  });

  test('a passing failure is reported as waiting, keeps its reason and stops the run', () async {
    // Today's quota spent on both models.
    fake
      ..status(429, 'Resource has been exhausted', details: quotaDetails(perDay: true, limit: '500'))
      ..status(429, 'Resource has been exhausted', details: quotaDetails(perDay: true, limit: '20'));
    final s = service();
    final a = await s.enqueue([await photo()]);
    await s.enqueue([await photo()]);
    final r = (await s.processQueue()).single;
    expect(r.waiting, isTrue);
    expect(r.job.id, a);
    final waiting = await job(a);
    expect(waiting.status, ScanStatus.queued);
    expect(waiting.lastError, isNotNull);
    expect(fake.requests, hasLength(2), reason: 'the second job is not tried against a spent quota');
  });

  test('a photo that is gone fails with a reason instead of staying "Reading…"', () async {
    final s = service();
    final id = await s.enqueue([await photo()]);
    for (final p in (await job(id)).imagePaths) {
      File(p).deleteSync();
    }
    final r = (await s.processQueue()).single;
    expect(r.waiting, isFalse);
    final failed = await job(id);
    expect(failed.status, ScanStatus.failed);
    expect(failed.lastError, contains('Retake'));
    expect(fake.requests, isEmpty);
  });

  test('a scan discarded while it is read stays discarded', () async {
    fake.reply(promptExample('receipt_extraction.v4.md'));
    final s = service();
    final id = await s.enqueue([await photo()]);
    final running = s.processQueue();
    await s.discard(id);
    await running;
    expect((await job(id)).status, ScanStatus.discarded);
  });

  test('the capture hint survives until the next launch takes it', () async {
    final store = ImageStore('${tmp.path}/store');
    expect(await store.takeCapture(), isNull, reason: 'no camera was open');
    await store.rememberCapture('pantry');
    expect(await ImageStore('${tmp.path}/store').takeCapture(), 'pantry');
    expect(await store.takeCapture(), isNull, reason: 'taken once');
  });

  test('a compressor that gives back nothing keeps the original photo', () async {
    final store = ImageStore('${tmp.path}/store', compressor: (_) async => null);
    final empty = ImageStore('${tmp.path}/store', compressor: (_) async => Uint8List(0));
    final src = await photo();
    expect(await store.readScaled(src), [0xFF, 0xD8, 0xFF, 0xD9]);
    expect(await empty.readScaled(src), [0xFF, 0xD8, 0xFF, 0xD9], reason: 'out of memory on every retry');
  });
}
