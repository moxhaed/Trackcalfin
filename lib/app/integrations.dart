import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../application/habit_scheduler.dart';
import '../application/housekeeping.dart';
import '../features/capture/cooked_sheet.dart';
import '../features/capture/expense_sheet.dart';
import '../features/capture/say_it_sheet.dart';
import '../features/capture/scan_flow.dart';
import 'messenger.dart';
import 'providers.dart';
import 'router.dart';

/// Entry points outside the app (rule R8) and lifecycle work.
class AppIntegrations {
  AppIntegrations(this.ref, this.router);
  final WidgetRef ref;
  final GoRouter router;

  final _subs = <StreamSubscription<dynamic>>[];
  DateTime? _lastHousekeeping;

  bool get _mobile => Platform.isAndroid || Platform.isIOS;

  HabitScheduler get _scheduler =>
      HabitScheduler(isar: ref.read(isarProvider), picks: ref.read(dailyPickServiceProvider));

  Future<void> start() async {
    // A user request held back by Gemini's per-minute limit says so instead of just spinning.
    _subs.add(
      ref
          .read(aiGatewayProvider)
          .gate
          .waits
          .listen((w) => notifyApp(w.message, duration: Duration(seconds: w.wait.inSeconds.clamp(3, 8)))),
    );
    if (_mobile) {
      _quickActions();
      _shareIntake();
    }
    // Before anything else reads the queue: a photo from a camera Android closed us for.
    if (Platform.isAndroid) await recoverLostScans(ref);
    if (_mobile) {
      try {
        _subs.add(
          Connectivity().onConnectivityChanged.listen((r) {
            if (!r.contains(ConnectivityResult.none)) unawaited(processScansInBackground(ref));
          }, onError: (_) {}),
        );
      } catch (_) {}
    }
    await onResume();
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }

  Future<void> onResume() async {
    unawaited(processScansInBackground(ref));
    unawaited(ref.read(nutritionServiceProvider).fillMissing());
    final t = DateTime.now();
    if (_lastHousekeeping == null || t.difference(_lastHousekeeping!).inHours >= 20) {
      _lastHousekeeping = t;
      unawaited(Housekeeping(ref.read(isarProvider), images: ref.read(imageStoreProvider)).run());
    }
    try {
      // A pick left over from yesterday (the app stayed open past the rollover) is looked up again.
      final day = ref.read(todayPickProvider).value?.recipe?.suggestedForDateKey;
      if (day != null && day != ref.read(dayClockProvider).dateKey(t)) ref.invalidate(todayPickProvider);
      final pick = await ref.read(todayPickProvider.future);
      if (pick.recipe != null && pick.fromAi) await _scheduler.scheduleTodayPick(pick.recipe);
      await _scheduler.refreshMealReminders();
      await _scheduler.scheduleWeeklyRecap();
    } catch (_) {
      // Scheduling is best effort; never block the UI on it.
    }
  }

  Future<void> onPause() => _scheduler.planTomorrowIfEvening();

  BuildContext? get _ctx => rootNavigatorKey.currentContext;

  void handleShortcut(String type) {
    final ctx = _ctx;
    if (ctx == null) return;
    switch (type) {
      case 'say_it':
        unawaited(showSayIt(ctx));
      case 'scan':
        router.go('/buy');
        unawaited(startScan(ctx, ref, hint: 'receipt'));
      case 'expense':
        unawaited(showExpenseSheet(ctx));
      case 'cooked':
        router.go('/cook');
        unawaited(showCookedSheet(ctx));
    }
  }

  void _quickActions() {
    try {
      const qa = QuickActions();
      qa.initialize((type) => WidgetsBinding.instance.addPostFrameCallback((_) => handleShortcut(type)));
      qa.setShortcutItems(const [
        ShortcutItem(type: 'say_it', localizedTitle: 'Say it', icon: 'ic_shortcut_say'),
        ShortcutItem(type: 'scan', localizedTitle: 'Scan receipt', icon: 'ic_shortcut_scan'),
        ShortcutItem(type: 'expense', localizedTitle: 'Log expense', icon: 'ic_shortcut_expense'),
        ShortcutItem(type: 'cooked', localizedTitle: 'I cooked', icon: 'ic_shortcut_cooked'),
      ]);
    } catch (_) {}
  }

  void _shareIntake() {
    Future<void> handle(List<SharedMediaFile> files) async {
      final paths = files
          .where(
            (f) =>
                f.type == SharedMediaType.image ||
                f.path.toLowerCase().endsWith('.jpg') ||
                f.path.toLowerCase().endsWith('.png'),
          )
          .map((f) => f.path)
          .toList();
      if (paths.isEmpty) return;
      await ref.read(scanServiceProvider).enqueue(paths, hint: 'receipt');
      router.go('/buy');
      unawaited(processScansInBackground(ref));
    }

    try {
      final intent = ReceiveSharingIntent.instance;
      _subs.add(intent.getMediaStream().listen(handle));
      intent.getInitialMedia().then((files) async {
        await handle(files);
        await intent.reset();
      });
    } catch (_) {}
  }
}
