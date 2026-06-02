import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/custom_code/calendar/merge_date_groups.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/prayer_type_catalog_helper.dart';
import '/custom_code/reminders/resolve_rosary_prayer.dart';

/// Resolves today's prayer for a liturgical reminder (date group + prayer type).
Future<String?> fetchPrayerIdForLiturgicalSelection({
  required DateTime date,
  required String dateGroupKey,
  required int prayerTypeId,
  int hour = -1,
}) async {
  final catalog = await fetchPrayerTypesCatalog();
  final typeNode = findPrayerTypeById(catalog, prayerTypeId);
  if (typeNode == null) {
    return null;
  }

  final typePrayerIds = prayerIdsUnderType(typeNode);
  if (typePrayerIds.isEmpty) {
    return null;
  }

  if (dateGroupKey == PrayerReminder.firstOfDayGroupKey) {
    return _firstMatchingPrayerInGroups(
      await fetchPrayersForDate(date, hour: hour),
      typePrayerIds,
      date.weekday,
    );
  }

  final groups = await fetchPrayersForDate(date, hour: hour);
  for (final group in groups) {
    if (dateGroupMergeKey(group) != dateGroupKey) {
      continue;
    }
    return _firstMatchingPrayerInGroup(group, typePrayerIds, date.weekday);
  }

  return null;
}

String? _firstMatchingPrayerInGroups(
  List<DateGroupStruct> groups,
  Set<String> typePrayerIds,
  int weekday,
) {
  for (final group in groups) {
    final id = _firstMatchingPrayerInGroup(group, typePrayerIds, weekday);
    if (id != null) {
      return id;
    }
  }
  return null;
}

String? _firstMatchingPrayerInGroup(
  DateGroupStruct group,
  Set<String> typePrayerIds,
  int weekday,
) {
  final candidates = group.prayers
      .where((prayer) => typePrayerIds.contains(prayer.id))
      .toList()
    ..sort((a, b) => a.sequence.compareTo(b.sequence));

  if (candidates.isEmpty) {
    return null;
  }

  return _pickBestPrayer(candidates, weekday).id;
}

PrayerStruct _pickBestPrayer(List<PrayerStruct> candidates, int weekday) {
  if (candidates.length == 1) {
    return candidates.first;
  }

  final keywords = rosaryMysteryKeywordsByWeekday[weekday] ?? [];
  if (keywords.isNotEmpty) {
    for (final prayer in candidates) {
      final hay = '${prayer.title} ${prayer.subtitle}'.toLowerCase();
      if (keywords.any(hay.contains)) {
        return prayer;
      }
    }
  }

  return candidates.first;
}
