import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/chapter_options_view_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'choose_chapter_model.dart';
export 'choose_chapter_model.dart';

class ChooseChapterWidget extends StatefulWidget {
  const ChooseChapterWidget({
    super.key,
    required this.chapterOptions,
    int? currentChapterIndex,
  }) : currentChapterIndex = currentChapterIndex ?? 0;

  final List<ChapterOptionStruct>? chapterOptions;
  final int currentChapterIndex;

  @override
  State<ChooseChapterWidget> createState() => _ChooseChapterWidgetState();
}

class _ChooseChapterWidgetState extends State<ChooseChapterWidget> {
  late ChooseChapterModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChooseChapterModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.1,
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Mergi la secțiunea dorită',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Merriweather',
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.4,
                decoration: const BoxDecoration(),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    wrapWithModel(
                      model: _model.chapterOptionsViewModel,
                      updateCallback: () => safeSetState(() {}),
                      child: ChapterOptionsViewWidget(
                        chapterOptions: widget.chapterOptions!,
                        currentChapterIndex: widget.currentChapterIndex,
                        onChooseChapter: (chosenChapter) async {
                          Navigator.pop(context, chosenChapter);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
