import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/date_group.dart';
import '/backend/supabase/supabase.dart';

/// Schedule hints derived from [date_group] rows linked to a prayer.
class PrayerReminderPrefill {
  const PrayerReminderPrefill({
    this.daysOfWeek = const {},
    this.time,
  });

  final Set<int> daysOfWeek;
  final TimeOfDay? time;

  bool get hasScheduleHint => daysOfWeek.isNotEmpty || time != null;
}

/// Maps DB weekday to Dart [DateTime.weekday] (Mon=1 … Sun=7).
int normalizeWeekday(int dbDay) {
  if (dbDay == 0) {
    return DateTime.sunday;
  }
  return dbDay;
}

PrayerReminderPrefill buildReminderPrefillFromDateGroups(
  List<DateGroupRow> dateGroups,
) {
  final days = <int>{};
  final hours = <int>{};

  for (final row in dateGroups) {
    if (row.dayOfWeek != null) {
      days.add(normalizeWeekday(row.dayOfWeek!));
    }
    if (row.hour != null) {
      hours.add(row.hour!);
    }
  }

  if (days.isEmpty && hours.isEmpty) {
    return const PrayerReminderPrefill();
  }

  return PrayerReminderPrefill(
    daysOfWeek: days,
    time: hours.length == 1
        ? TimeOfDay(hour: hours.first, minute: 0)
        : null,
  );
}

Future<PrayerReminderPrefill> fetchReminderPrefillForPrayer(
  String prayerId,
) async {
  if (prayerId.isEmpty) {
    return const PrayerReminderPrefill();
  }

  try {
    final rows = await SupaFlow.client
        .from('prayer_date_group')
        .select('date_group(day_of_week, hour)')
        .eq('prayer_id', prayerId);

    final dateGroups = <DateGroupRow>[];
    for (final row in rows as List<dynamic>) {
      final nested = row['date_group'];
      if (nested is! Map<String, dynamic>) {
        continue;
      }
      dateGroups.add(DateGroupRow({'id': 0, ...nested}));
    }

    return buildReminderPrefillFromDateGroups(dateGroups);
  } catch (_) {
    return const PrayerReminderPrefill();
  }
}
