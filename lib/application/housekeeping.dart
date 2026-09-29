import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/isar/collections/schemas.dart';
import '../platform/image_store.dart';
import 'clock.dart';

/// Daily cleanup: old photos, stale suggestions, log caps.
class Housekeeping {
  Housekeeping(this.isar, {this.images, Now? now}) : now = now ?? DateTime.now;
  final Isar isar;
  final ImageStore? images;
  final Now now;

  static const aiLogCap = 200;

  Future<Map<String, int>> run() async {
    final t = now();
    final out = <String, int>{};
    out['images'] = await images?.cleanup(const Duration(days: 30)) ?? 0;
    await isar.writeTxn(() async {
      final staleCutoff = t.subtract(const Duration(days: 30));
      final stale = await isar.recipes
          .filter()
          .group((q) => q.statusEqualTo(RecipeStatus.suggested).or().statusEqualTo(RecipeStatus.dismissed))
          .timesCookedEqualTo(0)
          .favoriteEqualTo(false)
          .createdAtLessThan(staleCutoff)
          .findAll();
      out['recipes'] = await isar.recipes.deleteAll(stale.map((r) => r.id).toList());

      final count = await isar.aiCallLogs.count();
      if (count > aiLogCap) {
        final old = await isar.aiCallLogs.where().sortByAt().limit(count - aiLogCap).findAll();
        out['aiLogs'] = await isar.aiCallLogs.deleteAll(old.map((l) => l.id).toList());
      }

      final jobsCutoff = t.subtract(const Duration(days: 60));
      final oldJobs = await isar.scanJobs
          .filter()
          .group((q) => q.statusEqualTo(ScanStatus.committed).or().statusEqualTo(ScanStatus.discarded))
          .capturedAtLessThan(jobsCutoff)
          .findAll();
      out['scanJobs'] = await isar.scanJobs.deleteAll(oldJobs.map((j) => j.id).toList());

      final sessionsCutoff = t.subtract(const Duration(days: 90));
      final oldSessions = await isar.cookSessions
          .filter()
          .not()
          .statusEqualTo(CookStatus.active)
          .cookedAtLessThan(sessionsCutoff)
          .findAll();
      // Keep sessions: they are cheap and give history; only drop undone ones.
      out['sessions'] = await isar.cookSessions.deleteAll(
        oldSessions.where((s) => s.status == CookStatus.undone).map((s) => s.id).toList(),
      );
    });
    return out;
  }
}
