import 'package:uuid/uuid.dart';

import '/custom_code/reminders/prayer_reminder.dart';

class ReminderTemplate {
  const ReminderTemplate({
    required this.label,
    required this.hour,
    required this.minute,
    required this.prayerId,
    required this.prayerTitle,
    this.prayerSubtitle = '',
  });

  final String label;
  final int hour;
  final int minute;
  final String prayerId;
  final String prayerTitle;
  final String prayerSubtitle;

  PrayerReminder toReminder() {
    return PrayerReminder(
      id: const Uuid().v4(),
      prayerId: prayerId,
      prayerTitle: prayerTitle,
      prayerSubtitle: prayerSubtitle,
      hour: hour,
      minute: minute,
      daysOfWeek: const [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ],
      enabled: true,
    );
  }
}

/// Built-in quick-add templates for the reminders page.
List<ReminderTemplate> get defaultReminderTemplates => [
      ReminderTemplate(
        label: 'Dimineața',
        hour: 8,
        minute: 0,
        prayerId: PrayerReminder.templatePickPrayerId,
        prayerTitle: 'Alege rugăciunea',
        prayerSubtitle: 'Deschide mementoul pentru a selecta',
      ),
      ReminderTemplate(
        label: 'Seara',
        hour: 20,
        minute: 0,
        prayerId: PrayerReminder.templatePickPrayerId,
        prayerTitle: 'Alege rugăciunea',
        prayerSubtitle: 'Deschide mementoul pentru a selecta',
      ),
      const ReminderTemplate(
        label: 'Rozariul zilei',
        hour: 21,
        minute: 0,
        prayerId: PrayerReminder.rosaryOfDayPrayerId,
        prayerTitle: 'Rozariul zilei',
        prayerSubtitle: 'Misterele zilei din săptămână',
      ),
    ];
