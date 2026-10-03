import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Wraps model text in a generateContent response body. [grounding] is the candidate's
/// groundingMetadata, as an answer that searched Google carries it.
http.Response geminiOk(String text, {String finish = 'STOP', Map<String, dynamic>? grounding}) => http.Response(
  jsonEncode({
    'candidates': [
      {
        'content': {
          'role': 'model',
          'parts': [
            {'text': 'thinking...', 'thought': true},
            {'text': text},
          ],
        },
        'finishReason': finish,
        'groundingMetadata': ?grounding,
      },
    ],
    'usageMetadata': {'promptTokenCount': 1200, 'candidatesTokenCount': 300},
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// A scripted fake: returns queued responses in order and records requests.
class FakeGemini {
  final responses = <http.Response Function(Map<String, dynamic> body)>[];
  final requests = <Map<String, dynamic>>[];
  final requestedUris = <Uri>[];

  void reply(String text, {Map<String, dynamic>? grounding}) =>
      responses.add((_) => geminiOk(text, grounding: grounding));
  void replyJson(Object json, {Map<String, dynamic>? grounding}) => reply(jsonEncode(json), grounding: grounding);
  void status(int code, String message, {List<Object>? details}) => responses.add(
    (_) => http.Response(
      jsonEncode({
        'error': {'code': code, 'message': message, 'details': ?details},
      }),
      code,
    ),
  );

  late final client = MockClient((req) async {
    final body = jsonDecode(req.body) as Map<String, dynamic>;
    requests.add(body);
    requestedUris.add(req.url);
    if (responses.isEmpty) return http.Response('{"error":{"message":"no scripted response"}}', 500);
    return responses.removeAt(0)(body);
  });
}

/// The details of a free-tier 429, as Google sends them: which quota, its size and when to retry.
List<Object> quotaDetails({required bool perDay, String limit = '15', String retryDelay = '12s'}) => [
  {
    '@type': 'type.googleapis.com/google.rpc.QuotaFailure',
    'violations': [
      {
        'quotaMetric': 'generativelanguage.googleapis.com/generate_content_free_tier_requests',
        'quotaId': perDay
            ? 'GenerateRequestsPerDayPerProjectPerModel-FreeTier'
            : 'GenerateRequestsPerMinutePerProjectPerModel-FreeTier',
        'quotaValue': limit,
      },
    ],
  },
  {'@type': 'type.googleapis.com/google.rpc.RetryInfo', 'retryDelay': retryDelay},
];

/// Virtual time for code that takes a clock and a delay function (GeminiGate): [advance]
/// moves the clock and fires the delays that fall due, in order.
class FakeTime {
  DateTime now = DateTime.utc(2026, 10, 3, 12);
  final _timers = <({DateTime at, Completer<void> done})>[];

  Future<void> delay(Duration d) {
    final done = Completer<void>();
    _timers.add((at: now.add(d), done: done));
    return done.future;
  }

  Future<void> advance(Duration d) async {
    final end = now.add(d);
    while (true) {
      await settleAsync();
      _timers.sort((a, b) => a.at.compareTo(b.at));
      if (_timers.isEmpty || _timers.first.at.isAfter(end)) break;
      final t = _timers.removeAt(0);
      if (t.at.isAfter(now)) now = t.at;
      t.done.complete();
    }
    now = end;
    await settleAsync();
  }
}

/// Lets pending futures (a fake HTTP reply, the gate's next step) run.
Future<void> settleAsync() async {
  for (var i = 0; i < 40; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// The example JSON lines embedded in a prompt file, in order.
List<String> promptExamples(String file) {
  final s = File('assets/prompts/$file').readAsStringSync();
  return s.split('\n').where((l) => l.startsWith('{"schema_version"')).toList();
}

/// The first example JSON line embedded in a prompt file.
String promptExample(String file) => promptExamples(file).first;

Future<String> loadPromptAsset(String path) => File(path).readAsString();

/// groundingMetadata as the API returns it for an answer that searched Google.
Map<String, dynamic> groundingMetadata({
  List<String> queries = const ['Barilla Spaghetti n.5 500 g Preis'],
  Map<String, String> pages = const {'lidl.de': 'https://vertexaisearch.cloud.google.com/grounding-api-redirect/a1'},
  String? html = '<div class="container"><a class="chip" href="https://www.google.com/search?q=x">x</a></div>',
}) => {
  'webSearchQueries': queries,
  'groundingChunks': [
    for (final e in pages.entries)
      {
        'web': {'uri': e.value, 'title': e.key},
      },
  ],
  if (html != null) 'searchEntryPoint': {'renderedContent': html},
};
