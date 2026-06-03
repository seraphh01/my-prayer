import 'package:auto_size_text/auto_size_text.dart';

import '/backend/schema/structs/index.dart';
import '/components/chapter_options_view_widget.dart';
import '/custom_code/prayer/prayer_typography.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class ChooseChapterWidget extends StatefulWidget {
  const ChooseChapterWidget({
    super.key,
    required this.chapterOptions,
    this.title,
    int? currentChapterIndex,
  }) : currentChapterIndex = currentChapterIndex ?? 0;

  final List<ChapterOptionStruct>? chapterOptions;
  final int currentChapterIndex;
  final String? title;

  @override
  State<ChooseChapterWidget> createState() => _ChooseChapterWidgetState();
}

class _ChooseChapterWidgetState extends State<ChooseChapterWidget> {
  @override
  Widget build(BuildContext context) {
    return PrayerTypographyScope(
      child: Material(
        color: Colors.transparent,
        elevation: 5.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height * 0.5,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Builder(
              builder: (context) {
                final typography = PrayerTypography.of(context);
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AutoSizeText(
                          widget.title ?? 'Mergi la secțiunea dorită',
                          style: typography.style(
                            FlutterFlowTheme.of(context).headlineSmall,
                            scaleFontSize: false,
                            letterSpacing: 0.0,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ChapterOptionsViewWidget(
                        chapterOptions: widget.chapterOptions!,
                        currentChapterIndex: widget.currentChapterIndex,
                        onChooseChapter: (chosenChapter) async {
                          Navigator.pop(context, chosenChapter);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
