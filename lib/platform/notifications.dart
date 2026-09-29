import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../app/bootstrap.dart';
import '../application/cook_service.dart';

const actionAte = 'ate';
const actionSkip = 'skip';

/// Lock-screen "Ate it": logs a fridge portion without opening the app.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(NotificationResponse r) async {
  if (r.actionId != actionAte) return;
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final isar = await openAppIsar();
  await CookService(isar).eatOldest();
}

/// Local notifications: daily pick, meal-time actions, recap, scan results.
class Notifications {
  Notifications._();
  static final instance = Notifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const dailyPickId = 1;
  static const mealBaseId = 10;
  static const recapId = 30;
  static const scanId = 40;

  static bool get supported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  Future<void> init({void Function(NotificationResponse)? onResponse}) async {
    if (!supported || _ready) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      const android = AndroidInitializationSettings('ic_notification');
      final darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            'meal',
            actions: [
              DarwinNotificationAction.plain(actionAte, 'Ate it'),
              DarwinNotificationAction.plain(actionSkip, 'Not now'),
            ],
          ),
        ],
      );
      await _plugin.initialize(
        settings: InitializationSettings(android: android, iOS: darwin, macOS: darwin),
        onDidReceiveNotificationResponse: onResponse,
        onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
      );
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Payload of the notification that launched the app, if any.
  Future<NotificationResponse?> launchResponse() async {
    if (!_ready) return null;
    try {
      final d = await _plugin.getNotificationAppLaunchDetails();
      return d?.didNotificationLaunchApp == true ? d!.notificationResponse : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  NotificationDetails _details(
    String channel,
    String name, {
    List<AndroidNotificationAction>? actions,
    String? category,
  }) => NotificationDetails(
    android: AndroidNotificationDetails(
      channel,
      name,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      actions: actions,
    ),
    iOS: DarwinNotificationDetails(categoryIdentifier: category),
    macOS: DarwinNotificationDetails(categoryIdentifier: category),
  );

  tz.TZDateTime _tz(DateTime at) => tz.TZDateTime.from(at, tz.local);

  Future<void> _schedule(int id, DateTime at, String title, String body, NotificationDetails d, String payload) async {
    if (!_ready) return;
    if (at.isBefore(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: _tz(at),
        notificationDetails: d,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (_) {}
  }

  Future<void> scheduleDailyPick({required DateTime at, required String title, required String body}) async {
    await cancel(dailyPickId);
    await _schedule(dailyPickId, at, title, body, _details('daily_pick', 'Daily pick'), '/cook');
  }

  Future<void> scheduleMealReminder({
    required int slot,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    await cancel(mealBaseId + slot);
    await _schedule(
      mealBaseId + slot,
      at,
      title,
      body,
      _details(
        'meals',
        'Meal reminders',
        category: 'meal',
        actions: const [
          AndroidNotificationAction(actionAte, 'Ate it'),
          AndroidNotificationAction(actionSkip, 'Not now'),
        ],
      ),
      '/cook',
    );
  }

  Future<void> cancelMealReminders() async {
    for (var i = 0; i < 6; i++) {
      await cancel(mealBaseId + i);
    }
  }

  Future<void> scheduleWeeklyRecap({required DateTime at, required String body}) async {
    await cancel(recapId);
    await _schedule(recapId, at, 'Your week', body, _details('recap', 'Weekly recap'), '/quick-check');
  }

  Future<void> showScanResult(String message) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: scanId,
        title: 'Scan processed',
        body: message,
        notificationDetails: _details('scans', 'Scans'),
        payload: '/inbox',
      );
    } catch (_) {}
  }

  Future<void> cancel(int id) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }
}
