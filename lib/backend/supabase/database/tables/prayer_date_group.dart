import '../database.dart';

class PrayerDateGroupTable extends SupabaseTable<PrayerDateGroupRow> {
  @override
  String get tableName => 'prayer_date_group';

  @override
  PrayerDateGroupRow createRow(Map<String, dynamic> data) => PrayerDateGroupRow(data);
}

class PrayerDateGroupRow extends SupabaseDataRow {
  PrayerDateGroupRow(super.data);

  @override
  SupabaseTable get table => PrayerDateGroupTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get prayerId => getField<String>('prayer_id')!;
  set prayerId(String value) => setField<String>('prayer_id', value);

  int get dateGroupId => getField<int>('date_group_id')!;
  set dateGroupId(int value) => setField<int>('date_group_id', value);

  int get sequence => getField<int>('sequence')!;
  set sequence(int value) => setField<int>('sequence', value);
}
