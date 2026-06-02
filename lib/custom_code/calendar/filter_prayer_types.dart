import '/backend/schema/structs/index.dart';

/// Keeps [PrayerTypeStruct] nodes that contain at least one prayer from
/// [allowedPrayerIds], preserving nested [PrayerTypeStruct.subtypes].
List<PrayerTypeStruct> filterPrayerTypesForCalendar(
  List<PrayerTypeStruct> types,
  Set<String> allowedPrayerIds,
) {
  if (allowedPrayerIds.isEmpty || types.isEmpty) {
    return const [];
  }

  final filtered = <PrayerTypeStruct>[];
  final sortedTypes = types.toList()
    ..sort((a, b) => a.sequence.compareTo(b.sequence));

  for (final type in sortedTypes) {
    final pruned = _prunePrayerType(type, allowedPrayerIds);
    if (pruned != null) {
      filtered.add(pruned);
    }
  }

  return filtered;
}

PrayerTypeStruct? _prunePrayerType(
  PrayerTypeStruct type,
  Set<String> allowedPrayerIds,
) {
  final filteredSubtypes = <PrayerTypeStruct>[];
  final sortedSubtypes = type.subtypes.toList()
    ..sort((a, b) => a.sequence.compareTo(b.sequence));

  for (final subtype in sortedSubtypes) {
    final prunedSubtype = _prunePrayerType(subtype, allowedPrayerIds);
    if (prunedSubtype != null) {
      filteredSubtypes.add(prunedSubtype);
    }
  }

  final filteredPrayers = type.prayers
      .where((prayer) => allowedPrayerIds.contains(prayer.id))
      .toList()
    ..sort((a, b) => a.sequence.compareTo(b.sequence));

  if (filteredSubtypes.isEmpty && filteredPrayers.isEmpty) {
    return null;
  }

  return PrayerTypeStruct(
    id: type.id,
    type: type.type,
    sequence: type.sequence,
    subtypes: filteredSubtypes,
    prayers: filteredPrayers,
  );
}

Set<String> prayerIdsFromDateGroups(List<DateGroupStruct> dateGroups) {
  final ids = <String>{};
  for (final group in dateGroups) {
    for (final prayer in group.prayers) {
      if (prayer.id.isNotEmpty) {
        ids.add(prayer.id);
      }
    }
  }
  return ids;
}
