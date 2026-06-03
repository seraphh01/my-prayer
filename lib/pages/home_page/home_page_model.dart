import '/backend/api_requests/api_calls.dart';
import '/components/sub_types_view_widget.dart';
import '/custom_code/recommended_prayer_picker.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  Completer<ApiCallResponse>? apiRequestCompleter;
  Future<RecommendedPrayerResult?>? recommendedPrayerFuture;
  // Model for SubTypesView component.
  SubTypesViewModel? _subTypesViewModel;
  SubTypesViewModel get subTypesViewModel =>
      _subTypesViewModel ??= SubTypesViewModel();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    subTypesViewModel.dispose();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
