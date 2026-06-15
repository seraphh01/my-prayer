import '/components/sub_types_view_widget.dart';
import '/custom_code/calendar/merge_date_groups.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'calendar_page_model.dart';
export 'calendar_page_model.dart';

class CalendarPageWidget extends StatefulWidget {
  const CalendarPageWidget({super.key});

  @override
  State<CalendarPageWidget> createState() => _CalendarPageWidgetState();
}

class _CalendarPageWidgetState extends State<CalendarPageWidget> {
  late CalendarPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _model.setCurrentDate(
        context,
        dateTime: getCurrentTimestamp,
      );
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _openPrayer(BuildContext context, PrayerStruct prayer) {
    context.openPrayerWithHomeOnStack(prayer.id);
  }

  Widget _buildPrayerListTile(
    BuildContext context, {
    required PrayerStruct prayer,
    required String title,
    String? subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => _openPrayer(context, prayer),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              title: Text(
                title,
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Merriweather',
                      letterSpacing: 0.0,
                    ),
              ),
              subtitle: subtitle != null && subtitle.isNotEmpty
                  ? Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    )
                  : null,
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 16.0,
              ),
              dense: true,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                12.0,
                0.0,
                12.0,
                0.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Divider(
          height: 1.0,
          thickness: 1.0,
          color: FlutterFlowTheme.of(context).secondary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            iconTheme:
                IconThemeData(color: FlutterFlowTheme.of(context).alternate),
            automaticallyImplyLeading: true,
            title: Text(
              'Calendar',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: 'Merriweather',
                    color: FlutterFlowTheme.of(context).alternate,
                    letterSpacing: 0.0,
                  ),
            ),
            actions: const [],
            centerTitle: true,
            toolbarHeight: 64.0,
            elevation: 0.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlutterFlowCalendar(
                    color: FlutterFlowTheme.of(context).secondary,
                    iconColor: FlutterFlowTheme.of(context).primaryText,
                    weekFormat: false,
                    weekStartsMonday: true,
                    initialDate: DateTime.fromMillisecondsSinceEpoch(
                        getCurrentTimestamp.millisecondsSinceEpoch),
                    rowHeight: 48.0,
                    onChange: (DateTimeRange? newSelectedDate) async {
                      if (_model.calendarSelectedDay == newSelectedDate) {
                        return;
                      }
                      _model.calendarSelectedDay = newSelectedDate;
                      await _model.setCurrentDate(
                        context,
                        dateTime: _model.calendarSelectedDay?.start,
                      );
                      safeSetState(() {});
                    },
                    titleStyle:
                        FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Merriweather',
                              letterSpacing: 0.0,
                            ),
                    dayOfWeekStyle:
                        FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                    dateStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                    selectedDateStyle: FlutterFlowTheme.of(context)
                        .titleSmall
                        .override(
                          fontFamily: 'Merriweather',
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          letterSpacing: 0.0,
                        ),
                    inactiveDateStyle:
                        FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w100,
                            ),
                    locale: FFLocalizations.of(context).languageCode,
                  ),
                  if (_model.dateGroups.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        key: const PageStorageKey<String>('calendar_prayers_list'),
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        itemCount: _model.dateGroups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                        itemBuilder: (context, dateGroupIndex) {
                          final dateGroupItem = _model.dateGroups[dateGroupIndex];
                          final nestedPrayerTypes =
                              _model.nestedTypesForDateGroup(dateGroupItem);

                          if (dateGroupItem.prayers.isEmpty &&
                              nestedPrayerTypes.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (dateGroupItem.name.isNotEmpty)
                                Text(
                                  dateGroupItem.name,
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Merriweather',
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              if (dateGroupItem.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    dateGroupItem.description,
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              Divider(
                                height: 1.0,
                                thickness: 1.0,
                                color:
                                    FlutterFlowTheme.of(context).secondary,
                              ),
                              if (nestedPrayerTypes.isNotEmpty)
                                SubTypesViewWidget(
                                  prayerTypes: nestedPrayerTypes,
                                  onSelectPrayer: (prayerId) async {
                                    context.openPrayerWithHomeOnStack(
                                      prayerId,
                                    );
                                  },
                                )
                              else
                                ..._buildPrayerGroupTiles(context, dateGroupItem),
                            ],
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPrayerGroupTiles(
    BuildContext context,
    DateGroupStruct dateGroupItem,
  ) {
    final prayerGroups = groupPrayersByTitle(
      dateGroupItem.prayers
          .sortedList(
            keyOf: (e) => e.sequence,
            desc: false,
          )
          .toList(),
    );

    return prayerGroups.map((prayerGroup) {
      if (prayerGroup.prayers.length == 1) {
        final prayer = prayerGroup.prayers.first;
        return _buildPrayerListTile(
          context,
          prayer: prayer,
          title: prayer.title,
          subtitle: prayer.subtitle,
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              key: PageStorageKey<String>(
                'calendar_prayer_group_${prayerGroup.title.hashCode}_${prayerGroup.prayers.first.id}',
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
              childrenPadding: EdgeInsets.zero,
              title: Text(
                prayerGroup.title,
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Merriweather',
                      letterSpacing: 0.0,
                    ),
              ),
              children: prayerGroup.prayers
                  .map(
                    (prayer) => _buildPrayerListTile(
                      context,
                      prayer: prayer,
                      title: prayer.title.isNotEmpty
                          ? prayer.title
                          : prayer.subtitle,
                      subtitle:
                          prayer.title.isNotEmpty ? prayer.subtitle : null,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      );
    }).toList();
  }
}
