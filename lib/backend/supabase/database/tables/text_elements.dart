import '../database.dart';

class TextElementsTable extends SupabaseTable<TextElementsRow> {
  @override
  String get tableName => 'text_elements';

  @override
  TextElementsRow createRow(Map<String, dynamic> data) => TextElementsRow(data);
}

class TextElementsRow extends SupabaseDataRow {
  TextElementsRow(super.data);

  @override
  SupabaseTable get table => TextElementsTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get text => getField<String>('text')!;
  set text(String value) => setField<String>('text', value);

  int get sequence => getField<int>('sequence')!;
  set sequence(int value) => setField<int>('sequence', value);

  String? get textId => getField<String>('text_id');
  set textId(String? value) => setField<String>('text_id', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);
}
