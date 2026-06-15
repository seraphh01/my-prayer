import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/merge_date_groups.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Loads liturgical prayer groups for a calendar day (same API as Calendar page).
Future<List<DateGroupStruct>> fetchPrayersForDate(
  DateTime date, {
  int hour = -1,
}) async {
  if (hour < 0) {
    return fetchCalendarPrayersForDate(date);
  }

  final selectedDate = DateTime(date.year, date.month, date.day);
  final response =
      await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
    dayOfWeek: selectedDate.weekday,
    month: selectedDate.month,
    day: selectedDate.day,
    specificDate: dateTimeFormat('yyyy-MM-dd', selectedDate),
    hour: hour,
  );
  if (response.succeeded != true) {
    return [];
  }

  final rawGroups = parseRawDateGroups(response.jsonBody);

  return mergeSimilarDateGroups(rawGroups);
}

/// Raw RPC rows without merging — for home screen hour-aware selection.
Future<List<DateGroupStruct>> fetchRawPrayersForDate(
  DateTime date, {
  int hour = -1,
}) async {
  final selectedDate = DateTime(date.year, date.month, date.day);
  final response =
      await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
    dayOfWeek: selectedDate.weekday,
    month: selectedDate.month,
    day: selectedDate.day,
    specificDate: dateTimeFormat('yyyy-MM-dd', selectedDate),
    hour: hour,
  );
  if (response.succeeded != true) {
    return const [];
  }

  return parseRawDateGroups(response.jsonBody);
}

/// Hour-of-day scheduling groups (home “Pentru astăzi” only, not Calendar).
bool isHourSlotDateGroup(DateGroupStruct group) {
  if (group.hasHour()) {
    return true;
  }

  final name = group.name.trim().toLowerCase();
  return name == 'pentru momentul zilei';
}

/// Calendar view: hide hour-of-day sections, but keep every prayer for the day.
List<DateGroupStruct> dayOnlyDateGroupsFromRaw(List<DateGroupStruct> rawGroups) {
  final dayGroups = <DateGroupStruct>[];
  final hourSlotPrayers = <PrayerStruct>[];

  for (final group in rawGroups) {
    if (isHourSlotDateGroup(group)) {
      hourSlotPrayers.addAll(group.prayers);
      continue;
    }

    if (group.prayers.isEmpty) {
      continue;
    }

    dayGroups.add(
      DateGroupStruct(
        name: group.name,
        description: group.description,
        prayers: List<PrayerStruct>.from(group.prayers),
      ),
    );
  }

  if (hourSlotPrayers.isEmpty) {
    return dayGroups;
  }

  final mergedHourPrayers = _dedupePrayersById(hourSlotPrayers);
  if (dayGroups.isEmpty) {
    return [
      DateGroupStruct(
        name: 'Rugăciunile din ziuă',
        prayers: mergedHourPrayers,
      ),
    ];
  }

  final targetIndex = _primaryDayGroupIndex(dayGroups);
  final target = dayGroups[targetIndex];
  dayGroups[targetIndex] = DateGroupStruct(
    name: target.name,
    description: target.description,
    prayers: _dedupePrayersById([
      ...target.prayers,
      ...mergedHourPrayers,
    ]),
  );

  return dayGroups;
}

const _primaryDayGroupName = 'rugăciunile din ziuă';

int _primaryDayGroupIndex(List<DateGroupStruct> dayGroups) {
  final primaryIndex = dayGroups.indexWhere(
    (group) => group.name.trim().toLowerCase() == _primaryDayGroupName,
  );
  return primaryIndex >= 0 ? primaryIndex : 0;
}

List<PrayerStruct> _dedupePrayersById(Iterable<PrayerStruct> prayers) {
  final byId = <String, PrayerStruct>{};
  for (final prayer in prayers) {
    if (prayer.id.isEmpty) {
      continue;
    }
    final existing = byId[prayer.id];
    if (existing == null || prayer.sequence < existing.sequence) {
      byId[prayer.id] = prayer;
    }
  }

  return byId.values.toList()
    ..sort((a, b) {
      final bySequence = a.sequence.compareTo(b.sequence);
      if (bySequence != 0) {
        return bySequence;
      }
      return a.title.compareTo(b.title);
    });
}

/// Calendar page: weekday/feast groups for the day; hour slots folded in, not listed separately.
Future<List<DateGroupStruct>> fetchCalendarPrayersForDate(DateTime date) async {
  final rawGroups = await fetchRawPrayersForDate(date);
  return mergeSimilarDateGroups(dayOnlyDateGroupsFromRaw(rawGroups));
}

List<DateGroupStruct> parseRawDateGroups(dynamic jsonBody) {
  return ((jsonBody ?? '').toList()
          .map<DateGroupStruct?>(DateGroupStruct.maybeFromMap)
          .toList() as Iterable<DateGroupStruct?>)
      .withoutNulls
      .toList();
}

/// First prayer id from [date]'s calendar groups, optionally filtered by [hour].
Future<String?> fetchTodayFeaturedPrayerIdForDate(
  DateTime date, {
  int hour = -1,
}) async {
  final groups = await fetchPrayersForDate(date, hour: hour);
  for (final group in groups) {
    if (group.prayers.isNotEmpty && group.prayers.first.id.isNotEmpty) {
      return group.prayers.first.id;
    }
  }
  return null;
}

/// Resolves a prayer id for a liturgical group on [date].
Future<String?> fetchPrayerIdForDateGroup({
  required DateTime date,
  required String groupKey,
  int hour = -1,
}) async {
  if (groupKey == PrayerReminder.firstOfDayGroupKey) {
    return fetchTodayFeaturedPrayerIdForDate(date, hour: hour);
  }

  final groups = await fetchPrayersForDate(date, hour: hour);
  for (final group in groups) {
    if (dateGroupMergeKey(group) != groupKey) {
      continue;
    }
    if (group.prayers.isEmpty) {
      return null;
    }
    return group.prayers.first.id;
  }
  return null;
}

/// First prayer id from today's calendar groups, or null if none.
Future<String?> fetchTodayFeaturedPrayerId() async {
  return fetchTodayFeaturedPrayerIdForDate(DateTime.now());
}

/// Short one-line summary for the home screen hint.
String summarizeTodayPrayers(List<DateGroupStruct> groups) {
  if (groups.isEmpty) {
    return 'Nicio rugăciune specială — vezi calendarul';
  }

  final labels = <String>[];
  for (final group in groups) {
    if (group.name.isNotEmpty) {
      labels.add(group.name);
    }
  }

  final prayerCount =
      groups.fold<int>(0, (sum, group) => sum + group.prayers.length);

  if (labels.isNotEmpty) {
    final head = labels.take(2).join(' · ');
    final suffix = labels.length > 2 ? '…' : '';
    if (prayerCount > 0) {
      return '$head$suffix · $prayerCount rugăciuni';
    }
    return '$head$suffix';
  }

  final titles = groups
      .expand((g) => g.prayers)
      .map((p) => p.title.isNotEmpty ? p.title : p.subtitle)
      .where((t) => t.isNotEmpty)
      .take(2)
      .toList();
  if (titles.isEmpty) {
    return '$prayerCount rugăciuni pentru azi';
  }
  final head = titles.join(' · ');
  return prayerCount > 2 ? '$head…' : head;
}
