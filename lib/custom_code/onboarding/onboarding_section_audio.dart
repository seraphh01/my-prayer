import 'package:audio_service/audio_service.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/audio/notifiers/play_button_notifier.dart';
import '/custom_code/audio/page_manager.dart';
import '/service_locator.dart';

class OnboardingAudioPreview {
  const OnboardingAudioPreview({
    required this.section,
    required this.title,
    required this.subtitle,
    required this.audioUrl,
    required this.imageUrl,
    required this.texts,
  });

  final PrayerSectionStruct section;
  final String title;
  final String subtitle;
  final String audioUrl;
  final String imageUrl;
  final List<SectionTextStruct> texts;

  bool get hasAudio => audioUrl.isNotEmpty;

  SectionTextStruct? get previewText =>
      texts.length > 1 ? texts[1] : (texts.isNotEmpty ? texts.first : null);
}

class OnboardingSectionAudio {
  OnboardingSectionAudio._();

  static const demoSectionId = 'd07ace76-84e4-4460-ac5e-04aa31ac6234';
  static const fallbackTitle = 'Primul mister din Rozariul de durere';

  static Future<OnboardingAudioPreview?> loadPreview(String sectionId) async {
    if (sectionId.isEmpty) {
      return null;
    }

    try {
      final response = await PrayerSectionContentCall.call(
        prayerSectionId: sectionId,
      );
      if (response.succeeded != true) {
        return null;
      }

      final section = PrayerSectionStruct.maybeFromMap(response.jsonBody ?? '');
      if (section == null) {
        return null;
      }

      final audioUrl = section.audioUrl.isNotEmpty
          ? section.audioUrl
          : (PrayerSectionContentCall.audioUrl(response.jsonBody) ?? '');

      final texts = section.texts.toList()
        ..sort((a, b) => a.sequence.compareTo(b.sequence));

      return OnboardingAudioPreview(
        section: section,
        title: section.title.isNotEmpty ? section.title : fallbackTitle,
        subtitle: section.subtitle,
        audioUrl: audioUrl,
        imageUrl: section.imageUrl,
        texts: texts,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> prepareQueue(OnboardingAudioPreview preview) async {
    if (!preview.hasAudio) {
      return false;
    }

    final pageManager = getIt<PageManager>();
    await stop();

    final section = preview.section;
    final mediaItem = MediaItem(
      id: section.id.isNotEmpty ? section.id : demoSectionId,
      album: preview.subtitle,
      artist: 'Rugăciuni și cântări',
      title: preview.title,
      artUri: Uri.parse(
        section.imageUrl.isNotEmpty
            ? section.imageUrl
            : 'https://nrapqjwyqvwopwoxevlw.supabase.co/storage/v1/object/public/images/logo_new.jpg',
      ),
      duration: section.duration > 0
          ? Duration(seconds: section.duration)
          : null,
      extras: {
        'url': preview.audioUrl,
        'isDownloaded': false,
        'filePath': '',
        'fallbackUrl': preview.audioUrl,
      },
    );

    pageManager.ensureQueueBeforePlay = null;
    await pageManager.setQueue([mediaItem]);
    return pageManager.hasActiveQueue;
  }

  static Future<void> togglePlayback() async {
    final pageManager = getIt<PageManager>();
    if (!pageManager.hasActiveQueue) {
      return;
    }

    if (pageManager.playButtonNotifier.value == ButtonState.playing) {
      pageManager.pause();
      return;
    }

    await pageManager.play();
  }

  static Future<void> stop() async {
    final pageManager = getIt<PageManager>();
    pageManager.ensureQueueBeforePlay = null;
    pageManager.pause();
    await pageManager.stop();
    if (pageManager.hasActiveQueue) {
      await pageManager.clearQueue();
    }
    pageManager.playButtonNotifier.value = ButtonState.paused;
  }
}
