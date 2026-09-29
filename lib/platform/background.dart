import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../app/bootstrap.dart';
import '../application/ai_gateway.dart';
import '../application/daily_pick_service.dart';
import '../application/habit_scheduler.dart';
import '../data/ai/prompt_repository.dart';
import 'notifications.dart';
import 'secret_store.dart';

const morningTask = 'trackcalfin.morning-pick';

/// Fallback daily-pick generation in the 04:00–09:00 window when the
/// evening-before plan didn't happen. Best effort on iOS.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, input) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      final hour = DateTime.now().hour;
      if (hour < 4 || hour > 9) return true;
      final isar = await openAppIsar();
      await Notifications.instance.init();
      final ai = AiGateway(
        isar: isar,
        secrets: SecureSecretStore(fallbackDir: await appSupportPath()),
        prompts: PromptRepository(rootBundle.loadString),
      );
      final picks = DailyPickService(isar: isar, ai: ai);
      final out = await picks.ensure();
      await HabitScheduler(isar: isar, picks: picks).scheduleTodayPick(out.fromAi ? out.recipe : null);
    } catch (_) {
      // Never crash the background isolate; the app retries on open.
    }
    return true;
  });
}

class BackgroundScheduler {
  const BackgroundScheduler._();

  static Future<void> register() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    try {
      await Workmanager().initialize(backgroundDispatcher);
      await Workmanager().registerPeriodicTask(
        morningTask,
        morningTask,
        frequency: const Duration(hours: 6),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (_) {}
  }
}
