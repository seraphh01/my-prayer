import 'dart:async';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';

class PrayerContentCache {
  final Map<String, PrayerStruct> _cache = {};
  final Map<String, Future<PrayerStruct?>> _inFlight = {};

  bool hasCachedPrayer(String prayerId) =>
      prayerId.isNotEmpty && _cache.containsKey(prayerId);

  PrayerStruct? cachedPrayer(String prayerId) => _cache[prayerId];

  void seed(String prayerId, PrayerStruct prayer) {
    if (prayerId.isEmpty) {
      return;
    }
    _cache[prayerId] = prayer;
  }

  Future<PrayerStruct?> loadPrayer(String prayerId) async {
    if (prayerId.isEmpty) {
      return null;
    }

    final cached = _cache[prayerId];
    if (cached != null) {
      return cached;
    }

    final existing = _inFlight[prayerId];
    if (existing != null) {
      return existing;
    }

    final future = _fetchPrayer(prayerId);
    _inFlight[prayerId] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(prayerId);
    }
  }

  void prefetch(String prayerId) {
    if (prayerId.isEmpty || _cache.containsKey(prayerId)) {
      return;
    }
    unawaited(loadPrayer(prayerId));
  }

  Future<PrayerStruct?> _fetchPrayer(String prayerId) async {
    final response =
        await SuapabaseQueriesGroup.getPrayerWithSectionsRecursiveCall.call(
      requestPrayerId: prayerId,
    );

    if (!(response.succeeded ?? true)) {
      return null;
    }

    final prayer = PrayerStruct.maybeFromMap(response.jsonBody ?? '');
    if (prayer != null) {
      _cache[prayerId] = prayer;
    }
    return prayer;
  }
}
