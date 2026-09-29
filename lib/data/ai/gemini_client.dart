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
  const Turn.model(this.text)
      : role = 'model',
        images = const [];
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
  });

  final String systemPrompt;
  final List<Turn> turns;
  final String thinkingLevel;
  final bool highMediaResolution;
  final Map<String, dynamic>? responseSchema;
  final int maxOutputTokens;
  final Duration timeout;

  GeminiRequest copyWith({List<Turn>? turns, int? maxOutputTokens}) => GeminiRequest(
        systemPrompt: systemPrompt,
        turns: turns ?? this.turns,
        thinkingLevel: thinkingLevel,
        highMediaResolution: highMediaResolution,
        responseSchema: responseSchema,
        maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
        timeout: timeout,
      );
}

class GeminiResponse {
  GeminiResponse({
    required this.text,
    required this.finishReason,
    required this.latencyMs,
    this.inputTokens,
    this.outputTokens,
  });
  final String text;
  final String? finishReason;
  final int latencyMs;
  final int? inputTokens;
  final int? outputTokens;

  bool get truncated => finishReason == 'MAX_TOKENS';
}

/// Thin REST client for `models/{model}:generateContent`.
///
/// Sends the full config first (JSON schema, thinking level, media resolution).
/// If the API rejects a field with HTTP 400, it steps down to a simpler body and
/// remembers the level that works, so a renamed field never breaks the app.
class GeminiClient {
  GeminiClient({
    required this.httpClient,
    required this.apiKey,
    required this.model,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future.delayed;

  final http.Client httpClient;
  final Future<String?> Function() apiKey;
  final String model;
  final String baseUrl;
  final Future<void> Function(Duration) _delay;

  /// 0 = full config, 1 = no schema / media resolution, 2 = JSON mime type only.
  static int compatLevel = 0;
  static const _backoff = [Duration(seconds: 2), Duration(seconds: 8)];

  Map<String, dynamic> buildBody(GeminiRequest r, {int level = 0}) {
    final config = <String, dynamic>{
      'responseMimeType': 'application/json',
      'maxOutputTokens': r.maxOutputTokens,
    };
    if (level < 2) config['thinkingConfig'] = {'thinkingLevel': r.thinkingLevel};
    if (level < 1) {
      if (r.responseSchema != null) config['responseJsonSchema'] = r.responseSchema;
      if (r.highMediaResolution) config['mediaResolution'] = 'MEDIA_RESOLUTION_HIGH';
    }
    return {
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
    var attempt = 0;
    while (true) {
      try {
        return await _send(r, key.trim());
      } on GeminiException catch (e) {
        if (e.status == 400 && compatLevel < 2 && _looksLikeFieldRejection(e.message)) {
          compatLevel++;
          continue;
        }
        if (!e.retryable || attempt >= _backoff.length) rethrow;
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

  Future<GeminiResponse> _send(GeminiRequest r, String key) async {
    final uri = Uri.parse('$baseUrl/models/$model:generateContent');
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
        msg = (jsonDecode(res.body) as Map)['error']?['message']?.toString() ?? res.body;
      } catch (_) {}
      throw GeminiException(msg,
          status: res.statusCode, retryable: res.statusCode == 429 || res.statusCode >= 500);
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
    );
  }

  /// Removes ```json fences a model sometimes adds despite JSON mode.
  static String stripFences(String s) {
    final t = s.trim();
    final m = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(t);
    if (m != null) return m.group(1)!;
    final start = t.indexOf('{');
    final end = t.lastIndexOf('}');
    if (start > 0 && end > start) return t.substring(start, end + 1);
    return t;
  }
}
