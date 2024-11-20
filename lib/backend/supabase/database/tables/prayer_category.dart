import '../database.dart';

class PrayerCategoryTable extends SupabaseTable<PrayerCategoryRow> {
  @override
  String get tableName => 'prayer_category';

  @override
  PrayerCategoryRow createRow(Map<String, dynamic> data) =>
      PrayerCategoryRow(data);
}

class PrayerCategoryRow extends SupabaseDataRow {
  PrayerCategoryRow(super.data);

  @override
  SupabaseTable get table => PrayerCategoryTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  int? get sequence => getField<int>('sequence');
  set sequence(int? value) => setField<int>('sequence', value);
}
