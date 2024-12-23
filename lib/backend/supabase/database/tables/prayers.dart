import '../database.dart';

class PrayersTable extends SupabaseTable<PrayersRow> {
  @override
  String get tableName => 'prayers';

  @override
  PrayersRow createRow(Map<String, dynamic> data) => PrayersRow(data);
}

class PrayersRow extends SupabaseDataRow {
  PrayersRow(super.data);

  @override
  SupabaseTable get table => PrayersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  int? get prayerTypeId => getField<int>('prayer_type_id');
  set prayerTypeId(int? value) => setField<int>('prayer_type_id', value);

  String? get subtitle => getField<String>('subtitle');
  set subtitle(String? value) => setField<String>('subtitle', value);

  int? get sequence => getField<int>('sequence');
  set sequence(int? value) => setField<int>('sequence', value);
}
