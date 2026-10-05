import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/habit_scheduler.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/widgets.dart';

/// Shared "I cooked this" action: instant commit + undo + celebration line.
Future<void> cookNow(BuildContext context, WidgetRef ref, Recipe recipe, int portions, {LogTimer? timer}) async {
  final cook = ref.read(cookServiceProvider);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final res = await cook.cook(recipe.id, portions);
    celebrate();
    unawaited(ref.read(metricsServiceProvider).record('cook', (timer ?? LogTimer()).elapsed));
    final protein = res.plan.perPortion.proteinG.round();
    final fridge = res.portionsInFridge;
    // What happened on the first line, the number on the second (§7.15).
    final (msg, detail) = res.autoLoggedEntryId != null
        ? (fridge > 0
              ? ('1 logged, $fridge in the fridge', '$protein g protein each')
              : ('Logged · $protein g protein', null))
        : ('$portions portions in the fridge', '$protein g protein each');
    if (messenger != null) showUndoOn(messenger, msg, detail: detail, onUndo: () => cook.undoCook(res.sessionId));
    if (res.plan.hasShortfall) {
      unawaited(
        Future<void>.delayed(const Duration(seconds: 5), () {
          messenger?.showSnackBar(
            const SnackBar(content: Text('Some stock ran out sooner than expected. Added to Quick Check.')),
          );
        }),
      );
    }
    unawaited(_afterCook(ref));
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text('Could not log: $e')));
  }
}

Future<void> _afterCook(WidgetRef ref) async {
  final scheduler = HabitScheduler(isar: ref.read(isarProvider), picks: ref.read(dailyPickServiceProvider));
  await scheduler.refreshMealReminders();
  await scheduler.planTomorrowIfEvening();
}

Future<void> eatFromFridge(BuildContext context, WidgetRef ref, CookSession s) async {
  final cook = ref.read(cookServiceProvider);
  final timer = LogTimer();
  final id = await cook.eatPortion(s.id);
  if (id == null) return;
  celebrate();
  unawaited(ref.read(metricsServiceProvider).record('eat', timer.elapsed));
  final key = ref.read(dayClockProvider).dateKey(DateTime.now());
  final log = await ref.read(isarProvider).dailyLogs.getByDateKey(key);
  final profile = ref.read(profileProvider).value;
  if (!context.mounted) return;
  final p = log?.totals.proteinG.round() ?? 0;
  final target = profile?.dailyProteinTargetG.round();
  showUndo(
    context,
    'Logged ${s.recipeTitle}',
    detail: target != null ? 'Protein today: $p / $target g' : null,
    onUndo: () => cook.deleteMeal(key, id),
  );
  unawaited(
    HabitScheduler(isar: ref.read(isarProvider), picks: ref.read(dailyPickServiceProvider)).refreshMealReminders(),
  );
}
