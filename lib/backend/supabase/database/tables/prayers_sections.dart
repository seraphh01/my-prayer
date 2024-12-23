import '../database.dart';

class PrayersSectionsTable extends SupabaseTable<PrayersSectionsRow> {
  @override
  String get tableName => 'prayers_sections';

  @override
  PrayersSectionsRow createRow(Map<String, dynamic> data) =>
      PrayersSectionsRow(data);
}

class PrayersSectionsRow extends SupabaseDataRow {
  PrayersSectionsRow(super.data);

  @override
  SupabaseTable get table => PrayersSectionsTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get prayerId => getField<String>('prayer_id')!;
  set prayerId(String value) => setField<String>('prayer_id', value);

  int get sequence => getField<int>('sequence')!;
  set sequence(int value) => setField<int>('sequence', value);

  String? get sectionId => getField<String>('section_id');
  set sectionId(String? value) => setField<String>('section_id', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get parentId => getField<String>('parent_id');
  set parentId(String? value) => setField<String>('parent_id', value);
}
