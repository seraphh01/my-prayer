import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/playback_highlight_state.dart';
import 'prayer_text_span.dart';
import 'prayer_text_styles.dart';
import 'section_text_title_row.dart';

class SectionTextBlockWidget extends StatelessWidget {
  const SectionTextBlockWidget({
    super.key,
    required this.blockKey,
    required this.text,
    required this.textIndex,
    required this.highlightListenable,
    required this.isAudioSynced,
    required this.onSeekBlock,
    required this.onSeekElement,
    required this.styles,
  });

  final Key blockKey;
  final SectionTextStruct text;
  final int textIndex;
  final ValueListenable<PlaybackHighlightState> highlightListenable;
  final bool isAudioSynced;
  final VoidCallback onSeekBlock;
  final void Function(int elementStartTime) onSeekElement;
  final PrayerTextStyles styles;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: blockKey,
      child: Padding(
        padding: EdgeInsets.only(top: text.title.isNotEmpty ? 8.0 : 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionTextTitleRow(
              text: text,
              textIndex: textIndex,
              highlightListenable: highlightListenable,
              onSeek: onSeekBlock,
            ),
            if (text.textElements.isNotEmpty)
              Column(
                spacing: 4.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var elementIndex = 0;
                      elementIndex < text.textElements.length;
                      elementIndex++)
                    _SectionTextElementLine(
                      key: ValueKey(
                        'section_text_${textIndex}_element_$elementIndex',
                      ),
                      text: text,
                      textIndex: textIndex,
                      element: text.textElements[elementIndex],
                      elementIndex: elementIndex,
                      highlightListenable: highlightListenable,
                      isAudioSynced: isAudioSynced,
                      showDropCap: text.textElements[elementIndex].highlight ||
                          elementIndex == 0,
                      styles: styles,
                      onSeekElement: onSeekElement,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTextElementLine extends StatefulWidget {
  const _SectionTextElementLine({
    super.key,
    required this.text,
    required this.textIndex,
    required this.element,
    required this.elementIndex,
    required this.highlightListenable,
    required this.isAudioSynced,
    required this.showDropCap,
    required this.styles,
    required this.onSeekElement,
  });

  final SectionTextStruct text;
  final int textIndex;
  final TextElementStruct element;
  final int elementIndex;
  final ValueListenable<PlaybackHighlightState> highlightListenable;
  final bool isAudioSynced;
  final bool showDropCap;
  final PrayerTextStyles styles;
  final void Function(int elementStartTime) onSeekElement;

  @override
  State<_SectionTextElementLine> createState() =>
      _SectionTextElementLineState();
}

class _SectionTextElementLineState extends State<_SectionTextElementLine> {
  bool _isActiveBlock = false;

  @override
  void initState() {
    super.initState();
    widget.highlightListenable.addListener(_onHighlightChanged);
    _syncActiveState(widget.highlightListenable.value);
  }

  @override
  void didUpdateWidget(_SectionTextElementLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightListenable != widget.highlightListenable) {
      oldWidget.highlightListenable.removeListener(_onHighlightChanged);
      widget.highlightListenable.addListener(_onHighlightChanged);
      _syncActiveState(widget.highlightListenable.value);
    }
  }

  @override
  void dispose() {
    widget.highlightListenable.removeListener(_onHighlightChanged);
    super.dispose();
  }

  void _onHighlightChanged() {
    _syncActiveState(widget.highlightListenable.value);
  }

  void _syncActiveState(PlaybackHighlightState highlight) {
    final nextActive = highlight.isTextBlockActive(widget.textIndex);
    if (nextActive != _isActiveBlock) {
      setState(() => _isActiveBlock = nextActive);
    } else if (_isActiveBlock) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlight = widget.highlightListenable.value;
    final isPlaying = _isActiveBlock &&
        highlight.isElementPlayingAt(
          textIndex: widget.textIndex,
          text: widget.text,
          element: widget.element,
        );
    final hasPassed = highlight.hasElementPassedAt(
      text: widget.text,
      element: widget.element,
    );

    return PrayerTextSpan(
      text: widget.element.text,
      type: widget.element.type,
      quoteSource: widget.element.quoteSource,
      showDropCap: widget.showDropCap,
      isPlaying: isPlaying,
      hasPassed: hasPassed,
      isSynced: widget.isAudioSynced,
      styles: widget.styles,
      onPressed: () => widget.onSeekElement(widget.element.startTime),
    );
  }
}
