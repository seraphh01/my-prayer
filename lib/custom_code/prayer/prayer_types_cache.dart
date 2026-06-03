import 'dart:async';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';

class PrayerTypesCache {
  List<PrayerTypeStruct>? _cached;
  Future<List<PrayerTypeStruct>>? _inFlight;

  List<PrayerTypeStruct>? get cached => _cached;

  Future<List<PrayerTypeStruct>> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) {
      return _cached!;
    }

    if (!forceRefresh && _inFlight != null) {
      return _inFlight!;
    }

    final future = _fetch();
    _inFlight = future;
    try {
      return await future;
    } finally {
      _inFlight = null;
    }
  }

  void seed(List<PrayerTypeStruct> types) {
    _cached = List<PrayerTypeStruct>.from(types);
  }

  void invalidate() {
    _cached = null;
    _inFlight = null;
  }

  Future<List<PrayerTypeStruct>> _fetch() async {
    final response = await SuapabaseQueriesGroup.getPrayerTypesCall.call();
    if (!(response.succeeded ?? true) || response.jsonBody is! List) {
      return _cached ?? const [];
    }

    final types = (response.jsonBody as List)
        .map(PrayerTypeStruct.maybeFromMap)
        .whereType<PrayerTypeStruct>()
        .toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    _cached = types;
    return types;
  }
}
