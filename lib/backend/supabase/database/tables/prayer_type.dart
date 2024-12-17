import '../database.dart';

class PrayerTypeTable extends SupabaseTable<PrayerTypeRow> {
  @override
  String get tableName => 'prayer_type';

  @override
  PrayerTypeRow createRow(Map<String, dynamic> data) => PrayerTypeRow(data);
}

class PrayerTypeRow extends SupabaseDataRow {
  PrayerTypeRow(super.data);

  @override
  SupabaseTable get table => PrayerTypeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  int? get sequence => getField<int>('sequence');
  set sequence(int? value) => setField<int>('sequence', value);

  int? get parentTypeId => getField<int>('parent_type_id');
  set parentTypeId(int? value) => setField<int>('parent_type_id', value);
}
