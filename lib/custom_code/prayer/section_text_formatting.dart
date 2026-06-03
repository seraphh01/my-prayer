import '/backend/schema/structs/index.dart';

String formatRepetitionPrefix(int repetition) {
  if (repetition <= 1) {
    return '';
  }
  return '$repetition ';
}

String previewFromTextElements(SectionTextStruct text) {
  final body = text.textElements
      .map((element) => element.text.trim())
      .where((elementText) => elementText.isNotEmpty)
      .join(' ');
  final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return '-';
  }
  final words = normalized.split(' ');
  final preview =
      words.length <= 3 ? words.join(' ') : words.take(3).join(' ');
  return '$preview...';
}

/// Title shown in text mode (includes repetition when title is set).
String formatSectionTextBlockTitle(SectionTextStruct text) {
  final prefix = formatRepetitionPrefix(text.repetition);
  if (text.title.isNotEmpty) {
    return '$prefix${text.title}';
  }
  final preview = previewFromTextElements(text);
  if (preview == '-') {
    return preview;
  }
  return '$prefix$preview';
}

/// Title shown on the audio page (repetition only when title exists).
String formatSectionTextDisplayTitle(SectionTextStruct text) {
  if (text.title.isNotEmpty) {
    return formatSectionTextBlockTitle(text);
  }
  final preview = previewFromTextElements(text);
  if (preview == '-') {
    return preview;
  }
  return '${formatRepetitionPrefix(text.repetition)}$preview';
}

int findActiveTextIndex(List<SectionTextStruct> texts, int audioTimeSeconds) {
  if (texts.isEmpty) {
    return -1;
  }

  var low = 0;
  var high = texts.length - 1;
  var result = -1;

  while (low <= high) {
    final mid = low + ((high - low) >> 1);
    final text = texts[mid];
    if (audioTimeSeconds < text.startTime) {
      high = mid - 1;
    } else if (audioTimeSeconds >= text.endTime) {
      low = mid + 1;
    } else {
      result = mid;
      break;
    }
  }

  return result;
}

int findActiveElementIndex(
  SectionTextStruct text,
  int audioTimeSeconds,
) {
  final elements = text.textElements;
  if (elements.isEmpty) {
    return -1;
  }

  final blockStart = text.startTime;
  for (var i = 0; i < elements.length; i++) {
    final element = elements[i];
    final start = blockStart + element.startTime;
    final end = blockStart + element.endTime;
    if (audioTimeSeconds >= start && audioTimeSeconds < end) {
      return i;
    }
  }
  return -1;
}

bool isTextBlockActive(SectionTextStruct text, int audioTimeSeconds) {
  return text.startTime <= audioTimeSeconds && audioTimeSeconds < text.endTime;
}

bool isElementPlaying({
  required SectionTextStruct text,
  required TextElementStruct element,
  required int audioTimeSeconds,
}) {
  final start = text.startTime + element.startTime;
  final end = text.startTime + element.endTime;
  return audioTimeSeconds >= start && audioTimeSeconds < end;
}

bool hasElementPassed({
  required SectionTextStruct text,
  required TextElementStruct element,
  required int audioTimeSeconds,
}) {
  return audioTimeSeconds >= text.startTime + element.endTime;
}
