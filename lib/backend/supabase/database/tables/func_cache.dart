import '../database.dart';

class FuncCacheTable extends SupabaseTable<FuncCacheRow> {
  @override
  String get tableName => 'func_cache';

  @override
  FuncCacheRow createRow(Map<String, dynamic> data) => FuncCacheRow(data);
}

class FuncCacheRow extends SupabaseDataRow {
  FuncCacheRow(super.data);

  @override
  SupabaseTable get table => FuncCacheTable();

  String get cacheKey => getField<String>('cache_key')!;
  set cacheKey(String value) => setField<String>('cache_key', value);

  dynamic get value => getField<dynamic>('value');
  set value(dynamic value) => setField<dynamic>('value', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  dynamic get meta => getField<dynamic>('meta');
  set meta(dynamic value) => setField<dynamic>('meta', value);
}
