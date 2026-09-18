import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../notifications/notification_service.dart';
import '../notifications/reminder_action.dart';

const _kChannelId = 'task_reminders';
const _kChannelName = 'Task reminders';
const _kChannelDesc = 'Reminders for tasks and assignments';
const _kDarwinCategory = 'task_reminders';

@pragma('vm:entry-point')
void reminderTapBackground(NotificationResponse response) {
  // Actions use showsUserInterface / foreground options so the main isolate
  // handles Done/Snooze (encrypted DB + dialog). This entry-point exists so
  // the plugin can register the background callback.
}

class ParentNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Object? initError;

  @override
  Future<void> init() => _ensureInitialized();

  @override
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return await android.areNotificationsEnabled() ?? true;
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      const channel = MethodChannel('net.moonbaseone.kinetic.parent/settings');
      final result = await channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      try {
        tz.initializeTimeZones();
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      } catch (_) {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.UTC);
      }

      await _plugin.initialize(
        InitializationSettings(
          android: const AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            notificationCategories: [
              DarwinNotificationCategory(
                _kDarwinCategory,
                actions: [
                  DarwinNotificationAction.plain(
                    ReminderActionId.done,
                    ReminderActionLabels.done,
                    options: {DarwinNotificationActionOption.foreground},
                  ),
                  DarwinNotificationAction.plain(
                    ReminderActionId.snooze,
                    ReminderActionLabels.snooze,
                    options: {DarwinNotificationActionOption.foreground},
                  ),
                ],
              ),
            ],
          ),
        ),
        onDidReceiveNotificationResponse: _onResponse,
        onDidReceiveBackgroundNotificationResponse: reminderTapBackground,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        final response = launch!.notificationResponse;
        if (response != null) _onResponse(response);
      }

      _initialized = true;
      initError = null;
    } catch (e, st) {
      initError = e;
      Error.throwWithStackTrace(e, st);
    }
  }

  void _onResponse(NotificationResponse response) {
    ReminderActionBus.instance.dispatch(
      actionId: response.actionId,
      payload: response.payload,
    );
  }

  NotificationDetails _reminderDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        actions: [
          AndroidNotificationAction(
            ReminderActionId.done,
            ReminderActionLabels.done,
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            ReminderActionId.snooze,
            ReminderActionLabels.snooze,
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: _kDarwinCategory,
      ),
    );
  }

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    String? payload,
  }) async {
    await _ensureInitialized();

    final scheduled = tz.TZDateTime.from(at, tz.local);
    if (scheduled.isBefore(DateTime.now())) return;

    final details = _reminderDetails();
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancelReminder(int id) async {
    await _ensureInitialized();
    await _plugin.cancel(id);
  }

  @override
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();
    await _plugin.show(0, title, body, _reminderDetails(), payload: payload);
  }
}
