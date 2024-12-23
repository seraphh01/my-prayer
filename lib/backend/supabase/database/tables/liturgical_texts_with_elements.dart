import '../database.dart';

class LiturgicalTextsWithElementsTable
    extends SupabaseTable<LiturgicalTextsWithElementsRow> {
  @override
  String get tableName => 'liturgical_texts_with_elements';

  @override
  LiturgicalTextsWithElementsRow createRow(Map<String, dynamic> data) =>
      LiturgicalTextsWithElementsRow(data);
}

class LiturgicalTextsWithElementsRow extends SupabaseDataRow {
  LiturgicalTextsWithElementsRow(super.data);

  @override
  SupabaseTable get table => LiturgicalTextsWithElementsTable();

  String? get liturgicalTextId => getField<String>('liturgical_text_id');
  set liturgicalTextId(String? value) =>
      setField<String>('liturgical_text_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  List<String> get textElementsList =>
      getListField<String>('text_elements_list');
  set textElementsList(List<String>? value) =>
      setListField<String>('text_elements_list', value);

  String? get fullText => getField<String>('full_text');
  set fullText(String? value) => setField<String>('full_text', value);
}
