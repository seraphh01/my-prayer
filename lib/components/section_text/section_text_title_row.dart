import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/playback_highlight_state.dart';
import '/custom_code/prayer/section_text_formatting.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'prayer_text_styles.dart';

class SectionTextTitleRow extends StatefulWidget {
  const SectionTextTitleRow({
    super.key,
    required this.text,
    required this.textIndex,
    required this.highlightListenable,
    required this.onTap,
    this.isManuallyExpandable = false,
    this.isExpanded = true,
  });

  final SectionTextStruct text;
  final int textIndex;
  final ValueListenable<PlaybackHighlightState> highlightListenable;
  final VoidCallback onTap;
  final bool isManuallyExpandable;
  final bool isExpanded;

  @override
  State<SectionTextTitleRow> createState() => _SectionTextTitleRowState();
}

class _SectionTextTitleRowState extends State<SectionTextTitleRow> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    widget.highlightListenable.addListener(_onHighlightChanged);
    _syncActiveState(widget.highlightListenable.value);
  }

  @override
  void didUpdateWidget(SectionTextTitleRow oldWidget) {
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
    if (nextActive != _isActive) {
      setState(() => _isActive = nextActive);
    } else if (_isActive) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.title.isEmpty) {
      return const SizedBox.shrink();
    }

    final titleStyles =
        SectionTitleStyles.of(context, italic: widget.text.italic);
    final theme = FlutterFlowTheme.of(context);
    final title = formatSectionTextBlockTitle(widget.text);

    return Align(
      alignment: AlignmentDirectional.center,
      child: Semantics(
        button: true,
        label: title,
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: widget.onTap,
          child: Row(
            spacing: 4.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isManuallyExpandable)
                Icon(
                  widget.isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: theme.secondary,
                  size: 20.0,
                )
              else if (_isActive)
                Icon(
                  Icons.chevron_right,
                  color: theme.secondary,
                  size: 16.0,
                ),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: _isActive ? titleStyles.active : titleStyles.inactive,
                ),
              ),
              if (!widget.isManuallyExpandable && _isActive)
                Icon(
                  Icons.chevron_left,
                  color: theme.secondary,
                  size: 16.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
