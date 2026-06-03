import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:my_prayer/components/download_progress_indicator.dart';
import 'package:my_prayer/custom_code/actions/retrieve_audio_file.dart';
import 'package:my_prayer/custom_code/audio/notifiers/play_button_notifier.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:path_provider/path_provider.dart';
import '/custom_code/journal/prayer_journal_storage.dart';
import '/custom_code/reminders/prayer_reminder_flow.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';
import 'package:my_prayer/custom_code/download/notifiers/download_state_notifier.dart';
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
import 'package:flutter/services.dart';
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
  final ScrollController _scrollController = ScrollController();
  /// When true, the app header and bottom audio/control bar are visible.
  final ValueNotifier<bool> _chromeVisible = ValueNotifier(true);
  final ValueNotifier<bool> _allowScroll = ValueNotifier(true);
  static const double _appBarToolbarHeight = 64.0;
  static const double _floatingBackgroundOpacityActive = 0.65;
  static const double _floatingBackgroundOpacityIdle = 0.1;
  static const Duration _floatingControlsIdleDelay = Duration(seconds: 1);

  final ValueNotifier<double> _floatingControlsBackgroundOpacity =
      ValueNotifier(_floatingBackgroundOpacityActive);
  Timer? _floatingControlsIdleTimer;
  bool? _wasInTextMode;

  void _toggleChrome() {
    _onFloatingControlsInteraction();
    _chromeVisible.value = !_chromeVisible.value;
  }

  void _setFloatingControlsActiveOpacity() {
    if (_floatingControlsBackgroundOpacity.value !=
        _floatingBackgroundOpacityActive) {
      _floatingControlsBackgroundOpacity.value =
          _floatingBackgroundOpacityActive;
    }
    _scheduleFloatingControlsIdleFade();
  }

  void _onFloatingControlsInteraction() {
    _setFloatingControlsActiveOpacity();
  }

  void _onUserScrollActivity() {
    _setFloatingControlsActiveOpacity();
  }

  void _scheduleFloatingControlsIdleFade() {
    _floatingControlsIdleTimer?.cancel();
    _floatingControlsIdleTimer = Timer(_floatingControlsIdleDelay, () {
      if (!mounted) {
        return;
      }
      _floatingControlsBackgroundOpacity.value =
          _floatingBackgroundOpacityIdle;
    });
  }

  bool _handleFloatingControlsScrollNotification(
    ScrollNotification notification,
  ) {
    if (notification is UserScrollNotification ||
        notification is ScrollUpdateNotification) {
      _onUserScrollActivity();
    }
    return false;
  }

  void _onAllowScrollChanged() {
    if (_allowScroll.value || !_scrollController.hasClients) {
      return;
    }

    final target = (_scrollController.offset - 12.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  bool _currentSectionHasAudio() {
    if (flattenedSections.isEmpty) {
      return false;
    }
    final index = _pageManager.trackIndexNotifier.value;
    if (index < 0 || index >= flattenedSections.length) {
      return false;
    }
    return flattenedSections[index].audioUrl.isNotEmpty;
  }

  BoxDecoration _floatingControlDecoration(
    BuildContext context,
    double backgroundOpacity,
  ) {
    return BoxDecoration(
      color: FlutterFlowTheme.of(context)
          .secondaryBackground
          .withOpacity(backgroundOpacity),
      borderRadius: BorderRadius.circular(18.0),
      border: Border.all(
        color: FlutterFlowTheme.of(context)
            .primary
            .withOpacity(backgroundOpacity * 0.22),
      ),
    );
  }

  Widget _buildChromeToggleButton(
    BuildContext context,
    bool chromeVisible,
    double backgroundOpacity,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleChrome,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          width: 36.0,
          height: 36.0,
          decoration: _floatingControlDecoration(context, backgroundOpacity),
          child: Icon(
            chromeVisible
                ? Icons.fullscreen_rounded
                : Icons.fullscreen_exit_rounded,
            color: FlutterFlowTheme.of(context).primary,
            size: 22.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPlayPauseButton(
    BuildContext context,
    double backgroundOpacity,
  ) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _pageManager.playButtonNotifier,
      builder: (context, state, _) {
        if (state == ButtonState.loading) {
          return Container(
            width: 36.0,
            height: 36.0,
            decoration: _floatingControlDecoration(context, backgroundOpacity),
            alignment: Alignment.center,
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
          );
        }

        final isPlaying = state == ButtonState.playing;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _onFloatingControlsInteraction();
              if (isPlaying) {
                _pageManager.pause();
              } else {
                _pageManager.play();
              }
            },
            borderRadius: BorderRadius.circular(18.0),
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: _floatingControlDecoration(context, backgroundOpacity),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 22.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingControlsOverlay(
    BuildContext context, {
    required bool chromeVisible,
    required bool showPlayPause,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: _floatingControlsBackgroundOpacity,
      builder: (context, backgroundOpacity, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          opacity: backgroundOpacity / _floatingBackgroundOpacityActive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChromeToggleButton(
                context,
                chromeVisible,
                backgroundOpacity,
              ),
              if (showPlayPause) ...[
                const SizedBox(height: 8.0),
                _buildFloatingPlayPauseButton(context, backgroundOpacity),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> setInitialMediaItems() async {
    if (flattenedSections.isEmpty) {
      return;
    }

    final targetIndex = _pageManager.trackIndexNotifier.value
        .clamp(0, flattenedSections.length - 1);
    _pageManager.trackIndexNotifier.value = targetIndex;

    final hasAudio =
        flattenedSections.any((section) => section.audioUrl.isNotEmpty);
    final documentsDir =
        hasAudio ? await getApplicationDocumentsDirectory() : null;
    final fallbackAudioUrl = flattenedSections
        .map((section) => section.audioUrl)
        .firstWhere((url) => url.isNotEmpty, orElse: () => '');

    final mediaItems = flattenedSections.map((section) {
      final artUri = section.imageUrl.isNotEmpty
          ? Uri.parse(section.imageUrl)
          : Uri.parse(
              'https://nrapqjwyqvwopwoxevlw.supabase.co/storage/v1/object/public/images/logo.jpg');

      if (!hasAudio) {
        return MediaItem(
          id: section.id,
          album: section.subtitle,
          artist: _model.currentPrayer?.title ?? '',
          title: section.title,
          artUri: artUri,
          duration: const Duration(seconds: 0),
          extras: {
            'url': '',
            'isDownloaded': false,
            'filePath': '',
            'fallbackUrl': '',
          },
        );
      }

      final filePath = documentsDir != null && section.audioUrl.isNotEmpty
          ? localAudioPathForUrl(section.audioUrl, documentsDir)
          : null;

      return MediaItem(
        id: section.id,
        album: section.subtitle,
        artist: _model.currentPrayer?.title ?? '',
        title: section.title,
        artUri: artUri,
        duration: const Duration(seconds: 0),
        extras: {
          'url': section.audioUrl,
          'isDownloaded': filePath != null,
          'filePath': filePath ?? '',
          'fallbackUrl': fallbackAudioUrl,
        },
      );
    }).toList();

    await _pageManager.setQueue(mediaItems);
  }

  Future<void> _initializeAudioQueue() async {
    try {
      await setInitialMediaItems().timeout(const Duration(seconds: 45));
    } catch (error, stackTrace) {
      debugPrint('Audio queue initialization failed: $error\n$stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RosaryPageModel());
    _allowScroll.addListener(_onAllowScrollChanged);

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
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

      _pageManager.trackIndexNotifier.value = widget.page;

      if (mounted) {
        setState(() {});
      }

      unawaited(_initializeAudioQueue());

      if (!mounted) {
        return;
      }

      if (!FFAppState().isDisplayingAudio) {
        _scheduleFloatingControlsIdleFade();
      }

      final prayer = _model.currentPrayer;
      if (prayer != null && prayer.id.isNotEmpty) {
        unawaited(
          PrayerJournalStorage.recordPrayerOpen(
            prayerId: prayer.id,
            prayerTitle: prayer.title,
            prayerSubtitle: prayer.subtitle,
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _floatingControlsIdleTimer?.cancel();
    _floatingControlsBackgroundOpacity.dispose();
    _scrollController.dispose();
    _chromeVisible.dispose();
    _allowScroll.removeListener(_onAllowScrollChanged);
    _allowScroll.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get _isTextMode => !FFAppState().isDisplayingAudio;

  bool _showAppChrome(bool chromeVisible) =>
      !_isTextMode || chromeVisible;

  bool _usePrimaryStatusBarFill(bool chromeVisible) =>
      _isTextMode || chromeVisible;

  Widget _buildPrimaryStatusBarFill(
    BuildContext context, {
    required bool visible,
  }) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    final height = MediaQuery.viewPaddingOf(context).top;
    if (height <= 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: ColoredBox(color: _isTextMode && !_chromeVisible.value? FlutterFlowTheme.of(context).primaryBackground : FlutterFlowTheme.of(context).primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final prayerLoaded = _model.currentPrayer?.id != null &&
        _model.currentPrayer!.id.isNotEmpty;

    if (!_isTextMode) {
      _floatingControlsIdleTimer?.cancel();
      if (_floatingControlsBackgroundOpacity.value !=
          _floatingBackgroundOpacityActive) {
        _floatingControlsBackgroundOpacity.value =
            _floatingBackgroundOpacityActive;
      }
    } else if (_wasInTextMode != true) {
      _setFloatingControlsActiveOpacity();
    }
    _wasInTextMode = _isTextMode;

    if (!_isTextMode && !_chromeVisible.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _chromeVisible.value = true;
        }
      });
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _chromeVisible,
        builder: (context, chromeVisible, child) {
          final primaryStatusBar = _usePrimaryStatusBarFill(chromeVisible);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  primaryStatusBar ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  primaryStatusBar ? Brightness.dark : Brightness.light,
            ),
            child: child!,
          );
        },
        child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _allowScroll,
              builder: (context, allowScroll, child) {
                return NotificationListener<ScrollNotification>(
                  onNotification: _handleFloatingControlsScrollNotification,
                  child: NestedScrollView(
                  controller: _scrollController,
                  physics: allowScroll
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  floatHeaderSlivers: false,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                ValueListenableBuilder<bool>(
                  valueListenable: _chromeVisible,
                  builder: (context, chromeVisible, _) {
                    if (!_showAppChrome(chromeVisible)) {
                      return const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    }
                    return SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                      sliver: SliverAppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
              floating: false,
              pinned: true,
              snap: false,
              leading: IconButton(
                onPressed: () {
                  context.goHomeReplacingStack();
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
                                color: _downloadManager
                                                .downloadStateNotifier.value !=
                                            DownloadState.downloading &&
                                        _downloadManager.downloadStateNotifier
                                                .value !=
                                            DownloadState.loading
                                    ? FlutterFlowTheme.of(context).alternate
                                    : Colors.transparent,
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
                                          enableDownloadButton: FFAppState()
                                                  .isDeviceOnline &&
                                              (!valueOrDefault<bool>(
                                                FFAppState()
                                                    .downloadedPrayers
                                                    .map((e) => e.id)
                                                    .contains(
                                                        (widget.prayerId!)),
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
                                    await SharePlus.instance.share(
                                      ShareParams(
                                        text:
                                            'Descoperă rugăciunea „${_model.currentPrayer?.title}” în aplicația „Rugăciuni și Cântări - CMD”! \nDescarcă aplicația din  App Store sau Google Play: '
                                            '\nhttps://play.google.com/store/apps/details?id=com.surorilecmd.rugaciunisicantari'
                                            '\nhttps://apps.apple.com/app/rugaciunisicantaricmd/id6758237098',
                                        subject: _model.currentPrayer?.title,
                                        title:
                                            'Descoperă „${_model.currentPrayer?.title}” în aplicația „Rugăciuni și Cântări - CMD”!',
                                        sharePositionOrigin:
                                            getWidgetBoundingBox(context),
                                      ),
                                    );
                                  }
                                } else if (_model.pressedButton == 'save') {
                                  FFAppState().savedPrayer =
                                      SavedPrayerDataStruct(
                                    prayer: _model.currentPrayer,
                                    page: _pageManager.trackIndexNotifier.value,
                                    audioTime: _pageManager
                                        .currentProgressNotifier
                                        .value
                                        .inSeconds,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Semnul de carte către ${_model.currentPrayer!.title.isNotEmpty ? '„${_model.currentPrayer!.title}” - ' : ''}„${flattenedSections.elementAtOrNull(_pageManager.trackIndexNotifier.value)?.title}” a fost salvat!',
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
                                } else if (_model.pressedButton ==
                                    'clear_save') {
                                  FFAppState().deleteSavedPrayer();
                                  FFAppState().savedPrayer =
                                      SavedPrayerDataStruct();
                                } else if (_model.pressedButton == 'reminder') {
                                  final prayer = _model.currentPrayer;
                                  if (prayer != null) {
                                    await openPrayerReminderFlow(
                                      context,
                                      prayer: prayer,
                                    );
                                  }
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
              toolbarHeight: _appBarToolbarHeight,
              elevation: 0.0,
            ),
                    );
                  },
                ),
          ],
          body: ValueListenableBuilder<bool>(
            valueListenable: _chromeVisible,
            builder: (context, chromeVisible, child) {
              return SafeArea(
                top: _isTextMode && !chromeVisible,
                bottom: false,
                child: child!,
              );
            },
            child: SizedBox(
              height: double.infinity,
              child: Builder(
                builder: (context) {
                  if (prayerLoaded) {
                    return SectionsViewWidget(
                      sections: _model.currentPrayer?.sections,
                      prayerTitle: _model.currentPrayer?.title,
                      prayerSubtitle: _model.currentPrayer?.subtitle,
                      controlBarVisibilityNotifier: _chromeVisible,
                      allowScrollNotifier: _allowScroll,
                    );
                  }

                  return Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: SizedBox(
                      width: 64.0,
                      height: 64.0,
                      child: custom_widgets.CustomCircularProgressIndicator(
                        width: 64.0,
                        height: 64.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
                ),
                );
              },
            ),
            if (prayerLoaded)
              ValueListenableBuilder<bool>(
                valueListenable: _chromeVisible,
                builder: (context, chromeVisible, _) {
                  return _buildPrimaryStatusBarFill(
                    context,
                    visible: _usePrimaryStatusBarFill(chromeVisible),
                  );
                },
              ),
            if (prayerLoaded && _isTextMode)
              ValueListenableBuilder<int>(
                valueListenable: _pageManager.trackIndexNotifier,
                builder: (context, trackIndex, _) {
                  final sectionHasAudio = _currentSectionHasAudio();
                  return ValueListenableBuilder<bool>(
                    valueListenable: _chromeVisible,
                    builder: (context, chromeVisible, _) {

                      final topInset = MediaQuery.viewPaddingOf(context).top;
                      final top = topInset + (_chromeVisible.value ? 72.0 : 8.0);
                      final showPlayPause = !chromeVisible && sectionHasAudio;
                      return Positioned(
                        top: top,
                        right: 16.0,
                        child: Material(
                          type: MaterialType.transparency,
                          elevation: 4.0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(18.0),
                          child: _buildFloatingControlsOverlay(
                            context,
                            chromeVisible: chromeVisible,
                            showPlayPause: showPlayPause,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
      ),
    );
  }
}
