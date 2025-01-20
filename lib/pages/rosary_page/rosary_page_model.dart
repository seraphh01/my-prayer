import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/sections_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'rosary_page_widget.dart' show RosaryPageWidget;
import 'package:flutter/material.dart';

class RosaryPageModel extends FlutterFlowModel<RosaryPageWidget> {
  ///  Local state fields for this page.
  bool playingAudio = false;

  double? currentAudioTime;

  String? currentAudioUrl;

  PrayerStruct? currentPrayer;
  void updateCurrentPrayerStruct(Function(PrayerStruct) updateFn) {
    updateFn(currentPrayer ??= PrayerStruct());
  }

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Get prayer with sections recursive)] action in RosaryPage widget.
  ApiCallResponse? prayerResponse;
  // Stores action output result for [Bottom Sheet - PrayerOptions] action in IconButton widget.
  String? pressedButton;
  // Model for SectionsView component.
  late SectionsViewModel sectionsViewModel;

  @override
  void initState(BuildContext context) {
    sectionsViewModel = createModel(context, () => SectionsViewModel());
  }

  @override
  void dispose() {
    sectionsViewModel.dispose();
  }
}
