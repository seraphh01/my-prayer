import 'prayer_reminder.dart';

class PrayerReminderService {
  PrayerReminderService._();

  static final PrayerReminderService instance = PrayerReminderService._();

  Future<void> initialize({void Function(String prayerId)? onPrayerTap}) async {}

  Future<bool> requestPermissionIfNeeded() async => false;

  Future<bool> areNotificationsEnabled() async => false;

  Future<void> scheduleReminder(PrayerReminder reminder) async {}

  Future<void> cancelReminder(PrayerReminder reminder) async {}

  Future<void> rescheduleAll(List<PrayerReminder> reminders) async {}
}
