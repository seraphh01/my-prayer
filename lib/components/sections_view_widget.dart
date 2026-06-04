import 'dart:async';

import 'package:collection/collection.dart';
import 'package:my_prayer/components/choose_chapter_widget.dart';
import 'package:my_prayer/custom_code/audio/notifiers/play_button_notifier.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/prayer/prayer_section_content_cache.dart';
import 'package:my_prayer/custom_code/prayer/reading_anchor_presets.dart';
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
  (int textIndex, int elementIndex) _scrollCursor = (-1, -1);
  int currentSectionIndex = 0;
  late final ValueNotifier<bool> _controlBarVisibility;
  final Map<int, List<GlobalKey>> _keys = {};
  final Map<int, List<List<GlobalKey>>> _elementKeys = {};

  final _pageManager = getIt<PageManager>();
  final _sectionCache = getIt<PrayerSectionContentCache>();
  final ValueNotifier<bool> _isContentLoading = ValueNotifier(false);
  bool _hasInitialContent = false;

  Timer? _clippedAboveDebounce;
  Timer? _scrollbarHideTimer;
  bool _scrollbarThumbVisible = false;
  static const Duration _scrollbarHideDelay = Duration(seconds: 1);
  static const Duration _clippedAboveRecoverDelay =
      Duration(milliseconds: 2500);
  /// Elements taller than this fraction of the visible viewport scroll to their top.
  static const double kLargeElementViewportRatio = 0.4;
  static const double kPaddingBelowAppBar = 12.0;
  static const double kAppBarToolbarHeight = 64.0;

  double get _readingAnchorAlignment => FFAppState().readingAnchorAlignment;

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
      _ensureElementKeys(index, section.texts);
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

  double _scrollTopInset(BuildContext context) {
    if (!_needsScrollOverlap) {
      return 0.0;
    }

    try {
      final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
      final extent = handle.layoutExtent;
      if (extent != null && extent > 0) {
        return extent;
      }
    } catch (_) {
      // Not under a NestedScrollView.
    }

    return MediaQuery.viewPaddingOf(context).top + kAppBarToolbarHeight;
  }

  double _scrollbarTopPadding(BuildContext context) {
    final topInset = _scrollTopInset(context);
    if (topInset > 0) {
      return topInset;
    }
    return MediaQuery.viewPaddingOf(context).top;
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
      _resetScrollCursor();
      _onHighlightCursorChanged();
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

  void _ensureElementKeys(int sectionIndex, List<SectionTextStruct> texts) {
    setTextKeys(sectionIndex, texts.length);

    final existing = _elementKeys[sectionIndex];
    if (existing != null && existing.length == texts.length) {
      var matches = true;
      for (var textIndex = 0; textIndex < texts.length; textIndex++) {
        if (existing[textIndex].length != texts[textIndex].textElements.length) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return;
      }
    }

    _elementKeys[sectionIndex] = texts
        .map(
          (text) => List.generate(
            text.textElements.length,
            (_) => GlobalKey(),
          ),
        )
        .toList();
  }

  GlobalKey getElementKey(
    int sectionIndex,
    int textIndex,
    int elementIndex,
  ) {
    if (sectionIndex >= _model.flattenedSections.length) {
      return GlobalKey();
    }

    final texts = _model.flattenedSections[sectionIndex].texts;
    if (textIndex >= texts.length) {
      return GlobalKey();
    }

    final elements = texts[textIndex].textElements;
    if (elementIndex >= elements.length) {
      return GlobalKey();
    }

    _ensureElementKeys(sectionIndex, texts);
    return _elementKeys[sectionIndex]![textIndex][elementIndex];
  }

  void _resetScrollCursor() {
    _scrollCursor = (-1, -1);
  }

  void _scrollAfterSeek() {
    _resetScrollCursor();
    _updatePlaybackHighlight();
    _onHighlightCursorChanged();
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
    final texts = _model.currentSection?.texts ?? const <SectionTextStruct>[];
    _ensureElementKeys(sectionIndex, texts);
    _updatePlaybackHighlight();
    _sectionCache.prefetchAdjacent(_model.flattenedSections, sectionIndex);
    _markContentReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (switchingSection) {
        _syncScrollWithHeader();
        _resetScrollCursor();
      }
      _onHighlightCursorChanged();
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
    _resetScrollCursor();
    await setCurrentSection(_pageManager.trackIndexNotifier.value);
  }

  ({RenderBox element, RenderBox viewport})? _elementScrollMetrics(
    BuildContext elementContext,
  ) {
    final elementBox = elementContext.findRenderObject() as RenderBox?;
    if (elementBox == null || !elementBox.hasSize) {
      return null;
    }

    final scrollable = Scrollable.maybeOf(elementContext);
    final viewportBox = scrollable?.context.findRenderObject() as RenderBox?;
    if (viewportBox == null) {
      return null;
    }

    return (element: elementBox, viewport: viewportBox);
  }

  bool _isLargeTextElement(
    RenderBox elementBox,
    RenderBox viewportBox,
    double topInset,
  ) {
    final viewportHeight = viewportBox.size.height;
    final effectiveHeight = (viewportHeight - topInset).clamp(1.0, viewportHeight);
    if (effectiveHeight <= 0) {
      return false;
    }

    final elementHeight = elementBox.size.height;
    if (elementHeight > effectiveHeight * kLargeElementViewportRatio) {
      return true;
    }

    final spaceBelowAnchor = effectiveHeight * (1.0 - _readingAnchorAlignment);
    return elementHeight > spaceBelowAnchor * 0.85;
  }

  double _alignmentForViewportY(double viewportHeight, double targetY) {
    if (viewportHeight <= 0) {
      return _readingAnchorAlignment;
    }
    return (targetY / viewportHeight).clamp(0.0, 1.0);
  }

  double _visibleContentTop(double topInset) => topInset + kPaddingBelowAppBar;

  double _elementTopInViewport(RenderBox elementBox, RenderBox viewportBox) {
    return elementBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
  }

  bool _isElementTopAboveVisibleArea(
    double elementTop,
    double topInset,
  ) {
    return elementTop < _visibleContentTop(topInset);
  }

  BuildContext? _activeHighlightedElementContext() {
    final highlight = _pageManager.playbackHighlightNotifier.value;
    final textIndex = highlight.activeTextIndex;
    final elementIndex = highlight.activeElementIndex;
    if (textIndex < 0 || elementIndex < 0) {
      return null;
    }

    return getElementKey(
      currentSectionIndex,
      textIndex,
      elementIndex,
    ).currentContext;
  }

  ({double alignment, bool skipScroll}) _scrollTargetForElement(
    BuildContext elementContext,
  ) {
    final metrics = _elementScrollMetrics(elementContext);
    if (metrics == null) {
      return (alignment: _readingAnchorAlignment, skipScroll: false);
    }

    final elementBox = metrics.element;
    final viewportBox = metrics.viewport;
    final viewportHeight = viewportBox.size.height;
    final topInset = _scrollTopInset(elementContext);
    final effectiveHeight =
        (viewportHeight - topInset).clamp(1.0, viewportHeight);
    final elementTop = _elementTopInViewport(elementBox, viewportBox);

    final targetTopY = _isLargeTextElement(elementBox, viewportBox, topInset)
        ? topInset + effectiveHeight * ReadingAnchorPresets.highAlignment + 32.0
        : topInset + effectiveHeight * _readingAnchorAlignment;
    final isTopAboveVisibleArea =
        _isElementTopAboveVisibleArea(elementTop, topInset);
    final elementBottom = elementTop + elementBox.size.height;
    final isBelowReadingAnchor = elementTop > targetTopY + 4.0;
    final isBelowVisibleViewport =
        elementBottom > viewportHeight - kPaddingBelowAppBar;
    final isAlreadyAtOrAboveAnchor = !isTopAboveVisibleArea &&
        !isBelowReadingAnchor &&
        !isBelowVisibleViewport &&
        elementTop <= targetTopY;

    return (
      alignment: _alignmentForViewportY(viewportHeight, targetTopY),
      skipScroll: isAlreadyAtOrAboveAnchor,
    );
  }

  void _scrollElementToTarget(
    BuildContext elementContext, {
    bool force = false,
    bool immediate = false,
  }) {
    final target = _scrollTargetForElement(elementContext);
    if (!force && target.skipScroll) {
      return;
    }

    Scrollable.ensureVisible(
      elementContext,
      alignment: target.alignment,
      duration: immediate
          ? Duration.zero
          : const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _maybeScheduleClippedAboveRecovery() {
    if (!_isTextAutoScrollEnabled ||
        _pageManager.playButtonNotifier.value != ButtonState.playing ||
        _model.displayAudioPage) {
      _clippedAboveDebounce?.cancel();
      _clippedAboveDebounce = null;
      return;
    }

    if (_clippedAboveDebounce?.isActive == true) {
      return;
    }

    final elementContext = _activeHighlightedElementContext();
    if (elementContext == null) {
      return;
    }

    final metrics = _elementScrollMetrics(elementContext);
    if (metrics == null) {
      return;
    }

    final topInset = _scrollTopInset(elementContext);
    final elementTop =
        _elementTopInViewport(metrics.element, metrics.viewport);
    if (!_isElementTopAboveVisibleArea(elementTop, topInset)) {
      return;
    }

    _clippedAboveDebounce = Timer(_clippedAboveRecoverDelay, () {
      _clippedAboveDebounce = null;
      _recoverIfActiveElementClippedAbove();
    });
  }

  void _recoverIfActiveElementClippedAbove() {
    if (!_isTextAutoScrollEnabled ||
        _pageManager.playButtonNotifier.value != ButtonState.playing ||
        _model.displayAudioPage) {
      return;
    }

    final elementContext = _activeHighlightedElementContext();
    if (elementContext == null) {
      return;
    }

    final metrics = _elementScrollMetrics(elementContext);
    if (metrics == null) {
      return;
    }

    final topInset = _scrollTopInset(elementContext);
    final elementTop =
        _elementTopInViewport(metrics.element, metrics.viewport);
    if (!_isElementTopAboveVisibleArea(elementTop, topInset)) {
      return;
    }

    _scrollElementToTarget(elementContext);
  }

  bool get _isTextAutoScrollEnabled => FFAppState().textAutoScrollEnabled;

  void _onReadingScrollSettingsChanged() {
    if (!_isTextAutoScrollEnabled) {
      _clippedAboveDebounce?.cancel();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _resetScrollCursor();
      _onHighlightCursorChanged();
    });
  }

  void _scheduleScrollAfterSwitchingToText() {
    _resetScrollCursor();
    if (!_isTextAutoScrollEnabled) {
      return;
    }
    _retryAlignActiveElementAfterShowingText(0);
  }

  void _retryAlignActiveElementAfterShowingText(int attempt) {
    if (attempt > 12 || !mounted || _model.displayAudioPage) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _model.displayAudioPage) {
        return;
      }

      final elementContext = _activeHighlightedElementContext();
      if (elementContext == null) {
        _retryAlignActiveElementAfterShowingText(attempt + 1);
        return;
      }

      _scrollElementToTarget(elementContext, force: true);
      final highlight = _pageManager.playbackHighlightNotifier.value;
      if (highlight.activeTextIndex >= 0 && highlight.activeElementIndex >= 0) {
        _scrollCursor = (
          highlight.activeTextIndex,
          highlight.activeElementIndex,
        );
      }
    });
  }

  void _scrollToActiveElementOnSelection({int attempt = 0}) {
    if (!_isTextAutoScrollEnabled || _model.displayAudioPage) {
      return;
    }

    final elementContext = _activeHighlightedElementContext();
    if (elementContext == null) {
      if (attempt < 8) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToActiveElementOnSelection(attempt: attempt + 1);
          }
        });
      }
      return;
    }

    _scrollElementToTarget(elementContext);
  }

  void _scrollOnElementSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _scrollToActiveElementOnSelection();
    });
  }

  void _onHighlightCursorChanged() {
    if (!_isTextAutoScrollEnabled || _model.displayAudioPage) {
      return;
    }

    final highlight = _pageManager.playbackHighlightNotifier.value;
    final textIndex = highlight.activeTextIndex;
    final elementIndex = highlight.activeElementIndex;
    if (textIndex < 0 || elementIndex < 0) {
      return;
    }

    if (textIndex != _scrollCursor.$1 || elementIndex != _scrollCursor.$2) {
      _scrollCursor = (textIndex, elementIndex);
      _clippedAboveDebounce?.cancel();
      _clippedAboveDebounce = null;
      _scrollOnElementSelected();
    }
  }

  void onCurrentAudioTimeChanged() {
    _updatePlaybackHighlight();

    if (_pageManager.playButtonNotifier.value != ButtonState.playing ||
        _model.displayAudioPage) {
      return;
    }

    _onHighlightCursorChanged();
    _maybeScheduleClippedAboveRecovery();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SectionsViewModel());
    _controlBarVisibility =
        widget.controlBarVisibilityNotifier ?? ValueNotifier(true);
    _controlBarVisibility.addListener(_onControlBarVisibilityChanged);
    FFAppState().addListener(_onReadingScrollSettingsChanged);

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
    _clippedAboveDebounce?.cancel();
    _scrollbarHideTimer?.cancel();
    _isContentLoading.dispose();
    _model.maybeDispose();
    _pageManager.trackIndexNotifier.removeListener(onTrackIndexChanged);
    _pageManager.currentProgressNotifier
        .removeListener(onCurrentAudioTimeChanged);
    _controlBarVisibility.removeListener(_onControlBarVisibilityChanged);
    FFAppState().removeListener(_onReadingScrollSettingsChanged);
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
                  elementKeyFor: isAudioSynced
                      ? (elementIndex) => getElementKey(
                            currentSectionIndex,
                            textIndex,
                            elementIndex,
                          )
                      : null,
                  onSeekBlock: () async {
                    await _pageManager.seek(Duration(seconds: text.startTime));
                    _scrollAfterSeek();
                  },
                  onSeekElement: (elementStartTime) async {
                    final seekTime = text.startTime + elementStartTime;
                    await _pageManager.seek(Duration(seconds: seekTime));
                    _scrollAfterSeek();
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
                              final leavingAudioPage = _model.displayAudioPage;
                              _model.displayAudioPage =
                                  !_model.displayAudioPage;
                              FFAppState().isDisplayingAudio =
                                  _model.displayAudioPage;
                              safeSetState(() {});
                              if (leavingAudioPage) {
                                _scheduleScrollAfterSwitchingToText();
                              } else {
                                _resetScrollCursor();
                              }
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
