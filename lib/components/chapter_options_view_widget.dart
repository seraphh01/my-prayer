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
  });

  final List<ChapterOptionStruct>? chapterOptions;
  final Future Function(int chosenChapter)? onChooseChapter;

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
    return Builder(
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
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: Column(
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
                        await widget.onChooseChapter?.call(
                          childOptionItem.index,
                        );
                      }
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(
                          childOptionItem.title.maybeHandleOverflow(
                            maxChars: 40,
                          ),
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        trailing: Icon(
                          Icons.arrow_right,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 16.0,
                        ),
                        tileColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
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
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_right,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 16.0,
                                          ),
                                          tileColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsetsDirectional.fromSTEB(
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
              ),
            );
          },
        );
      },
    );
  }
}
