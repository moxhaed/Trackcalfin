import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../data/isar/collections/schemas.dart';

/// Full JSON export/import of the database (AiCallLog excluded).
class BackupService {
  BackupService(this.isar);
  final Isar isar;

  static const format = 'trackcalfin-backup';
  static const version = 1;

  Future<String> exportJson() async {
    final data = <String, dynamic>{
      'format': format,
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'ingredients': await isar.ingredients.where().exportJson(),
      'transactions': await isar.transactions.where().exportJson(),
      'recipes': await isar.recipes.where().exportJson(),
      'dailyLogs': await isar.dailyLogs.where().exportJson(),
      'cookSessions': await isar.cookSessions.where().exportJson(),
      'scanJobs': await isar.scanJobs.where().exportJson(),
      'userProfiles': await isar.userProfiles.where().exportJson(),
      'metricEvents': await isar.metricEvents.where().exportJson(),
    };
    return jsonEncode(data);
  }

  /// Replaces everything with the backup. Throws [FormatException] on a bad file.
  Future<Map<String, int>> importJson(String json) async {
    final data = jsonDecode(json);
    if (data is! Map || data['format'] != format) throw const FormatException('Not a Trackcalfin backup file');
    List<Map<String, dynamic>> list(String k) =>
        ((data[k] as List?) ?? const []).cast<Map>().map((m) => m.cast<String, dynamic>()).toList();
    final counts = <String, int>{};
    await isar.writeTxn(() async {
      await isar.clear();
      await isar.ingredients.importJson(list('ingredients'));
      await isar.transactions.importJson(list('transactions'));
      await isar.recipes.importJson(list('recipes'));
      await isar.dailyLogs.importJson(list('dailyLogs'));
      await isar.cookSessions.importJson(list('cookSessions'));
      await isar.scanJobs.importJson(list('scanJobs'));
      await isar.userProfiles.importJson(list('userProfiles'));
      await isar.metricEvents.importJson(list('metricEvents'));
    });
    for (final k in ['ingredients', 'transactions', 'recipes', 'dailyLogs', 'cookSessions']) {
      counts[k] = list(k).length;
    }
    return counts;
  }
}
