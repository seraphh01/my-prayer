import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/filter_prayer_types.dart';
import '/custom_code/prayer/calendar_prayers_cache.dart';
import '/custom_code/prayer/prayer_types_cache.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:my_prayer/service_locator.dart';
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

  final _calendarCache = getIt<CalendarPrayersCache>();
  final _typesCache = getIt<PrayerTypesCache>();

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
    final selectedDate = DateTime(dateTime!.year, dateTime.month, dateTime.day);

    dateGroups = await _calendarCache.loadForDate(selectedDate);
    prayerTypesCatalog = await _typesCache.load();
  }

  List<PrayerTypeStruct> nestedTypesForDateGroup(DateGroupStruct group) {
    final prayerIds = group.prayers
        .map((prayer) => prayer.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    return filterPrayerTypesForCalendar(prayerTypesCatalog, prayerIds);
  }
}
