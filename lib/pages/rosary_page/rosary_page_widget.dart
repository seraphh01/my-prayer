import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_prayer/components/download_progress_indicator.dart';
import 'package:my_prayer/custom_code/actions/retrieve_audio_file.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/prayer_options_widget.dart';
import '/components/sections_view_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:aligned_tooltip/aligned_tooltip.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'rosary_page_model.dart';
export 'rosary_page_model.dart';

class RosaryPageWidget extends StatefulWidget {
  const RosaryPageWidget({
    super.key,
    required this.prayerId,
    int? page,
    bool? clearSavedPrayer,
    int? initialAudioTime,
    bool? continueAudio,
  }) : page = page ?? 0;

  final String? prayerId;
  final int page;

  @override
  State<RosaryPageWidget> createState() => _RosaryPageWidgetState();
}

class _RosaryPageWidgetState extends State<RosaryPageWidget> {
  late RosaryPageModel _model;
  final _downloadManager = getIt<DownloadManager>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageManager = getIt<PageManager>();
  List<PrayerSectionStruct> flattenedSections = [];

  Future<void> setInitialMediaItems() async {
    if (flattenedSections.isEmpty) {
      return;
    }

    _pageManager.clearQueue();

    final mediaItems = await Future.wait(flattenedSections.map((section) async {
      final artUri = section.imageUrl.isNotEmpty
          ? Uri.parse(section.imageUrl)
          : Uri.parse(
              'https://nrapqjwyqvwopwoxevlw.supabase.co/storage/v1/object/public/images/logo.jpg');

      final filePath = await retrieveAudioFile(section.audioUrl);

      final tempPlayer = AudioPlayer();
      final source = filePath != null
          ? AudioSource.uri(Uri.file(filePath))
          : AudioSource.uri(Uri.parse(section.audioUrl));
      await tempPlayer.setAudioSource(source);
      final duration = tempPlayer.duration;
      await tempPlayer.dispose();

      return MediaItem(
        id: section.id,
        album: section.subtitle,
        artist: _model.currentPrayer?.title ?? '',
        title: section.title,
        artUri: artUri,
        duration: duration,
        extras: {
          'url': section.audioUrl,
          'isDownloaded': filePath != null,
          'filePath': filePath,
        },
      );
    }).toList());

    await _pageManager.setQueue(mediaItems);
    await _pageManager.skipToIndex(widget.page);
    await _pageManager.seek(const Duration(seconds: 0));
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RosaryPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      var hasChangedPrayer = FFAppState().currentPrayerId != widget.prayerId;
      FFAppState().currentPrayerId = widget.prayerId ?? '';

      if (FFAppState()
          .downloadedPrayers
          .map((e) => e.id)
          .toList()
          .contains((widget.prayerId!))) {
        _model.currentPrayer = FFAppState()
            .downloadedPrayers
            .firstWhereOrNull((e) => valueOrDefault<bool>(
                  e.id == widget.prayerId,
                  false,
                ));
      } else {
        _model.prayerResponse =
            await SuapabaseQueriesGroup.getPrayerWithSectionsRecursiveCall.call(
          requestPrayerId: widget.prayerId,
        );

        if ((_model.prayerResponse?.succeeded ?? true)) {
          _model.currentPrayer = PrayerStruct.maybeFromMap(
              (_model.prayerResponse?.jsonBody ?? ''));
        }
      }

      flattenedSections = functions.flattenSectionsList(
              _model.currentPrayer?.sections.toList() ?? []) ??
          [];

      if (hasChangedPrayer) {
        await setInitialMediaItems();
      }

      safeSetState(() {});
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
          preferredSize: const Size.fromHeight(64.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.home_rounded,
                color: FlutterFlowTheme.of(context).alternate,
                size: 24.0,
              ),
              iconSize: 24.0,
            ),
            iconTheme:
                IconThemeData(color: FlutterFlowTheme.of(context).alternate),
            title: AutoSizeText(
              valueOrDefault<String>(
                _model.currentPrayer?.title,
                '',
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
                  if (!FFAppState().isDeviceOnline && !isWeb)
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: const BoxDecoration(),
                      child: AlignedTooltip(
                        content: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            valueOrDefault<bool>(
                              FFAppState()
                                  .downloadedPrayers
                                  .map((e) => e.id)
                                  .toList()
                                  .contains((widget.prayerId!)),
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
                              FFAppState()
                                  .downloadedPrayers
                                  .map((e) => e.id)
                                  .toList()
                                  .contains((widget.prayerId!)),
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
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: PrayerOptionsWidget(
                                        prayer: _model.currentPrayer!,
                                        enableDownloadButton: FFAppState()
                                                .isDeviceOnline &&
                                            (!valueOrDefault<bool>(
                                              FFAppState()
                                                  .downloadedPrayers
                                                  .map((e) => e.id)
                                                  .contains((widget.prayerId!)),
                                              false,
                                            )),
                                        currentPageIndex: _pageManager
                                            .trackIndexNotifier.value,
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(
                                  () => _model.pressedButton = value));

                              if (_model.pressedButton == 'download') {
                                safeSetState(() {});
                                await _downloadManager.downloadPrayer(
                                  context: context,
                                  prayer: _model.currentPrayer!,
                                );
                              } else if (_model.pressedButton == 'share') {
                                if (!isWeb) {
                                  await Share.share(
                                    'rugaciuni-si-cnatari-cmd://rugaciuni-si-cantari-cmd.com${GoRouterState.of(context).uri.toString()}',
                                    sharePositionOrigin:
                                        getWidgetBoundingBox(context),
                                  );
                                }
                              } else if (_model.pressedButton == 'save') {
                                FFAppState().savedPrayer =
                                    SavedPrayerDataStruct(
                                  prayer: _model.currentPrayer,
                                  page: _pageManager.trackIndexNotifier.value,
                                  audioTime: _pageManager
                                      .currentProgressNotifier.value.inSeconds,
                                );
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Semnul de carte către ${_model.currentPrayer!.title.isNotEmpty ? '„${_model.currentPrayer!.title}” - ' : ''}„${flattenedSections.elementAtOrNull(_pageManager.trackIndexNotifier.value)?.title}” a fost salvat!',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 5000),
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
                              } else if (_model.pressedButton == 'clear_save') {
                                FFAppState().deleteSavedPrayer();
                                FFAppState().savedPrayer =
                                    SavedPrayerDataStruct();
                              }

                              safeSetState(() {});
                            },
                          ),
                        ),
                        const Hero(
                            tag: "downloadIndicator",
                            child: DownloadProgressIndicator())
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
                      return SectionsViewWidget(
                        sections: _model.currentPrayer?.sections,
                        prayerTitle: _model.currentPrayer?.title,
                        prayerSubtitle: _model.currentPrayer?.subtitle,
                      );
                    } else {
                      return const Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: SizedBox(
                          width: 64.0,
                          height: 64.0,
                          child: custom_widgets.CustomCircularProgressIndicator(
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
    );
  }
}
