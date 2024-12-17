import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  int dayOfWeek = 0;

  List<DateGroupStruct> dateGroups = [];
  void addToDateGroups(DateGroupStruct item) => dateGroups.add(item);
  void removeFromDateGroups(DateGroupStruct item) => dateGroups.remove(item);
  void removeAtIndexFromDateGroups(int index) => dateGroups.removeAt(index);
  void insertAtIndexInDateGroups(int index, DateGroupStruct item) =>
      dateGroups.insert(index, item);
  void updateDateGroupsAtIndex(int index, Function(DateGroupStruct) updateFn) =>
      dateGroups[index] = updateFn(dateGroups[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Get Prayers By Date Groups)] action in HomePage widget.
  ApiCallResponse? dateGroupsResponse;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
