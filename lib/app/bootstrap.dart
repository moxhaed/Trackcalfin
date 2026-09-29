import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../data/isar/collections/schemas.dart';

/// App data root. Documents on phones; falls back to app support where a
/// desktop has no XDG documents folder.
Future<String> appDataPath() async {
  Directory base;
  try {
    base = await getApplicationDocumentsDirectory();
  } catch (_) {
    base = await getApplicationSupportDirectory();
  }
  final dir = Directory('${base.path}/trackcalfin');
  await dir.create(recursive: true);
  return dir.path;
}

/// Opens (or reuses) the app database. Safe to call from background isolates.
Future<Isar> openAppIsar() async {
  final existing = Isar.getInstance();
  if (existing != null) return existing;
  return Isar.open(allSchemas, directory: await appDataPath(), inspector: false);
}

Future<String> appSupportPath() async => (await getApplicationSupportDirectory()).path;
Future<String> scansPath() async => '${await appDataPath()}/scans';
