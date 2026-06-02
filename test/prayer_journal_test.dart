import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/custom_code/journal/prayer_journal_entry.dart';
import 'package:my_prayer/custom_code/reminders/prayer_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_prayer/custom_code/journal/prayer_journal_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PrayerJournalStorage keeps entries for a day in order', () async {
    final t1 = DateTime(2026, 6, 1, 8, 0);
    final t2 = DateTime(2026, 6, 1, 20, 30);
    await PrayerJournalStorage.addEntry(
      PrayerJournalEntry(
        prayerId: 'a',
        prayerTitle: 'Dimineața',
        completedAt: t1,
      ),
    );
    await PrayerJournalStorage.addEntry(
      PrayerJournalEntry(
        prayerId: 'b',
        prayerTitle: 'Rozariu',
        completedAt: t2,
      ),
    );

    final today = await PrayerJournalStorage.entriesForDay(t1);
    expect(today.length, 2);
    expect(today.first.prayerTitle, 'Dimineața');
    expect(today.last.prayerTitle, 'Rozariu');
  });

  test('recordPrayerOpen blocks consecutive duplicate, allows after another', () async {
    expect(
      await PrayerJournalStorage.recordPrayerOpen(
        prayerId: 'a',
        prayerTitle: 'Rozariu',
      ),
      true,
    );
    expect(
      await PrayerJournalStorage.recordPrayerOpen(
        prayerId: 'a',
        prayerTitle: 'Rozariu',
      ),
      false,
    );
    expect(
      await PrayerJournalStorage.recordPrayerOpen(
        prayerId: 'b',
        prayerTitle: 'Dimineața',
      ),
      true,
    );
    expect(
      await PrayerJournalStorage.recordPrayerOpen(
        prayerId: 'a',
        prayerTitle: 'Rozariu',
      ),
      true,
    );

    final today = await PrayerJournalStorage.entriesForDay(DateTime.now());
    expect(today.length, 3);
    expect(today.map((e) => e.prayerId).toList(), ['a', 'b', 'a']);
  });

  test('PrayerReminder calendar today id is stable', () {
    expect(
      PrayerReminder.calendarTodayPrayerId,
      '__calendar_today__',
    );
  });
}
