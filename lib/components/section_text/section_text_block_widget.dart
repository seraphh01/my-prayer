import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/playback_highlight_state.dart';
import 'prayer_text_span.dart';
import 'prayer_text_styles.dart';
import 'section_text_title_row.dart';

class SectionTextBlockWidget extends StatefulWidget {
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
    this.initiallyExpanded = true,
    this.elementKeyFor,
  });

  final Key blockKey;
  final SectionTextStruct text;
  final int textIndex;
  final ValueListenable<PlaybackHighlightState> highlightListenable;
  final bool isAudioSynced;
  final VoidCallback onSeekBlock;
  final void Function(int elementStartTime) onSeekElement;
  final PrayerTextStyles styles;
  final bool initiallyExpanded;
  final GlobalKey? Function(int elementIndex)? elementKeyFor;

  @override
  State<SectionTextBlockWidget> createState() => _SectionTextBlockWidgetState();
}

class _SectionTextBlockWidgetState extends State<SectionTextBlockWidget> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isAudioSynced ? true : widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(SectionTextBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAudioSynced && !oldWidget.isAudioSynced) {
      _expanded = true;
    }
  }

  void _onTitleTap() {
    if (widget.isAudioSynced) {
      widget.onSeekBlock();
      return;
    }
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final showBody = widget.isAudioSynced || _expanded;

    return RepaintBoundary(
      key: widget.blockKey,
      child: Padding(
        padding: EdgeInsets.only(top: widget.text.title.isNotEmpty ? 8.0 : 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionTextTitleRow(
              text: widget.text,
              textIndex: widget.textIndex,
              highlightListenable: widget.highlightListenable,
              onTap: _onTitleTap,
              isManuallyExpandable: !widget.isAudioSynced,
              isExpanded: _expanded,
            ),
            if (showBody && widget.text.textElements.isNotEmpty)
              Column(
                spacing: 4.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var elementIndex = 0;
                      elementIndex < widget.text.textElements.length;
                      elementIndex++)
                    _SectionTextElementLine(
                      key: ValueKey(
                        'section_text_${widget.textIndex}_element_$elementIndex',
                      ),
                      elementKey: widget.elementKeyFor?.call(elementIndex),
                      text: widget.text,
                      textIndex: widget.textIndex,
                      element: widget.text.textElements[elementIndex],
                      elementIndex: elementIndex,
                      highlightListenable: widget.highlightListenable,
                      isAudioSynced: widget.isAudioSynced,
                      showDropCap:
                          widget.text.textElements[elementIndex].highlight ||
                              elementIndex == 0,
                      styles: widget.styles,
                      onSeekElement: widget.onSeekElement,
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
    this.elementKey,
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

  final GlobalKey? elementKey;
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

    return RepaintBoundary(
      key: widget.elementKey,
      child: PrayerTextSpan(
        text: widget.element.text,
        type: widget.element.type,
        quoteSource: widget.element.quoteSource,
        showDropCap: widget.showDropCap,
        isPlaying: isPlaying,
        hasPassed: hasPassed,
        isSynced: widget.isAudioSynced,
        styles: widget.styles,
        onPressed: () => widget.onSeekElement(widget.element.startTime),
      ),
    );
  }
}
