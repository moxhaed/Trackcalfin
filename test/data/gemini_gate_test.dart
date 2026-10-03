import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';

import '../support/fake_gemini.dart';

void main() {
  late FakeTime time;
  setUp(() {
    time = FakeTime();
    GeminiClient.compatLevel = 0;
  });

  GeminiGate gate({int maxInFlight = 2, int maxBackground = 1, Duration spacing = Duration.zero}) => GeminiGate(
    maxInFlight: maxInFlight,
    maxBackgroundInFlight: maxBackground,
    minSpacing: spacing,
    clock: () => time.now,
    delay: time.delay,
  );

  group('GeminiGate', () {
    test('user requests go first, then first come first served', () async {
      final g = gate(maxInFlight: 1, maxBackground: 1);
      final started = <String>[];
      final hold = Completer<void>();
      unawaited(g.run('m', AiPriority.user, () => hold.future));
      final done = [
        for (final (name, p) in [
          ('bg1', AiPriority.background),
          ('user1', AiPriority.user),
          ('bg2', AiPriority.background),
          ('user2', AiPriority.user),
        ])
          g.run('m', p, () async => started.add(name)),
      ];
      await settleAsync();
      expect(started, isEmpty, reason: 'one request at a time');
      expect(g.waiting, 4);
      hold.complete();
      await Future.wait(done);
      expect(started, ['user1', 'user2', 'bg1', 'bg2']);
    });

    test('at most two in flight, and only one of them background work', () async {
      final g = gate();
      final holds = <String, Completer<void>>{};
      Future<void> req(String name, AiPriority p) => g.run('m', p, () => (holds[name] = Completer<void>()).future);
      final all = [
        req('bg1', AiPriority.background),
        req('bg2', AiPriority.background),
        req('bg3', AiPriority.background),
      ];
      await settleAsync();
      expect(holds.keys, ['bg1'], reason: 'a slot stays free for the user');
      final user = req('user', AiPriority.user);
      await settleAsync();
      expect(holds.keys, ['bg1', 'user']);
      expect(g.inFlight, 2);
      holds['bg1']!.complete();
      await settleAsync();
      expect(holds.keys, ['bg1', 'user', 'bg2']);
      holds['user']!.complete();
      holds['bg2']!.complete();
      await settleAsync();
      holds['bg3']!.complete();
      await Future.wait([...all, user]);
    });

    test('requests start at least the minimum spacing apart', () async {
      final g = gate(spacing: const Duration(seconds: 1));
      final starts = <DateTime>[];
      final all = [for (var i = 0; i < 3; i++) g.run('m', AiPriority.user, () async => starts.add(time.now))];
      await time.advance(const Duration(seconds: 5));
      await Future.wait(all);
      final t0 = DateTime.utc(2026, 10, 3, 12);
      expect(starts, [t0, t0.add(const Duration(seconds: 1)), t0.add(const Duration(seconds: 2))]);
    });

    test("a rate-limited model waits out its cooldown and then keeps under Google's per-minute limit", () async {
      final g = gate();
      final waits = <GateWait>[];
      g.waits.listen(waits.add);
      g.rateLimited('lite', const Duration(seconds: 20), limit: 2);
      expect(g.available('lite'), isFalse);
      final starts = <String, List<DateTime>>{};
      Future<void> req(String model, [AiPriority p = AiPriority.user]) =>
          g.run(model, p, () async => (starts[model] ??= []).add(time.now));
      final lite = [req('lite'), req('lite'), req('lite')];
      final other = req('flash');
      await settleAsync();
      expect(starts.keys, ['flash'], reason: 'another model is not held back');
      expect(waits.single.message, "Gemini's free tier allows 2 requests a minute; trying again in 20 s…");

      await time.advance(const Duration(seconds: 25));
      expect(starts['lite'], hasLength(2), reason: '2 a minute');
      await time.advance(const Duration(seconds: 60));
      await Future.wait([...lite, other]);
      final t0 = DateTime.utc(2026, 10, 3, 12);
      expect(starts['lite']![0], t0.add(const Duration(seconds: 20)));
      expect(starts['lite']![2], t0.add(const Duration(seconds: 20)).add(GeminiGate.window));
      expect(g.perMinuteBudget('lite'), 2);
    });

    test('a spent daily quota is remembered until it resets', () {
      final g = gate();
      g.dailyLimitReached('lite', time.now.add(const Duration(hours: 3)), 'Daily free-tier limit reached');
      expect(g.dailyLimit('lite'), 'Daily free-tier limit reached');
      expect(g.available('lite'), isFalse);
      time.now = time.now.add(const Duration(hours: 3));
      expect(g.dailyLimit('lite'), isNull);
    });

    test('daily quotas reset at midnight Pacific, summer time or not', () {
      expect(GeminiClient.nextPacificMidnight(DateTime.utc(2026, 10, 3, 12)), DateTime.utc(2026, 10, 4, 7));
      expect(GeminiClient.nextPacificMidnight(DateTime.utc(2026, 10, 3, 6)), DateTime.utc(2026, 10, 3, 7));
      expect(GeminiClient.nextPacificMidnight(DateTime.utc(2026, 12, 1, 20)), DateTime.utc(2026, 12, 2, 8));
    });
  });

  group('429 handling', () {
    GeminiClient client(FakeGemini fake, GeminiGate g, {String? fallback = 'flash'}) =>
        GeminiClient(httpClient: fake.client, apiKey: () async => 'k', model: 'lite', fallbackModel: fallback, gate: g);

    GeminiRequest req([AiPriority p = AiPriority.user]) =>
        GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')], priority: p);

    List<String> models(FakeGemini fake) => [for (final u in fake.requestedUris) u.pathSegments.last.split(':').first];

    test('a short per-minute 429 is waited out once and retried on the same model', () async {
      final g = gate();
      final fake = FakeGemini()
        ..status(429, 'Resource exhausted. Please retry in 12s.', details: quotaDetails(perDay: false))
        ..reply('{"ok":true}');
      final waits = <GateWait>[];
      g.waits.listen(waits.add);
      final res = client(fake, g, fallback: null).generate(req());
      await time.advance(const Duration(seconds: 11));
      expect(fake.requests, hasLength(1), reason: 'still waiting');
      await time.advance(const Duration(seconds: 2));
      expect((await res).model, 'lite');
      expect(models(fake), ['lite', 'lite']);
      expect(waits.single.message, "Gemini's free tier allows 15 requests a minute; trying again in 12 s…");
    });

    test('a user request goes to the fallback when that is quicker than waiting', () async {
      final g = gate();
      final fake = FakeGemini()
        ..status(429, 'Resource exhausted', details: quotaDetails(perDay: false, retryDelay: '20s'))
        ..reply('{"ok":true}')
        ..reply('{"ok":true}');
      final res = await client(fake, g).generate(req());
      expect(res.model, 'flash');
      expect(models(fake), ['lite', 'flash']);
      // The next user request doesn't knock on the cooling model first.
      await client(fake, g).generate(req());
      expect(models(fake), ['lite', 'flash', 'flash']);
    });

    test("background work waits for the main model and never spends the fallback's quota", () async {
      final g = gate();
      final fake = FakeGemini()
        ..status(429, 'Resource exhausted', details: quotaDetails(perDay: false, retryDelay: '40s'))
        ..reply('{"ok":true}');
      final res = client(fake, g).generate(req(AiPriority.background));
      await time.advance(const Duration(seconds: 41));
      expect((await res).model, 'lite');
      expect(models(fake), ['lite', 'lite']);
    });

    test('a per-minute 429 that clears too late fails with a message that says so', () async {
      final g = gate();
      final fake = FakeGemini()
        ..status(429, 'Resource exhausted', details: quotaDetails(perDay: false, retryDelay: '50s'));
      await expectLater(
        client(fake, g, fallback: null).generate(req()),
        throwsA(
          isA<GeminiException>()
              .having((e) => e.quota, 'quota', QuotaKind.perMinute)
              .having((e) => e.retryable, 'retryable', isTrue)
              .having(
                (e) => e.message,
                'message',
                "Gemini's free tier allows 15 requests a minute on lite, and they're used up. Try again in about 50 s.",
              ),
        ),
      );
      expect(fake.requests, hasLength(1));
    });

    test('a per-day 429 fails fast, and the model is not asked again until it resets', () async {
      final g = gate();
      final fake = FakeGemini()..status(429, 'Quota exceeded', details: quotaDetails(perDay: true, limit: '500'));
      const daily = 'Daily free-tier limit reached for lite (500 requests). It resets at midnight Pacific time.';
      final dailyError = throwsA(isA<GeminiException>().having((e) => e.message, 'message', daily));
      await expectLater(client(fake, g, fallback: null).generate(req(AiPriority.background)), dailyError);
      await expectLater(client(fake, g, fallback: null).generate(req()), dailyError);
      expect(fake.requests, hasLength(1), reason: 'the second one never left the phone');
      expect(g.dailyLimit('lite'), daily);
    });

    test('a per-day 429 sends a user request to the fallback, background work not', () async {
      final g = gate();
      final fake = FakeGemini()
        ..status(429, 'Quota exceeded', details: quotaDetails(perDay: true, limit: '500'))
        ..reply('{"ok":true}');
      await expectLater(
        client(fake, g).generate(req(AiPriority.background)),
        throwsA(isA<GeminiException>().having((e) => e.quota, 'quota', QuotaKind.perDay)),
      );
      expect((await client(fake, g).generate(req())).model, 'flash');
      expect(models(fake), ['lite', 'flash']);
    });

    test('both models out for the day is one plain message', () async {
      final g = gate();
      final fake = FakeGemini()
        ..status(429, 'Quota exceeded', details: quotaDetails(perDay: true, limit: '500'))
        ..status(429, 'Quota exceeded', details: quotaDetails(perDay: true, limit: '20'));
      await expectLater(
        client(fake, g).generate(req()),
        throwsA(
          isA<GeminiException>().having(
            (e) => e.message,
            'message',
            'Daily limits reached for lite and flash. They reset at midnight Pacific time.',
          ),
        ),
      );
    });

    test('a timed-out request is not sent to the same model again', () async {
      final g = gate();
      final sent = <String>[];
      final hang = MockClient((r) {
        sent.add(r.url.pathSegments.last);
        return sent.length == 1 ? Completer<http.Response>().future : Future.value(geminiOk('{"ok":true}'));
      });
      final c = GeminiClient(httpClient: hang, apiKey: () async => 'k', model: 'lite', fallbackModel: 'flash', gate: g);
      final res = await c.generate(
        GeminiRequest(systemPrompt: 's', turns: const [Turn.user('x')], timeout: const Duration(milliseconds: 20)),
      );
      expect(res.model, 'flash');
      expect(sent, ['lite:generateContent', 'flash:generateContent']);
    });

    test('quota details: per-minute token limits, paid tiers and a 429 without details', () {
      final tokens = QuotaInfo.parse({
        'details': [
          {
            '@type': 'type.googleapis.com/google.rpc.QuotaFailure',
            'violations': [
              {'quotaId': 'GenerateContentInputTokensPerModelPerMinute-FreeTier', 'quotaValue': '250000'},
            ],
          },
          {'@type': 'type.googleapis.com/google.rpc.RetryInfo', 'retryDelay': '7.25s'},
        ],
      });
      expect(tokens.kind, QuotaKind.perMinute);
      expect(tokens.unit, 'input tokens');
      expect(tokens.limit, 250000);
      expect(tokens.retryAfter, const Duration(milliseconds: 7250));
      final bare = QuotaInfo.parse({'message': 'Too many requests. Please retry in 3.5s.'});
      expect(bare.kind, QuotaKind.perMinute);
      expect(bare.retryAfter, const Duration(milliseconds: 3500));
      expect(bare.limit, isNull);
      final paid = QuotaInfo.parse({
        'details': [
          {
            '@type': 'type.googleapis.com/google.rpc.QuotaFailure',
            'violations': [
              {'quotaId': 'GenerateRequestsPerMinutePerProjectPerModel', 'quotaValue': '4000'},
            ],
          },
        ],
      });
      expect(paid.freeTier, isFalse);
    });
  });
}
