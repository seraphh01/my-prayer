import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({
    super.key,
    bool? hasNavigatedHere,
  }) : hasNavigatedHere = hasNavigatedHere ?? false;

  final bool hasNavigatedHere;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.dayOfWeek = valueOrDefault<int>(
        DateTime.fromMillisecondsSinceEpoch(
                getCurrentTimestamp.millisecondsSinceEpoch)
            .weekday,
        0,
      );
      _model.dateGroupsResponse =
          await SuapabaseQueriesGroup.getPrayersByDateGroupsCall.call(
        dayOfWeek: _model.dayOfWeek,
      );

      if ((_model.dateGroupsResponse?.succeeded ?? true)) {
        _model.dateGroups = ((_model.dateGroupsResponse?.jsonBody ?? '')
                .toList()
                .map<DateGroupStruct?>(DateGroupStruct.maybeFromMap)
                .toList() as Iterable<DateGroupStruct?>)
            .withoutNulls
            .toList()
            .cast<DateGroupStruct>();
        safeSetState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            iconTheme:
                IconThemeData(color: FlutterFlowTheme.of(context).alternate),
            automaticallyImplyLeading: true,
            actions: [
              Align(
                alignment: const AlignmentDirectional(1.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 48.0,
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: FlutterFlowTheme.of(context).alternate,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.pushNamed(
                          'CalendarPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 250),
                            ),
                          },
                        );
                      },
                    ),
                    FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 48.0,
                      icon: Icon(
                        Icons.download_rounded,
                        color: FlutterFlowTheme.of(context).alternate,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.pushNamed(
                          'DownloadedPrayersPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 250),
                            ),
                          },
                        );
                      },
                    ),
                    FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 48.0,
                      disabledIconColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      icon: Icon(
                        Icons.favorite_rounded,
                        color: FlutterFlowTheme.of(context).alternate,
                        size: 24.0,
                      ),
                      onPressed: !FFAppState().isDeviceOnline
                          ? null
                          : () async {
                              context.pushNamed(
                                'FavoritePrayersPage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType: PageTransitionType.fade,
                                    duration: Duration(milliseconds: 250),
                                  ),
                                },
                              );
                            },
                    ),
                    FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 48.0,
                      icon: Icon(
                        Icons.settings_rounded,
                        color: FlutterFlowTheme.of(context).alternate,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.pushNamed(
                          'SettingsPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 250),
                            ),
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            centerTitle: true,
            toolbarHeight: 48.0,
            elevation: 0.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary,
                  const Color(0xFF3C010C)
                ],
                stops: const [0.0, 1.0],
                begin: const AlignmentDirectional(0.0, -1.0),
                end: const AlignmentDirectional(0, 1.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: AutoSizeText(
                        'Congregația Surorilor Maicii Domnului',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 18.0,
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'PlayBall',
                                  color: FlutterFlowTheme.of(context).alternate,
                                  fontSize: 32.0,
                                  letterSpacing: 0.0,
                                  shadows: [
                                    const Shadow(
                                      color: Color(0xFF1C1200),
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 2.0,
                                    )
                                  ],
                                  useGoogleFonts: false,
                                ),
                      ),
                    ),
                    Text(
                      '- ${dateTimeFormat(
                        "yMMMMEEEEd",
                        DateTime.fromMillisecondsSinceEpoch(
                            getCurrentTimestamp.millisecondsSinceEpoch),
                        locale: FFLocalizations.of(context).languageCode,
                      )} -',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).alternate,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
                if (valueOrDefault<bool>(
                  (FFAppState().savedPrayer != null) &&
                      !widget.hasNavigatedHere &&
                      (FFAppState().savedPrayer.prayer != null) &&
                      (FFAppState().savedPrayer.prayer.id != ''),
                  false,
                ))
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.goNamed(
                          'RosaryPage',
                          queryParameters: {
                            'prayerId': serializeParam(
                              FFAppState().savedPrayer.prayer.id,
                              ParamType.String,
                            ),
                            'page': serializeParam(
                              valueOrDefault<int>(
                                FFAppState().savedPrayer.page,
                                0,
                              ),
                              ParamType.int,
                            ),
                            'clearSavedPrayer': serializeParam(
                              true,
                              ParamType.bool,
                            ),
                            'initialAudioTime': serializeParam(
                              valueOrDefault<double>(
                                FFAppState().savedPrayer.audioTime,
                                0.0,
                              ),
                              ParamType.double,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 250),
                            ),
                          },
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(
                            'Continuă rugăciunea salvată',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Merriweather',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          subtitle: Text(
                            '${FFAppState().savedPrayer.prayer.title} - ${FFAppState().savedPrayer.prayer.subtitle}',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 16.0,
                          ),
                          tileColor: FlutterFlowTheme.of(context).alternate,
                          dense: true,
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 12.0, 0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_model.dateGroups.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    final dateGroup =
                                        _model.dateGroups.toList();

                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: dateGroup.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8.0),
                                      itemBuilder: (context, dateGroupIndex) {
                                        final dateGroupItem =
                                            dateGroup[dateGroupIndex];
                                        return Visibility(
                                          visible: valueOrDefault<bool>(
                                            dateGroupItem.prayers.isNotEmpty,
                                            false,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              if (valueOrDefault<bool>(
                                                (dateGroupItem.name !=
                                                            '') &&
                                                    valueOrDefault<bool>(
                                                      dateGroupItem
                                                                  .description !=
                                                              '',
                                                      false,
                                                    ),
                                                false,
                                              ))
                                                Text(
                                                  valueOrDefault<String>(
                                                    dateGroupItem.name,
                                                    'Rugăciuni',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily:
                                                            'Merriweather',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Divider(
                                                    height: 1.0,
                                                    thickness: 1.0,
                                                    indent: 10.0,
                                                    endIndent: 10.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                  ),
                                                  Builder(
                                                    builder: (context) {
                                                      final prayers =
                                                          dateGroupItem.prayers
                                                              .sortedList(
                                                                  keyOf: (e) =>
                                                                      e.sequence,
                                                                  desc: false)
                                                              .toList();

                                                      return ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        primary: false,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            prayers.length,
                                                        itemBuilder: (context,
                                                            prayersIndex) {
                                                          final prayersItem =
                                                              prayers[
                                                                  prayersIndex];
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  await actions
                                                                      .navigateWithRelacement(
                                                                    context,
                                                                    'RosaryPage',
                                                                    <String,
                                                                        String>{
                                                                      'prayerId':
                                                                          prayersItem
                                                                              .id,
                                                                    },
                                                                  );
                                                                },
                                                                child: Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      prayersItem
                                                                          .title,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleLarge
                                                                          .override(
                                                                            fontFamily:
                                                                                'Merriweather',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      prayersItem
                                                                          .subtitle,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Inter',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w200,
                                                                          ),
                                                                    ),
                                                                    trailing:
                                                                        Icon(
                                                                      Icons
                                                                          .arrow_forward_ios_rounded,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .alternate,
                                                                      size:
                                                                          16.0,
                                                                    ),
                                                                    dense: true,
                                                                    contentPadding:
                                                                        const EdgeInsetsDirectional.fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                height: 1.0,
                                                                thickness: 1.0,
                                                                indent: 10.0,
                                                                endIndent: 10.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ].divide(const SizedBox(height: 4.0)),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                        'AllPrayersPage',
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey: const TransitionInfo(
                                            hasTransition: true,
                                            transitionType:
                                                PageTransitionType.fade,
                                            duration:
                                                Duration(milliseconds: 250),
                                          ),
                                        },
                                      );
                                    },
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        title: Text(
                                          'Toate rugăciunile',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                fontFamily: 'Merriweather',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          size: 16.0,
                                        ),
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                12.0, 0.0, 12.0, 0.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    indent: 10.0,
                                    endIndent: 10.0,
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ].divide(const SizedBox(height: 16.0)),
            ),
          ),
        ),
      ),
    );
  }
}
