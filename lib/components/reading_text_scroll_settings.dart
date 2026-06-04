import '/app_state.dart';
import '/components/reading_anchor_picker.dart';
import '/components/text_auto_scroll_toggle.dart';
import 'package:flutter/material.dart';

class ReadingTextScrollSettings extends StatelessWidget {
  const ReadingTextScrollSettings({
    super.key,
    this.showTitle = false,
    this.showHint = false,
    this.compact = false,
  });

  final bool showTitle;
  final bool showHint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FFAppState(),
      builder: (context, _) {
        final autoScrollEnabled = FFAppState().textAutoScrollEnabled;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextAutoScrollToggle(compact: compact),
            if (autoScrollEnabled)
              ReadingAnchorPicker(
                showTitle: showTitle,
                showHint: showHint,
                compact: compact,
              ),
          ],
        );
      },
    );
  }
}
