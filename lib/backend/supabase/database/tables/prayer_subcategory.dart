import '../database.dart';

class PrayerSubcategoryTable extends SupabaseTable<PrayerSubcategoryRow> {
  @override
  String get tableName => 'prayer_subcategory';

  @override
  PrayerSubcategoryRow createRow(Map<String, dynamic> data) =>
      PrayerSubcategoryRow(data);
}

class PrayerSubcategoryRow extends SupabaseDataRow {
  PrayerSubcategoryRow(super.data);

  @override
  SupabaseTable get table => PrayerSubcategoryTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  int? get categoryId => getField<int>('category_id');
  set categoryId(int? value) => setField<int>('category_id', value);

  int? get sequence => getField<int>('sequence');
  set sequence(int? value) => setField<int>('sequence', value);
}
