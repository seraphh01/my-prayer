import 'package:collection/collection.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/custom_code/calendar/merge_date_groups.dart';

import '/custom_code/reminders/prayer_reminder.dart';

/// A liturgical date-group entry shown in the reminder picker.
class DynamicDateGroupOption {
  const DynamicDateGroupOption({
    required this.key,
    required this.name,
    this.description = '',
    this.samplePrayerIds = const {},
  });

  final String key;
  final String name;
  final String description;
  final Set<String> samplePrayerIds;

  bool get isRosaryLike {
    final hay = '$name $description'.toLowerCase();
    return hay.contains('rozar') || hay.contains('mistere');
  }
}

/// Loads distinct liturgical groups by sampling each weekday (same source as Calendar).
Future<List<DynamicDateGroupOption>> fetchDynamicDateGroupOptions() async {
  final byKey = <String, DynamicDateGroupOption>{};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
    final delta = (weekday - now.weekday + 7) % 7;
    final date = today.add(Duration(days: delta));
    final groups = await fetchPrayersForDate(date);
    for (final group in groups) {
      final key = dateGroupMergeKey(group);
      final prayerIds = group.prayers
          .map((prayer) => prayer.id)
          .where((id) => id.isNotEmpty)
          .toSet();
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = DynamicDateGroupOption(
          key: key,
          name: _displayName(group),
          description: group.description.trim(),
          samplePrayerIds: prayerIds,
        );
      } else {
        byKey[key] = DynamicDateGroupOption(
          key: key,
          name: existing.name,
          description: existing.description,
          samplePrayerIds: {...existing.samplePrayerIds, ...prayerIds},
        );
      }
    }
  }

  final list = byKey.values.toList()
    ..sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

  return [
    const DynamicDateGroupOption(
      key: PrayerReminder.firstOfDayGroupKey,
      name: 'Prima rugăciune a zilei',
      description: 'Prima rugăciune din calendarul liturgic al zilei',
    ),
    ...list,
  ];
}

String _displayName(DateGroupStruct group) {
  if (group.name.trim().isNotEmpty) {
    return group.name.trim();
  }
  if (group.description.trim().isNotEmpty) {
    return group.description.trim();
  }
  if (group.prayers.isNotEmpty) {
    final prayer = group.prayers.first;
    if (prayer.title.trim().isNotEmpty) {
      return prayer.title.trim();
    }
    if (prayer.subtitle.trim().isNotEmpty) {
      return prayer.subtitle.trim();
    }
  }
  return 'Grup liturgic';
}

DynamicDateGroupOption? matchLegacyReminderToDateGroup(
  List<DynamicDateGroupOption> options, {
  required bool calendarToday,
  required bool rosaryOfDay,
  String? dateGroupKey,
  ({String dateGroupKey, int prayerTypeId})? liturgicalSelection,
}) {
  if (liturgicalSelection != null) {
    return options
        .where((option) => option.key == liturgicalSelection.dateGroupKey)
        .firstOrNull;
  }
  if (dateGroupKey != null &&
      dateGroupKey.isNotEmpty &&
      dateGroupKey != PrayerReminder.firstOfDayGroupKey) {
    return options.where((option) => option.key == dateGroupKey).firstOrNull;
  }
  if (dateGroupKey == PrayerReminder.firstOfDayGroupKey || calendarToday) {
    return options
        .where((option) => option.key == PrayerReminder.firstOfDayGroupKey)
        .firstOrNull;
  }
  if (rosaryOfDay) {
    return options.where((option) => option.isRosaryLike).firstOrNull;
  }
  return null;
}
