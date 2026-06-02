import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/filter_prayer_types.dart';

class PrayerTypePickerItem {
  const PrayerTypePickerItem({
    required this.typeId,
    required this.name,
    required this.path,
  });

  final int typeId;
  final String name;
  final String path;

  String get searchHaystack => '$name $path'.toLowerCase();
}

List<PrayerTypeStruct>? _cachedPrayerTypesCatalog;

Future<List<PrayerTypeStruct>> fetchPrayerTypesCatalog() async {
  if (_cachedPrayerTypesCatalog != null) {
    return _cachedPrayerTypesCatalog!;
  }

  final response = await SuapabaseQueriesGroup.getPrayerTypesCall.call();
  if (response.succeeded != true || response.jsonBody is! List) {
    return const [];
  }

  _cachedPrayerTypesCatalog = (response.jsonBody as List)
      .map(PrayerTypeStruct.maybeFromMap)
      .whereType<PrayerTypeStruct>()
      .toList();
  return _cachedPrayerTypesCatalog!;
}

PrayerTypeStruct? findPrayerTypeById(
  List<PrayerTypeStruct> types,
  int typeId,
) {
  for (final type in types) {
    if (type.id == typeId) {
      return type;
    }
    final nested = findPrayerTypeById(type.subtypes, typeId);
    if (nested != null) {
      return nested;
    }
  }
  return null;
}

Set<String> prayerIdsUnderType(PrayerTypeStruct type) {
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

bool typeHasPrayersInAllowedSet(
  PrayerTypeStruct type,
  Set<String> allowedPrayerIds,
) {
  if (type.prayers.any((prayer) => allowedPrayerIds.contains(prayer.id))) {
    return true;
  }
  return type.subtypes
      .any((subtype) => typeHasPrayersInAllowedSet(subtype, allowedPrayerIds));
}

List<PrayerTypePickerItem> buildPrayerTypePickerItems(
  List<PrayerTypeStruct> catalog,
  Set<String> allowedPrayerIds,
) {
  if (catalog.isEmpty || allowedPrayerIds.isEmpty) {
    return const [];
  }

  final filtered = filterPrayerTypesForCalendar(catalog, allowedPrayerIds);
  final items = <PrayerTypePickerItem>[];

  void walk(PrayerTypeStruct type, String prefix) {
    final path = prefix.isEmpty ? type.type : '$prefix > ${type.type}';
    if (typeHasPrayersInAllowedSet(type, allowedPrayerIds)) {
      items.add(
        PrayerTypePickerItem(
          typeId: type.id,
          name: type.type,
          path: path,
        ),
      );
    }
    for (final subtype in type.subtypes) {
      walk(subtype, path);
    }
  }

  for (final type in filtered) {
    walk(type, '');
  }

  return items;
}

List<PrayerTypePickerItem> searchPrayerTypePickerItems(
  List<PrayerTypePickerItem> items,
  String query,
) {
  final lower = query.trim().toLowerCase();
  if (lower.isEmpty) {
    return items;
  }
  return items.where((item) => item.searchHaystack.contains(lower)).toList();
}
