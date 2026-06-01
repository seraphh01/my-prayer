import '../database.dart';

class SectionsTable extends SupabaseTable<SectionsRow> {
  @override
  String get tableName => 'sections';

  @override
  SectionsRow createRow(Map<String, dynamic> data) => SectionsRow(data);
}

class SectionsRow extends SupabaseDataRow {
  SectionsRow(super.data);

  @override
  SupabaseTable get table => SectionsTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get audioUrl => getField<String>('audio_url')!;
  set audioUrl(String value) => setField<String>('audio_url', value);

  String? get subtitle => getField<String>('subtitle');
  set subtitle(String? value) => setField<String>('subtitle', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  bool? get showTitle => getField<bool>('show_title');
  set showTitle(bool? value) => setField<bool>('show_title', value);

  bool? get showSubtitle => getField<bool>('show_subtitle');
  set showSubtitle(bool? value) => setField<bool>('show_subtitle', value);
}
