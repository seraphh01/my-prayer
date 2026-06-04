import '/backend/schema/structs/index.dart';

class PrayerSearchEntry {
  const PrayerSearchEntry({
    required this.prayer,
    required this.path,
    required this.searchHaystack,
  });

  final PrayerStruct prayer;
  final String path;
  final String searchHaystack;

  /// Category path shown under the prayer name in search results.
  String get displaySubtitle => path;
}

class PrayerSearchIndex {
  PrayerSearchIndex._(this.entries);

  final List<PrayerSearchEntry> entries;

  static PrayerSearchIndex build(List<PrayerTypeStruct> types) {
    final results = <PrayerSearchEntry>[];

    void walkType(PrayerTypeStruct type, String prefix) {
      final currentPath =
          prefix.isEmpty ? type.type : '$prefix > ${type.type}';

      for (final prayer in type.prayers) {
        final haystack =
            '${prayer.title} ${prayer.subtitle} $currentPath'.toLowerCase();
        results.add(
          PrayerSearchEntry(
            prayer: prayer,
            path: currentPath,
            searchHaystack: haystack,
          ),
        );
      }

      for (final subtype in type.subtypes) {
        walkType(subtype, currentPath);
      }
    }

    for (final type in types) {
      walkType(type, '');
    }

    return PrayerSearchIndex._(results);
  }

  List<PrayerSearchEntry> search(String query, {int maxResults = 50}) {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) {
      return const [];
    }

    final matches = <PrayerSearchEntry>[];
    for (final entry in entries) {
      if (entry.searchHaystack.contains(lower)) {
        matches.add(entry);
        if (matches.length >= maxResults) {
          break;
        }
      }
    }
    return matches;
  }
}
