import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';

import '../data/ai/ai_runner.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/prompt_repository.dart';
import '../platform/secret_store.dart';

/// Builds an [AiRunner] when an API key is available.
class AiGateway {
  AiGateway({
    required this.isar,
    required this.secrets,
    required this.prompts,
    http.Client? httpClient,
    this.model = GeminiClient.defaultPrimaryModel,
    this.fallbackModel = GeminiClient.defaultFallbackModel,
    this.baseUrl = GeminiClient.defaultBaseUrl,
  }) : httpClient = httpClient ?? http.Client();

  final Isar isar;
  final SecretStore secrets;
  final PromptRepository prompts;
  final http.Client httpClient;
  final String model;

  /// Null pins every call to [model] (the model eval does this).
  final String? fallbackModel;

  /// Google's endpoint, or a local stand-in for UI checks (`--dart-define=GEMINI_BASE_URL`).
  final String baseUrl;

  Future<bool> get hasKey async => ((await secrets.readApiKey()) ?? '').trim().isNotEmpty;

  Future<AiRunner?> runner() async {
    if (!await hasKey) return null;
    final client = GeminiClient(
      httpClient: httpClient,
      apiKey: secrets.readApiKey,
      model: model,
      fallbackModel: fallbackModel,
      baseUrl: baseUrl,
    );
    return AiRunner(isar, client);
  }

  /// Settings → "Test connection".
  Future<String?> testConnection() async {
    final r = await runner();
    if (r == null) return 'No API key set.';
    try {
      final res = await r.client.generate(
        GeminiRequest(
          systemPrompt: 'Reply with the JSON object {"ok": true} and nothing else.',
          turns: const [Turn.user('ping')],
          thinkingLevel: 'low',
          maxOutputTokens: 256,
          timeout: const Duration(seconds: 30),
        ),
      );
      return res.text.contains('ok') ? null : 'Unexpected reply: ${res.text}';
    } on GeminiException catch (e) {
      return e.message;
    }
  }
}
