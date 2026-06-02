import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/filter_prayer_types.dart';
import '/custom_code/calendar/merge_date_groups.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'calendar_page_widget.dart' show CalendarPageWidget;
import 'package:flutter/material.dart';

class CalendarPageModel extends FlutterFlowModel<CalendarPageWidget> {
  ///  Local state fields for this page.

  List<DateGroupStruct> dateGroups = [];
  List<PrayerTypeStruct> prayerTypesCatalog = [];
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

    final selectedDate = DateTime(dateTime!.year, dateTime.month, dateTime.day);

    dateGroupsResponseAfterSelectedDayCopy =
        await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
      dayOfWeek: selectedDate.weekday,
      month: selectedDate.month,
      day: selectedDate.day,
      specificDate: dateTimeFormat('yyyy-MM-dd', selectedDate),
      hour: -1,
    );

    if ((dateGroupsResponseAfterSelectedDayCopy.succeeded ?? true)) {
      final rawGroups = ((dateGroupsResponseAfterSelectedDayCopy.jsonBody ?? '')
              .toList()
              .map<DateGroupStruct?>(DateGroupStruct.maybeFromMap)
              .toList() as Iterable<DateGroupStruct?>)
          .withoutNulls
          .toList()
          .cast<DateGroupStruct>();
      dateGroups = mergeSimilarDateGroups(rawGroups);
    }

    await _ensurePrayerTypesCatalogLoaded();
  }

  Future<void> _ensurePrayerTypesCatalogLoaded() async {
    if (prayerTypesCatalog.isNotEmpty) {
      return;
    }

    final typesResponse =
        await SuapabaseQueriesGroup.getPrayerTypesCall.call();
    if ((typesResponse.succeeded ?? true) && typesResponse.jsonBody is List) {
      prayerTypesCatalog = (typesResponse.jsonBody as List)
          .map(PrayerTypeStruct.maybeFromMap)
          .whereType<PrayerTypeStruct>()
          .toList();
    }
  }

  List<PrayerTypeStruct> nestedTypesForDateGroup(DateGroupStruct group) {
    final prayerIds = group.prayers
        .map((prayer) => prayer.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    return filterPrayerTypesForCalendar(prayerTypesCatalog, prayerIds);
  }
}
