import 'package:flutter/foundation.dart';

import '/backend/schema/structs/index.dart';
import 'section_text_formatting.dart' as fmt;

class PlaybackHighlightState {
  const PlaybackHighlightState({
    this.audioTimeSeconds = 0,
    this.activeTextIndex = -1,
    this.activeElementIndex = -1,
    this.isAudioSynced = false,
  });

  final int audioTimeSeconds;
  final int activeTextIndex;
  final int activeElementIndex;
  final bool isAudioSynced;

  static const idle = PlaybackHighlightState();

  bool isTextBlockActive(int textIndex) =>
      isAudioSynced && activeTextIndex == textIndex;

  bool isElementPlayingAt({
    required int textIndex,
    required SectionTextStruct text,
    required TextElementStruct element,
  }) {
    if (!isTextBlockActive(textIndex)) {
      return false;
    }
    return fmt.isElementPlaying(
      text: text,
      element: element,
      audioTimeSeconds: audioTimeSeconds,
    );
  }

  bool hasElementPassedAt({
    required SectionTextStruct text,
    required TextElementStruct element,
  }) {
    if (!isAudioSynced) {
      return false;
    }
    return fmt.hasElementPassed(
      text: text,
      element: element,
      audioTimeSeconds: audioTimeSeconds,
    );
  }

  PlaybackHighlightState copyWith({
    int? audioTimeSeconds,
    int? activeTextIndex,
    int? activeElementIndex,
    bool? isAudioSynced,
  }) {
    return PlaybackHighlightState(
      audioTimeSeconds: audioTimeSeconds ?? this.audioTimeSeconds,
      activeTextIndex: activeTextIndex ?? this.activeTextIndex,
      activeElementIndex: activeElementIndex ?? this.activeElementIndex,
      isAudioSynced: isAudioSynced ?? this.isAudioSynced,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlaybackHighlightState &&
        other.audioTimeSeconds == audioTimeSeconds &&
        other.activeTextIndex == activeTextIndex &&
        other.activeElementIndex == activeElementIndex &&
        other.isAudioSynced == isAudioSynced;
  }

  @override
  int get hashCode => Object.hash(
        audioTimeSeconds,
        activeTextIndex,
        activeElementIndex,
        isAudioSynced,
      );
}

class PlaybackHighlightNotifier extends ValueNotifier<PlaybackHighlightState> {
  PlaybackHighlightNotifier() : super(PlaybackHighlightState.idle);

  void updateFromTexts({
    required List<SectionTextStruct> texts,
    required int audioTimeSeconds,
    required bool isAudioSynced,
  }) {
    if (!isAudioSynced || texts.isEmpty) {
      final next = PlaybackHighlightState(
        audioTimeSeconds: audioTimeSeconds,
        isAudioSynced: false,
      );
      if (next != value) {
        value = next;
      }
      return;
    }

    final textIndex = fmt.findActiveTextIndex(texts, audioTimeSeconds);
    final elementIndex = textIndex >= 0
        ? fmt.findActiveElementIndex(texts[textIndex], audioTimeSeconds)
        : -1;

    final next = PlaybackHighlightState(
      audioTimeSeconds: audioTimeSeconds,
      activeTextIndex: textIndex,
      activeElementIndex: elementIndex,
      isAudioSynced: true,
    );
    if (next != value) {
      value = next;
    }
  }

  void reset() {
    if (value != PlaybackHighlightState.idle) {
      value = PlaybackHighlightState.idle;
    }
  }
}
