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
import 'package:my_prayer/custom_code/prayer/downloaded_prayer_repository.dart';
import 'package:my_prayer/custom_code/prayer/media_items_cache.dart';
import 'package:my_prayer/custom_code/prayer/prayer_content_cache.dart';
import 'package:my_prayer/custom_code/prayer/prayer_section_content_cache.dart';
import 'package:my_prayer/custom_code/prayer/prayer_typography.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/choose_chapter_widget.dart';
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
  })  : page = page ?? 0,
        initialAudioTime = initialAudioTime ?? 0,
        continueAudio = continueAudio ?? false;

  final String? prayerId;
  final int page;
  final int initialAudioTime;
  final bool continueAudio;

  @override
  State<RosaryPageWidget> createState() => _RosaryPageWidgetState();
}

class _RosaryPageWidgetState extends State<RosaryPageWidget> {
  late RosaryPageModel _model;
  final _downloadManager = getIt<DownloadManager>();
  final _prayerCache = getIt<PrayerContentCache>();
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
  bool _displayingAudio = true;
  bool _audioQueueInitialized = false;
  Future<void>? _audioQueueInitFuture;
  bool _pageReady = false;

  Future<void> _preloadInitialSection() async {
    if (flattenedSections.isEmpty) {
      return;
    }

    final maxIndex = flattenedSections.length - 1;
    final index = _pageManager.trackIndexNotifier.value.clamp(0, maxIndex);
    final section = flattenedSections[index];
    if (section.texts.isNotEmpty) {
      return;
    }

    final sectionCache = getIt<PrayerSectionContentCache>();
    final cached = sectionCache.cachedTexts(section.sectionId);
    if (cached != null) {
      section.texts = cached;
      return;
    }

    section.texts = await sectionCache.loadTexts(section.sectionId);
    sectionCache.prefetchAdjacent(flattenedSections, index);
  }

  bool _shouldForceAudioMode() {
    final prayer = _model.currentPrayer;
    if (prayer == null) {
      return false;
    }
    if (prayer.mode == PrayerMode.audioOnly) {
      return true;
    }
    if (prayer.mode == PrayerMode.textOnly) {
      return false;
    }

    final hasAudio =
        flattenedSections.any((section) => section.audioUrl.isNotEmpty);
    if (!hasAudio) {
      return false;
    }

    return !flattenedSections.any((section) => section.texts.isNotEmpty);
  }

  bool _shouldOpenInTextMode() {
    final prayer = _model.currentPrayer;
    if (prayer?.mode == PrayerMode.textOnly) {
      return true;
    }
    if (flattenedSections.isEmpty) {
      return false;
    }
    return !flattenedSections.any((section) => section.audioUrl.isNotEmpty);
  }

  void _syncDisplayModeForPrayer({required bool continuingExistingAudio}) {
    if (continuingExistingAudio) {
      _displayingAudio = FFAppState().isDisplayingAudio;
      return;
    }

    if (_shouldForceAudioMode()) {
      FFAppState().isDisplayingAudio = true;
      _displayingAudio = true;
      return;
    }

    if (_shouldOpenInTextMode()) {
      FFAppState().isDisplayingAudio = false;
      _displayingAudio = false;
      return;
    }

    _displayingAudio = FFAppState().isDisplayingAudio;
  }

  bool _isAudioActivelyPlaying() {
    return _pageManager.playButtonNotifier.value == ButtonState.playing;
  }

  Future<void> _prepareAudioForOpen({
    required bool continuingExistingAudio,
  }) async {
    final hasAudio =
        flattenedSections.any((section) => section.audioUrl.isNotEmpty);
    if (!hasAudio) {
      return;
    }

    final needsAudioQueue =
        FFAppState().isDisplayingAudio || _shouldForceAudioMode();
    if (!needsAudioQueue) {
      return;
    }

    if (continuingExistingAudio &&
        _pageManager.isQueueReadyForSectionCount(flattenedSections.length)) {
      _audioQueueInitialized = true;
      if (!_isAudioActivelyPlaying() && widget.initialAudioTime > 0) {
        await _pageManager.seek(Duration(seconds: widget.initialAudioTime));
      }
      return;
    }

    _audioQueueInitialized = false;
    if (!flattenedSections.any((section) => section.audioUrl.isNotEmpty)) {
      return;
    }

    await _ensureAudioQueueInitialized();
    if (!_isAudioQueueReady()) {
      return;
    }
    final maxIndex =
        flattenedSections.isEmpty ? 0 : flattenedSections.length - 1;
    _pageManager.setTrackIndex(widget.page.clamp(0, maxIndex));
    if (widget.initialAudioTime > 0) {
      await _pageManager.seek(Duration(seconds: widget.initialAudioTime));
    }
    if (!widget.continueAudio || !_isAudioActivelyPlaying()) {
      _pageManager.pause();
      _pageManager.playButtonNotifier.value = ButtonState.paused;
    }
  }

  void _onAppStateChanged() {
    if (!mounted) {
      return;
    }
    final isAudio = FFAppState().isDisplayingAudio;
    if (isAudio && _pageReady) {
      unawaited(_ensureAudioQueueInitialized());
    }
    if (_displayingAudio != isAudio) {
      setState(() => _displayingAudio = isAudio);
    }
  }

  bool _isAudioQueueReady() {
    return _pageManager.isQueueReadyForSectionCount(flattenedSections.length);
  }

  Future<void> _ensureAudioQueueInitialized() async {
    if (flattenedSections.isEmpty) {
      return;
    }
    if (!flattenedSections.any((section) => section.audioUrl.isNotEmpty)) {
      return;
    }

    if (_audioQueueInitialized && _isAudioQueueReady()) {
      return;
    }

    _audioQueueInitialized = false;

    final inFlight = _audioQueueInitFuture;
    if (inFlight != null) {
      await inFlight;
      _audioQueueInitialized = _isAudioQueueReady();
      return;
    }

    final future = _initializeAudioQueue();
    _audioQueueInitFuture = future;
    try {
      final success = await future;
      _audioQueueInitialized = success && _isAudioQueueReady();
    } finally {
      if (identical(_audioQueueInitFuture, future)) {
        _audioQueueInitFuture = null;
      }
    }
  }

  bool _canContinueExistingAudio({String? previousPrayerId}) {
    if (!widget.continueAudio) {
      return false;
    }
    final prayerId = widget.prayerId;
    if (prayerId == null || prayerId.isEmpty) {
      return false;
    }
    if (previousPrayerId != prayerId) {
      return false;
    }
    if (flattenedSections.isEmpty) {
      return false;
    }
    return _pageManager.isQueueReadyForSectionCount(flattenedSections.length);
  }

  Future<void> _stopPreviousPrayerAudioIfNeeded() async {
    final canContinueAudio =
        widget.continueAudio && FFAppState().currentPrayerId == widget.prayerId;
    if (canContinueAudio) {
      return;
    }

    await _pageManager.stop();
    if (_pageManager.hasActiveQueue) {
      await _pageManager.clearQueue();
    }
    _audioQueueInitialized = false;
    _audioQueueInitFuture = null;
    _pageManager.clearPendingTrackIndex();
    _pageManager.playButtonNotifier.value = ButtonState.paused;
    _pageManager.setTrackIndex(widget.page);
    _pageManager.currentProgressNotifier.value = Duration.zero;
    _pageManager.totalDurationNotifier.value = Duration.zero;
  }

  void _applyTrackIndexForOpen({required bool continuingExistingAudio}) {
    final maxIndex =
        flattenedSections.isEmpty ? 0 : flattenedSections.length - 1;
    if (continuingExistingAudio && _pageManager.hasActiveQueue) {
      if (_isAudioActivelyPlaying()) {
        return;
      }
      final currentIndex =
          _pageManager.trackIndexNotifier.value.clamp(0, maxIndex);
      if (_pageManager.trackIndexNotifier.value != currentIndex) {
        _pageManager.setTrackIndex(currentIndex);
      }
      return;
    }

    final targetIndex = widget.page.clamp(0, maxIndex);
    _pageManager.setTrackIndex(targetIndex);
  }

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
      _floatingControlsBackgroundOpacity.value = _floatingBackgroundOpacityIdle;
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
            onTap: () async {
              _onFloatingControlsInteraction();
              if (isPlaying) {
                _pageManager.pause();
              } else {
                await _pageManager.play();
              }
            },
            borderRadius: BorderRadius.circular(18.0),
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration:
                  _floatingControlDecoration(context, backgroundOpacity),
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

  Widget _buildFloatingChapterButton(
    BuildContext context,
    double backgroundOpacity,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          _onFloatingControlsInteraction();
          final chapterOptions =
              functions.convertPrayerSectionToChapterOption(flattenedSections);
          final index = await showModalBottomSheet<int>(
            context: context,
            isDismissible: true,
            useSafeArea: true,
            builder: (context) => ChooseChapterWidget(
              title:
                  '${_model.currentPrayer?.title ?? ''}${(_model.currentPrayer?.title.isNotEmpty ?? false) ? ' - ' : ''}${_model.currentPrayer?.subtitle ?? ''}',
              currentChapterIndex: _pageManager.trackIndexNotifier.value,
              chapterOptions: chapterOptions,
            ),
          );
          if (index != null) {
            await _pageManager.skipToIndex(index);
          }
        },
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          width: 36.0,
          height: 36.0,
          decoration: _floatingControlDecoration(context, backgroundOpacity),
          child: Icon(
            Icons.menu_book_rounded,
            color: FlutterFlowTheme.of(context).primary,
            size: 22.0,
          ),
        ),
      ),
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
              const SizedBox(height: 8.0),
              _buildFloatingChapterButton(context, backgroundOpacity),
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

  Duration? _sectionMediaDuration(PrayerSectionStruct section) {
    if (section.duration > 0) {
      return Duration(seconds: section.duration);
    }
    return null;
  }

  List<MediaItem> _hydrateMediaItemDurations(List<MediaItem> items) {
    if (flattenedSections.length != items.length) {
      return items;
    }

    return List.generate(items.length, (index) {
      final knownDuration = _sectionMediaDuration(flattenedSections[index]);
      if (knownDuration == null) {
        return items[index];
      }

      final currentDuration = items[index].duration;
      if (currentDuration != null && currentDuration > Duration.zero) {
        return items[index];
      }

      return items[index].copyWith(duration: knownDuration);
    });
  }

  Future<void> setInitialMediaItems() async {
    if (flattenedSections.isEmpty) {
      return;
    }

    final targetIndex = widget.page.clamp(0, flattenedSections.length - 1);
    _pageManager.setTrackIndex(targetIndex);

    final prayerId = _model.currentPrayer?.id ?? widget.prayerId ?? '';
    final mediaCache = getIt<MediaItemsCache>();
    final cachedItems = mediaCache.get(prayerId, flattenedSections.length);
    if (cachedItems != null) {
      await _pageManager.setQueue(_hydrateMediaItemDurations(cachedItems));
      return;
    }

    final hasAudio =
        flattenedSections.any((section) => section.audioUrl.isNotEmpty);
    // Local audio files are stored on device storage, which is unavailable on web.
    final documentsDir =
        hasAudio && !isWeb ? await getApplicationDocumentsDirectory() : null;
    final fallbackAudioUrl = flattenedSections
        .map((section) => section.audioUrl)
        .firstWhere((url) => url.isNotEmpty, orElse: () => '');
    final localFallbackPath =
        documentsDir != null && fallbackAudioUrl.isNotEmpty
            ? localAudioPathForUrl(fallbackAudioUrl, documentsDir)
            : null;

    final mediaItems = flattenedSections.map((section) {
      final artUri = section.imageUrl.isNotEmpty
          ? Uri.parse(section.imageUrl)
          : Uri.parse(
              'https://nrapqjwyqvwopwoxevlw.supabase.co/storage/v1/object/public/images/logo_new.jpg');

      if (!hasAudio) {
        return MediaItem(
          id: section.id,
          album: section.subtitle,
          artist: _model.currentPrayer?.title ?? '',
          title: section.title,
          artUri: artUri,
          duration: _sectionMediaDuration(section),
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
        duration: _sectionMediaDuration(section),
        extras: {
          'url': section.audioUrl,
          'isDownloaded': filePath != null,
          'filePath': filePath ?? '',
          'fallbackUrl': localFallbackPath ?? fallbackAudioUrl,
          'fallbackIsLocal': localFallbackPath != null,
        },
      );
    }).toList();

    mediaCache.put(prayerId, flattenedSections.length, mediaItems);
    await _pageManager.setQueue(mediaItems);
  }

  Future<bool> _initializeAudioQueue() async {
    try {
      await setInitialMediaItems().timeout(const Duration(seconds: 45));
      return _isAudioQueueReady();
    } catch (error, stackTrace) {
      debugPrint('Audio queue initialization failed: $error\n$stackTrace');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RosaryPageModel());
    _allowScroll.addListener(_onAllowScrollChanged);
    _displayingAudio = FFAppState().isDisplayingAudio;
    FFAppState().addListener(_onAppStateChanged);
    _pageManager.ensureQueueBeforePlay = _ensureAudioQueueInitialized;

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final previousPrayerId = FFAppState().currentPrayerId;
      await _stopPreviousPrayerAudioIfNeeded();
      FFAppState().currentPrayerId = widget.prayerId ?? '';

      if (FFAppState().downloadedPrayers.any((e) => e.id == widget.prayerId)) {
        _model.currentPrayer =
            await getIt<DownloadedPrayerRepository>().loadFullPrayer(
          widget.prayerId!,
        );
        if (_model.currentPrayer != null) {
          _prayerCache.seed(widget.prayerId!, _model.currentPrayer!);
        }
      } else {
        _model.currentPrayer = await _prayerCache.loadPrayer(widget.prayerId!);
      }

      flattenedSections = functions.flattenSectionsList(
              _model.currentPrayer?.sections.toList() ?? []) ??
          [];

      final continuingExistingAudio =
          _canContinueExistingAudio(previousPrayerId: previousPrayerId);
      _applyTrackIndexForOpen(
        continuingExistingAudio: continuingExistingAudio,
      );

      _syncDisplayModeForPrayer(
        continuingExistingAudio: continuingExistingAudio,
      );

      await _prepareAudioForOpen(
        continuingExistingAudio: continuingExistingAudio,
      );
      await _preloadInitialSection();

      if (!mounted) {
        return;
      }

      setState(() => _pageReady = true);

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
    if (_pageManager.ensureQueueBeforePlay == _ensureAudioQueueInitialized) {
      _pageManager.ensureQueueBeforePlay = null;
    }
    FFAppState().removeListener(_onAppStateChanged);
    _floatingControlsIdleTimer?.cancel();
    _floatingControlsBackgroundOpacity.dispose();
    _scrollController.dispose();
    _chromeVisible.dispose();
    _allowScroll.removeListener(_onAllowScrollChanged);
    _allowScroll.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get _isTextMode => !_displayingAudio;

  bool _showAppChrome(bool chromeVisible) => !_isTextMode || chromeVisible;

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
      child: ColoredBox(
          color: _isTextMode && !_chromeVisible.value
              ? FlutterFlowTheme.of(context).primaryBackground
              : FlutterFlowTheme.of(context).primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerLoaded = _pageReady;

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

    return PrayerTypographyScope(
      child: GestureDetector(
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
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(
                                  context,
                                ),
                                sliver: SliverAppBar(
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).primary,
                                  automaticallyImplyLeading: false,
                                  floating: false,
                                  pinned: true,
                                  snap: false,
                                  leading: IconButton(
                                    onPressed: () {
                                      context.safePop();
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      size: 24.0,
                                    ),
                                    iconSize: 24.0,
                                  ),
                                  iconTheme: IconThemeData(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate),
                                  title: Builder(
                                    builder: (context) {
                                      final typography =
                                          PrayerTypography.of(context);
                                      final theme =
                                          FlutterFlowTheme.of(context);
                                      return AutoSizeText(
                                        valueOrDefault<String>(
                                          _model.currentPrayer?.title,
                                          '',
                                        ),
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        minFontSize: 16.0,
                                        style: typography
                                            .style(
                                              theme.headlineMedium,
                                              fontSize: 20.0,
                                              scaleFontSize: false,
                                            )
                                            .copyWith(
                                              color: theme.alternate,
                                              letterSpacing: 0.0,
                                            ),
                                      );
                                    },
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if (!FFAppState().isDeviceOnline &&
                                            !isWeb)
                                          Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: const BoxDecoration(),
                                            child: AlignedTooltip(
                                              content: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  valueOrDefault<bool>(
                                                    FFAppState()
                                                        .downloadedPrayers
                                                        .map((e) => e.id)
                                                        .toList()
                                                        .contains(
                                                            (widget.prayerId!)),
                                                    false,
                                                  )
                                                      ? 'Disponibilă în mod offline.'
                                                      : 'Nedisponibilă în mod offline.',
                                                  style: PrayerTypography.of(
                                                          context)
                                                      .style(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyLarge,
                                                        scaleFontSize: false,
                                                      )
                                                      .copyWith(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                              offset: 2.0,
                                              preferredDirection:
                                                  AxisDirection.down,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              elevation: 4.0,
                                              tailBaseWidth: 24.0,
                                              tailLength: 12.0,
                                              waitDuration: const Duration(
                                                  milliseconds: 100),
                                              showDuration: const Duration(
                                                  milliseconds: 1500),
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              child: Builder(
                                                builder: (context) {
                                                  if (valueOrDefault<bool>(
                                                    FFAppState()
                                                        .downloadedPrayers
                                                        .map((e) => e.id)
                                                        .toList()
                                                        .contains(
                                                            (widget.prayerId!)),
                                                    false,
                                                  )) {
                                                    return Icon(
                                                      Icons
                                                          .download_done_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      size: 24.0,
                                                    );
                                                  } else {
                                                    return Icon(
                                                      Icons
                                                          .file_download_off_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
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
                                                builder: (context) =>
                                                    FlutterFlowIconButton(
                                                  borderRadius: 8.0,
                                                  buttonSize: 48.0,
                                                  icon: Icon(
                                                    Icons.more_vert_rounded,
                                                    color: _downloadManager
                                                                    .downloadStateNotifier
                                                                    .value !=
                                                                DownloadState
                                                                    .downloading &&
                                                            _downloadManager
                                                                    .downloadStateNotifier
                                                                    .value !=
                                                                DownloadState
                                                                    .loading
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .alternate
                                                        : Colors.transparent,
                                                    size: 24.0,
                                                  ),
                                                  onPressed: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      enableDrag: false,
                                                      useSafeArea: true,
                                                      context: context,
                                                      builder: (context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                PrayerOptionsWidget(
                                                              prayer: _model
                                                                  .currentPrayer!,
                                                              enableDownloadButton:
                                                                  FFAppState()
                                                                          .isDeviceOnline &&
                                                                      (!valueOrDefault<
                                                                          bool>(
                                                                        FFAppState()
                                                                            .downloadedPrayers
                                                                            .map((e) =>
                                                                                e.id)
                                                                            .contains((widget.prayerId!)),
                                                                        false,
                                                                      )),
                                                              currentPageIndex:
                                                                  _pageManager
                                                                      .trackIndexNotifier
                                                                      .value,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() => _model
                                                                .pressedButton =
                                                            value));

                                                    if (_model.pressedButton ==
                                                        'download') {
                                                      safeSetState(() {});
                                                      await _downloadManager
                                                          .downloadPrayer(
                                                        context: context,
                                                        prayer: _model
                                                            .currentPrayer!,
                                                      );
                                                    } else if (_model
                                                            .pressedButton ==
                                                        'share') {
                                                      if (!isWeb) {
                                                        await SharePlus.instance
                                                            .share(
                                                          ShareParams(
                                                            text:
                                                                'Descoperă rugăciunea „${_model.currentPrayer?.title}” în aplicația „Rugăciuni și Cântări - CMD”! \nDescarcă aplicația din  App Store sau Google Play: '
                                                                '\nhttps://play.google.com/store/apps/details?id=com.surorilecmd.rugaciunisicantari'
                                                                '\nhttps://apps.apple.com/app/rugaciunisicantaricmd/id6758237098',
                                                            subject: _model
                                                                .currentPrayer
                                                                ?.title,
                                                            title:
                                                                'Descoperă „${_model.currentPrayer?.title}” în aplicația „Rugăciuni și Cântări - CMD”!',
                                                            sharePositionOrigin:
                                                                getWidgetBoundingBox(
                                                                    context),
                                                          ),
                                                        );
                                                      }
                                                    } else if (_model
                                                            .pressedButton ==
                                                        'save') {
                                                      FFAppState().savedPrayer =
                                                          SavedPrayerDataStruct(
                                                        prayer: _model
                                                            .currentPrayer,
                                                        page: _pageManager
                                                            .trackIndexNotifier
                                                            .value,
                                                        audioTime: _pageManager
                                                            .currentProgressNotifier
                                                            .value
                                                            .inSeconds,
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .clearSnackBars();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Semnul de carte către ${_model.currentPrayer!.title.isNotEmpty ? '„${_model.currentPrayer!.title}” - ' : ''}„${flattenedSections.elementAtOrNull(_pageManager.trackIndexNotifier.value)?.title}” a fost salvat!',
                                                            style: PrayerTypography
                                                                    .of(context)
                                                                .style(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium,
                                                                  scaleFontSize:
                                                                      false,
                                                                )
                                                                .copyWith(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .alternate,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      5000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          action:
                                                              SnackBarAction(
                                                            label: 'Anulează',
                                                            textColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                            onPressed:
                                                                () async {
                                                              FFAppState()
                                                                  .deleteSavedPrayer();
                                                              FFAppState()
                                                                      .savedPrayer =
                                                                  SavedPrayerDataStruct();
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    } else if (_model
                                                            .pressedButton ==
                                                        'clear_save') {
                                                      FFAppState()
                                                          .deleteSavedPrayer();
                                                      FFAppState().savedPrayer =
                                                          SavedPrayerDataStruct();
                                                    } else if (_model
                                                            .pressedButton ==
                                                        'reminder') {
                                                      final prayer =
                                                          _model.currentPrayer;
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
                                                  child:
                                                      DownloadProgressIndicator())
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
                                    prayerSubtitle:
                                        _model.currentPrayer?.subtitle,
                                    controlBarVisibilityNotifier:
                                        _chromeVisible,
                                    allowScrollNotifier: _allowScroll,
                                  );
                                }

                                return Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: SizedBox(
                                    width: 64.0,
                                    height: 64.0,
                                    child: custom_widgets
                                        .CustomCircularProgressIndicator(
                                      width: 64.0,
                                      height: 64.0,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
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
                          final topInset =
                              MediaQuery.viewPaddingOf(context).top;
                          final top =
                              topInset + (_chromeVisible.value ? 72.0 : 8.0);
                          final showPlayPause =
                              !chromeVisible && sectionHasAudio;
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
      ),
    );
  }
}
