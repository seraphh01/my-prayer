import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/audio_page_widget.dart';
import '/components/prayer_text_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'sections_view_widget.dart' show SectionsViewWidget;
import 'package:flutter/material.dart';

class SectionsViewModel extends FlutterFlowModel<SectionsViewWidget> {
  ///  Local state fields for this component.

  bool playingAudio = false;

  double? currentAudioTime = 0.0;

  List<PrayerSectionStruct> flattenedSections = [];
  void addToFlattenedSections(PrayerSectionStruct item) =>
      flattenedSections.add(item);
  void removeFromFlattenedSections(PrayerSectionStruct item) =>
      flattenedSections.remove(item);
  void removeAtIndexFromFlattenedSections(int index) =>
      flattenedSections.removeAt(index);
  void insertAtIndexInFlattenedSections(int index, PrayerSectionStruct item) =>
      flattenedSections.insert(index, item);
  void updateFlattenedSectionsAtIndex(
          int index, Function(PrayerSectionStruct) updateFn) =>
      flattenedSections[index] = updateFn(flattenedSections[index]);

  bool displayAudioPage = true;

  int? currentSectionIndex = 0;

  PrayerSectionStruct? currentSection;
  void updateCurrentSectionStruct(Function(PrayerSectionStruct) updateFn) {
    updateFn(currentSection ??= PrayerSectionStruct());
  }

  bool isLoading = true;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (PrayerSectionContent)] action in SectionsView widget.
  ApiCallResponse? prayerSectionInitialDataResult;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Stores action output result for [Backend Call - API (PrayerSectionContent)] action in PageView widget.
  ApiCallResponse? prayerSectionDataResult;
  // Models for PrayerText dynamic component.
  late FlutterFlowDynamicModels<PrayerTextModel> prayerTextModels;
  // Models for AudioPage dynamic component.
  late FlutterFlowDynamicModels<AudioPageModel> audioPageModels;

  @override
  void initState(BuildContext context) {
    prayerTextModels = FlutterFlowDynamicModels(() => PrayerTextModel());
    audioPageModels = FlutterFlowDynamicModels(() => AudioPageModel());
  }

  @override
  void dispose() {
    prayerTextModels.dispose();
    audioPageModels.dispose();
  }
}
