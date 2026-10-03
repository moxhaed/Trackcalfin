import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'gemini_gate.dart';

export 'gemini_gate.dart' show AiPriority, GateWait, GeminiGate;

/// Which quota a 429 hit, from the quotaId Google sends with it.
enum QuotaKind { perMinute, perDay }

class GeminiException implements Exception {
  GeminiException(
    this.message, {
    this.status,
    this.retryable = false,
    this.quota,
    this.retryAfter,
    this.limit,
    this.timedOut = false,
  });
  final String message;
  final int? status;
  final bool retryable;

  /// Set for a 429: a per-minute quota clears after [retryAfter], a daily one at midnight Pacific.
  final QuotaKind? quota;
  final Duration? retryAfter;

  /// The quota's size when Google said (15 requests a minute, 500 a day).
  final int? limit;

  /// The request took longer than its timeout. The same model is not asked again.
  final bool timedOut;

  @override
  String toString() => 'GeminiException(${status ?? '-'}): $message';
}

/// What a 429's details say (Google's RetryInfo and QuotaFailure).
class QuotaInfo {
  const QuotaInfo({required this.kind, this.retryAfter, this.limit, this.unit = 'requests', this.freeTier = true});
  final QuotaKind kind;
  final Duration? retryAfter;
  final int? limit;

  /// 'requests' or 'input tokens'.
  final String unit;
  final bool freeTier;

  /// Google's text says "retry in 40s" even when the daily cap is hit, so the quotaId decides.
  /// A 429 that names no quota counts as a per-minute one.
  static QuotaInfo parse(Map? error) {
    Duration? retry;
    ({String id, int? value})? day, minute;
    for (final d in (error?['details'] as List?) ?? const []) {
      if (d is! Map) continue;
      if ('${d['@type']}'.endsWith('RetryInfo')) retry = parseDelay(d['retryDelay']);
      for (final v in (d['violations'] as List?) ?? const []) {
        if (v is! Map) continue;
        final id = '${v['quotaId'] ?? ''}';
        final value = int.tryParse('${v['quotaValue'] ?? ''}');
        if (id.contains('PerDay')) day ??= (id: id, value: value);
        if (id.contains('PerMinute')) minute ??= (id: id, value: value);
      }
    }
    final said = RegExp(r'retry in (\d+(?:\.\d+)?)s', caseSensitive: false).firstMatch('${error?['message'] ?? ''}');
    retry ??= said == null ? null : parseDelay('${said.group(1)}s');
    final hit = day ?? minute;
    return QuotaInfo(
      kind: day != null ? QuotaKind.perDay : QuotaKind.perMinute,
      retryAfter: retry,
      limit: hit?.value,
      unit: hit != null && hit.id.contains('Token') ? 'input tokens' : 'requests',
      freeTier: hit == null || hit.id.contains('FreeTier'),
    );
  }

  /// "46s" or "46.960238s" (a protobuf Duration in JSON).
  static Duration? parseDelay(Object? v) {
    final m = RegExp(r'^(\d+(?:\.\d+)?)s$').firstMatch('${v ?? ''}'.trim());
    if (m == null) return null;
    return Duration(milliseconds: (double.parse(m.group(1)!) * 1000).ceil());
  }
}

/// A document sent with a turn: its bytes inline, or a file uploaded with the Files API
/// (`GeminiFiles`), which later calls point at instead of sending it again.
class Attachment {
  const Attachment.inline(this.mimeType, Uint8List this.bytes) : fileUri = null;
  const Attachment.uploaded(this.mimeType, String this.fileUri) : bytes = null;
  final String mimeType;
  final Uint8List? bytes;
  final String? fileUri;

  Map<String, dynamic> toPart() => bytes != null
      ? {
          'inlineData': {'mimeType': mimeType, 'data': base64Encode(bytes!)},
        }
      : {
          'fileData': {'mimeType': mimeType, 'fileUri': fileUri},
        };
}

class Turn {
  const Turn.user(this.text, [this.images = const [], this.documents = const []]) : role = 'user';
  const Turn.model(this.text) : role = 'model', images = const [], documents = const [];
  final String role;
  final String text;
  final List<Uint8List> images;

  /// Sent before the text: Google advises putting the prompt after a document, and calls
  /// over the same document then share a prefix.
  final List<Attachment> documents;
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
    this.priority = AiPriority.user,
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

  /// Who waits for the answer: the gate serves user requests first, and only they spend the
  /// fallback model's small quota when the main model is rate limited.
  final AiPriority priority;

  GeminiRequest copyWith({List<Turn>? turns, int? maxOutputTokens}) => GeminiRequest(
    systemPrompt: systemPrompt,
    turns: turns ?? this.turns,
    thinkingLevel: thinkingLevel,
    highMediaResolution: highMediaResolution,
    responseSchema: responseSchema,
    maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
    timeout: timeout,
    googleSearch: googleSearch,
    priority: priority,
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
/// scarce Flash requests are only spent when Flash-Lite is down, or out of quota while a user
/// waits. Both accept `thinkingLevel` low and medium, so neither trips [compatLevel].
///
/// Every request goes through [gate] (one per app): it paces requests, serves user requests
/// first and remembers what each 429 said. A per-minute 429 is waited out once when it clears
/// soon; a per-day 429 makes the model fail fast, without a request, until midnight Pacific.
class GeminiClient {
  static const defaultPrimaryModel = 'gemini-3.5-flash-lite';
  static const defaultFallbackModel = 'gemini-3.8-flash';
  static const defaultBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiClient({
    required this.httpClient,
    required this.apiKey,
    this.model = defaultPrimaryModel,
    this.fallbackModel = defaultFallbackModel,
    this.baseUrl = defaultBaseUrl,
    GeminiGate? gate,
    Future<void> Function(Duration)? delay,
  }) : gate = gate ?? GeminiGate(),
       _delay = delay ?? Future.delayed;

  final http.Client httpClient;
  final Future<String?> Function() apiKey;
  final String model;
  final String? fallbackModel;
  final String baseUrl;
  final GeminiGate gate;
  final Future<void> Function(Duration) _delay;

  /// 0 = full config, 1 = no schema / media resolution, 2 = JSON mime type only.
  static int compatLevel = 0;
  static const _backoff = [Duration(seconds: 2), Duration(seconds: 8)];

  /// A per-minute 429 that clears within this is waited out when someone waits for the answer...
  static const maxUserWait = Duration(seconds: 30);

  /// ...and within this for background work, which nobody watches. Failing it would only
  /// queue the same request again later.
  static const maxBackgroundWait = Duration(seconds: 65);

  /// A user request waits this long for the main model rather than spend a fallback request.
  static const waitRatherThanFallBack = Duration(seconds: 5);

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
              for (final d in t.documents) d.toPart(),
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
    final k = key.trim();
    final fb = fallbackModel != null && fallbackModel != model ? fallbackModel! : null;
    final user = r.priority == AiPriority.user;
    final ownWait = user ? maxUserWait : maxBackgroundWait;
    // Someone waits and the main model is cooling down from a 429: the fallback is quicker.
    if (fb != null && user && gate.cooldownLeft(model) > waitRatherThanFallBack && gate.available(fb)) {
      try {
        return await _sendWithRetry(r, k, fb, maxRateWait: Duration.zero);
      } on GeminiException {
        // Wait for the main model after all.
      }
    }
    // Only a user request spends the fallback's small quota when the main model is out of quota.
    final fallbackReady = fb != null && user && gate.available(fb);
    final GeminiException primaryError;
    try {
      return await _sendWithRetry(r, k, model, maxRateWait: fallbackReady ? waitRatherThanFallBack : ownWait);
    } on GeminiException catch (e) {
      primaryError = e;
    }
    if (fb == null || (primaryError.quota != null && !fallbackReady)) throw primaryError;
    try {
      return await _sendWithRetry(r, k, fb, maxRateWait: Duration.zero);
    } on GeminiException catch (fallbackError) {
      // The fallback is out too, but the main model clears within the wait: wait for it once.
      final mainSoon =
          primaryError.quota == QuotaKind.perMinute &&
          (primaryError.retryAfter ?? Duration.zero) > waitRatherThanFallBack &&
          gate.cooldownLeft(model) <= ownWait;
      if (!mainSoon) throw _bothFailed(primaryError, fallbackError);
      try {
        return await _sendWithRetry(r, k, model, maxRateWait: Duration.zero);
      } on GeminiException catch (e) {
        throw _bothFailed(e, fallbackError);
      }
    }
  }

  GeminiException _bothFailed(GeminiException primary, GeminiException fallback) {
    if (primary.quota == QuotaKind.perDay && fallback.quota == QuotaKind.perDay) {
      return GeminiException(
        'Daily limits reached for $model and $fallbackModel. They reset at midnight Pacific time.',
        status: 429,
        retryable: true,
        quota: QuotaKind.perDay,
      );
    }
    // The main model's quota message says what to do; the fallback's raw error adds nothing.
    if (primary.quota != null) return primary;
    return GeminiException(
      'Primary ($model) failed: ${primary.message}; Fallback ($fallbackModel) failed: ${fallback.message}',
      status: fallback.status ?? primary.status,
      retryable: fallback.retryable || primary.retryable,
      quota: fallback.quota,
      retryAfter: fallback.retryAfter,
    );
  }

  /// Sends through the gate, retrying what a retry can fix: a rejected config field (stepped
  /// down), a 5xx or network error (backed off twice), and a per-minute 429 that clears within
  /// [maxRateWait] (once; the gate holds the retry until then). A model whose daily quota is
  /// spent fails at once, without a request.
  Future<GeminiResponse> _sendWithRetry(
    GeminiRequest r,
    String key,
    String targetModel, {
    required Duration maxRateWait,
  }) async {
    var attempt = 0;
    var waited = false;
    while (true) {
      final spent = gate.dailyLimit(targetModel);
      if (spent != null) throw GeminiException(spent, status: 429, retryable: true, quota: QuotaKind.perDay);
      try {
        return await gate.run(targetModel, r.priority, () => _send(r, key, targetModel));
      } on GeminiException catch (e) {
        // A model or key without Google Search answers a search request with a 400. That says
        // nothing about the config every other call uses, so don't step it down.
        if (r.googleSearch && e.status == 400) rethrow;
        if (e.status == 400 && compatLevel < 2 && _looksLikeFieldRejection(e.message)) {
          compatLevel++;
          continue;
        }
        if (e.quota == QuotaKind.perDay) {
          gate.dailyLimitReached(targetModel, nextPacificMidnight(gate.now), e.message);
          rethrow;
        }
        if (e.quota == QuotaKind.perMinute) {
          if (waited || e.retryAfter! > maxRateWait) rethrow;
          waited = true;
          continue;
        }
        // A model that ran past the timeout once likely will again; the fallback may not.
        if (e.timedOut || !e.retryable || attempt >= _backoff.length) rethrow;
        await _delay(_backoff[attempt]);
        attempt++;
      }
    }
  }

  /// When daily quotas reset: the next midnight in California (PDT in US summer time, else PST).
  static DateTime nextPacificMidnight(DateTime now) {
    final utc = now.toUtc();
    final offset = Duration(hours: _usSummerTime(utc) ? -7 : -8);
    final local = utc.add(offset);
    return DateTime.utc(local.year, local.month, local.day + 1).subtract(offset);
  }

  /// From the second Sunday of March to the first Sunday of November, 2:00 local time.
  static bool _usSummerTime(DateTime utc) {
    DateTime sunday(int month, int n) {
      final first = DateTime.utc(utc.year, month);
      return DateTime.utc(utc.year, month, 1 + (DateTime.sunday - first.weekday) % 7 + 7 * (n - 1));
    }

    final start = sunday(3, 2).add(const Duration(hours: 10));
    final end = sunday(11, 1).add(const Duration(hours: 9));
    return !utc.isBefore(start) && utc.isBefore(end);
  }

  /// What the user reads when a per-minute quota is used up and waiting didn't help.
  static String rateLimitMessage(String model, QuotaInfo q, Duration wait) {
    final s = (wait.inMilliseconds / 1000).ceil();
    final who = q.freeTier ? "Gemini's free tier" : 'Your Gemini plan';
    final what = q.limit == null
        ? 'Gemini is rate limiting $model right now (too many requests a minute)'
        : "$who allows ${q.limit} ${q.unit} a minute on $model, and they're used up";
    return '$what. Try again in about $s s.';
  }

  GeminiException _quotaError(Map? error, String targetModel) {
    final q = QuotaInfo.parse(error);
    if (q.kind == QuotaKind.perDay) {
      return GeminiException(
        '${q.freeTier ? 'Daily free-tier limit' : 'Daily limit'} reached for $targetModel'
        '${q.limit != null ? ' (${q.limit} requests)' : ''}. It resets at midnight Pacific time.',
        status: 429,
        retryable: true,
        quota: QuotaKind.perDay,
        limit: q.limit,
      );
    }
    final wait = q.retryAfter ?? const Duration(seconds: 30);
    gate.rateLimited(targetModel, wait, limit: q.limit, unit: q.unit, freeTier: q.freeTier);
    return GeminiException(
      rateLimitMessage(targetModel, q, wait),
      status: 429,
      retryable: true,
      quota: QuotaKind.perMinute,
      retryAfter: wait,
      limit: q.limit,
    );
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
      throw GeminiException('Timed out after ${r.timeout.inSeconds}s', retryable: true, timedOut: true);
    } on Exception catch (e) {
      throw GeminiException('Network error: $e', retryable: true);
    }
    final latency = DateTime.now().difference(started).inMilliseconds;
    if (res.statusCode != 200) {
      var msg = res.body;
      Map? error;
      try {
        error = (jsonDecode(res.body) as Map)['error'] as Map?;
        msg = error?['message']?.toString() ?? res.body;
      } catch (_) {}
      if (res.statusCode == 429) throw _quotaError(error, targetModel);
      throw GeminiException(msg, status: res.statusCode, retryable: res.statusCode >= 500);
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
