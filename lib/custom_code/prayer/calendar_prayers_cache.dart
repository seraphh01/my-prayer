import 'dart:async';

import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';

class CalendarPrayersCache {
  final Map<String, List<DateGroupStruct>> _cache = {};
  final Map<String, Future<List<DateGroupStruct>>> _inFlight = {};

  String _key({
    required DateTime date,
    required int dayOfWeek,
    required int month,
    required int day,
    required String specificDate,
  }) =>
      '$specificDate|$dayOfWeek|$month|$day';

  List<DateGroupStruct>? getCached(DateTime date) {
    final key = _key(
      date: date,
      dayOfWeek: date.weekday,
      month: date.month,
      day: date.day,
      specificDate: _formatDate(date),
    );
    return _cache[key];
  }

  Future<List<DateGroupStruct>> loadForDate(DateTime dateTime) async {
    final normalized = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final key = _key(
      date: normalized,
      dayOfWeek: normalized.weekday,
      month: normalized.month,
      day: normalized.day,
      specificDate: _formatDate(normalized),
    );

    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final existing = _inFlight[key];
    if (existing != null) {
      return existing;
    }

    final future = _fetch(normalized, key);
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  void invalidate() {
    _cache.clear();
    _inFlight.clear();
  }

  Future<List<DateGroupStruct>> _fetch(DateTime date, String key) async {
    final merged = await fetchCalendarPrayersForDate(date);
    _cache[key] = merged;
    return merged;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
