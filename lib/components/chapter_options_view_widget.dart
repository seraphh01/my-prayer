import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'chapter_options_view_model.dart';
export 'chapter_options_view_model.dart';

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
  late ChapterOptionsViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChapterOptionsViewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
      child: Builder(
        builder: (context) {
          final childOption = widget.chapterOptions!.toList();

          return ListView.builder(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: childOption.length,
            itemBuilder: (context, childOptionIndex) {
              final childOptionItem = childOption[childOptionIndex];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if ((childOptionItem.childOptions.isNotEmpty) == true) {
                        if (_model.currentExpandedType ==
                            childOptionItem.title) {
                          _model.currentExpandedType = null;
                          safeSetState(() {});
                        } else {
                          _model.currentExpandedType = childOptionItem.title;
                          safeSetState(() {});
                        }
                      } else {
                        if (childOptionItem.index !=
                            widget.currentChapterIndex) {
                          await widget.onChooseChapter?.call(
                            childOptionItem.index,
                          );
                        }
                      }
                    },
                    onLongPress: () async {
                      await widget.onChooseChapter?.call(
                        childOptionItem.index,
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(
                          childOptionItem.title.maybeHandleOverflow(
                            maxChars: 40,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                fontFamily: 'Inter',
                                color: valueOrDefault<Color>(
                                  (childOptionItem.index != null) &&
                                          (widget.currentChapterIndex ==
                                              childOptionItem.index)
                                      ? FlutterFlowTheme.of(context).alternate
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  FlutterFlowTheme.of(context).primaryText,
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
                            12.0, 0.0, 12.0, 0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  if (childOptionItem.title == _model.currentExpandedType)
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (childOptionItem.childOptions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final fianlOptions = childOptionItem
                                    .childOptions
                                    .where((e) =>
                                        (e.childOptions.isNotEmpty) == false)
                                    .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: fianlOptions.length,
                                  itemBuilder: (context, fianlOptionsIndex) {
                                    final fianlOptionsItem =
                                        fianlOptions[fianlOptionsIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await widget.onChooseChapter?.call(
                                          valueOrDefault<int>(
                                            fianlOptionsItem.index,
                                            0,
                                          ),
                                        );
                                      },
                                      child: Material(
                                        color: Colors.transparent,
                                        child: ListTile(
                                          title: Text(
                                            fianlOptionsItem.title,
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_right,
                                            color: (fianlOptionsItem.index !=
                                                        null) &&
                                                    (widget
                                                            .currentChapterIndex ==
                                                        valueOrDefault<int>(
                                                          fianlOptionsItem
                                                              .index,
                                                          0,
                                                        ))
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            size: 16.0,
                                          ),
                                          tileColor: (fianlOptionsItem.index !=
                                                      null) &&
                                                  (widget.currentChapterIndex ==
                                                      fianlOptionsItem.index)
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : const Color(0x00FFFFFF),
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                  12.0, 0.0, 12.0, 0.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        if (childOptionItem.childOptions
                            .where((e) => e.childOptions.isNotEmpty)
                            .toList()
                            .isNotEmpty)
                          wrapWithModel(
                            model: _model.chapterOptionsViewModels.getModel(
                              childOptionItem.title,
                              childOptionIndex,
                            ),
                            updateCallback: () => safeSetState(() {}),
                            child: ChapterOptionsViewWidget(
                              key: Key(
                                'Key3ij_${childOptionItem.title}',
                              ),
                              chapterOptions: childOptionItem.childOptions,
                              currentChapterIndex: widget.currentChapterIndex,
                              onChooseChapter: (chosenChapter) async {
                                await widget.onChooseChapter?.call(
                                  chosenChapter,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
