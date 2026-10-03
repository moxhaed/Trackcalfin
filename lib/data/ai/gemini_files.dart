import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'gemini_client.dart';

/// A file stored with the Gemini Files API.
class GeminiFile {
  const GeminiFile({required this.name, required this.uri, required this.mimeType, required this.state, this.expiresAt});

  /// "files/abc123": what `files/{id}` calls take.
  final String name;

  /// What a request points at (`fileData.fileUri`).
  final String uri;
  final String mimeType;

  /// PROCESSING, ACTIVE or FAILED.
  final String state;

  /// Files are kept for about 48 hours.
  final DateTime? expiresAt;

  bool get active => state == 'ACTIVE';

  static GeminiFile fromJson(Map m) => GeminiFile(
    name: '${m['name'] ?? ''}',
    uri: '${m['uri'] ?? ''}',
    mimeType: '${m['mimeType'] ?? ''}',
    state: '${m['state'] ?? 'ACTIVE'}',
    expiresAt: DateTime.tryParse('${m['expirationTime'] ?? ''}'),
  );
}

/// The Files API: a resumable upload (`upload/v1beta/files`: start, then upload and finalize
/// in one request), then `files/{id}` until the file is ACTIVE. A large PDF is uploaded once
/// and every call over it sends only its URI.
class GeminiFiles {
  GeminiFiles({
    required this.httpClient,
    required this.apiKey,
    this.baseUrl = GeminiClient.defaultBaseUrl,
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future.delayed;

  /// Uses [client]'s connection, key and endpoint.
  factory GeminiFiles.of(GeminiClient client, {Future<void> Function(Duration)? delay}) =>
      GeminiFiles(httpClient: client.httpClient, apiKey: client.apiKey, baseUrl: client.baseUrl, delay: delay);

  final http.Client httpClient;
  final Future<String?> Function() apiKey;
  final String baseUrl;
  final Future<void> Function(Duration) _delay;

  /// `https://…/v1beta` → `https://…/upload/v1beta/files`.
  Uri get uploadUri {
    final base = Uri.parse(baseUrl);
    return base.replace(path: '/upload${base.path}/files');
  }

  Future<String> _key() async {
    final key = (await apiKey())?.trim() ?? '';
    if (key.isEmpty) throw GeminiException('No Gemini API key set. Add one in Settings → AI.');
    return key;
  }

  Future<http.Response> _send(Future<http.Response> Function() call, Duration timeout) async {
    final http.Response res;
    try {
      res = await call().timeout(timeout);
    } on TimeoutException {
      throw GeminiException('Upload timed out after ${timeout.inSeconds}s', retryable: true);
    } on Exception catch (e) {
      throw GeminiException('Network error: $e', retryable: true);
    }
    if (res.statusCode != 200) {
      var msg = res.body;
      try {
        msg = ((jsonDecode(res.body) as Map)['error'] as Map?)?['message']?.toString() ?? res.body;
      } catch (_) {}
      throw GeminiException(msg, status: res.statusCode, retryable: res.statusCode == 429 || res.statusCode >= 500);
    }
    return res;
  }

  Future<GeminiFile> upload(
    Uint8List bytes, {
    required String mimeType,
    required String displayName,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final key = await _key();
    final start = await _send(
      () => httpClient.post(
        uploadUri,
        headers: {
          'x-goog-api-key': key,
          'X-Goog-Upload-Protocol': 'resumable',
          'X-Goog-Upload-Command': 'start',
          'X-Goog-Upload-Header-Content-Length': '${bytes.length}',
          'X-Goog-Upload-Header-Content-Type': mimeType,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': {'display_name': displayName},
        }),
      ),
      const Duration(seconds: 30),
    );
    final url = start.headers['x-goog-upload-url'];
    if (url == null || url.isEmpty) throw GeminiException('The upload was not accepted (no upload URL).');
    final res = await _send(
      () => httpClient.post(
        Uri.parse(url),
        headers: {'x-goog-api-key': key, 'X-Goog-Upload-Offset': '0', 'X-Goog-Upload-Command': 'upload, finalize'},
        body: bytes,
      ),
      timeout,
    );
    final file = GeminiFile.fromJson(((jsonDecode(res.body) as Map)['file'] as Map?) ?? const {});
    if (file.uri.isEmpty) throw GeminiException('The upload did not return a file URI.');
    return file.active ? file : waitUntilActive(file);
  }

  Future<GeminiFile> get(String name) async {
    final key = await _key();
    final res = await _send(
      () => httpClient.get(Uri.parse('$baseUrl/$name'), headers: {'x-goog-api-key': key}),
      const Duration(seconds: 30),
    );
    return GeminiFile.fromJson(jsonDecode(res.body) as Map);
  }

  /// Polls a file that is still PROCESSING. PDFs are usually ready at once.
  Future<GeminiFile> waitUntilActive(GeminiFile file, {int tries = 20}) async {
    var f = file;
    for (var i = 0; i < tries && f.state == 'PROCESSING'; i++) {
      await _delay(const Duration(seconds: 3));
      f = await get(f.name);
    }
    if (f.state == 'FAILED') throw GeminiException('Google could not process the file.');
    if (!f.active) throw GeminiException('The file is still being processed. Try again in a minute.', retryable: true);
    return f;
  }
}
