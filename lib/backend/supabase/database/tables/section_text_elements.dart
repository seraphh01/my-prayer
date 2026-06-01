import '../database.dart';

class SectionTextElementsTable extends SupabaseTable<SectionTextElementsRow> {
  @override
  String get tableName => 'section_text_elements';

  @override
  SectionTextElementsRow createRow(Map<String, dynamic> data) => SectionTextElementsRow(data);
}

class SectionTextElementsRow extends SupabaseDataRow {
  SectionTextElementsRow(super.data);

  @override
  SupabaseTable get table => SectionTextElementsTable();

  int get sectionTextId => getField<int>('section_text_id')!;
  set sectionTextId(int value) => setField<int>('section_text_id', value);

  String get textElementId => getField<String>('text_element_id')!;
  set textElementId(String value) => setField<String>('text_element_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int get startTime => getField<int>('start_time')!;
  set startTime(int value) => setField<int>('start_time', value);

  int get endTime => getField<int>('end_time')!;
  set endTime(int value) => setField<int>('end_time', value);

  int get sequence => getField<int>('sequence')!;
  set sequence(int value) => setField<int>('sequence', value);
}
