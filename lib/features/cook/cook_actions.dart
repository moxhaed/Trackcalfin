import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/habit_scheduler.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/widgets.dart';

/// Shared "I cooked this" action: instant commit + undo + celebration line.
///
/// Callers may close their sheet first and pass its [ref]: everything is read from [ref] before
/// the first await, since a disposed widget's ref throws (and "Could not log" would be wrong).
Future<void> cookNow(BuildContext context, WidgetRef ref, Recipe recipe, int portions, {LogTimer? timer}) async {
  final cook = ref.read(cookServiceProvider);
  final metrics = ref.read(metricsServiceProvider);
  final scheduler = _scheduler(ref);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final res = await cook.cook(recipe.id, portions);
    celebrate();
    unawaited(metrics.record('cook', (timer ?? LogTimer()).elapsed));
    final protein = res.plan.perPortion.proteinG.round();
    final fridge = res.portionsInFridge;
    final msg = res.autoLoggedEntryId != null
        ? (fridge > 0 ? '1 logged, $fridge in the fridge · $protein g protein each' : 'Logged · $protein g protein')
        : '$portions portions in the fridge · $protein g protein each';
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'Undo', onPressed: () => cook.undoCook(res.sessionId)),
        persist: false,
      ),
    );
    if (res.plan.hasShortfall) {
      unawaited(
        Future<void>.delayed(const Duration(seconds: 5), () {
          messenger?.showSnackBar(
            const SnackBar(content: Text('Some stock ran out sooner than expected. Added to Quick Check.')),
          );
        }),
      );
    }
    unawaited(_afterCook(scheduler));
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text('Could not log: $e')));
  }
}

HabitScheduler _scheduler(WidgetRef ref) =>
    HabitScheduler(isar: ref.read(isarProvider), picks: ref.read(dailyPickServiceProvider));

Future<void> _afterCook(HabitScheduler scheduler) async {
  await scheduler.refreshMealReminders();
  await scheduler.planTomorrowIfEvening();
}

/// Like [cookNow], reads everything from [ref] before the first await.
Future<void> eatFromFridge(BuildContext context, WidgetRef ref, CookSession s) async {
  final cook = ref.read(cookServiceProvider);
  final metrics = ref.read(metricsServiceProvider);
  final clock = ref.read(dayClockProvider);
  final isar = ref.read(isarProvider);
  final profile = ref.read(profileProvider).value;
  final scheduler = _scheduler(ref);
  final timer = LogTimer();
  final id = await cook.eatPortion(s.id);
  if (id == null) return;
  celebrate();
  unawaited(metrics.record('eat', timer.elapsed));
  final key = clock.dateKey(DateTime.now());
  final log = await isar.dailyLogs.getByDateKey(key);
  if (!context.mounted) return;
  final p = log?.totals.proteinG.round() ?? 0;
  final target = profile?.dailyProteinTargetG.round();
  showUndo(
    context,
    'Logged ${s.recipeTitle}',
    detail: target != null ? 'Protein today: $p / $target g' : null,
    onUndo: () => cook.deleteMeal(key, id),
  );
  unawaited(scheduler.refreshMealReminders());
}
