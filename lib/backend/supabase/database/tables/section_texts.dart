import '../database.dart';

class SectionTextsTable extends SupabaseTable<SectionTextsRow> {
  @override
  String get tableName => 'section_texts';

  @override
  SectionTextsRow createRow(Map<String, dynamic> data) => SectionTextsRow(data);
}

class SectionTextsRow extends SupabaseDataRow {
  SectionTextsRow(super.data);

  @override
  SupabaseTable get table => SectionTextsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get liturgicalTextId => getField<String>('liturgical_text_id');
  set liturgicalTextId(String? value) =>
      setField<String>('liturgical_text_id', value);

  String? get prayerSectionId => getField<String>('prayer_section_id');
  set prayerSectionId(String? value) =>
      setField<String>('prayer_section_id', value);

  int get sequence => getField<int>('sequence')!;
  set sequence(int value) => setField<int>('sequence', value);

  int? get repetition => getField<int>('repetition');
  set repetition(int? value) => setField<int>('repetition', value);

  int? get startTime => getField<int>('start_time');
  set startTime(int? value) => setField<int>('start_time', value);

  int? get endTime => getField<int>('end_time');
  set endTime(int? value) => setField<int>('end_time', value);
}
