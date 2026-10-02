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
