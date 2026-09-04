import 'dart:async';

import 'package:flutter/foundation.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'package:my_prayer/service_locator.dart';

import 'services/audio_handler.dart';
import 'package:my_prayer/custom_code/prayer/playback_highlight_state.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final trackIndexNotifier = ValueNotifier<int>(0);
  final playbackSpeedNotifier = ValueNotifier<double>(1.0);
  final playlistNotifier = ValueNotifier<List<String>>([]);

  final currentProgressNotifier = ValueNotifier<Duration>(Duration.zero);
  final totalDurationNotifier = ValueNotifier<Duration>(Duration.zero);
  final bufferedTimeNotifier = ValueNotifier<Duration>(Duration.zero);
  final playbackHighlightNotifier = PlaybackHighlightNotifier();

  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final isQueueReadyNotifier = ValueNotifier<bool>(false);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final playBackStateNotifier =
      ValueNotifier<AudioProcessingState>(AudioProcessingState.idle);

  final _audioHandler = getIt<AudioHandler>();
  int? _pendingTrackIndex;
  int _lastQueueLength = 0;

  /// Optional hook (e.g. Rosary page) to load the queue before [play].
  Future<void> Function()? ensureQueueBeforePlay;

  void init() {
    _listenToChangesInPlaylist();
    _listenToPlaybackStateUpdates();
    _listenToCurrentPosition();
    _listenToTotalDuration();
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        _lastQueueLength = 0;
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
        final wasEmpty = _lastQueueLength == 0;
        _lastQueueLength = playlist.length;
        if (wasEmpty) {
          final targetIndex = _pendingTrackIndex ?? trackIndexNotifier.value;
          if (targetIndex >= 0 && targetIndex < playlist.length) {
            unawaited(_audioHandler.skipToQueueItem(targetIndex));
          }
        }
      }
      _updateSkipButtons();
    });
  }

  /// Single subscription for play button, buffer, track index, and processing state.
  void _listenToPlaybackStateUpdates() {
    _audioHandler.playbackState.listen(_handlePlaybackState);
  }

  void _handlePlaybackState(PlaybackState playbackState) {
    final isPlaying = playbackState.playing;
    final processingState = playbackState.processingState;

    if (processingState == AudioProcessingState.loading ||
        processingState == AudioProcessingState.buffering) {
      playButtonNotifier.value =
          isPlaying ? ButtonState.loading : ButtonState.paused;
    } else if (!isPlaying) {
      playButtonNotifier.value = ButtonState.paused;
    } else if (processingState != AudioProcessingState.completed) {
      playButtonNotifier.value = ButtonState.playing;
    } else {
      _audioHandler.seek(Duration.zero);
      _audioHandler.pause();
    }

    final bufferedPosition = playbackState.bufferedPosition;
    if (bufferedTimeNotifier.value != bufferedPosition) {
      bufferedTimeNotifier.value = bufferedPosition;
    }

    if (playBackStateNotifier.value != processingState) {
      playBackStateNotifier.value = processingState;
    }

    if (processingState == AudioProcessingState.completed) {
      final completedIndex = playbackState.queueIndex ?? 0;
      if (_pendingTrackIndex != null && completedIndex != _pendingTrackIndex) {
        return;
      }
      if (trackIndexNotifier.value != completedIndex) {
        trackIndexNotifier.value = completedIndex;
      }
      if (_pendingTrackIndex == completedIndex) {
        _pendingTrackIndex = null;
      }
      return;
    }

    final newIndex = playbackState.queueIndex ?? 0;

    if (_pendingTrackIndex != null && newIndex != _pendingTrackIndex) {
      return;
    }
    if (_pendingTrackIndex != null && newIndex == _pendingTrackIndex) {
      _pendingTrackIndex = null;
    }

    if (!isPlaying) {
      return;
    }

    if (trackIndexNotifier.value != newIndex) {
      trackIndexNotifier.value = newIndex;
    }
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      currentProgressNotifier.value = position;
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null &&
          mediaItem.duration != null &&
          mediaItem.duration!.inSeconds > 0) {
        totalDurationNotifier.value = mediaItem.duration!;
      }
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  Future<void> play() async {
    if (ensureQueueBeforePlay != null) {
      await ensureQueueBeforePlay!();
    }

    final queue = _audioHandler.queue.value;
    if (queue.isEmpty) {
      playButtonNotifier.value = ButtonState.paused;
      return;
    }

    final index = trackIndexNotifier.value.clamp(0, queue.length - 1);
    final currentIndex = _audioHandler.playbackState.value.queueIndex;

    if (index >= 0 &&
        index < queue.length &&
        (currentIndex == null || currentIndex != index)) {
      await skipToIndex(index);
    }
    await _audioHandler.play();
  }

  void pause() {
    _audioHandler.pause();
  }

  Future<void> seek(Duration position) async =>
      await _audioHandler.seek(position);

  void previous() {
    final queue = _audioHandler.queue.value;
    if (currentProgressNotifier.value.inSeconds > 3) {
      unawaited(seek(Duration.zero));
      return;
    }
    if (queue.isEmpty || trackIndexNotifier.value <= 0) {
      return;
    }
    unawaited(skipToIndex(trackIndexNotifier.value - 1));
  }

  void next() {
    final queue = _audioHandler.queue.value;
    if (queue.isEmpty || trackIndexNotifier.value >= queue.length - 1) {
      return;
    }
    unawaited(skipToIndex(trackIndexNotifier.value + 1));
  }

  Future<void> skipToIndex(int index) async {
    if (index < 0) {
      return;
    }
    setTrackIndex(index);
    final queue = _audioHandler.queue.value;
    if (index < queue.length) {
      await _audioHandler.skipToQueueItem(index);
    }
  }

  Future<void> playAtIndex(int index) async {
    if (ensureQueueBeforePlay != null) {
      await ensureQueueBeforePlay!();
    }

    final queue = _audioHandler.queue.value;
    if (index < 0 || index >= queue.length) {
      return;
    }

    setTrackIndex(index);
    if (_audioHandler is MyAudioHandler) {
      await (_audioHandler as MyAudioHandler).playQueueItem(index);
      return;
    }

    await _audioHandler.skipToQueueItem(index);
    await _audioHandler.play();
  }

  /// Sets the UI track index and ignores stale playback index updates until
  /// the handler reports this index (or [clearPendingTrackIndex] is called).
  void setTrackIndex(int index) {
    _pendingTrackIndex = index;
    trackIndexNotifier.value = index;
  }

  void clearPendingTrackIndex() {
    _pendingTrackIndex = null;
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _audioHandler.setSpeed(speed);
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> remove() async {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    await _audioHandler.removeQueueItemAt(lastIndex);
  }

  bool get hasActiveQueue => _audioHandler.queue.value.isNotEmpty;

  bool isQueueReadyForSectionCount(int sectionCount) {
    if (sectionCount <= 0) {
      return false;
    }
    return _audioHandler.queue.value.length == sectionCount;
  }

  Future<void> setQueue(List<MediaItem> mediaItems) async {
    isQueueReadyNotifier.value = false;
    final index = trackIndexNotifier.value.clamp(
      0,
      mediaItems.isEmpty ? 0 : mediaItems.length - 1,
    );
    setTrackIndex(index);

    var queueReady = false;
    try {
      if (_audioHandler is MyAudioHandler) {
        await (_audioHandler as MyAudioHandler)
            .loadQueueAtIndex(mediaItems, initialIndex: index)
            .timeout(const Duration(seconds: 60));
        _lastQueueLength = mediaItems.length;
        setTrackIndex(index);
        queueReady = _audioHandler.queue.value.length == mediaItems.length;
      } else {
        await _audioHandler.stop();
        await _audioHandler.updateQueue(mediaItems);
        await skipToIndex(index);
        _lastQueueLength = mediaItems.length;
        queueReady = true;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to set audio queue: $error\n$stackTrace');
    } finally {
      isQueueReadyNotifier.value = queueReady;
    }
  }

  Future<void> clearQueue() async {
    isQueueReadyNotifier.value = false;
    clearPendingTrackIndex();
    if (_audioHandler is MyAudioHandler) {
      await (_audioHandler as MyAudioHandler).resetQueue();
    } else {
      await _audioHandler.updateQueue([]);
    }
    _lastQueueLength = 0;
    isQueueReadyNotifier.value = false;
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  Future<void> stop() async {
    if (_audioHandler is MyAudioHandler) {
      await (_audioHandler as MyAudioHandler).stopPlayback();
    } else {
      await _audioHandler.stop();
    }
  }
}
