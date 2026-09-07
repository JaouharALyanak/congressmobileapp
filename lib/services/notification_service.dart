import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('Background tapped: ${notificationResponse.payload}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;
    // ── Timezone ──────────────────────────────────────────────────────────
    // IMPORTANT : tz.local reste UTC si on n'appelle pas setLocalLocation.
    // flutter_timezone récupère le fuseau horaire réel de l'appareil.
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      debugPrint('Timezone initialisé : ${tzInfo.identifier}');
    } catch (e) {
      // Fallback : fuseau Europe/Paris (événement en France)
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));
      debugPrint('Timezone fallback Europe/Paris ($e)');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For Darwin (iOS/macOS), the request permissions are now typically handled
    // within the platform-specific implementation directly, not in InitializationSettings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false, // Will request manually below
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            debugPrint('Tapped: ${notificationResponse.payload}');
          },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackground, // ✅ FIX
    );

    // Request permissions explicitly
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        // requestNotificationsPermission() for Android 13+
        await androidImplementation.requestNotificationsPermission();
        // requestExactAlarmsPermission() for Android 12+
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Duration beforeEvent = const Duration(minutes: 10),
  }) async {
    final notificationTime = scheduledDate.subtract(beforeEvent);

    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('Notification ignorée : la date est passée.');
      return;
    }

    final scheduledTZDate = tz.TZDateTime.from(notificationTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'agenda_channel_id',
          'Agenda Reminders',
          channelDescription: 'Reminders for your scheduled items',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // *******************************************************************
    // FIX for flutter_local_notifications: ^21.0.0
    // Arguments are now named parameters directly on the zonedSchedule method.
    // The previous `settings` or multiple positional arguments are gone.
    // *******************************************************************
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'item_$id',
    );

    debugPrint('Notification planifiée à : $scheduledTZDate');
  }

  static Future<void> cancelNotification(int id) async =>
      await _notificationsPlugin.cancel(id: id);

  static Future<void> cancelAll() async =>
      await _notificationsPlugin.cancelAll();

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return _notificationsPlugin.pendingNotificationRequests();
  }
}
