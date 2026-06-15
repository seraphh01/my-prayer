import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/custom_code/calendar/filter_prayer_types.dart';
import '/custom_code/calendar/merge_date_groups.dart';
import '/custom_code/debug/simulated_clock.dart';
import '/custom_code/prayer/prayer_types_cache.dart';
import 'package:my_prayer/service_locator.dart';

/// Maximum number of today-prayer cards shown on the home screen.
const int kTodayPrayersHomeMax = 4;

/// Hour-tagged prayers appear this many minutes before the scheduled hour.
const int kHourPrayerLeadMinutes = 15;

/// Hour-tagged prayers stay visible this long after the scheduled hour (until HH+2:59).
const int kHourPrayerTailMinutes = 2 * 60 + 59;

class RecommendedPrayerResult {
  const RecommendedPrayerResult({
    required this.prayer,
    required this.groupName,
    this.groupDescription,
  });

  final PrayerStruct prayer;
  final String groupName;
  final String? groupDescription;
}

class TodayPrayerEntry {
  const TodayPrayerEntry({
    required this.prayer,
    required this.groupLabel,
    this.groupDescription,
    this.voicePrayers = const [],
    this.prayerTypeTitle,
    this.prayerTypeSubtitle,
  });

  final PrayerStruct prayer;
  final String groupLabel;
  final String? groupDescription;

  /// Variants of the same prayer type at one hour (e.g. multiple glasuri).
  final List<PrayerStruct> voicePrayers;

  /// Collapsed catalog labels for [opensPrayerType] cards.
  final String? prayerTypeTitle;
  final String? prayerTypeSubtitle;

  bool get opensPrayerType => voicePrayers.length > 1;
}

class ScheduleTime {
  const ScheduleTime({
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;
}

class HourScheduleSlot {
  const HourScheduleSlot({
    required this.scheduleTime,
    required this.groups,
  });

  final ScheduleTime scheduleTime;
  final List<DateGroupStruct> groups;

  int get startMinutes => scheduleTime.minutesSinceMidnight;
}

/// DB stores [DateGroupStruct.hour] as 0–23 on a 24h clock (0 = midnight, 6 = 6 AM).
ScheduleTime? scheduleTimeFromDbHour(int hour) {
  if (hour < 0 || hour > 23) {
    return null;
  }
  return ScheduleTime(hour: hour, minute: 0);
}

String formatScheduleTimeLabel(ScheduleTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  return '$hour:00';
}

List<HourScheduleSlot> buildHourSlots(List<DateGroupStruct> hourGroups) {
  final byStart = <int, List<DateGroupStruct>>{};
  final orderedStarts = <int>[];

  for (final group in hourGroups) {
    if (!group.hasHour() || group.prayers.isEmpty) {
      continue;
    }

    final scheduleTime = scheduleTimeFromDbHour(group.hour!);
    if (scheduleTime == null) {
      continue;
    }

    final start = scheduleTime.minutesSinceMidnight;
    final bucket = byStart.putIfAbsent(start, () {
      orderedStarts.add(start);
      return <DateGroupStruct>[];
    });
    bucket.add(group);
  }

  orderedStarts.sort();
  return orderedStarts
      .map(
        (start) => HourScheduleSlot(
          scheduleTime: scheduleTimeFromDbHour(byStart[start]!.first.hour!)!,
          groups: byStart[start]!,
        ),
      )
      .toList();
}

int _hourSlotWindowStartMinutes(
  HourScheduleSlot slot, {
  required bool isFirstSlot,
}) {
  if (isFirstSlot) {
    return 0;
  }
  return slot.startMinutes - kHourPrayerLeadMinutes;
}

int _hourSlotWindowEndMinutesInclusive(
  HourScheduleSlot slot, {
  required bool isLastSlot,
}) {
  if (isLastSlot) {
    return (24 * 60) - 1;
  }
  return slot.startMinutes + kHourPrayerTailMinutes;
}

bool _isHourSlotVisibleAt(
  HourScheduleSlot slot,
  int nowMinutes, {
  required bool isFirstSlot,
  required bool isLastSlot,
}) {
  return nowMinutes >= _hourSlotWindowStartMinutes(slot, isFirstSlot: isFirstSlot) &&
      nowMinutes <=
          _hourSlotWindowEndMinutesInclusive(slot, isLastSlot: isLastSlot);
}

/// Hour slots whose visibility window contains [now] (windows may overlap).
List<HourScheduleSlot> resolveVisibleHourSlots(
  List<HourScheduleSlot> slots,
  DateTime now,
) {
  if (slots.isEmpty) {
    return const [];
  }

  final sorted = List<HourScheduleSlot>.from(slots)
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  final nowMinutes = now.hour * 60 + now.minute;

  return [
    for (var i = 0; i < sorted.length; i++)
      if (_isHourSlotVisibleAt(
        sorted[i],
        nowMinutes,
        isFirstSlot: i == 0,
        isLastSlot: i == sorted.length - 1,
      ))
        sorted[i],
  ];
}

/// First visible hour slot, if any (for single-card recommendations).
HourScheduleSlot? resolveVisibleHourSlot(
  List<HourScheduleSlot> slots,
  DateTime now,
) {
  final visible = resolveVisibleHourSlots(slots, now);
  if (visible.isEmpty) {
    return null;
  }
  return visible.first;
}

List<PrayerStruct> uniqueSortedPrayers(Iterable<PrayerStruct> prayers) {
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

List<TodayPrayerEntry> pickTodayPrayers(
  List<DateGroupStruct> groups, {
  required DateTime now,
  int maxEntries = kTodayPrayersHomeMax,
}) {
  if (maxEntries <= 0 || groups.isEmpty) {
    return const [];
  }

  final hourTaggedGroups = groups
      .where((group) => group.hasHour() && group.prayers.isNotEmpty)
      .toList();
  final dayOnlyGroups = groups
      .where((group) => !group.hasHour() && group.prayers.isNotEmpty)
      .toList();
  final hourPrayerIds = hourTaggedGroups
      .expand((group) => group.prayers)
      .map((prayer) => prayer.id)
      .where((id) => id.isNotEmpty)
      .toSet();

  final slots = buildHourSlots(hourTaggedGroups);
  final visibleSlots = resolveVisibleHourSlots(slots, now);

  final entries = <TodayPrayerEntry>[];
  final seenPrayerIds = <String>{};

  bool addEntry(TodayPrayerEntry entry) {
    if (entries.length >= maxEntries) {
      return false;
    }

    final prayerIds = entry.opensPrayerType
        ? entry.voicePrayers.map((prayer) => prayer.id)
        : [entry.prayer.id];

    for (final prayerId in prayerIds) {
      if (seenPrayerIds.contains(prayerId)) {
        return false;
      }
    }

    for (final prayerId in prayerIds) {
      seenPrayerIds.add(prayerId);
    }
    entries.add(entry);
    return true;
  }

  for (final slot in visibleSlots) {
    for (final entry in _entriesFromHourSlot(slot)) {
      if (!addEntry(entry)) {
        break;
      }
    }
    if (entries.length >= maxEntries) {
      break;
    }
  }

  for (final group in dayOnlyGroups) {
    if (entries.length >= maxEntries) {
      break;
    }

    final prayers = uniqueSortedPrayers(group.prayers)
        .where((prayer) => !hourPrayerIds.contains(prayer.id))
        .toList();
    for (final prayer in prayers) {
      if (entries.length >= maxEntries) {
        break;
      }

      addEntry(
        TodayPrayerEntry(
          prayer: prayer,
          groupLabel: group.name,
          groupDescription:
              group.description.isNotEmpty ? group.description : null,
        ),
      );
    }
  }

  return entries;
}

List<TodayPrayerEntry> _entriesFromHourSlot(HourScheduleSlot slot) {
  final prayers = uniqueSortedPrayers(
    slot.groups.expand((group) => group.prayers),
  );
  if (prayers.isEmpty) {
    return const [];
  }

  final label = _hourSlotLabel(slot);
  final titleGroups = groupPrayersByTitle(prayers);

  return titleGroups.map((titleGroup) {
    final groupPrayers = titleGroup.prayers;
    if (groupPrayers.length == 1) {
      return TodayPrayerEntry(
        prayer: groupPrayers.first,
        groupLabel: label,
        groupDescription: _hourSlotDescription(slot, 1),
      );
    }

    return TodayPrayerEntry(
      prayer: groupPrayers.first,
      groupLabel: label,
      voicePrayers: groupPrayers,
    );
  }).toList();
}

String _hourSlotLabel(HourScheduleSlot slot) {
  if (slot.groups.length == 1) {
    final groupName = slot.groups.first.name.trim();
    if (groupName.isNotEmpty) {
      return groupName;
    }
  }

  return 'Ora ${formatScheduleTimeLabel(slot.scheduleTime)}';
}

String? _hourSlotDescription(HourScheduleSlot slot, int prayerCount) {
  if (prayerCount > 1) {
    return '$prayerCount glasuri';
  }

  for (final group in slot.groups) {
    if (group.description.isNotEmpty) {
      return group.description;
    }
  }

  return null;
}

RecommendedPrayerResult? pickRecommendedPrayer(
  List<DateGroupStruct> groups, {
  required DateTime now,
}) {
  final entries = pickTodayPrayers(groups, now: now, maxEntries: 1);
  if (entries.isEmpty) {
    return null;
  }

  final entry = entries.first;
  return RecommendedPrayerResult(
    prayer: entry.prayer,
    groupName: entry.groupLabel,
    groupDescription: entry.groupDescription,
  );
}

TodayPrayerEntry _withPrayerTypeLabel(
  TodayPrayerEntry entry,
  List<PrayerTypeStruct> catalog,
) {
  if (!entry.opensPrayerType) {
    return entry;
  }

  final resolved = resolveTodayPrayerType(catalog, entry.voicePrayers);
  if (resolved == null) {
    return entry;
  }

  return TodayPrayerEntry(
    prayer: entry.prayer,
    groupLabel: entry.groupLabel,
    groupDescription: entry.groupDescription,
    voicePrayers: entry.voicePrayers,
    prayerTypeTitle: resolved.cardTitle,
    prayerTypeSubtitle: resolved.cardSubtitle,
  );
}

Future<List<TodayPrayerEntry>> fetchTodayPrayers() async {
  final now = effectiveNow();
  final selectedDate = DateTime(now.year, now.month, now.day);
  final rawGroups = await fetchRawPrayersForDate(selectedDate);

  if (rawGroups.isEmpty) {
    return const [];
  }

  final entries = pickTodayPrayers(rawGroups, now: now);
  final catalog = await getIt<PrayerTypesCache>().load();
  return entries.map((entry) => _withPrayerTypeLabel(entry, catalog)).toList();
}

Future<RecommendedPrayerResult?> fetchRecommendedPrayer() async {
  final entries = await fetchTodayPrayers();
  if (entries.isEmpty) {
    return null;
  }

  final entry = entries.first;
  return RecommendedPrayerResult(
    prayer: entry.prayer,
    groupName: entry.groupLabel,
    groupDescription: entry.groupDescription,
  );
}
