import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'sections_view_widget.dart' show SectionsViewWidget;
import 'package:flutter/material.dart';

class SectionsViewModel extends FlutterFlowModel<SectionsViewWidget> {
  ///  Local state fields for this component.

  String? currentAudioUrl;

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

  ///  State fields for stateful widgets in this component.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
