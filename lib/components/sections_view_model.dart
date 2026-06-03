import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/audio_page_widget.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'sections_view_widget.dart' show SectionsViewWidget;
import 'package:flutter/material.dart';

class SectionsViewModel extends FlutterFlowModel<SectionsViewWidget> {
  ///  Local state fields for this component.

  List<PrayerSectionStruct> flattenedSections = [];
  List<ChapterOptionStruct> chapterOptions = [];

  bool displayAudioPage = true;

  PrayerSectionStruct? currentSection;
  void updateCurrentSectionStruct(Function(PrayerSectionStruct) updateFn) {
    updateFn(currentSection ??= PrayerSectionStruct());
  }

  bool isLoading = true;

  ///  State fields for stateful widgets in this component.

  ApiCallResponse? prayerSectionDataResult;
  late FlutterFlowDynamicModels<AudioPageModel> audioPageModels;

  @override
  void initState(BuildContext context) {
    audioPageModels = FlutterFlowDynamicModels(() => AudioPageModel());
  }

  @override
  void dispose() {
    audioPageModels.dispose();
  }
}
