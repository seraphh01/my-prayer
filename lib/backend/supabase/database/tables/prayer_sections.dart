import '../database.dart';

class PrayerSectionsTable extends SupabaseTable<PrayerSectionsRow> {
  @override
  String get tableName => 'prayer_sections';

  @override
  PrayerSectionsRow createRow(Map<String, dynamic> data) =>
      PrayerSectionsRow(data);
}

class PrayerSectionsRow extends SupabaseDataRow {
  PrayerSectionsRow(super.data);

  @override
  SupabaseTable get table => PrayerSectionsTable();

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get prayerId => getField<String>('prayer_id');
  set prayerId(String? value) => setField<String>('prayer_id', value);

  int? get sequence => getField<int>('sequence');
  set sequence(int? value) => setField<int>('sequence', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get audioUrl => getField<String>('audio_url')!;
  set audioUrl(String value) => setField<String>('audio_url', value);

  String? get subtitle => getField<String>('subtitle');
  set subtitle(String? value) => setField<String>('subtitle', value);
}
