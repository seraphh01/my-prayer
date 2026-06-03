import 'dart:async';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';

class PrayerSectionContentCache {
  final Map<String, List<SectionTextStruct>> _cache = {};
  final Map<String, Future<List<SectionTextStruct>>> _inFlight = {};

  bool hasCachedTexts(String sectionId) =>
      sectionId.isNotEmpty && _cache.containsKey(sectionId);

  List<SectionTextStruct>? cachedTexts(String sectionId) => _cache[sectionId];

  void seed(String sectionId, List<SectionTextStruct> texts) {
    if (sectionId.isEmpty) {
      return;
    }
    _cache[sectionId] = texts;
  }

  Future<List<SectionTextStruct>> loadTexts(String sectionId) async {
    if (sectionId.isEmpty) {
      return const [];
    }

    final cached = _cache[sectionId];
    if (cached != null) {
      return cached;
    }

    final existing = _inFlight[sectionId];
    if (existing != null) {
      return existing;
    }

    final future = _fetchTexts(sectionId);
    _inFlight[sectionId] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(sectionId);
    }
  }

  void prefetch(String sectionId) {
    if (sectionId.isEmpty || _cache.containsKey(sectionId)) {
      return;
    }
    unawaited(loadTexts(sectionId));
  }

  void prefetchAdjacent(List<PrayerSectionStruct> sections, int index) {
    if (index > 0) {
      prefetch(sections[index - 1].sectionId);
    }
    if (index + 1 < sections.length) {
      prefetch(sections[index + 1].sectionId);
    }
  }

  Future<List<SectionTextStruct>> _fetchTexts(String sectionId) async {
    final response = await PrayerSectionContentCall.call(
      prayerSectionId: sectionId,
    );

    if (!(response.succeeded ?? true)) {
      return const [];
    }

    final section = PrayerSectionStruct.maybeFromMap(response.jsonBody ?? '');
    final texts = section?.texts ?? const [];
    _cache[sectionId] = texts;
    return texts;
  }
}
