import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/prayer/section_text_formatting.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/prayer_typography.dart';
import '/components/section_text/cached_section_image.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'audio_page_model.dart';

export 'audio_page_model.dart';

class AudioPageWidget extends StatefulWidget {
  const AudioPageWidget({
    super.key,
    String? title,
    String? subtitle,
    String? audioUrl,
    required this.onAudioTimeChanged,
    required this.imageUrls,
    required this.imageUrl,
    this.texts,
  })  : title = title ?? 'Titlu',
        subtitle = subtitle ?? 'Subtitlu',
        audioUrl = audioUrl ?? '';

  final String title;
  final String subtitle;
  final Future Function(int selectedAudioTime)? onAudioTimeChanged;
  final String? imageUrl;
  final List<String> imageUrls;
  final List<SectionTextStruct>? texts;
  final String? audioUrl;

  @override
  State<AudioPageWidget> createState() => _AudioPageWidgetState();
}

class _AudioPageWidgetState extends State<AudioPageWidget> {
  late AudioPageModel _model;
  final _pageManager = getIt<PageManager>();
  PageController? _pageViewController;
  int _currentSection = 0;
  bool _isSliding = false;
  int _slideAudioTime = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AudioPageModel());
    _currentSection = _pageManager.trackIndexNotifier.value;
    _pageViewController =
        PageController(initialPage: _pageManager.trackIndexNotifier.value);
    _pageManager.trackIndexNotifier.addListener(_onTrackIndexChanged);
  }

  void _onTrackIndexChanged() {
    final target = _pageManager.trackIndexNotifier.value;
    if (_currentSection == target) {
      return;
    }
    _currentSection = target;
    final controller = _pageViewController;
    if (controller == null || !controller.hasClients) {
      return;
    }
    final currentPageIndex = controller.page?.round() ?? 0;
    if ((target - currentPageIndex).abs() > 5) {
      controller.jumpToPage(target);
    } else {
      controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  @override
  void dispose() {
    _pageManager.trackIndexNotifier.removeListener(_onTrackIndexChanged);
    _pageViewController?.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  static const double _sectionTitleSize = 22.0;
  static const double _sectionSubtitleSize = 16.0;

  double _headerImageSize(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return math.min(screenHeight * 0.26, 260.0);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    PrayerTypography typography,
  ) {
    final imageSize = _headerImageSize(context);
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Hero(
          tag: 'sectionImageHero',
          child: SizedBox(
            height: imageSize,
            child: PageView.builder(
              controller: _pageViewController,
              onPageChanged: (pageIndex) async {
                _currentSection = pageIndex;
                await _pageManager.skipToIndex(pageIndex);
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return Center(
                  child: CachedSectionImage(
                    imageUrl: widget.imageUrls[index],
                    width: imageSize,
                    height: imageSize,
                    borderRadius: BorderRadius.circular(imageSize * 0.3),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32.0),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: typography.style(
            theme.headlineSmall,
            fontSize: _sectionTitleSize,
            scaleFontSize: false,
            letterSpacing: 0.0,
          ),
        ),
        if (widget.subtitle.isNotEmpty) ...[
          const SizedBox(height: 6.0),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: typography.style(
              theme.bodyLarge,
              fontSize: _sectionSubtitleSize,
              scaleFontSize: false,
              color: theme.secondaryText,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds >= 3600 ? '${seconds ~/ 3600}:' : '';
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.audioUrl != null && widget.audioUrl!.isNotEmpty;
    // Ensure this subtree rebuilds when the app font changes.
    final typography = PrayerTypography.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: FlutterFlowTheme.of(context).primaryBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: _buildSectionHeader(context, typography),
                ),
              ),
            ),
            if (hasAudio)
              _AudioControlsPanel(
                pageManager: _pageManager,
                texts: widget.texts,
                isSliding: _isSliding,
                slideAudioTime: _slideAudioTime,
                onSlideStart: (value) async {
                  setState(() {
                    _isSliding = true;
                    _slideAudioTime = functions.doubleToInt(value);
                  });
                },
                onSlideEnd: (value) async {
                  await widget.onAudioTimeChanged?.call(
                    functions.doubleToInt(value),
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _isSliding = false;
                    _slideAudioTime = 0;
                  });
                },
                onSeekToText: (time) async {
                  await widget.onAudioTimeChanged?.call(time);
                },
                formatTime: _formatTime,
              ),
          ],
        ),
      ),
    );
  }
}

class _AudioControlsPanel extends StatelessWidget {
  const _AudioControlsPanel({
    required this.pageManager,
    required this.texts,
    required this.isSliding,
    required this.slideAudioTime,
    required this.onSlideStart,
    required this.onSlideEnd,
    required this.onSeekToText,
    required this.formatTime,
  });

  final PageManager pageManager;
  final List<SectionTextStruct>? texts;
  final bool isSliding;
  final int slideAudioTime;
  final Future<void> Function(double value) onSlideStart;
  final Future<void> Function(double value) onSlideEnd;
  final Future<void> Function(int time)? onSeekToText;
  final String Function(int seconds) formatTime;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final typography = PrayerTypography.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (texts != null && texts!.isNotEmpty)
          _AudioTextNavigationRow(
            pageManager: pageManager,
            texts: texts!,
            isSliding: isSliding,
            slideAudioTime: slideAudioTime,
            onSeekToText: onSeekToText,
          ),
        ValueListenableBuilder<Duration>(
          valueListenable: pageManager.currentProgressNotifier,
          builder: (context, progress, _) {
            return ValueListenableBuilder<Duration>(
              valueListenable: pageManager.bufferedTimeNotifier,
              builder: (context, buffered, __) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: pageManager.totalDurationNotifier,
                  builder: (context, total, ___) {
                    final currentSeconds = isSliding
                        ? slideAudioTime
                        : progress.inSeconds;
                    final totalSeconds = total.inSeconds;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 32.0,
                          child: custom_widgets.CustomSlider(
                            width: double.infinity,
                            height: 32.0,
                            sliderValue: currentSeconds.toDouble(),
                            bufferValue: buffered.inSeconds,
                            minValue: 0,
                            maxValue: totalSeconds,
                            onValueChange: onSlideStart,
                            onValueChangeEnd: onSlideEnd,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatTime(currentSeconds),
                                style: typography.style(
                                  theme.bodySmall,
                                  scaleFontSize: false,
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              Text(
                                formatTime(totalSeconds),
                                style: typography.style(
                                  theme.bodySmall,
                                  scaleFontSize: false,
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AudioTextNavigationRow extends StatefulWidget {
  const _AudioTextNavigationRow({
    required this.pageManager,
    required this.texts,
    required this.isSliding,
    required this.slideAudioTime,
    required this.onSeekToText,
  });

  final PageManager pageManager;
  final List<SectionTextStruct> texts;
  final bool isSliding;
  final int slideAudioTime;
  final Future<void> Function(int time)? onSeekToText;

  @override
  State<_AudioTextNavigationRow> createState() =>
      _AudioTextNavigationRowState();
}

class _AudioTextNavigationRowState extends State<_AudioTextNavigationRow> {
  int _lastRenderedIndex = -2;

  @override
  void initState() {
    super.initState();
    widget.pageManager.currentProgressNotifier.addListener(_onProgressChanged);
  }

  @override
  void didUpdateWidget(_AudioTextNavigationRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSliding != oldWidget.isSliding ||
        widget.slideAudioTime != oldWidget.slideAudioTime) {
      _maybeUpdate();
    }
  }

  @override
  void dispose() {
    widget.pageManager.currentProgressNotifier
        .removeListener(_onProgressChanged);
    super.dispose();
  }

  int _activeIndex() {
    final audioTime = widget.isSliding
        ? widget.slideAudioTime
        : widget.pageManager.currentProgressNotifier.value.inSeconds;
    return findActiveTextIndex(widget.texts, audioTime);
  }

  void _onProgressChanged() {
    _maybeUpdate();
  }

  void _maybeUpdate() {
    final index = _activeIndex();
    if (index != _lastRenderedIndex) {
      setState(() => _lastRenderedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _activeIndex();
    if (index < 0 || index >= widget.texts.length) {
      return const SizedBox.shrink();
    }

    final currentText = widget.texts[index];
    final theme = FlutterFlowTheme.of(context);
    final typography = PrayerTypography.of(context);
    final iconButtonStyle = IconButton.styleFrom(
      foregroundColor: theme.secondary,
      disabledForegroundColor: theme.secondaryText.withValues(alpha: 0.45),
      minimumSize: const Size(32.0, 32.0),
      padding: EdgeInsets.zero,
    );

    final hasPrevious = index > 0;
    final hasNext = index < widget.texts.length - 1;

    return Padding(
      padding: hasNext || hasPrevious ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if(!hasPrevious) 
            const SizedBox(width: 48.0,),
          if (hasPrevious) 
            IconButton(
              style: iconButtonStyle,
              onPressed: () async {
                await widget.onSeekToText
                    ?.call(widget.texts[index - 1].startTime);
              },
              icon: const Icon(Icons.skip_previous_rounded, size: 24.0),
            ),
            
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await widget.onSeekToText?.call(currentText.startTime);
              },
              child: AutoSizeText(
                formatSectionTextDisplayTitle(currentText),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: typography.style(
                  theme.titleSmall,
                  scaleFontSize: false,
                  color: theme.secondary,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if(!hasNext) 
            const SizedBox(width: 48.0,),
          if (hasNext)
            IconButton(
              style: iconButtonStyle,
              onPressed: () async {
                await widget.onSeekToText
                    ?.call(widget.texts[index + 1].startTime);
              },
              icon: const Icon(Icons.skip_next_rounded, size: 24.0),
            ),
        ],
      ),
    );
  }
}
