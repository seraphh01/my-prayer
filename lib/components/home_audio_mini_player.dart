import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/custom_code/audio/notifiers/play_button_notifier.dart';
import '/custom_code/audio/page_manager.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class HomeAudioMiniPlayer extends StatelessWidget {
  const HomeAudioMiniPlayer({
    super.key,
    required this.pageManager,
    required this.audioHandler,
    required this.onClose,
    required this.onOpenPrayer,
  });

  /// Inner row height (artwork / controls).
  static const double contentHeight = 44.0;

  static const double progressBarHeight = 3.0;

  static const double _cardPaddingHorizontal = 12.0;
  static const double _cardPaddingTop = 10.0;
  static const double _progressTopGap = 8.0;
  static const double _cardPaddingBottom = 10.0;

  /// Margin around the player on the home screen (top + bottom).
  static const double homeScreenMarginVertical = 16.0;

  /// Total vertical space the home page should reserve below the catalog scroll.
  static double get homeReservedHeight =>
      _cardPaddingTop +
      contentHeight +
      _progressTopGap +
      progressBarHeight +
      _cardPaddingBottom +
      homeScreenMarginVertical;

  final PageManager pageManager;
  final AudioHandler audioHandler;
  final VoidCallback onClose;
  final VoidCallback onOpenPrayer;

  bool _hasAudioUrl(MediaItem item) {
    final url = item.extras?['url']?.toString() ?? '';
    return url.isNotEmpty;
  }

  bool _hasPlaybackStarted() {
    final playState = pageManager.playButtonNotifier.value;
    final current = pageManager.currentProgressNotifier.value;
    final processingState = pageManager.playBackStateNotifier.value;

    if (playState == ButtonState.playing || playState == ButtonState.loading) {
      return true;
    }
    if (current.inMilliseconds > 0) {
      return true;
    }
    return processingState != AudioProcessingState.idle;
  }

  Widget _buildArtwork(BuildContext context, MediaItem mediaItem) {
    final theme = FlutterFlowTheme.of(context);
    final artUri = mediaItem.artUri?.toString() ?? '';

    if (artUri.isEmpty) {
      return Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: theme.primary,
          size: 22.0,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: artUri,
        width: 44.0,
        height: 44.0,
        fit: BoxFit.cover,
        memCacheWidth: 88,
        memCacheHeight: 88,
        placeholder: (_, __) => Container(
          width: 44.0,
          height: 44.0,
          color: theme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.music_note_rounded, color: theme.primary, size: 22),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 44.0,
          height: 44.0,
          color: theme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.music_note_rounded, color: theme.primary),
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return SizedBox(
              width: 44.0,
              height: 44.0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              ),
            );
          case ButtonState.paused:
            return FlutterFlowIconButton(
              buttonSize: 44.0,
              icon: Icon(Icons.play_arrow_rounded, color: theme.primary),
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return FlutterFlowIconButton(
              buttonSize: 44.0,
              icon: Icon(Icons.pause_rounded, color: theme.primary),
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        pageManager.currentProgressNotifier,
        pageManager.totalDurationNotifier,
      ]),
      builder: (context, _) {
        final current = pageManager.currentProgressNotifier.value;
        final total = pageManager.totalDurationNotifier.value;
        final progress = total.inMilliseconds > 0
            ? (current.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(999.0),
          child: LinearProgressIndicator(
            minHeight: progressBarHeight,
            value: progress > 0 ? progress : null,
            backgroundColor: theme.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.primary.withValues(alpha: 0.75),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return StreamBuilder<List<MediaItem>?>(
      stream: audioHandler.queue,
      builder: (context, queueSnapshot) {
        final queue = queueSnapshot.data;
        if (queue == null || queue.isEmpty) {
          return const SizedBox.shrink();
        }

        final trackIndex = pageManager.trackIndexNotifier.value;
        if (trackIndex < 0 || trackIndex >= queue.length) {
          return const SizedBox.shrink();
        }

        final mediaItem = queue[trackIndex];
        final hasAudio = _hasAudioUrl(mediaItem);

        return ListenableBuilder(
          listenable: Listenable.merge([
            pageManager.playButtonNotifier,
            pageManager.currentProgressNotifier,
            pageManager.playBackStateNotifier,
          ]),
          builder: (context, _) {
            final showProgressBar = hasAudio && _hasPlaybackStarted();

            return Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.alternate,
                  theme.alternate.withValues(alpha: 0.95),
                ],
                begin: const AlignmentDirectional(-1.0, -1.0),
                end: const AlignmentDirectional(1.0, 1.0),
              ),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: theme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.15),
                  blurRadius: 12.0,
                  offset: const Offset(0.0, 4.0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onOpenPrayer,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        _cardPaddingHorizontal,
                        _cardPaddingTop,
                        4.0,
                        showProgressBar ? 0.0 : _cardPaddingBottom,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'sectionImageHero',
                            child: _buildArtwork(context, mediaItem),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mediaItem.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.titleSmall.override(
                                    fontFamily: 'Merriweather',
                                    color: theme.primary,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                if (mediaItem.album != null &&
                                    mediaItem.album!.isNotEmpty)
                                  Text(
                                    mediaItem.album!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.labelSmall.override(
                                      fontFamily: 'Inter',
                                      color: theme.primary,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (hasAudio) _buildPlayButton(context),
                          ValueListenableBuilder<ButtonState>(
                            valueListenable: pageManager.playButtonNotifier,
                            builder: (_, playState, __) {

                              return IconButton(
                                onPressed: onClose,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: theme.primary,
                                ),
                                tooltip: 'Închide',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 44.0,
                                  minHeight: 44.0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showProgressBar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _cardPaddingHorizontal,
                        _progressTopGap,
                        _cardPaddingHorizontal,
                        _cardPaddingBottom,
                      ),
                      child: _buildProgressBar(context),
                    ),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }
}
