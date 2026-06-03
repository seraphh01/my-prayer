import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/custom_code/prayer/prayer_types_cache.dart';
import '/custom_code/reminders/prayer_catalog_helper.dart';
import 'package:my_prayer/service_locator.dart';

/// Catholic rosary mystery schedule (Romanian keyword hints for catalog match).
const Map<int, List<String>> rosaryMysteryKeywordsByWeekday = {
  DateTime.monday: ['bucur', 'gaud'],
  DateTime.tuesday: ['dur', 'duro', 'durer'],
  DateTime.wednesday: ['glor', 'mări', 'marire', 'mărire'],
  DateTime.thursday: ['lumin'],
  DateTime.friday: ['dur', 'duro', 'durer'],
  DateTime.saturday: ['bucur', 'gaud'],
  DateTime.sunday: ['glor', 'mări', 'marire', 'mărire'],
};

/// Resolves the rosary prayer for [date] (calendar rules first, catalog fallback).
Future<String?> fetchRosaryPrayerIdForDate(DateTime date) async {
  final groups = await fetchPrayersForDate(date);
  final fromCalendar = _pickRosaryFromGroups(groups, date.weekday);
  if (fromCalendar != null && fromCalendar.id.isNotEmpty) {
    return fromCalendar.id;
  }

  return _fetchRosaryFromCatalog(date.weekday);
}

String _prayerHaystack(PrayerStruct prayer) {
  return '${prayer.title} ${prayer.subtitle}'.toLowerCase();
}

bool _looksLikeRosary(String haystack, {String groupHaystack = ''}) {
  return haystack.contains('rozar') ||
      haystack.contains('mistere') ||
      groupHaystack.contains('rozar') ||
      groupHaystack.contains('mistere');
}

PrayerStruct? _pickRosaryFromGroups(
  List<DateGroupStruct> groups,
  int weekday,
) {
  final candidates = <PrayerStruct>[];

  for (final group in groups) {
    final groupHaystack =
        '${group.name} ${group.description}'.toLowerCase();
    for (final prayer in group.prayers) {
      final hay = _prayerHaystack(prayer);
      if (_looksLikeRosary(hay, groupHaystack: groupHaystack)) {
        candidates.add(prayer);
      }
    }
  }

  if (candidates.isEmpty) {
    return null;
  }
  if (candidates.length == 1) {
    return candidates.first;
  }

  return _matchPrayerByWeekday(candidates, weekday) ?? candidates.first;
}

PrayerStruct? _matchPrayerByWeekday(
  List<PrayerStruct> prayers,
  int weekday,
) {
  final keywords = rosaryMysteryKeywordsByWeekday[weekday] ?? [];
  if (keywords.isEmpty) {
    return null;
  }

  for (final prayer in prayers) {
    final hay = _prayerHaystack(prayer);
    if (keywords.any(hay.contains)) {
      return prayer;
    }
  }
  return null;
}

Future<String?> _fetchRosaryFromCatalog(int weekday) async {
  try {
    final types = await getIt<PrayerTypesCache>().load();
    if (types.isEmpty) {
      return null;
    }

    final catalog = flattenPrayerCatalog(types);

    final candidates = catalog
        .where(
          (item) => _looksLikeRosary(
            item.searchHaystack,
            groupHaystack: item.path.toLowerCase(),
          ),
        )
        .map((item) => item.prayer)
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    final matched = _matchPrayerByWeekday(candidates, weekday);
    return (matched ?? candidates.first).id;
  } catch (_) {
    return null;
  }
}
