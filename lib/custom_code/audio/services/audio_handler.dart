import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

Future<void> configureAppAudioSession() async {
  if (kIsWeb) {
    return;
  }
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
}

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.surorilecmd.rugaciunisicantari.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: false,
      androidNotificationIcon: 'mipmap/launcher_icon',
      androidStopForegroundOnPause: true,
      androidResumeOnClick: true,
    ),
  );
}

bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  late final Future<void> _playlistReady;
  Future<void> _queueOperation = Future.value();
  int _expandGeneration = 0;

  static const _setSourceTimeout = Duration(seconds: 20);
  static const _iosProgressiveMinLength = 2;

  MyAudioHandler() {
    _playlistReady = _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    if (kIsWeb) {
      // just_audio_web mishandles an initially empty bound playlist; bind on first load.
      return;
    }
    try {
      await _player
          .setAudioSource(_playlist, preload: false)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error loading empty playlist: $e');
    }
  }

  Future<T> _runQueueOperation<T>(Future<T> Function() operation) async {
    final previous = _queueOperation;
    final completer = Completer<void>();
    _queueOperation = completer.future;
    await previous;
    try {
      return await operation();
    } finally {
      completer.complete();
    }
  }

  Future<void> _preparePlayerForNewQueue() async {
    _expandGeneration++;
    if (_isIOS) {
      await _player.stop();
      _playlist.clear();
      try {
        await _player
            .setAudioSource(_playlist, preload: false)
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('iOS player rebind before queue load failed: $e');
      }
    }
  }

  Future<void> _setPlayerSource({
    required ConcatenatingAudioSource playlist,
    required int initialIndex,
    required bool preload,
  }) async {
    try {
      await _player
          .setAudioSource(
            playlist,
            initialIndex: initialIndex,
            preload: preload,
          )
          .timeout(_setSourceTimeout);
    } on TimeoutException {
      await _player.stop();
      await _player
          .setAudioSource(
            playlist,
            initialIndex: initialIndex,
            preload: false,
          )
          .timeout(_setSourceTimeout);
    }
  }

  int? _queueIndexForPlayerIndex(int? playerIndex) {
    if (playerIndex == null || queue.value.isEmpty) {
      return null;
    }

    final sequence = _player.sequenceState.effectiveSequence;
    if (playerIndex >= 0 && playerIndex < sequence.length) {
      final tag = sequence[playerIndex].tag;
      if (tag is MediaItem) {
        final queueIndex = queue.value.indexWhere((item) => item.id == tag.id);
        if (queueIndex >= 0) {
          return queueIndex;
        }
      }
    }

    var index = playerIndex;
    if (_player.shuffleModeEnabled && _player.shuffleIndices != null) {
      index = _player.shuffleIndices!.indexOf(playerIndex);
    }
    if (index >= 0 && index < queue.value.length) {
      return index;
    }
    return null;
  }

  int? _playerIndexForQueueIndex(int queueIndex) {
    if (queueIndex < 0 || queueIndex >= queue.value.length) {
      return null;
    }
    final targetId = queue.value[queueIndex].id;
    final sequence = _player.sequenceState.effectiveSequence;
    for (var i = 0; i < sequence.length; i++) {
      final tag = sequence[i].tag;
      if (tag is MediaItem && tag.id == targetId) {
        return i;
      }
    }
    return null;
  }

  void _updateQueueDurationAt(int queueIndex, Duration duration) {
    if (queueIndex < 0 || queueIndex >= queue.value.length) {
      return;
    }
    if (duration <= Duration.zero) {
      return;
    }

    final updatedQueue = List<MediaItem>.from(queue.value);
    final current = updatedQueue[queueIndex];
    if (current.duration == duration) {
      return;
    }

    final updatedItem = current.copyWith(duration: duration);
    updatedQueue[queueIndex] = updatedItem;
    queue.add(updatedQueue);

    final currentQueueIndex = _queueIndexForPlayerIndex(_player.currentIndex);
    if (currentQueueIndex == queueIndex) {
      mediaItem.add(updatedItem);
    }
  }

  void _publishDurationForCurrentItem() {
    final duration = _player.duration;
    final queueIndex = _queueIndexForPlayerIndex(_player.currentIndex);
    if (duration != null && queueIndex != null) {
      _updateQueueDurationAt(queueIndex, duration);
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _queueIndexForPlayerIndex(event.currentIndex),
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      if (duration == null) {
        return;
      }
      final queueIndex = _queueIndexForPlayerIndex(_player.currentIndex);
      if (queueIndex == null) {
        return;
      }
      _updateQueueDurationAt(queueIndex, duration);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final queueIndex = _queueIndexForPlayerIndex(index);
      if (queueIndex == null) {
        return;
      }
      final playlist = queue.value;
      if (queueIndex >= playlist.length) {
        return;
      }
      mediaItem.add(playlist[queueIndex]);
    });
  }

  @override
  Future<void> updateQueue(List<MediaItem> mediaItems) async {
    await loadQueueAtIndex(mediaItems, initialIndex: 0);
  }

  Future<void> loadQueueAtIndex(
    List<MediaItem> mediaItems, {
    int initialIndex = 0,
  }) async {
    return _runQueueOperation(() async {
      await _playlistReady;
      await _preparePlayerForNewQueue();
      if (!kIsWeb) {
        _playlist.clear();
      }
      queue.value.clear();

      if (mediaItems.isEmpty) {
        queue.add([]);
        await _player.stop();
        if (kIsWeb) {
          _playlist = ConcatenatingAudioSource(children: []);
        }
        return;
      }

      final index = initialIndex.clamp(0, mediaItems.length - 1);
      final sources = mediaItems.map(_createAudioSource).toList();
      final shouldPreload = !_isIOS;
      final useProgressiveLoad =
          _isIOS && mediaItems.length >= _iosProgressiveMinLength;

      if (useProgressiveLoad) {
        await _loadQueueProgressively(
          mediaItems,
          sources,
          index,
          preload: shouldPreload,
        );
        return;
      }

      if (kIsWeb) {
        await _loadWebQueue(mediaItems, sources, index);
        return;
      }

      _playlist.addAll(sources);
      queue.add(mediaItems);

      await _setPlayerSource(
        playlist: _playlist,
        initialIndex: index,
        preload: shouldPreload,
      );

      mediaItem.add(mediaItems[index]);
      _publishDurationForCurrentItem();
    });
  }

  Future<void> _loadQueueProgressively(
    List<MediaItem> mediaItems,
    List<AudioSource> sources,
    int index, {
    required bool preload,
  }) async {
    const windowRadius = 4;
    final start = (index - windowRadius).clamp(0, mediaItems.length - 1);
    final end = (index + windowRadius).clamp(0, mediaItems.length - 1);
    final generation = _expandGeneration;

    _playlist.addAll(sources.sublist(start, end + 1));
    queue.add(mediaItems);

    await _setPlayerSource(
      playlist: _playlist,
      initialIndex: index - start,
      preload: preload,
    );

    mediaItem.add(mediaItems[index]);
    _publishDurationForCurrentItem();

    await _expandPlaylistSources(sources, start, end, generation);
  }

  Future<void> _loadWebQueue(
    List<MediaItem> mediaItems,
    List<AudioSource> sources,
    int index,
  ) async {
    await _player.stop();
    _playlist = ConcatenatingAudioSource(children: sources);
    queue.add(mediaItems);

    try {
      await _player
          .setAudioSource(
            _playlist,
            initialIndex: index,
            preload: false,
          )
          .timeout(_setSourceTimeout);
    } on TimeoutException {
      await _player.stop();
      await _player
          .setAudioSource(
            _playlist,
            initialIndex: index,
            preload: false,
          )
          .timeout(_setSourceTimeout);
    }

    mediaItem.add(mediaItems[index]);
    _publishDurationForCurrentItem();
  }

  Future<void> _expandPlaylistSources(
    List<AudioSource> sources,
    int start,
    int end,
    int generation,
  ) async {
    for (var i = start - 1; i >= 0; i--) {
      if (generation != _expandGeneration) {
        return;
      }
      await _playlist.insert(0, sources[i]);
      if (_isIOS) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    for (var i = end + 1; i < sources.length; i++) {
      if (generation != _expandGeneration) {
        return;
      }
      await _playlist.add(sources[i]);
      if (_isIOS) {
        await Future<void>.delayed(Duration.zero);
      }
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  AudioSource _createAudioSource(MediaItem mediaItem) {
    final isDownloaded = mediaItem.extras!['isDownloaded'] as bool? ?? false;
    final filePath = mediaItem.extras!['filePath'] as String? ?? '';
    final url = mediaItem.extras!['url'] as String? ?? '';

    if (isDownloaded && filePath.isNotEmpty) {
      return AudioSource.uri(Uri.file(filePath), tag: mediaItem);
    }
    if (url.isNotEmpty) {
      return AudioSource.uri(Uri.parse(url), tag: mediaItem);
    }

    // Text-only section: silence keeps queue indices aligned without I/O on iOS.
    final placeholderDuration = (mediaItem != null && mediaItem.duration != null && mediaItem.duration! > Duration.zero)
        ? mediaItem.duration!
        : const Duration(milliseconds: 1);
    return SilenceAudioSource(
      duration: placeholderDuration,
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    _playlist.removeAt(index);

    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() async => await _player.play();

  @override
  Future<void> pause() async => await _player.pause();

  @override
  Future<void> seek(Duration position) async => await _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) {
      return;
    }

    var playerIndex = index;
    if (_player.shuffleModeEnabled) {
      playerIndex = _player.shuffleIndices![index];
    } else {
      playerIndex = _playerIndexForQueueIndex(index) ?? index;
    }

    await _player.seek(Duration.zero, index: playerIndex);
    mediaItem.add(queue.value[index]);
    _publishDurationForCurrentItem();
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      _player.seek(Duration.zero);
      return;
    }

    _player.seekToPrevious();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  /// Stops playback without tearing down [AudioService] (safe between prayers).
  Future<void> stopPlayback() async {
    await _player.stop();
    await super.stop();
  }

  /// Clears the just_audio playlist and audio_service queue.
  Future<void> resetQueue() async {
    await _runQueueOperation(() async {
      await _preparePlayerForNewQueue();
      if (kIsWeb) {
        _playlist = ConcatenatingAudioSource(children: []);
      } else {
        _playlist.clear();
      }
      queue.add([]);
      await _player.stop();
    });
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      await AudioService.stop();
      super.stop();
    }
  }

  @override
  Future<void> stop() async {
    await stopPlayback();
  }
}
