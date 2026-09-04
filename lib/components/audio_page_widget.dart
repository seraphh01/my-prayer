import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/prayer/section_text_formatting.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/prayer_typography.dart';
import '/components/section_text/cached_section_image.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'audio_page_model.dart';

export 'audio_page_model.dart';

class AudioPageWidget extends StatefulWidget {
  const AudioPageWidget({
    super.key,
    String? prayerTitle,
    String? prayerSubtitle,
    String? audioUrl,
    required this.onAudioTimeChanged,
    required this.imageUrls,
    required this.imageUrl,
    this.texts,
    this.sections = const [],
  })  : prayerTitle = prayerTitle ?? '',
        prayerSubtitle = prayerSubtitle ?? '',
        audioUrl = audioUrl ?? '';

  final String prayerTitle;
  final String prayerSubtitle;
  final Future Function(int selectedAudioTime)? onAudioTimeChanged;
  final String? imageUrl;
  final List<String> imageUrls;
  final List<SectionTextStruct>? texts;
  final String? audioUrl;
  final List<PrayerSectionStruct> sections;

  @override
  State<AudioPageWidget> createState() => _AudioPageWidgetState();
}

class _AudioPageWidgetState extends State<AudioPageWidget> {
  late AudioPageModel _model;
  final _pageManager = getIt<PageManager>();
  PageController? _pageViewController;
  late final ScrollController _sectionListController;
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AudioPageModel());
    _currentSection = _pageManager.trackIndexNotifier.value;
    _pageViewController =
        PageController(initialPage: _pageManager.trackIndexNotifier.value);
    _sectionListController = ScrollController();
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
    controller.jumpToPage(target);
  }

  @override
  void dispose() {
    _pageManager.trackIndexNotifier.removeListener(_onTrackIndexChanged);
    _pageViewController?.dispose();
    _sectionListController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  double _headerImageSize(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return math.min(screenHeight * 0.26, 260.0);
  }

  Widget _buildAlbumHeader(
    BuildContext context,
    PrayerTypography typography,
  ) {
    final theme = FlutterFlowTheme.of(context);
    final imageSize = _headerImageSize(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Hero(
            tag: 'sectionImageHero',
            child: PageView.builder(
              controller: _pageViewController,
              onPageChanged: (pageIndex) async {
                _currentSection = pageIndex;
                await _pageManager.skipToIndex(pageIndex);
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return CachedSectionImage(
                  imageUrl: widget.imageUrls[index],
                  width: imageSize,
                  height: imageSize,
                  borderRadius: BorderRadius.circular(imageSize * 0.3),
                );
              },
            ),
          ),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _pageManager.trackIndexNotifier,
          builder: (context, activeIndex, _) {
            final section = widget.sections.elementAtOrNull(activeIndex);
            if (section == null || section.title.trim().isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    section.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.style(
                      theme.titleMedium,
                      scaleFontSize: true,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  if (section.subtitle.trim().isNotEmpty)
                    Text(
                      section.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.style(
                        theme.labelLarge,
                        fontStyle: FontStyle.italic,
                        scaleFontSize: true,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionList(
    BuildContext context,
    PrayerTypography typography,
  ) {
    final theme = FlutterFlowTheme.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: _pageManager.trackIndexNotifier,
      builder: (context, activeIndex, _) {
        return ListView.separated(
          controller: _sectionListController,
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          itemCount: widget.sections.length,
          separatorBuilder: (_, __) => Divider(
            height: 1.0,
            color: theme.primary.withValues(alpha: 0.12),
          ),
          itemBuilder: (context, index) {
            final section = widget.sections[index];
            final isActive = index == activeIndex;
            final tile = ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              leading: CircleAvatar(
                backgroundColor: isActive
                    ? theme.primary
                    : theme.primary.withValues(alpha: 0.12),
                child: Text(
                  '${index + 1}',
                  style: typography.style(
                    theme.labelLarge,
                    scaleFontSize: false,
                    color: isActive ? theme.alternate : theme.primary,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              title: Text(
                section.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.style(
                  theme.titleSmall,
                  scaleFontSize: false,
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                ),
              ),
              subtitle: section.subtitle.isEmpty
                  ? null
                  : Text(
                      section.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () async {
                await _pageManager.playAtIndex(index);
              },
            );
            if (!isActive) {
              return tile;
            }
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              elevation: 1.0,
              color: theme.secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                leading: tile.leading,
                title: tile.title,
                subtitle: tile.subtitle,
                onTap: tile.onTap,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Ensure this subtree rebuilds when the app font changes.
    final typography = PrayerTypography.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAlbumHeader(context, typography),
            const SizedBox(height: 8.0),
            Expanded(child: _buildSectionList(context, typography)),
          ],
        ),
      ),
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
      padding: hasNext || hasPrevious
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (!hasPrevious)
            const SizedBox(
              width: 48.0,
            ),
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
          if (!hasNext)
            const SizedBox(
              width: 48.0,
            ),
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
