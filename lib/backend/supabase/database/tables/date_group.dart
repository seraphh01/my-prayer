import '../database.dart';

class DateGroupTable extends SupabaseTable<DateGroupRow> {
  @override
  String get tableName => 'date_group';

  @override
  DateGroupRow createRow(Map<String, dynamic> data) => DateGroupRow(data);
}

class DateGroupRow extends SupabaseDataRow {
  DateGroupRow(super.data);

  @override
  SupabaseTable get table => DateGroupTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get specificDate => getField<String>('specific_date');
  set specificDate(String? value) => setField<String>('specific_date', value);

  int? get dayOfWeek => getField<int>('day_of_week');
  set dayOfWeek(int? value) => setField<int>('day_of_week', value);

  int? get month => getField<int>('month');
  set month(int? value) => setField<int>('month', value);

  int? get day => getField<int>('day');
  set day(int? value) => setField<int>('day', value);

  int? get hour => getField<int>('hour');
  set hour(int? value) => setField<int>('hour', value);

  int? get dateGroupTypeId => getField<int>('date_group_type_id');
  set dateGroupTypeId(int? value) => setField<int>('date_group_type_id', value);
}
