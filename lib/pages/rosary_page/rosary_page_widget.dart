import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/prayer_options_widget.dart';
import '/components/sections_view_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:aligned_tooltip/aligned_tooltip.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'rosary_page_model.dart';
export 'rosary_page_model.dart';

class RosaryPageWidget extends StatefulWidget {
  const RosaryPageWidget({
    super.key,
    required this.prayerId,
    int? page,
    this.downloadedPrayer,
    bool? clearSavedPrayer,
    double? initialAudioTime,
  })  : page = page ?? 0,
        clearSavedPrayer = clearSavedPrayer ?? false,
        initialAudioTime = initialAudioTime ?? 0.0;

  final String? prayerId;
  final int page;
  final PrayerStruct? downloadedPrayer;
  final bool clearSavedPrayer;
  final double initialAudioTime;

  @override
  State<RosaryPageWidget> createState() => _RosaryPageWidgetState();
}

class _RosaryPageWidgetState extends State<RosaryPageWidget> {
  late RosaryPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RosaryPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.clearSavedPrayer) {
        FFAppState().deleteSavedPrayer();
        FFAppState().savedPrayer = SavedPrayerDataStruct();

        safeSetState(() {});
      }
      _model.weekDay = valueOrDefault<int>(
        DateTime.fromMillisecondsSinceEpoch(
                getCurrentTimestamp.millisecondsSinceEpoch)
            .weekday,
        1,
      );
      _model.rosaryTabIndex = valueOrDefault<int>(
        () {
          if ((_model.weekDay == 1) || (_model.weekDay == 6)) {
            return 0;
          } else if (_model.weekDay == 4) {
            return 1;
          } else if ((_model.weekDay == 2) || (_model.weekDay == 5)) {
            return 2;
          } else {
            return 3;
          }
        }(),
        0,
      );
      if (widget.downloadedPrayer != null) {
        _model.currentPrayer = widget.downloadedPrayer;
        safeSetState(() {});
      } else if (FFAppState()
          .downloadedPrayers
          .map((e) => e.id)
          .toList()
          .toList()
          .contains((widget.prayerId!))) {
        _model.currentPrayer = FFAppState()
            .downloadedPrayers
            .where((e) => valueOrDefault<bool>(
                  e.id == widget.prayerId,
                  false,
                ))
            .toList()
            .firstOrNull;
        safeSetState(() {});
      } else {
        _model.prayerResponse =
            await SuapabaseQueriesGroup.getPrayerWithSectionsRecursiveCall.call(
          requestPrayerId: widget.prayerId,
        );

        if ((_model.prayerResponse?.succeeded ?? true)) {
          _model.currentPrayer = PrayerStruct.maybeFromMap(
              (_model.prayerResponse?.jsonBody ?? ''));
          safeSetState(() {});
        }
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
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64.0),
            child: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              iconTheme: IconThemeData(
                  color: FlutterFlowTheme.of(context).primaryText),
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderRadius: 8.0,
                buttonSize: 48.0,
                disabledIconColor: const Color(0xFF171717),
                icon: Icon(
                  Icons.home_rounded,
                  color: FlutterFlowTheme.of(context).alternate,
                  size: 24.0,
                ),
                onPressed: (_model.isDownloading || _model.isLoadingDownload)
                    ? null
                    : () async {
                        context.pushNamed(
                          'HomePage',
                          queryParameters: {
                            'hasNavigatedHere': serializeParam(
                              true,
                              ParamType.bool,
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
              ),
              title: AutoSizeText(
                valueOrDefault<String>(
                  _model.currentPrayer?.title,
                  'Titlu Rugăciune',
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
                minFontSize: 16.0,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Merriweather',
                      color: FlutterFlowTheme.of(context).alternate,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                    ),
              ),
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (!FFAppState().isDeviceOnline)
                      Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: const BoxDecoration(),
                        child: AlignedTooltip(
                          content: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              valueOrDefault<bool>(
                                (widget.downloadedPrayer != null) ||
                                    (FFAppState()
                                        .downloadedPrayers
                                        .map((e) => e.id)
                                        .toList()
                                        .contains((widget.prayerId!))),
                                false,
                              )
                                  ? 'Disponibilă în mod offline.'
                                  : 'Nedisponibilă în mod offline.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          offset: 2.0,
                          preferredDirection: AxisDirection.down,
                          borderRadius: BorderRadius.circular(8.0),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 4.0,
                          tailBaseWidth: 24.0,
                          tailLength: 12.0,
                          waitDuration: const Duration(milliseconds: 100),
                          showDuration: const Duration(milliseconds: 1500),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Builder(
                            builder: (context) {
                              if (valueOrDefault<bool>(
                                (widget.downloadedPrayer != null) ||
                                    (FFAppState()
                                        .downloadedPrayers
                                        .map((e) => e.id)
                                        .toList()
                                        .contains((widget.prayerId!))),
                                false,
                              )) {
                                return Icon(
                                  Icons.download_done_rounded,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  size: 24.0,
                                );
                              } else {
                                return Icon(
                                  Icons.file_download_off_rounded,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  size: 24.0,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: const BoxDecoration(),
                      child: Stack(
                        children: [
                          Builder(
                            builder: (context) => FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 48.0,
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  enableDrag: false,
                                  useSafeArea: true,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: PrayerOptionsWidget(
                                          prayer: _model.currentPrayer!,
                                          enableDownloadButton:
                                              FFAppState().isDeviceOnline &&
                                                  (widget.downloadedPrayer ==
                                                      null),
                                          currentPageIndex: _model
                                              .sectionsViewModel
                                              .pageViewCurrentIndex,
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(
                                    () => _model.pressedButton = value));

                                if (_model.pressedButton == 'download') {
                                  _model.isLoadingDownload = true;
                                  safeSetState(() {});
                                  await actions.downloadPrayer(
                                    context,
                                    _model.currentPrayer!,
                                    (downloadedSize, totalSize) async {
                                      _model.downloadProgress =
                                          downloadedSize / (totalSize!);
                                      _model.downloadedSize = downloadedSize;
                                      _model.totalSize = totalSize;
                                      safeSetState(() {});
                                    },
                                    () async {
                                      _model.isDownloading = true;
                                      _model.isLoadingDownload = false;
                                      safeSetState(() {});
                                    },
                                    () async {
                                      _model.downloadProgress = 0.0;
                                      _model.isLoadingDownload = false;
                                      _model.isDownloading = false;
                                      safeSetState(() {});
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Descărcarea a fost finalizată!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    () async {
                                      _model.downloadProgress = 0.0;
                                      _model.isLoadingDownload = false;
                                      _model.isDownloading = false;
                                      safeSetState(() {});
                                      await showDialog(
                                        context: context,
                                        builder: (alertDialogContext) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Descărcarea nu a putut fi finalizată!'),
                                            content: const Text(
                                                'Ne pare rău, a intervenit o eroare. Încearcă mai târziu.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                  _model.isDownloading = false;
                                  _model.isLoadingDownload = false;
                                  safeSetState(() {});
                                } else if (_model.pressedButton == 'share') {
                                  if (!isWeb) {
                                    await Share.share(
                                      'myprayer://myprayer.com${GoRouterState.of(context).uri.toString()}',
                                      sharePositionOrigin:
                                          getWidgetBoundingBox(context),
                                    );
                                  }
                                } else if (_model.pressedButton == 'save') {
                                  FFAppState().savedPrayer =
                                      SavedPrayerDataStruct(
                                    prayer: _model.currentPrayer,
                                    page: _model
                                        .sectionsViewModel.pageViewCurrentIndex,
                                    audioTime: _model.currentAudioTime,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Semnu de carte către${valueOrDefault<String>(
                                          _model.currentPrayer?.title,
                                          'Titlu Rugăciune',
                                        )} - ${(functions.flattenSectionsList(_model.currentPrayer!.sections.toList())?.elementAtOrNull(_model.sectionsViewModel.pageViewCurrentIndex))?.title} a fost salvat!',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      duration: const Duration(milliseconds: 5000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      action: SnackBarAction(
                                        label: 'Anulează',
                                        textColor: FlutterFlowTheme.of(context)
                                            .alternate,
                                        onPressed: () async {
                                          FFAppState().deleteSavedPrayer();
                                          FFAppState().savedPrayer =
                                              SavedPrayerDataStruct();
                                        },
                                      ),
                                    ),
                                  );
                                } else if (_model.pressedButton ==
                                    'clear_save') {
                                  FFAppState().deleteSavedPrayer();
                                  FFAppState().savedPrayer =
                                      SavedPrayerDataStruct();
                                }

                                safeSetState(() {});
                              },
                            ),
                          ),
                          if (_model.isDownloading || _model.isLoadingDownload)
                            Builder(
                              builder: (context) {
                                if (_model.isLoadingDownload) {
                                  return Container(
                                    width: 48.0,
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: SizedBox(
                                        width: 20.0,
                                        height: 20.0,
                                        child: custom_widgets
                                            .CustomCircularProgressIndicator(
                                          width: 20.0,
                                          height: 20.0,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (_model.isDownloading) {
                                  return Container(
                                    width: 48.0,
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: AlignedTooltip(
                                      content: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          valueOrDefault<String>(
                                            (int current, int total) {
                                              return "${(current / (1024 * 1024)).toStringAsFixed(2)} / ${(total / (1024 * 1024)).toStringAsFixed(2)} MB";
                                            }(_model.downloadedSize!,
                                                _model.totalSize!),
                                            '0/0 MB',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily: 'Inter',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                      offset: 4.0,
                                      preferredDirection: AxisDirection.down,
                                      borderRadius: BorderRadius.circular(8.0),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      elevation: 4.0,
                                      tailBaseWidth: 24.0,
                                      tailLength: 12.0,
                                      waitDuration: const Duration(milliseconds: 100),
                                      showDuration:
                                          const Duration(milliseconds: 1000),
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Align(
                                        alignment:
                                            const AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 4.0, 0.0, 0.0),
                                          child: CircularPercentIndicator(
                                            percent: _model.downloadProgress,
                                            radius: 12.0,
                                            lineWidth: 4.0,
                                            animation: true,
                                            animateFromLastPercent: true,
                                            progressColor:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                            backgroundColor: const Color(0xFF676767),
                                            startAngle: 0.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: 0.0,
                                    height: 0.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              centerTitle: true,
              toolbarHeight: 64.0,
              elevation: 0.0,
            ),
          ),
          body: SafeArea(
            top: true,
            child: Visibility(
              visible: valueOrDefault<bool>(
                _model.currentPrayer != null,
                false,
              ),
              child: SafeArea(
                child: SizedBox(
                  height: double.infinity,
                  child: Builder(
                    builder: (context) {
                      if (_model.currentPrayer?.id != null &&
                          _model.currentPrayer?.id != '') {
                        return wrapWithModel(
                          model: _model.sectionsViewModel,
                          updateCallback: () => safeSetState(() {}),
                          child: SectionsViewWidget(
                            sections: _model.currentPrayer?.sections,
                            initialPage: widget.page,
                            initialAudioTime: valueOrDefault<double>(
                              widget.initialAudioTime,
                              0.0,
                            ),
                          ),
                        );
                      } else {
                        return const Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SizedBox(
                            width: 64.0,
                            height: 64.0,
                            child:
                                custom_widgets.CustomCircularProgressIndicator(
                              width: 64.0,
                              height: 64.0,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
