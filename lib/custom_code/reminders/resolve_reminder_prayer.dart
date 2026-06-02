import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/resolve_liturgical_prayer.dart';
import '/custom_code/reminders/resolve_rosary_prayer.dart';

/// Resolves the concrete prayer id for a reminder at [when] (defaults to now).
Future<String?> resolveReminderPrayerId(
  PrayerReminder reminder, {
  DateTime? when,
}) async {
  final date = when ?? DateTime.now();

  final liturgical = PrayerReminder.liturgicalSelectionFromPrayerId(
    reminder.prayerId,
  );
  if (liturgical != null) {
    return fetchPrayerIdForLiturgicalSelection(
      date: date,
      dateGroupKey: liturgical.dateGroupKey,
      prayerTypeId: liturgical.prayerTypeId,
      hour: reminder.hour,
    );
  }

  if (reminder.isDateGroupDynamic) {
    final key = PrayerReminder.dateGroupKeyFromPrayerId(reminder.prayerId);
    if (key == null || key.isEmpty) {
      return null;
    }
    return fetchPrayerIdForDateGroup(
      date: date,
      groupKey: key,
      hour: reminder.hour,
    );
  }

  if (reminder.isCalendarToday) {
    return fetchPrayerIdForDateGroup(
      date: date,
      groupKey: PrayerReminder.firstOfDayGroupKey,
      hour: reminder.hour,
    );
  }

  if (reminder.isRosaryOfDay) {
    return fetchRosaryPrayerIdForDate(date);
  }

  return reminder.prayerId;
}

/// Resolves [prayerId] from a notification tap (no reminder hour available).
Future<String?> resolvePrayerIdFromNotificationTap(String prayerId) async {
  final date = DateTime.now();

  final liturgical = PrayerReminder.liturgicalSelectionFromPrayerId(prayerId);
  if (liturgical != null) {
    return fetchPrayerIdForLiturgicalSelection(
      date: date,
      dateGroupKey: liturgical.dateGroupKey,
      prayerTypeId: liturgical.prayerTypeId,
    );
  }

  if (prayerId == PrayerReminder.calendarTodayPrayerId) {
    return fetchTodayFeaturedPrayerIdForDate(date);
  }

  if (prayerId == PrayerReminder.rosaryOfDayPrayerId) {
    return fetchRosaryPrayerIdForDate(date);
  }

  final groupKey = PrayerReminder.dateGroupKeyFromPrayerId(prayerId);
  if (groupKey != null) {
    return fetchPrayerIdForDateGroup(date: date, groupKey: groupKey);
  }

  return prayerId;
}
