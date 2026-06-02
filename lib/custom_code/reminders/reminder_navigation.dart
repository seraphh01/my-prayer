import 'package:flutter/material.dart';

import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/resolve_reminder_prayer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';

/// Opens a prayer after a reminder notification, keeping [HomePage] on the
/// stack when the app was cold-started (so back/home still works).
void navigateToPrayerFromReminder(String prayerId) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
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

    if (context.canPop()) {
      context.pushNamed(
        'RosaryPage',
        queryParameters: {'prayerId': resolvedId},
      );
      return;
    }

    context.goNamed('HomePage');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nestedContext = appNavigatorKey.currentContext;
      if (nestedContext == null || !nestedContext.mounted) {
        return;
      }
      nestedContext.pushNamed(
        'RosaryPage',
        queryParameters: {'prayerId': resolvedId},
      );
    });
  });
}
