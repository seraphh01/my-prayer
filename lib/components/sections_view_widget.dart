import 'dart:async';

import 'package:collection/collection.dart';
import 'package:my_prayer/components/choose_chapter_widget.dart';
import 'package:my_prayer/custom_code/audio/notifiers/play_button_notifier.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/prayer/prayer_section_content_cache.dart';
import 'package:my_prayer/custom_code/prayer/prayer_typography.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/components/audio_page_widget.dart';
import '/components/empty_list_component_widget.dart';
import '/components/section_text/prayer_text_styles.dart';
import '/components/section_text/section_header_widget.dart';
import '/components/section_text/section_text_block_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'sections_view_model.dart';
export 'sections_view_model.dart';

class SectionsViewWidget extends StatefulWidget {
  const SectionsViewWidget({
    super.key,
    this.sections,
    this.prayerTitle,
    this.prayerSubtitle,
    this.controlBarVisibilityNotifier,
    this.allowScrollNotifier,
  });

  final List<PrayerSectionStruct>? sections;
  final String? prayerTitle;
  final String? prayerSubtitle;
  final ValueNotifier<bool>? controlBarVisibilityNotifier;
  final ValueNotifier<bool>? allowScrollNotifier;

  @override
  State<SectionsViewWidget> createState() => _SectionsViewWidgetState();
}

class _SectionsViewWidgetState extends State<SectionsViewWidget> {
  late SectionsViewModel _model;
  ScrollController? _primaryScrollController;
  int currentPlayingTextIndex = 0;
  int currentSectionIndex = 0;
  late final ValueNotifier<bool> _controlBarVisibility;
  final Map<int, List<GlobalKey>> _keys = {};

  final _pageManager = getIt<PageManager>();
  final _sectionCache = getIt<PrayerSectionContentCache>();
  final ValueNotifier<bool> _isContentLoading = ValueNotifier(false);
  bool _hasInitialContent = false;

  Timer? _scrollDebounce;
  Timer? _scrollbarHideTimer;
  bool _scrollbarThumbVisible = false;
  static const Duration _scrollbarHideDelay = Duration(seconds: 1);

  void _markContentReady() {
    _model.isLoading = false;
    _hasInitialContent = true;
    if (_isContentLoading.value) {
      _isContentLoading.value = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _hydrateInitialSectionFromCache() {
    final index = _pageManager.trackIndexNotifier.value;
    final section = _model.flattenedSections.elementAtOrNull(index);
    if (section == null) {
      return;
    }

    final cached = _sectionCache.cachedTexts(section.sectionId);
    if (cached != null) {
      section.texts = cached;
      _model.currentSection = section;
      currentSectionIndex = index;
      setTextKeys(index, section.texts.length);
      _updatePlaybackHighlight();
      _markContentReady();
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _primaryScrollController = PrimaryScrollController.of(context);
  }

  ScrollController? _getActiveScrollController() => _primaryScrollController;

  void _onScrollbarActivity() {
    _scrollbarHideTimer?.cancel();
    if (!_scrollbarThumbVisible && mounted) {
      setState(() => _scrollbarThumbVisible = true);
    }
    _scrollbarHideTimer = Timer(_scrollbarHideDelay, () {
      if (mounted) {
        setState(() => _scrollbarThumbVisible = false);
      }
    });
  }

  double _scrollbarTopPadding(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    if (!_needsScrollOverlap) {
      return topInset;
    }
    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final extent = handle.layoutExtent;
    if (extent != null && extent > 0) {
      return extent;
    }
    return topInset + 64.0;
  }

  Widget _buildTextScrollView({required List<Widget> slivers}) {
    final controller = _getActiveScrollController();
    final theme = FlutterFlowTheme.of(context);
    final topPadding = _scrollbarTopPadding(context);

    final scrollView = CustomScrollView(
      primary: controller == null,
      controller: controller,
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );

    if (controller == null) {
      return scrollView;
    }

    final thumbColor = theme.primary.withValues(alpha: 0.45);

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(thumbColor),
          trackColor: WidgetStateProperty.all(Colors.transparent),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
          radius: const Radius.circular(8.0),
          thickness: WidgetStateProperty.all(5.0),
          crossAxisMargin: 2.0,
          mainAxisMargin: 4.0,
          interactive: true,
        ),
      ),
      child: RawScrollbar(
        controller: controller,
        thumbVisibility: _scrollbarThumbVisible,
        trackVisibility: false,
        interactive: true,
        thumbColor: thumbColor,
        thickness: 5.0,
        radius: const Radius.circular(8.0),
        padding: EdgeInsets.fromLTRB(0.0, topPadding, 2.0, 4.0),
        child: Listener(
          onPointerDown: (_) => _onScrollbarActivity(),
          onPointerMove: (_) => _onScrollbarActivity(),
          onPointerSignal: (_) => _onScrollbarActivity(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification ||
                  notification is ScrollUpdateNotification) {
                _onScrollbarActivity();
              }
              return false;
            },
            child: scrollView,
          ),
        ),
      ),
    );
  }

  bool get _needsScrollOverlap {
    if (FFAppState().isDisplayingAudio) {
      return true;
    }
    return _controlBarVisibility.value;
  }

  void _syncScrollWithHeader() {
    final controller = _getActiveScrollController();
    if (controller == null || !controller.hasClients) {
      return;
    }
    if (controller.offset != 0.0) {
      controller.jumpTo(0.0);
    }
  }

  void _onControlBarVisibilityChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncScrollWithHeader();
      setState(() {});
    });
  }

  void _setAllowScroll(bool allow) {
    if (widget.allowScrollNotifier == null) {
      return;
    }
    if (widget.allowScrollNotifier!.value == allow) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.allowScrollNotifier!.value = allow;
    });
  }

  void setTextKeys(int sectionIndex, int textCount) {
    final existing = _keys[sectionIndex];
    if (existing != null && existing.length == textCount) {
      return;
    }
    _keys[sectionIndex] = List.generate(textCount, (_) => GlobalKey());
  }

  Future<void> setCurrentSection(int sectionIndex) async {
    final section = _model.flattenedSections.elementAtOrNull(sectionIndex);
    if (section == null) {
      return;
    }

    final switchingSection =
        _hasInitialContent && sectionIndex != currentSectionIndex;
    if (switchingSection) {
      _isContentLoading.value = true;
    }

    if (section.texts.isNotEmpty) {
      _model.currentSection = section;
    } else {
      final cached = _sectionCache.cachedTexts(section.sectionId);
      if (cached != null) {
        section.texts = cached;
        _model.currentSection = section;
      } else {
        final texts = await _sectionCache.loadTexts(section.sectionId);
        section.texts = texts;
        _model.currentSection = section;
      }
    }

    currentSectionIndex = sectionIndex;
    setTextKeys(sectionIndex, _model.currentSection?.texts.length ?? 0);
    _updatePlaybackHighlight();
    _sectionCache.prefetchAdjacent(_model.flattenedSections, sectionIndex);
    _markContentReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncScrollWithHeader();
    });
  }

  GlobalKey getTextKey(int sectionIndex, int textIndex) {
    if (sectionIndex >= _model.flattenedSections.length) {
      return GlobalKey();
    }

    final texts = _model.flattenedSections[sectionIndex].texts;
    if (textIndex >= texts.length) {
      return GlobalKey();
    }

    setTextKeys(sectionIndex, texts.length);
    return _keys[sectionIndex]![textIndex];
  }

  bool get _isAudioSynced {
    final section = _model.currentSection;
    return section != null && section.audioUrl.isNotEmpty;
  }

  bool get _prayerHasAudio =>
      _model.flattenedSections.any((section) => section.audioUrl.isNotEmpty);

  bool get _isSingleSectionTextOnlyPrayer {
    final sections = _model.flattenedSections;
    if (sections.length != 1) {
      return false;
    }
    return !_prayerHasAudio && sections.first.texts.isNotEmpty;
  }

  bool get _shouldShowControlBar =>
      !_isSingleSectionTextOnlyPrayer &&
      (_model.displayAudioPage || _controlBarVisibility.value);

  void _updatePlaybackHighlight() {
    final texts = _model.currentSection?.texts ?? const <SectionTextStruct>[];
    final audioTime = _pageManager.currentProgressNotifier.value.inSeconds;
    _pageManager.playbackHighlightNotifier.updateFromTexts(
      texts: texts,
      audioTimeSeconds: audioTime,
      isAudioSynced: _isAudioSynced,
    );
  }

  void onTrackIndexChanged() async {
    if (currentSectionIndex == _pageManager.trackIndexNotifier.value) {
      return;
    }
    final controller = _getActiveScrollController();
    if (controller != null && controller.hasClients) {
      controller.jumpTo(0.0);
    }

    _isContentLoading.value = true;
    await setCurrentSection(_pageManager.trackIndexNotifier.value);
    currentPlayingTextIndex =
        _pageManager.playbackHighlightNotifier.value.activeTextIndex;
  }

  void _scheduleScrollToActiveText() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 300), _scrollToActiveText);
  }

  void _scrollToActiveText() {
    if (_pageManager.playButtonNotifier.value != ButtonState.playing ||
        _model.displayAudioPage) {
      return;
    }

    final controller = _getActiveScrollController();
    if (controller == null || !controller.hasClients) {
      return;
    }

    if (currentPlayingTextIndex <= 0) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      return;
    }

    final blockContext =
        getTextKey(currentSectionIndex, currentPlayingTextIndex).currentContext;
    if (blockContext != null) {
      Scrollable.ensureVisible(
        blockContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        alignment: 0.15,
      );
    }
  }

  void onCurrentAudioTimeChanged() {
    _updatePlaybackHighlight();

    if (_pageManager.playButtonNotifier.value != ButtonState.playing ||
        _model.displayAudioPage) {
      return;
    }

    final activeIndex =
        _pageManager.playbackHighlightNotifier.value.activeTextIndex;
    if (activeIndex != currentPlayingTextIndex) {
      currentPlayingTextIndex = activeIndex;
      _scheduleScrollToActiveText();
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SectionsViewModel());
    _controlBarVisibility =
        widget.controlBarVisibilityNotifier ?? ValueNotifier(true);
    _controlBarVisibility.addListener(_onControlBarVisibilityChanged);

    _model.flattenedSections = functions
        .flattenSectionsList(widget.sections!.toList())!
        .toList()
        .cast<PrayerSectionStruct>();
    _model.chapterOptions =
        functions.convertPrayerSectionToChapterOption(widget.sections!);

    _hydrateInitialSectionFromCache();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (_model.currentSection != null) {
        _sectionCache.prefetchAdjacent(
          _model.flattenedSections,
          currentSectionIndex,
        );
        return;
      }
      await setCurrentSection(_pageManager.trackIndexNotifier.value);
    });

    if (_isSingleSectionTextOnlyPrayer || !_prayerHasAudio) {
      _model.displayAudioPage = false;
      FFAppState().isDisplayingAudio = false;
    } else {
      _model.displayAudioPage = FFAppState().isDisplayingAudio;
    }

    _pageManager.trackIndexNotifier.addListener(onTrackIndexChanged);
    _pageManager.currentProgressNotifier.addListener(onCurrentAudioTimeChanged);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollbarHideTimer?.cancel();
    _isContentLoading.dispose();
    _model.maybeDispose();
    _pageManager.trackIndexNotifier.removeListener(onTrackIndexChanged);
    _pageManager.currentProgressNotifier
        .removeListener(onCurrentAudioTimeChanged);
    _controlBarVisibility.removeListener(_onControlBarVisibilityChanged);
    if (widget.controlBarVisibilityNotifier == null) {
      _controlBarVisibility.dispose();
    }
    super.dispose();
  }

  List<Widget> _buildTextSlivers(
    BuildContext context,
    PrayerSectionStruct section,
    PrayerTextStyles styles,
  ) {
    final texts = section.texts;
    final highlightListenable = _pageManager.playbackHighlightNotifier;
    final isAudioSynced = _isAudioSynced;

    return [
      if (_needsScrollOverlap)
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
      SliverToBoxAdapter(
        child: SectionHeaderWidget(section: section),
      ),
      if (texts.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: SizedBox(
              width: double.infinity,
              height: 300.0,
              child: EmptyListComponentWidget(
                title: 'Textul nu a putut fi încărcat!',
                subtitle: 'Vă rugăm încercați mai târziu.',
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, textIndex) {
                final text = texts[textIndex];
                return SectionTextBlockWidget(
                  blockKey: getTextKey(currentSectionIndex, textIndex),
                  text: text,
                  textIndex: textIndex,
                  highlightListenable: highlightListenable,
                  isAudioSynced: isAudioSynced,
                  initiallyExpanded: !isAudioSynced,
                  styles: styles,
                  onSeekBlock: () async {
                    currentPlayingTextIndex = textIndex;
                    await _pageManager.seek(Duration(seconds: text.startTime));
                    _updatePlaybackHighlight();
                  },
                  onSeekElement: (elementStartTime) async {
                    currentPlayingTextIndex = textIndex;
                    final seekTime = text.startTime + elementStartTime;
                    await _pageManager.seek(Duration(seconds: seekTime));
                    _updatePlaybackHighlight();
                  },
                );
              },
              childCount: texts.length,
            ),
          ),
        ),
      const SliverPadding(padding: EdgeInsets.only(bottom: 16.0)),
    ];
  }

  Widget _buildTextContent(
    BuildContext context,
    PrayerSectionStruct section,
  ) {
    final styles = PrayerTextStyles.of(context);
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(),
      child: _buildTextScrollView(
        slivers: _buildTextSlivers(context, section, styles),
      ),
    );
  }

  Widget _buildAudioContent(PrayerSectionStruct section) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(),
      child: wrapWithModel(
        model: _model.audioPageModels.getModel(
          section.id,
          currentSectionIndex,
        ),
        updateCallback: () {
          safeSetState(() {});
        },
        updateOnChange: true,
        child: AudioPageWidget(
          key: const Key('Keyvha_audioPage'),
          title: valueOrDefault<String>(section.title, 'Titlu'),
          audioUrl: section.audioUrl,
          subtitle: section.subtitle,
          imageUrl: section.imageUrl,
          onAudioTimeChanged: (selectedAudioTime) async {
            await getIt<PageManager>()
                .seek(Duration(seconds: selectedAudioTime));
            _updatePlaybackHighlight();
          },
          imageUrls:
              _model.flattenedSections.map((s) => s.imageUrl).toList(),
          texts: section.texts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrayerTypographyScope(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Builder(
              builder: (context) {
                if (_model.flattenedSections.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: [
                      Builder(
                        builder: (context) {
                          if (_model.currentSection == null) {
                            _setAllowScroll(true);
                            return const SizedBox.shrink();
                          }

                          final section = _model.currentSection!;
                          final hasAudioContent = section.audioUrl.isNotEmpty;
                          final isAudioPage =
                              _model.displayAudioPage && hasAudioContent;
                          _setAllowScroll(!isAudioPage);

                          final showTextPage = (!_model.displayAudioPage ||
                                  !hasAudioContent) &&
                              section.texts.isNotEmpty;

                          if (showTextPage) {
                            return _buildTextContent(context, section);
                          }
                          return _buildAudioContent(section);
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isContentLoading,
                        builder: (context, isLoading, _) {
                          if (!isLoading || !_hasInitialContent) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                            child: Align(
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
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _controlBarVisibility,
            builder: (context, showControlBar, child) {
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              final effectiveShowControlBar =
                  _shouldShowControlBar &&
                  (_model.displayAudioPage || showControlBar);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: effectiveShowControlBar ? 80.0 + bottomInset : 0.0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  offset: effectiveShowControlBar
                      ? Offset.zero
                      : const Offset(0.0, 1.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    opacity: effectiveShowControlBar ? 1.0 : 0.0,
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        height: 80.0,
                        child: custom_widgets.SectionsControlBar(
                            width: double.infinity,
                            height: double.infinity,
                            showingTextContent: !_model.displayAudioPage,
                            playbackRate: valueOrDefault<double>(
                              FFAppState().audioSpeed,
                              1.0,
                            ),
                            hasAudioContent:
                                _model.currentSection?.audioUrl.isNotEmpty ??
                                    false,
                            hasTextContent:
                                _model.currentSection?.texts.isNotEmpty ??
                                    false,
                            switchContent: () async {
                              currentPlayingTextIndex = -1;
                              _model.displayAudioPage =
                                  !_model.displayAudioPage;
                              FFAppState().isDisplayingAudio =
                                  _model.displayAudioPage;
                              safeSetState(() {});
                            },
                            chooseChapter: () async {
                              final index =
                                  await showModalBottomSheet<int>(
                                isDismissible: true,
                                useSafeArea: true,
                                context: context,
                                builder: (context) {
                                  return ChooseChapterWidget(
                                    title:
                                        "${widget.prayerTitle}${widget.prayerTitle!.isNotEmpty ? ' - ' : ''}${widget.prayerSubtitle}",
                                    currentChapterIndex: _pageManager
                                        .trackIndexNotifier.value,
                                    chapterOptions: _model.chapterOptions,
                                  );
                                },
                              );
                              if (index == null) {
                                return;
                              }
                              await _pageManager.skipToIndex(index);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}
