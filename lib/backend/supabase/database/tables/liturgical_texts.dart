import '../database.dart';

class LiturgicalTextsTable extends SupabaseTable<LiturgicalTextsRow> {
  @override
  String get tableName => 'liturgical_texts';

  @override
  LiturgicalTextsRow createRow(Map<String, dynamic> data) =>
      LiturgicalTextsRow(data);
}

class LiturgicalTextsRow extends SupabaseDataRow {
  LiturgicalTextsRow(super.data);

  @override
  SupabaseTable get table => LiturgicalTextsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  int? get audioTime => getField<int>('audio_time');
  set audioTime(int? value) => setField<int>('audio_time', value);
}
