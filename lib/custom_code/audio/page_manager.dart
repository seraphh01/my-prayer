import 'dart:async';

import 'package:flutter/foundation.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'package:my_prayer/service_locator.dart';

import 'services/audio_handler.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final trackIndexNotifier = ValueNotifier<int>(0);
  final playbackSpeedNotifier = ValueNotifier<double>(1.0);
  final playlistNotifier = ValueNotifier<List<String>>([]);

  final currentProgressNotifier = ValueNotifier<Duration>(Duration.zero);
  final totalDurationNotifier = ValueNotifier<Duration>(Duration.zero);
  final bufferedTimeNotifier = ValueNotifier<Duration>(Duration.zero);

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

  // Events: Calls coming from the UI
  void init() {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToTrackIndexStateChanges();
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
          final targetIndex = trackIndexNotifier.value;
          if (targetIndex >= 0 && targetIndex < playlist.length) {
            unawaited(_audioHandler.skipToQueueItem(targetIndex));
          }
        }
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      currentProgressNotifier.value = position;
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      bufferedTimeNotifier.value = playbackState.bufferedPosition;
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null && mediaItem.duration != null && mediaItem.duration!.inSeconds > 0) {
          totalDurationNotifier.value = mediaItem.duration!;
        }
    });
  }

  bool _shouldSyncTrackIndexFromPlayback({
    required bool playing,
    required AudioProcessingState processingState,
  }) {
    if (playing) {
      return true;
    }
    switch (processingState) {
      case AudioProcessingState.loading:
      case AudioProcessingState.buffering:
      case AudioProcessingState.ready:
        return true;
      case AudioProcessingState.idle:
      case AudioProcessingState.completed:
      case AudioProcessingState.error:
        return false;
    }
  }

  void _listenToTrackIndexStateChanges() {
    _audioHandler.playbackState.listen((playbackState) {
      // Track index change only when it is a new item or a skip
      final newIndex = playbackState.queueIndex ?? 0;

      if (playBackStateNotifier.value != playbackState.processingState) {
        playBackStateNotifier.value = playbackState.processingState;
      }

      // just_audio often reports queueIndex 0 while idle, even after skipToQueueItem.
      // Keep the UI-driven index until playback is actually active.
      if (_pendingTrackIndex != null && newIndex != _pendingTrackIndex) {
        return;
      }
      if (_pendingTrackIndex != null && newIndex == _pendingTrackIndex) {
        _pendingTrackIndex = null;
      }

      if (!_shouldSyncTrackIndexFromPlayback(
            playing: playbackState.playing,
            processingState: playbackState.processingState,
          ) &&
          newIndex != trackIndexNotifier.value) {
        return;
      }

      if (trackIndexNotifier.value != newIndex) {
        trackIndexNotifier.value = newIndex;
      }
    });

    _audioHandler.playbackState.listen((playbackState) {
      if (playbackState.processingState == AudioProcessingState.completed) {
        trackIndexNotifier.value = playbackState.queueIndex ?? 0;
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
    final index = trackIndexNotifier.value;
    await skipToIndex(index);
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
    if (queue.isEmpty ||
        trackIndexNotifier.value >= queue.length - 1) {
      return;
    }
    unawaited(skipToIndex(trackIndexNotifier.value + 1));
  }

  Future<void> skipToIndex(int index) async {
    if (index < 0) {
      return;
    }
    _pendingTrackIndex = index;
    trackIndexNotifier.value = index;
    final queue = _audioHandler.queue.value;
    if (index < queue.length) {
      await _audioHandler.skipToQueueItem(index);
    }
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

  Future<void> setQueue(List<MediaItem> mediaItems) async {
    isQueueReadyNotifier.value = false;
    final index = trackIndexNotifier.value.clamp(
      0,
      mediaItems.isEmpty ? 0 : mediaItems.length - 1,
    );

    if (_audioHandler is MyAudioHandler) {
      await (_audioHandler as MyAudioHandler)
          .loadQueueAtIndex(mediaItems, initialIndex: index);
      _pendingTrackIndex = null;
      _lastQueueLength = mediaItems.length;
      if (mediaItems.isNotEmpty) {
        trackIndexNotifier.value = index;
      }
    } else {
      await _audioHandler.stop();
      await _audioHandler.updateQueue(mediaItems);
      await skipToIndex(index);
      _lastQueueLength = mediaItems.length;
    }

    isQueueReadyNotifier.value = true;
  }

  Future<void> clearQueue() async {
    await _audioHandler.skipToQueueItem(0);
    await _audioHandler.seek(Duration(seconds: 0));
    await _audioHandler.stop();
    await _audioHandler.updateQueue([]);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}
