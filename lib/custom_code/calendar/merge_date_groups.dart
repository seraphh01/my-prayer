import '/backend/schema/structs/index.dart';

/// UI grouping: prayers that share the same [PrayerStruct.title] (e.g. hours of
/// the same office) shown under one header.
class PrayerTitleGroup {
  const PrayerTitleGroup({
    required this.title,
    required this.prayers,
  });

  final String title;
  final List<PrayerStruct> prayers;
}

/// Combines [DateGroupStruct] rows returned for one day when the API matches
/// multiple DB rules (e.g. weekday + feast). Groups with the same normalized
/// [name] are merged; prayers are deduplicated by id and sorted by sequence.
List<DateGroupStruct> mergeSimilarDateGroups(List<DateGroupStruct> groups) {
  final orderedKeys = <String>[];
  final merged = <String, DateGroupStruct>{};

  for (final group in groups) {
    if (group.prayers.isEmpty) {
      continue;
    }

    final key = dateGroupMergeKey(group);
    final existing = merged[key];
    if (existing == null) {
      orderedKeys.add(key);
      merged[key] = DateGroupStruct(
        name: group.name,
        description: group.description,
        prayers: List<PrayerStruct>.from(group.prayers),
      );
      continue;
    }

    merged[key] = _mergeDateGroupPair(existing, group);
  }

  return orderedKeys.map((key) => merged[key]!).toList();
}

/// Stable key for matching a liturgical group across days (same as merge logic).
String dateGroupMergeKey(DateGroupStruct group) {
  final name = group.name.trim().toLowerCase();
  if (name.isNotEmpty) {
    return 'name:$name';
  }

  final description = group.description.trim().toLowerCase();
  if (description.isNotEmpty) {
    return 'desc:$description';
  }

  final prayerIds = group.prayers.map((prayer) => prayer.id).toList()..sort();
  return 'prayers:${prayerIds.join('|')}';
}

DateGroupStruct _mergeDateGroupPair(
  DateGroupStruct first,
  DateGroupStruct second,
) {
  final prayersById = <String, PrayerStruct>{};

  void addPrayers(List<PrayerStruct> prayers) {
    for (final prayer in prayers) {
      final existing = prayersById[prayer.id];
      if (existing == null || prayer.sequence < existing.sequence) {
        prayersById[prayer.id] = prayer;
      }
    }
  }

  addPrayers(first.prayers);
  addPrayers(second.prayers);

  final mergedPrayers = prayersById.values.toList()
    ..sort((a, b) => a.sequence.compareTo(b.sequence));

  return DateGroupStruct(
    name: first.name.isNotEmpty ? first.name : second.name,
    description:
        first.description.isNotEmpty ? first.description : second.description,
    prayers: mergedPrayers,
  );
}

List<PrayerTitleGroup> groupPrayersByTitle(List<PrayerStruct> prayers) {
  if (prayers.isEmpty) {
    return const [];
  }

  final orderedKeys = <String>[];
  final byTitle = <String, List<PrayerStruct>>{};

  for (final prayer in prayers) {
    final key = prayer.title.trim().toLowerCase();
    if (key.isEmpty) {
      final fallbackKey = 'id:${prayer.id}';
      orderedKeys.add(fallbackKey);
      byTitle[fallbackKey] = [prayer];
      continue;
    }

    final bucket = byTitle.putIfAbsent(key, () {
      orderedKeys.add(key);
      return <PrayerStruct>[];
    });

    if (!bucket.any((existing) => existing.id == prayer.id)) {
      bucket.add(prayer);
    }
  }

  final groups = <PrayerTitleGroup>[];
  for (final key in orderedKeys) {
    final bucket = byTitle[key]!;
    bucket.sort((a, b) {
      final bySequence = a.sequence.compareTo(b.sequence);
      if (bySequence != 0) {
        return bySequence;
      }
      return a.subtitle.compareTo(b.subtitle);
    });
    groups.add(
      PrayerTitleGroup(
        title: bucket.first.title,
        prayers: bucket,
      ),
    );
  }

  groups.sort((a, b) {
    int minSequence(PrayerTitleGroup group) => group.prayers
        .map((prayer) => prayer.sequence)
        .reduce((left, right) => left < right ? left : right);

    return minSequence(a).compareTo(minSequence(b));
  });

  return groups;
}
