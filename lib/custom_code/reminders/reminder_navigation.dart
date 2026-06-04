import 'dart:async';

import 'package:flutter/material.dart';

import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/prayer_reminder_service.dart';
import '/custom_code/reminders/resolve_reminder_prayer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';

String? _pendingReminderPrayerId;
int _navigationAttempts = 0;
const _maxNavigationAttempts = 60;

/// Called once [MaterialApp.router] and [GoRouter] are ready (e.g. from [MyApp]).
void flushPendingReminderNavigation() {
  unawaited(
    PrayerReminderService.instance.handleLaunchNotificationTap().then((_) {
      if (_pendingReminderPrayerId == null) {
        return;
      }
      _scheduleReminderNavigation();
    }),
  );
}

/// Opens a prayer after a reminder notification, keeping [HomePage] on the
/// stack when the app was cold-started (so back/home still works).
void navigateToPrayerFromReminder(String prayerId) {
  if (prayerId.isEmpty) {
    return;
  }
  _pendingReminderPrayerId = prayerId;
  _navigationAttempts = 0;
  _scheduleReminderNavigation();
}

void _scheduleReminderNavigation() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_executePendingReminderNavigation());
  });
}

Future<void> _executePendingReminderNavigation() async {
  final prayerId = _pendingReminderPrayerId;
  if (prayerId == null) {
    return;
  }

  final context = appNavigatorKey.currentContext;
  if (context == null || !context.mounted) {
    _navigationAttempts++;
    if (_navigationAttempts < _maxNavigationAttempts) {
      _scheduleReminderNavigation();
    }
    return;
  }

  final isDynamic = prayerId == PrayerReminder.calendarTodayPrayerId ||
      prayerId == PrayerReminder.rosaryOfDayPrayerId ||
      PrayerReminder.liturgicalSelectionFromPrayerId(prayerId) != null ||
      PrayerReminder.dateGroupKeyFromPrayerId(prayerId) != null;

  var resolvedId = prayerId;
  if (isDynamic) {
    resolvedId = await resolvePrayerIdFromNotificationTap(prayerId) ?? '';
    if (resolvedId.isEmpty) {
      _pendingReminderPrayerId = null;
      if (!context.mounted) {
        return;
      }
      if (prayerId == PrayerReminder.calendarTodayPrayerId ||
          PrayerReminder.liturgicalSelectionFromPrayerId(prayerId)
                  ?.dateGroupKey ==
              PrayerReminder.firstOfDayGroupKey ||
          PrayerReminder.dateGroupKeyFromPrayerId(prayerId) ==
              PrayerReminder.firstOfDayGroupKey) {
        context.pushNamed('CalendarPage');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nu s-a găsit rugăciunea pentru azi. Verifică calendarul liturgic.',
          ),
        ),
      );
      return;
    }
  }

  _pendingReminderPrayerId = null;

  if (!context.mounted) {
    return;
  }

  context.openPrayerWithHomeOnStack(resolvedId);
}
