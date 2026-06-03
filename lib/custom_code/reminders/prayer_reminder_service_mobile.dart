import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_reminder.dart';

class PrayerReminderService {
  PrayerReminderService._();

  static final PrayerReminderService instance = PrayerReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  void Function(String prayerId)? _onPrayerTap;
  bool _initialized = false;

  Future<void> initialize({void Function(String prayerId)? onPrayerTap}) async {
    if (_initialized) {
      return;
    }
    _onPrayerTap = onPrayerTap;

    tz_data.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _onPrayerTap?.call(payload);
        }
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onPrayerTap?.call(launchPayload);
      });
    }

    _initialized = true;
  }

  Future<bool> requestPermissionIfNeeded() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return (await android.areNotificationsEnabled()) ?? false;
      }
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final settings = await ios.checkPermissions();
        return settings?.isEnabled ?? false;
      }
    }
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> scheduleReminder(PrayerReminder reminder) async {
    if (!reminder.enabled) {
      await cancelReminder(reminder);
      return;
    }

    await cancelReminder(reminder);

    const androidDetails = AndroidNotificationDetails(
      'prayer_reminders',
      'Memento rugăciune',
      channelDescription: 'Reamintiri locale pentru rugăciuni programate',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    for (final weekday in reminder.daysOfWeek) {
      final scheduled = _nextInstanceOfWeekdayTime(
        weekday: weekday,
        hour: reminder.hour,
        minute: reminder.minute,
      );

      await _plugin.zonedSchedule(
        PrayerReminder.notificationIdFor(reminder.id, weekday),
        'Timp de rugăciune',
        reminder.notificationBody,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: reminder.prayerId,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> cancelReminder(PrayerReminder reminder) async {
    for (final id in reminder.notificationIds) {
      await _plugin.cancel(id);
    }
  }

  Future<void> cancelReminderById(String reminderId, List<int> weekdays) async {
    for (final weekday in weekdays) {
      await _plugin.cancel(
        PrayerReminder.notificationIdFor(reminderId, weekday),
      );
    }
  }

  Future<void> rescheduleAll(List<PrayerReminder> reminders) async {
    for (final reminder in reminders) {
      if (reminder.enabled) {
        await scheduleReminder(reminder);
      } else {
        await cancelReminder(reminder);
      }
    }
  }
}
