import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/supabase/database/tables/date_group.dart';
import 'package:my_prayer/custom_code/reminders/prayer_date_group_prefill.dart';

DateGroupRow _row({int? dayOfWeek, int? hour}) {
  return DateGroupRow({
    'id': 1,
    if (dayOfWeek != null) 'day_of_week': dayOfWeek,
    if (hour != null) 'hour': hour,
  });
}

void main() {
  test('returns empty prefill when no schedule fields', () {
    final prefill = buildReminderPrefillFromDateGroups([
      DateGroupRow({'id': 1}),
    ]);

    expect(prefill.daysOfWeek, isEmpty);
    expect(prefill.time, isNull);
    expect(prefill.hasScheduleHint, false);
  });

  test('prefills days when only day_of_week is set', () {
    final prefill = buildReminderPrefillFromDateGroups([
      _row(dayOfWeek: DateTime.monday),
      _row(dayOfWeek: DateTime.tuesday),
      _row(dayOfWeek: DateTime.wednesday),
    ]);

    expect(prefill.daysOfWeek, {
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
    });
    expect(prefill.time, isNull);
    expect(prefill.hasScheduleHint, true);
  });

  test('prefills days and hour when both are set', () {
    final prefill = buildReminderPrefillFromDateGroups([
      _row(dayOfWeek: DateTime.monday, hour: 21),
      _row(dayOfWeek: DateTime.tuesday, hour: 21),
      _row(dayOfWeek: DateTime.wednesday, hour: 21),
    ]);

    expect(prefill.daysOfWeek, {
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
    });
    expect(prefill.time, const TimeOfDay(hour: 21, minute: 0));
    expect(prefill.hasScheduleHint, true);
  });

  test('prefills only days when hours differ', () {
    final prefill = buildReminderPrefillFromDateGroups([
      _row(dayOfWeek: DateTime.monday, hour: 8),
      _row(dayOfWeek: DateTime.monday, hour: 20),
    ]);

    expect(prefill.daysOfWeek, {DateTime.monday});
    expect(prefill.time, isNull);
    expect(prefill.hasScheduleHint, true);
  });

  test('normalizes sunday stored as zero', () {
    expect(normalizeWeekday(0), DateTime.sunday);
  });
}
