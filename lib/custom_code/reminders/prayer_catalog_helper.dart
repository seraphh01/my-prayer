import '/backend/schema/structs/index.dart';

class PrayerCatalogItem {
  const PrayerCatalogItem({
    required this.prayer,
    required this.path,
  });

  final PrayerStruct prayer;
  final String path;

  String get searchHaystack =>
      '${prayer.title} ${prayer.subtitle} $path'.toLowerCase();
}

List<PrayerCatalogItem> flattenPrayerCatalog(List<PrayerTypeStruct> types) {
  final results = <PrayerCatalogItem>[];

  void walkType(PrayerTypeStruct type, String prefix) {
    final currentPath = prefix.isEmpty ? type.type : '$prefix > ${type.type}';

    for (final prayer in type.prayers) {
      results.add(PrayerCatalogItem(prayer: prayer, path: currentPath));
    }

    for (final subtype in type.subtypes) {
      walkType(subtype, currentPath);
    }
  }

  for (final type in types) {
    walkType(type, '');
  }

  return results;
}

List<PrayerCatalogItem> searchPrayerCatalog(
  List<PrayerCatalogItem> catalog,
  String query,
) {
  final lower = query.trim().toLowerCase();
  if (lower.isEmpty) {
    return catalog;
  }
  return catalog.where((item) => item.searchHaystack.contains(lower)).toList();
}

/// Flat search by prayer title or subtitle only (case insensitive).
List<PrayerStruct> searchPrayersByTitleOrSubtitle(
  List<PrayerTypeStruct> types,
  String query,
) {
  final lower = query.trim().toLowerCase();
  if (lower.isEmpty) {
    return const [];
  }

  final results = <PrayerStruct>[];
  final seenIds = <String>{};

  void walkType(PrayerTypeStruct type) {
    for (final prayer in type.prayers) {
      if (prayer.id.isEmpty || seenIds.contains(prayer.id)) {
        continue;
      }
      final title = prayer.title.toLowerCase();
      final subtitle = prayer.subtitle.toLowerCase();
      if (title.contains(lower) || subtitle.contains(lower)) {
        seenIds.add(prayer.id);
        results.add(prayer);
      }
    }
    for (final subtype in type.subtypes) {
      walkType(subtype);
    }
  }

  for (final type in types) {
    walkType(type);
  }

  return results;
}

List<PrayerTypeStruct> sortedPrayerTypes(List<PrayerTypeStruct> types) {
  final sorted = types.toList()..sort((a, b) => a.sequence.compareTo(b.sequence));
  return sorted;
}

int prayerTypeVisibleItemCount(PrayerTypeStruct type) {
  return type.subtypes.length + type.prayers.length;
}
