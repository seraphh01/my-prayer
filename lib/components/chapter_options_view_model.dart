import '/components/chapter_options_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chapter_options_view_widget.dart' show ChapterOptionsViewWidget;
import 'package:flutter/material.dart';

class ChapterOptionsViewModel
    extends FlutterFlowModel<ChapterOptionsViewWidget> {
  ///  Local state fields for this component.

  String? currentExpandedType;

  ///  State fields for stateful widgets in this component.

  // Models for ChapterOptionsView dynamic component.
  FlutterFlowDynamicModels<ChapterOptionsViewModel>? _chapterOptionsViewModels;
  FlutterFlowDynamicModels<ChapterOptionsViewModel>
      get chapterOptionsViewModels => _chapterOptionsViewModels ??=
          FlutterFlowDynamicModels(() => ChapterOptionsViewModel());

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    chapterOptionsViewModels.dispose();
  }
}
