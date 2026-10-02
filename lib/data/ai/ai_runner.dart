import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../core/enums.dart';
import '../isar/collections/ai_call_log.dart';
import 'gemini_client.dart';
import 'json_reader.dart';

class AiOutcome<T> {
  AiOutcome({
    this.value,
    this.errors = const [],
    this.logId,
    this.raw = '',
    this.repaired = false,
    this.transient = false,
    this.grounding,
  });
  final T? value;

  /// What Google Search contributed, for requests that let the model search.
  final Grounding? grounding;

  /// True when the failure was network/quota related and worth retrying later.
  final bool transient;
  final List<String> errors;
  final int? logId;
  final String raw;
  final bool repaired;
  bool get ok => value != null;
}

/// Runs one AI task: call, parse + validate, one repair retry, AiCallLog.
class AiRunner {
  AiRunner(this.isar, this.client);
  final Isar? isar;
  final GeminiClient client;

  static String repairMessage(List<String> errors) =>
      'Your previous response failed validation:\n${errors.take(15).map((e) => '- $e').join('\n')}\n'
      'Return the corrected JSON object only.';

  Future<AiOutcome<T>> run<T>({
    required AiTask task,
    required String promptVersion,
    required GeminiRequest request,
    required ParseResult<T> Function(Map<String, dynamic> json) parse,
  }) async {
    final started = DateTime.now();
    var req = request;
    var repaired = false;
    GeminiResponse? res;
    var errors = <String>[];
    T? value;
    String? fatal;
    var transient = false;
    var inTok = 0, outTok = 0;
    Grounding? grounding;
    try {
      for (var round = 0; round < 2; round++) {
        res = await client.generate(req);
        if (res.truncated) {
          res = await client.generate(req.copyWith(maxOutputTokens: req.maxOutputTokens * 2));
        }
        // A repair answer may not search again; the first round's searches still back it.
        grounding = res.grounding ?? grounding;
        inTok += res.inputTokens ?? 0;
        outTok += res.outputTokens ?? 0;
        final parsed = _decodeAndParse(res.text, parse);
        errors = parsed.errors;
        value = parsed.value;
        if (parsed.ok) break;
        if (round == 0) {
          repaired = true;
          req = req.copyWith(turns: [...req.turns, Turn.model(res.text), Turn.user(repairMessage(errors))]);
        }
      }
    } on GeminiException catch (e) {
      fatal = e.message;
      transient = e.retryable;
    }
    final ok = fatal == null && errors.isEmpty && value != null;
    int? logId;
    if (isar != null) {
      final raw = res?.text ?? '';
      final log = AiCallLog()
        ..at = started
        ..task = task
        ..promptVersion = promptVersion
        ..model = res?.model ?? client.model
        ..latencyMs = DateTime.now().difference(started).inMilliseconds
        ..inputTokens = inTok == 0 ? null : inTok
        ..outputTokens = outTok == 0 ? null : outTok
        ..parsedOk = ok
        ..repaired = repaired
        ..validationFlags = errors.take(20).toList()
        ..error = fatal
        ..rawResponse = raw.length > 20000 ? raw.substring(0, 20000) : raw;
      logId = await isar!.writeTxn(() => isar!.aiCallLogs.put(log));
    }
    if (!ok) {
      return AiOutcome(
        errors: fatal != null ? [fatal] : errors,
        logId: logId,
        raw: res?.text ?? '',
        repaired: repaired,
        transient: transient,
      );
    }
    return AiOutcome(value: value, logId: logId, raw: res!.text, repaired: repaired, grounding: grounding);
  }

  static ParseResult<T> _decodeAndParse<T>(String text, ParseResult<T> Function(Map<String, dynamic>) parse) {
    Object? decoded;
    try {
      decoded = jsonDecode(GeminiClient.stripFences(text));
    } on FormatException catch (e) {
      return ParseResult(null, ['Response is not valid JSON: ${e.message}']);
    }
    if (decoded is! Map) return ParseResult(null, [r'$ must be a JSON object']);
    return parse(decoded.cast<String, dynamic>());
  }
}
