import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/custom_code/reminders/prayer_reminder.dart';

void main() {
  test('serializes and deserializes reminder json', () {
    const reminder = PrayerReminder(
      id: 'abc',
      prayerId: 'prayer-1',
      prayerTitle: 'Rugaciunea Rozariului',
      prayerSubtitle: 'Misterele de Marire',
      hour: 8,
      minute: 30,
      daysOfWeek: [DateTime.monday, DateTime.wednesday],
      enabled: true,
    );

    final restored = PrayerReminder.fromJson(reminder.toJson());

    expect(restored.id, reminder.id);
    expect(restored.prayerId, reminder.prayerId);
    expect(restored.hour, 8);
    expect(restored.minute, 30);
    expect(restored.daysOfWeek, [DateTime.monday, DateTime.wednesday]);
    expect(restored.enabled, true);
  });

  test('formats time and weekday labels in Romanian', () {
    const reminder = PrayerReminder(
      id: 'x',
      prayerId: 'p',
      prayerTitle: 'Titlu',
      prayerSubtitle: 'Sub',
      hour: 7,
      minute: 5,
      daysOfWeek: [DateTime.monday, DateTime.friday],
    );

    expect(reminder.timeLabel, '07:05');
    expect(reminder.daysLabel, 'Lun, Vin');
    expect(reminder.notificationBody, 'Titlu — Sub');
  });

  test('date group prayer id roundtrip', () {
    const key = 'name:rozariu';
    final id = PrayerReminder.dateGroupPrayerId(key);
    expect(id, '__date_group__:name:rozariu');
    expect(PrayerReminder.dateGroupKeyFromPrayerId(id), key);
    expect(
      const PrayerReminder(
        id: 'x',
        prayerId: '__date_group__:name:rozariu',
        prayerTitle: 'Rozariu',
        prayerSubtitle: 'Misterele zilei',
        hour: 21,
        minute: 0,
        daysOfWeek: [DateTime.monday],
      ).isDateGroupDynamic,
      true,
    );
  });

  test('liturgical prayer id roundtrip', () {
    final id = PrayerReminder.liturgicalPrayerId(
      dateGroupKey: 'name:rozariu',
      prayerTypeId: 42,
    );
    expect(id, '__liturgical__:name:rozariu|42');
    final parsed = PrayerReminder.liturgicalSelectionFromPrayerId(id);
    expect(parsed?.dateGroupKey, 'name:rozariu');
    expect(parsed?.prayerTypeId, 42);
    expect(
      const PrayerReminder(
        id: 'x',
        prayerId: '__liturgical__:name:seară|7',
        prayerTitle: 'Oficiu',
        prayerSubtitle: 'Seara',
        hour: 20,
        minute: 0,
        daysOfWeek: [DateTime.monday],
      ).isLiturgicalDynamic,
      true,
    );
  });

  test('rosary of day reminder id is stable', () {
    expect(PrayerReminder.rosaryOfDayPrayerId, '__rosary_of_day__');
  });

  test('rosary notification body mentions mystery label', () {
    const reminder = PrayerReminder(
      id: 'x',
      prayerId: PrayerReminder.rosaryOfDayPrayerId,
      prayerTitle: 'Rozariul zilei',
      prayerSubtitle: '',
      hour: 19,
      minute: 0,
      daysOfWeek: [DateTime.monday],
    );

    expect(reminder.notificationBody, contains('Rozariul zilei'));
    expect(reminder.isRosaryOfDay, true);
  });
}
