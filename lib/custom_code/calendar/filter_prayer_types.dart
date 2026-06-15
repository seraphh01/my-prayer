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

/// Resolved prayer type for a “Pentru astăzi” card after skipping redundant levels.
class ResolvedTodayPrayerType {
  const ResolvedTodayPrayerType({
    required this.pathLabels,
    required this.entryType,
  });

  /// Collapsed type path from root to [entryType].
  final List<String> pathLabels;

  /// Type to open in home navigation (after skipping single-subtype wrappers).
  final PrayerTypeStruct entryType;

  /// Full path joined with ` - ` (legacy / debug).
  String get displayLabel => pathLabels.join(' - ');

  /// Card title: parent type when the path was collapsed (second-to-last).
  String? get cardTitle =>
      pathLabels.length >= 2 ? pathLabels[pathLabels.length - 2] : null;

  /// Card subtitle: the effective leaf type after collapsing.
  String? get cardSubtitle =>
      pathLabels.isNotEmpty ? pathLabels.last : null;
}

PrayerTypeStruct? _matchingFilteredType(
  List<PrayerTypeStruct> filtered,
  Set<String> prayerIds,
) {
  if (filtered.isEmpty) {
    return null;
  }
  if (filtered.length == 1) {
    return filtered.first;
  }

  for (final type in filtered) {
    if (prayerIds.every(_prayerIdsUnderType(type).contains)) {
      return type;
    }
  }

  return filtered.first;
}

/// Skips wrapper types that only contain one subtype; joins the path with ` - `.
ResolvedTodayPrayerType? resolveTodayPrayerType(
  List<PrayerTypeStruct> catalog,
  Iterable<PrayerStruct> prayers,
) {
  final ids = prayers.map((prayer) => prayer.id).where((id) => id.isNotEmpty).toSet();
  if (ids.isEmpty || catalog.isEmpty) {
    return null;
  }

  final filtered = filterPrayerTypesForCalendar(catalog, ids);
  final root = _matchingFilteredType(filtered, ids);
  if (root == null) {
    return null;
  }

  return _collapseSingleSubtypeChain(root);
}

ResolvedTodayPrayerType? _collapseSingleSubtypeChain(PrayerTypeStruct root) {
  final path = <String>[];
  var current = root;

  while (true) {
    final label = current.type.trim();
    if (label.isNotEmpty) {
      path.add(label);
    }

    if (current.subtypes.length != 1 || current.prayers.isNotEmpty) {
      break;
    }

    current = current.subtypes.first;
  }

  if (path.isEmpty) {
    return null;
  }

  return ResolvedTodayPrayerType(
    pathLabels: path,
    entryType: current,
  );
}

/// Resolves the catalog label for a set of prayer variants (e.g. multiple glasuri).
String? prayerTypeLabelForPrayers(
  List<PrayerTypeStruct> catalog,
  Iterable<PrayerStruct> prayers,
) {
  return resolveTodayPrayerType(catalog, prayers)?.displayLabel;
}

Set<String> _prayerIdsUnderType(PrayerTypeStruct type) {
  final ids = <String>{};
  void walk(PrayerTypeStruct node) {
    for (final prayer in node.prayers) {
      if (prayer.id.isNotEmpty) {
        ids.add(prayer.id);
      }
    }
    for (final subtype in node.subtypes) {
      walk(subtype);
    }
  }

  walk(type);
  return ids;
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
