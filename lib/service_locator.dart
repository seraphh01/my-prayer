import 'package:audio_service/audio_service.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';

import '../custom_code/audio/page_manager.dart';
import '../custom_code/audio/services/audio_handler.dart';
import '../custom_code/prayer/calendar_prayers_cache.dart';
import '../custom_code/prayer/downloaded_prayer_repository.dart';
import '../custom_code/prayer/media_items_cache.dart';
import '../custom_code/prayer/prayer_section_content_cache.dart';
import '../custom_code/prayer/prayer_content_cache.dart';
import '../custom_code/prayer/prayer_types_cache.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<AudioHandler>(await initAudioService());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());

  getIt.registerLazySingleton<DownloadManager>(() => DownloadManager());
  getIt.registerLazySingleton<PrayerSectionContentCache>(
    () => PrayerSectionContentCache(),
  );
  getIt.registerLazySingleton<PrayerContentCache>(() => PrayerContentCache());
  getIt.registerLazySingleton<PrayerTypesCache>(() => PrayerTypesCache());
  getIt.registerLazySingleton<CalendarPrayersCache>(
    () => CalendarPrayersCache(),
  );
  getIt.registerLazySingleton<MediaItemsCache>(() => MediaItemsCache());
  getIt.registerLazySingleton<DownloadedPrayerRepository>(
    () => DownloadedPrayerRepository(),
  );
}
