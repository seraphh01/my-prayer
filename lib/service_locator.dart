import 'package:audio_service/audio_service.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';

import '../custom_code/audio/page_manager.dart';
import '../custom_code/audio/services/audio_handler.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<AudioHandler>(await initAudioService());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());

  getIt.registerLazySingleton<DownloadManager>(() => DownloadManager());
}
