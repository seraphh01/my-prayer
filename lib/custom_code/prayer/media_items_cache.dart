import 'package:audio_service/audio_service.dart';

class MediaItemsCache {
  final Map<String, List<MediaItem>> _cache = {};

  String _key(String prayerId, int sectionCount) => '$prayerId|$sectionCount';

  List<MediaItem>? get(String prayerId, int sectionCount) =>
      _cache[_key(prayerId, sectionCount)];

  void put(String prayerId, int sectionCount, List<MediaItem> items) {
    _cache[_key(prayerId, sectionCount)] = List<MediaItem>.from(items);
  }

  void invalidatePrayer(String prayerId) {
    _cache.removeWhere((key, _) => key.startsWith('$prayerId|'));
  }

  void clear() => _cache.clear();
}
