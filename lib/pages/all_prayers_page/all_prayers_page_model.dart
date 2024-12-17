import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/sub_types_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'all_prayers_page_widget.dart' show AllPrayersPageWidget;
import 'dart:async';
import 'package:flutter/material.dart';

class AllPrayersPageModel extends FlutterFlowModel<AllPrayersPageWidget> {
  ///  Local state fields for this page.

  List<PrayerTypeStruct> prayerTypes = [];
  void addToPrayerTypes(PrayerTypeStruct item) => prayerTypes.add(item);
  void removeFromPrayerTypes(PrayerTypeStruct item) => prayerTypes.remove(item);
  void removeAtIndexFromPrayerTypes(int index) => prayerTypes.removeAt(index);
  void insertAtIndexInPrayerTypes(int index, PrayerTypeStruct item) =>
      prayerTypes.insert(index, item);
  void updatePrayerTypesAtIndex(
          int index, Function(PrayerTypeStruct) updateFn) =>
      prayerTypes[index] = updateFn(prayerTypes[index]);

  ///  State fields for stateful widgets in this page.

  Completer<ApiCallResponse>? apiRequestCompleter;
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
