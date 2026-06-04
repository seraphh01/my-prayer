import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';

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

List<DateGroupStruct> _parseDateGroups(ApiCallResponse response) {
  if (response.succeeded != true) {
    return [];
  }
  return ((response.jsonBody ?? '')
          .toList()
          .map<DateGroupStruct?>(DateGroupStruct.maybeFromMap)
          .toList() as Iterable<DateGroupStruct?>)
      .withoutNulls
      .toList()
      .cast<DateGroupStruct>();
}

/// Picks the recommended prayer using calendar priority:
/// 1. Date groups tied to the current hour (not in the day-only set)
/// 2. Date groups for the day of week without an hour constraint
/// 3. Any remaining group from the hour-filtered response
RecommendedPrayerResult? pickRecommendedPrayer(
  List<DateGroupStruct> withHourGroups,
  List<DateGroupStruct> dayOnlyGroups,
) {
  final dayOnlyGroupNames = dayOnlyGroups
      .map((group) => group.name)
      .where((name) => name.isNotEmpty)
      .toSet();

  final hourSpecificGroups = withHourGroups
      .where(
        (group) =>
            group.prayers.isNotEmpty &&
            group.name.isNotEmpty &&
            !dayOnlyGroupNames.contains(group.name),
      )
      .toList();

  final hourSpecific = _firstPrayerFromGroups(hourSpecificGroups);
  if (hourSpecific != null) {
    return hourSpecific;
  }

  final dayOnly = _firstPrayerFromGroups(
    dayOnlyGroups.where((group) => group.prayers.isNotEmpty).toList(),
  );
  if (dayOnly != null) {
    return dayOnly;
  }

  return _firstPrayerFromGroups(
    withHourGroups.where((group) => group.prayers.isNotEmpty).toList(),
  );
}

RecommendedPrayerResult? _firstPrayerFromGroups(List<DateGroupStruct> groups) {
  for (final group in groups) {
    final prayers = group.prayers
        .toList()
        .sortedList(keyOf: (prayer) => prayer.sequence, desc: false);
    if (prayers.isEmpty) {
      continue;
    }
    return RecommendedPrayerResult(
      prayer: prayers.first,
      groupName: group.name,
      groupDescription:
          group.description.isNotEmpty ? group.description : null,
    );
  }
  return null;
}

Future<RecommendedPrayerResult?> fetchRecommendedPrayer() async {
  final now = DateTime.fromMillisecondsSinceEpoch(
    getCurrentTimestamp.millisecondsSinceEpoch,
  );
  final dayOfWeek = now.weekday;
  final hour = now.hour;

  final withHourResponse =
      await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
    dayOfWeek: dayOfWeek,
    hour: hour,
  );
  final dayOnlyResponse =
      await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
    dayOfWeek: dayOfWeek,
    hour: -1,
  );

  final withHourGroups = _parseDateGroups(withHourResponse);
  final dayOnlyGroups = _parseDateGroups(dayOnlyResponse);

  if (withHourGroups.isEmpty && dayOnlyGroups.isEmpty) {
    return null;
  }

  return pickRecommendedPrayer(withHourGroups, dayOnlyGroups);
}
