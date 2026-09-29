import 'package:isar_community/isar.dart';

import '../../../core/enums.dart';

part 'ai_call_log.g.dart';

/// One Gemini call: for debugging and prompt tuning.
@collection
class AiCallLog {
  Id id = Isar.autoIncrement;

  @Index()
  DateTime at = DateTime.now();

  @Enumerated(EnumType.name)
  AiTask task = AiTask.receipt;

  /// e.g. "receipt_extraction.v1".
  String promptVersion = '';
  String model = '';
  int latencyMs = 0;
  int? inputTokens;
  int? outputTokens;
  bool parsedOk = false;
  bool repaired = false;
  List<String> validationFlags = [];
  String? error;

  /// Truncated to 20k chars.
  String rawResponse = '';
}
