import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/load_prayer_data_from_file.dart';
import '/custom_code/actions/save_prayer_data.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Persists full prayer payloads on disk; keeps compact metadata in [FFAppState].
class DownloadedPrayerRepository {
  PrayerStruct compactMetadata(PrayerStruct prayer) {
    return PrayerStruct(
      id: prayer.id,
      title: prayer.title,
      subtitle: prayer.subtitle,
      mode: prayer.mode,
      sequence: prayer.sequence,
    );
  }

  Future<void> registerDownload(PrayerStruct prayer) async {
    await savePrayerData(prayer);
    FFAppState().addToDownloadedPrayers(compactMetadata(prayer));
  }

  Future<PrayerStruct?> loadFullPrayer(String prayerId) async {
    if (prayerId.isEmpty) {
      return null;
    }

    try {
      final fromFile = await loadPrayerDataFromFile(prayerId);
      if (fromFile != null) {
        return fromFile;
      }
    } catch (_) {}

    return FFAppState()
        .downloadedPrayers
        .cast<PrayerStruct?>()
        .firstWhere(
          (p) => p?.id == prayerId,
          orElse: () => null,
        );
  }

  /// Migrates legacy full-prayer secure-storage entries to on-disk files.
  Future<void> migrateLegacyEntriesIfNeeded(
    List<PrayerStruct> loadedPrayers,
  ) async {
    var migrated = false;
    final next = <PrayerStruct>[];

    for (final prayer in loadedPrayers) {
      if (prayer.sections.isNotEmpty) {
        await savePrayerData(prayer);
        next.add(compactMetadata(prayer));
        migrated = true;
      } else {
        next.add(prayer);
      }
    }

    if (migrated) {
      FFAppState().downloadedPrayers = next;
    }
  }
}
