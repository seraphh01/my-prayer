import '/backend/schema/structs/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;

(String title, String? subtitle) prayerCardTitleAndSubtitle(
    PrayerStruct prayer) {
  final cardTitle = prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;
  final cardSubtitle = prayer.title.isNotEmpty &&
          prayer.subtitle.isNotEmpty &&
          prayer.subtitle != cardTitle
      ? prayer.subtitle
      : null;
  return (cardTitle, cardSubtitle);
}

PrayerSectionStruct? savedPrayerSection(SavedPrayerDataStruct saved) {
  final prayer = saved.prayer;
  if (prayer == null || prayer.sections.isEmpty) {
    return null;
  }

  final flattened = functions.flattenSectionsList(prayer.sections.toList());
  if (flattened == null || flattened.isEmpty) {
    return null;
  }

  final index = saved.page.clamp(0, flattened.length - 1);
  return flattened[index];
}

(String prayerTitle, String? sectionTitle, String? sectionImageUrl)
    savedPrayerCardContent(SavedPrayerDataStruct saved) {
  final prayer = saved.prayer;
  if (prayer == null) {
    return ('', null, null);
  }

  final prayerTitle = prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;
  final section = savedPrayerSection(saved);
  final sectionTitle =
      section != null && section.title.isNotEmpty ? section.title : null;
  final sectionImageUrl =
      section != null && section.imageUrl.isNotEmpty ? section.imageUrl : null;

  return (prayerTitle, sectionTitle, sectionImageUrl);
}
