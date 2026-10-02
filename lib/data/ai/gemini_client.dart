import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  GeminiException(this.message, {this.status, this.retryable = false});
  final String message;
  final int? status;
  final bool retryable;

  @override
  String toString() => 'GeminiException(${status ?? '-'}): $message';
}

class Turn {
  const Turn.user(this.text, [this.images = const []]) : role = 'user';
  const Turn.model(this.text) : role = 'model', images = const [];
  final String role;
  final String text;
  final List<Uint8List> images;
}

class GeminiRequest {
  GeminiRequest({
    required this.systemPrompt,
    required this.turns,
    this.thinkingLevel = 'medium',
    this.highMediaResolution = false,
    this.responseSchema,
    this.maxOutputTokens = 8192,
    this.timeout = const Duration(seconds: 45),
    this.googleSearch = false,
  });

  final String systemPrompt;
  final List<Turn> turns;
  final String thinkingLevel;
  final bool highMediaResolution;
  final Map<String, dynamic>? responseSchema;
  final int maxOutputTokens;
  final Duration timeout;

  /// Lets the model search Google (grounding). The answer then comes as plain text holding the
  /// JSON: with JSON mode on, the API leaves out the sources it searched.
  final bool googleSearch;

  GeminiRequest copyWith({List<Turn>? turns, int? maxOutputTokens}) => GeminiRequest(
    systemPrompt: systemPrompt,
    turns: turns ?? this.turns,
    thinkingLevel: thinkingLevel,
    highMediaResolution: highMediaResolution,
    responseSchema: responseSchema,
    maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
    timeout: timeout,
    googleSearch: googleSearch,
  );
}

/// A web page a grounded answer drew on. [title] is usually the site's domain ("rewe.de").
class WebSource {
  const WebSource(this.title, this.uri);
  final String title;
  final String uri;
}

/// What Google Search added to an answer (the response's groundingMetadata).
class Grounding {
  const Grounding({this.queries = const [], this.sources = const [], this.searchEntryHtml});

  /// The searches the model ran.
  final List<String> queries;
  final List<WebSource> sources;

  /// Google's search-suggestion chips as HTML. Google requires showing them unmodified
  /// next to anything taken from the search.
  final String? searchEntryHtml;

  static Grounding? fromJson(Map? m) {
    if (m == null) return null;
    final web = [
      for (final c in (m['groundingChunks'] as List?) ?? const [])
        if (c is Map && c['web'] is Map) c['web'] as Map,
    ];
    return Grounding(
      queries: [...((m['webSearchQueries'] as List?) ?? const []).whereType<String>()],
      sources: [
        for (final w in web)
          if (w['uri'] is String) WebSource(w['title'] is String ? w['title'] as String : '', w['uri'] as String),
      ],
      searchEntryHtml: (m['searchEntryPoint'] as Map?)?['renderedContent'] as String?,
    );
  }
}

class GeminiResponse {
  GeminiResponse({
    required this.text,
    required this.finishReason,
    required this.latencyMs,
    this.inputTokens,
    this.outputTokens,
    this.model,
    this.grounding,
  });
  final String text;
  final String? finishReason;
  final int latencyMs;
  final int? inputTokens;
  final int? outputTokens;
  final String? model;

  /// Set when the model searched Google.
  final Grounding? grounding;

  bool get truncated => finishReason == 'MAX_TOKENS';
}

/// Thin REST client for `models/{model}:generateContent`.
///
/// Sends the full config first (JSON schema, thinking level, media resolution).
/// If the API rejects a field with HTTP 400, it steps down to a simpler body and
/// remembers the level that works, so a renamed field never breaks the app.
///
/// Runs on `gemini-3.5-flash-lite` and falls back to `gemini-3.8-flash`.
/// On the free tier they have separate quotas (Flash-Lite: 500 requests/day, Flash: 20), so the
/// scarce Flash requests are only spent when Flash-Lite is rate limited or down. Both accept
/// `thinkingLevel` low and medium, so neither trips [compatLevel].
class GeminiClient {
  static const defaultPrimaryModel = 'gemini-3.5-flash-lite';
  static const defaultFallbackModel = 'gemini-3.8-flash';

  GeminiClient({
    required this.httpClient,
    required this.apiKey,
    this.model = defaultPrimaryModel,
    this.fallbackModel = defaultFallbackModel,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future.delayed;

  final http.Client httpClient;
  final Future<String?> Function() apiKey;
  final String model;
  final String? fallbackModel;
  final String baseUrl;
  final Future<void> Function(Duration) _delay;

  /// 0 = full config, 1 = no schema / media resolution, 2 = JSON mime type only.
  static int compatLevel = 0;
  static const _backoff = [Duration(seconds: 2), Duration(seconds: 8)];

  Map<String, dynamic> buildBody(GeminiRequest r, {int level = 0}) {
    final config = <String, dynamic>{'maxOutputTokens': r.maxOutputTokens};
    if (!r.googleSearch) config['responseMimeType'] = 'application/json';
    if (level < 2) config['thinkingConfig'] = {'thinkingLevel': r.thinkingLevel};
    if (level < 1) {
      if (r.responseSchema != null && !r.googleSearch) config['responseJsonSchema'] = r.responseSchema;
      if (r.highMediaResolution) config['mediaResolution'] = 'MEDIA_RESOLUTION_HIGH';
    }
    return {
      if (r.googleSearch)
        'tools': [
          {'google_search': <String, dynamic>{}},
        ],
      'systemInstruction': {
        'parts': [
          {'text': r.systemPrompt},
        ],
      },
      'contents': [
        for (final t in r.turns)
          {
            'role': t.role,
            'parts': [
              {'text': t.text},
              for (final img in t.images)
                {
                  'inlineData': {'mimeType': 'image/jpeg', 'data': base64Encode(img)},
                },
            ],
          },
      ],
      'generationConfig': config,
    };
  }

  Future<GeminiResponse> generate(GeminiRequest r) async {
    final key = await apiKey();
    if (key == null || key.trim().isEmpty) {
      throw GeminiException('No Gemini API key set. Add one in Settings → AI.');
    }
    final trimmedKey = key.trim();
    try {
      return await _sendWithRetry(r, trimmedKey, model);
    } on GeminiException catch (primaryError) {
      if (fallbackModel != null && fallbackModel != model) {
        try {
          return await _sendWithRetry(r, trimmedKey, fallbackModel!);
        } on GeminiException catch (fallbackError) {
          throw GeminiException(
            'Primary ($model) failed: ${primaryError.message}; Fallback ($fallbackModel) failed: ${fallbackError.message}',
            status: fallbackError.status ?? primaryError.status,
            retryable: fallbackError.retryable || primaryError.retryable,
          );
        }
      }
      rethrow;
    }
  }

  Future<GeminiResponse> _sendWithRetry(GeminiRequest r, String key, String targetModel) async {
    var attempt = 0;
    while (true) {
      try {
        return await _send(r, key, targetModel);
      } on GeminiException catch (e) {
        // A model or key without Google Search answers a search request with a 400. That says
        // nothing about the config every other call uses, so don't step it down.
        if (r.googleSearch && e.status == 400) rethrow;
        if (e.status == 400 && compatLevel < 2 && _looksLikeFieldRejection(e.message)) {
          compatLevel++;
          continue;
        }
        // A 429 means this model's quota is spent: backing off 10 s won't bring it back, the fallback might.
        if (!e.retryable || e.status == 429 || attempt >= _backoff.length) rethrow;
        await _delay(_backoff[attempt]);
        attempt++;
      }
    }
  }

  static bool _looksLikeFieldRejection(String msg) {
    final m = msg.toLowerCase();
    return m.contains('unknown name') ||
        m.contains('invalid json payload') ||
        m.contains('thinking') ||
        m.contains('schema') ||
        m.contains('media_resolution') ||
        m.contains('mediaresolution') ||
        m.contains('not supported');
  }

  /// Google's 429 text says "retry in 40s" even when the daily cap is hit; the quotaId tells them apart.
  static String? _dailyQuotaMessage(Map? error, String model) {
    for (final d in (error?['details'] as List?) ?? const []) {
      for (final v in (d is Map ? d['violations'] as List? : null) ?? const []) {
        if (v is Map && '${v['quotaId']}'.contains('PerDay')) {
          final limit = v['quotaValue'];
          return 'Daily free-tier limit reached for $model${limit != null ? ' ($limit requests)' : ''}. '
              'It resets at midnight Pacific time.';
        }
      }
    }
    return null;
  }

  Future<GeminiResponse> _send(GeminiRequest r, String key, String targetModel) async {
    final uri = Uri.parse('$baseUrl/models/$targetModel:generateContent');
    final started = DateTime.now();
    http.Response res;
    try {
      res = await httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'x-goog-api-key': key},
            body: jsonEncode(buildBody(r, level: compatLevel)),
          )
          .timeout(r.timeout);
    } on TimeoutException {
      throw GeminiException('Timed out after ${r.timeout.inSeconds}s', retryable: true);
    } on Exception catch (e) {
      throw GeminiException('Network error: $e', retryable: true);
    }
    final latency = DateTime.now().difference(started).inMilliseconds;
    if (res.statusCode != 200) {
      var msg = res.body;
      try {
        final error = (jsonDecode(res.body) as Map)['error'] as Map?;
        msg = error?['message']?.toString() ?? res.body;
        if (res.statusCode == 429) msg = _dailyQuotaMessage(error, targetModel) ?? msg;
      } catch (_) {}
      throw GeminiException(msg, status: res.statusCode, retryable: res.statusCode == 429 || res.statusCode >= 500);
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final candidates = (json['candidates'] as List?) ?? const [];
    if (candidates.isEmpty) {
      final reason = json['promptFeedback']?['blockReason'];
      throw GeminiException('No candidates returned${reason != null ? ' (blocked: $reason)' : ''}');
    }
    final c = candidates.first as Map<String, dynamic>;
    final parts = (c['content']?['parts'] as List?) ?? const [];
    final text = parts
        .whereType<Map>()
        .where((p) => p['thought'] != true && p['text'] is String)
        .map((p) => p['text'] as String)
        .join();
    final usage = json['usageMetadata'] as Map?;
    return GeminiResponse(
      text: text,
      finishReason: c['finishReason'] as String?,
      latencyMs: latency,
      inputTokens: (usage?['promptTokenCount'] as num?)?.toInt(),
      outputTokens: (usage?['candidatesTokenCount'] as num?)?.toInt(),
      model: targetModel,
      grounding: Grounding.fromJson(c['groundingMetadata'] as Map?),
    );
  }

  /// Removes ```json fences a model sometimes adds despite JSON mode.
  static String stripFences(String s) {
    final t = s.trim();
    final m = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(t);
    if (m != null) return m.group(1)!;
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start >= 0 && end > start) return t.substring(start, end + 1);
    return t;
  }
}
