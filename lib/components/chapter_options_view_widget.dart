import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/prayer_typography.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class ChapterOptionsViewWidget extends StatefulWidget {
  const ChapterOptionsViewWidget({
    super.key,
    required this.chapterOptions,
    required this.onChooseChapter,
    int? currentChapterIndex,
  }) : currentChapterIndex = currentChapterIndex ?? 0;

  final List<ChapterOptionStruct>? chapterOptions;
  final Future Function(int chosenChapter)? onChooseChapter;
  final int currentChapterIndex;

  @override
  State<ChapterOptionsViewWidget> createState() =>
      _ChapterOptionsViewWidgetState();
}

class _ChapterOptionsViewWidgetState extends State<ChapterOptionsViewWidget> {
  String? _expandedTitle;

  @override
  Widget build(BuildContext context) {
    final typography = PrayerTypography.of(context);
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: widget.chapterOptions!.length,
        itemBuilder: (context, childOptionIndex) {
          final childOptionItem = widget.chapterOptions![childOptionIndex];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (childOptionItem.childOptions.isNotEmpty) {
                    setState(() {
                      _expandedTitle = _expandedTitle == childOptionItem.title
                          ? null
                          : childOptionItem.title;
                    });
                  } else if (childOptionItem.index !=
                      widget.currentChapterIndex) {
                    await widget.onChooseChapter?.call(childOptionItem.index);
                  }
                },
                onLongPress: () async {
                  await widget.onChooseChapter?.call(childOptionItem.index);
                },
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(
                      childOptionItem.title.maybeHandleOverflow(
                        maxChars: 40,
                      ),
                      style: typography.style(
                        theme.labelMedium,
                        scaleFontSize: false,
                        color: valueOrDefault<Color>(
                          (childOptionItem.index != null) &&
                                  (widget.currentChapterIndex ==
                                      childOptionItem.index)
                              ? theme.alternate
                              : theme.primaryText,
                          theme.primaryText,
                        ),
                        letterSpacing: 0.0,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_right,
                      color: valueOrDefault<Color>(
                        (childOptionItem.index != null) &&
                                (widget.currentChapterIndex ==
                                    childOptionItem.index)
                            ? FlutterFlowTheme.of(context).primary
                            : FlutterFlowTheme.of(context).primaryText,
                        FlutterFlowTheme.of(context).secondaryText,
                      ),
                      size: 16.0,
                    ),
                    tileColor: valueOrDefault<Color>(
                      (childOptionItem.index != null) &&
                              (widget.currentChapterIndex ==
                                  childOptionItem.index)
                          ? FlutterFlowTheme.of(context).primary
                          : const Color(0x00FFFFFF),
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    dense: true,
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      12.0,
                      0.0,
                      12.0,
                      0.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              if (childOptionItem.title == _expandedTitle)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (childOptionItem.childOptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          8.0,
                          0.0,
                          0.0,
                          0.0,
                        ),
                        child: Column(
                          children: [
                            for (final leafOption in childOptionItem
                                .childOptions
                                .where((e) => e.childOptions.isEmpty))
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await widget.onChooseChapter?.call(
                                    valueOrDefault<int>(
                                      leafOption.index,
                                      0,
                                    ),
                                  );
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      leafOption.title,
                                      style: typography.style(
                                        theme.labelMedium,
                                        scaleFontSize: false,
                                        color: theme.primaryText,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_right,
                                      color: (leafOption.index != null) &&
                                              (widget.currentChapterIndex ==
                                                  valueOrDefault<int>(
                                                    leafOption.index,
                                                    0,
                                                  ))
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context)
                                              .primaryText,
                                      size: 16.0,
                                    ),
                                    tileColor: (leafOption.index != null) &&
                                            (widget.currentChapterIndex ==
                                                leafOption.index)
                                        ? FlutterFlowTheme.of(context).primary
                                        : const Color(0x00FFFFFF),
                                    dense: true,
                                    contentPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                      12.0,
                                      0.0,
                                      12.0,
                                      0.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (childOptionItem.childOptions
                        .any((e) => e.childOptions.isNotEmpty))
                      ChapterOptionsViewWidget(
                        key: Key('Key3ij_${childOptionItem.title}'),
                        chapterOptions: childOptionItem.childOptions
                            .where((e) => e.childOptions.isNotEmpty)
                            .toList(),
                        currentChapterIndex: widget.currentChapterIndex,
                        onChooseChapter: widget.onChooseChapter,
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
