import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'calendar_page_widget.dart' show CalendarPageWidget;
import 'package:flutter/material.dart';

class CalendarPageModel extends FlutterFlowModel<CalendarPageWidget> {
  ///  Local state fields for this page.

  List<DateGroupStruct> dateGroups = [];
  void addToDateGroups(DateGroupStruct item) => dateGroups.add(item);
  void removeFromDateGroups(DateGroupStruct item) => dateGroups.remove(item);
  void removeAtIndexFromDateGroups(int index) => dateGroups.removeAt(index);
  void insertAtIndexInDateGroups(int index, DateGroupStruct item) =>
      dateGroups.insert(index, item);
  void updateDateGroupsAtIndex(int index, Function(DateGroupStruct) updateFn) =>
      dateGroups[index] = updateFn(dateGroups[index]);

  ///  State fields for stateful widgets in this page.

  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {}

  /// Action blocks.
  Future setCurrentDate(
    BuildContext context, {
    required DateTime? dateTime,
  }) async {
    ApiCallResponse? dateGroupsResponseAfterSelectedDayCopy;

    dateGroupsResponseAfterSelectedDayCopy =
        await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
      dayOfWeek: valueOrDefault<int>(
        DateTime.fromMillisecondsSinceEpoch(dateTime!.millisecondsSinceEpoch)
            .weekday,
        0,
      ),
    );

    if ((dateGroupsResponseAfterSelectedDayCopy.succeeded ?? true)) {
      dateGroups = ((dateGroupsResponseAfterSelectedDayCopy.jsonBody ?? '')
              .toList()
              .map<DateGroupStruct?>(DateGroupStruct.maybeFromMap)
              .toList() as Iterable<DateGroupStruct?>)
          .withoutNulls
          .toList()
          .cast<DateGroupStruct>();
    }
  }
}
