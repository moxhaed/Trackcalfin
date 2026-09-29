import 'dart:ffi';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';

bool _coreReady = false;

/// Finds the libisar binary that isar_community_flutter_libs ships for this host,
/// so tests don't depend on downloading it.
String? _bundledCore() {
  final pubCache = Platform.environment['PUB_CACHE'] ?? '${Platform.environment['HOME']}/.pub-cache';
  final lib = Platform.isMacOS ? 'macos/libisar.dylib' : 'linux/libisar.so';
  final dir = Directory('$pubCache/hosted/pub.dev');
  if (!dir.existsSync()) return null;
  for (final e in dir.listSync()) {
    if (e is Directory && e.path.contains('isar_community_flutter_libs-')) {
      final f = File('${e.path}/$lib');
      if (f.existsSync()) return f.path;
    }
  }
  return null;
}

/// Opens a throwaway Isar instance for use-case tests.
Future<Isar> openTestDb() async {
  if (!_coreReady) {
    final path = _bundledCore();
    await Isar.initializeIsarCore(libraries: path == null ? const {} : {Abi.current(): path}, download: path == null);
    _coreReady = true;
  }
  final dir = await Directory.systemTemp.createTemp('trackcalfin_test_');
  return Isar.open(allSchemas, directory: dir.path, name: 'test_${DateTime.now().microsecondsSinceEpoch}');
}

Future<void> closeTestDb(Isar isar) => isar.close(deleteFromDisk: true);
