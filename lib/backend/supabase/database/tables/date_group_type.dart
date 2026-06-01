import '../database.dart';

class DateGroupTypeTable extends SupabaseTable<DateGroupTypeRow> {
  @override
  String get tableName => 'date_group_type';

  @override
  DateGroupTypeRow createRow(Map<String, dynamic> data) => DateGroupTypeRow(data);
}

class DateGroupTypeRow extends SupabaseDataRow {
  DateGroupTypeRow(super.data);

  @override
  SupabaseTable get table => DateGroupTypeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);
}
