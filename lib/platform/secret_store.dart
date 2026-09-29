import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the Gemini API key. Never stored in Isar, exports or logs.
abstract class SecretStore {
  Future<String?> readApiKey();
  Future<void> writeApiKey(String? key);
}

class MemorySecretStore implements SecretStore {
  MemorySecretStore([this._key]);
  String? _key;

  @override
  Future<String?> readApiKey() async => _key;

  @override
  Future<void> writeApiKey(String? key) async => _key = key;
}

/// Keychain / Keystore backed store. On desktop dev builds without a keyring
/// it falls back to a private file in the app support directory.
class SecureSecretStore implements SecretStore {
  SecureSecretStore({required this.fallbackDir});

  final String fallbackDir;
  static const _name = 'gemini_api_key';
  final _storage = const FlutterSecureStorage();

  File get _file => File('$fallbackDir/.gemini_key');

  @override
  Future<String?> readApiKey() async {
    try {
      final v = await _storage.read(key: _name);
      if (v != null) return v;
    } catch (_) {}
    if ((Platform.isLinux || Platform.isMacOS || Platform.isWindows) && _file.existsSync()) {
      return _file.readAsStringSync().trim();
    }
    return null;
  }

  @override
  Future<void> writeApiKey(String? key) async {
    final value = key?.trim();
    try {
      if (value == null || value.isEmpty) {
        await _storage.delete(key: _name);
      } else {
        await _storage.write(key: _name, value: value);
      }
      return;
    } catch (_) {
      if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) rethrow;
    }
    if (value == null || value.isEmpty) {
      if (_file.existsSync()) _file.deleteSync();
    } else {
      _file.parent.createSync(recursive: true);
      _file.writeAsStringSync(value);
    }
  }
}
