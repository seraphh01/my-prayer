import 'dart:async';



import 'package:audio_service/audio_service.dart';

import 'package:flutter/foundation.dart';

import 'package:just_audio/just_audio.dart';



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



class MyAudioHandler extends BaseAudioHandler {

  final _player = AudioPlayer();

  final _playlist = ConcatenatingAudioSource(children: []);

  late final Future<void> _playlistReady;



  MyAudioHandler() {

    _playlistReady = _loadEmptyPlaylist();

    _notifyAudioHandlerAboutPlaybackEvents();

    _listenForDurationChanges();

    _listenForCurrentSongIndexChanges();

  }



  Future<void> _loadEmptyPlaylist() async {

    try {

      await _player.setAudioSource(_playlist);

    } catch (e) {

      print("Error: $e");

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

    await _playlistReady;

    _playlist.clear();

    queue.value.clear();



    if (mediaItems.isEmpty) {

      queue.add([]);

      await _player.stop();

      return;

    }



    final index = initialIndex.clamp(0, mediaItems.length - 1);

    final sources = mediaItems.map(_createAudioSource).toList();

    final shouldPreload = defaultTargetPlatform != TargetPlatform.iOS;

    final useProgressiveLoad =

        mediaItems.length > 16 && defaultTargetPlatform == TargetPlatform.iOS;



    if (useProgressiveLoad) {

      await _loadQueueProgressively(

        mediaItems,

        sources,

        index,

        preload: shouldPreload,

      );

      return;

    }



    _playlist.addAll(sources);

    queue.add(mediaItems);



    try {

      await _player

          .setAudioSource(

            _playlist,

            initialIndex: index,

            preload: shouldPreload,

          )

          .timeout(const Duration(seconds: 30));

    } on TimeoutException {

      await _player.setAudioSource(

        _playlist,

        initialIndex: index,

        preload: false,

      );

    }



    mediaItem.add(mediaItems[index]);

    _publishDurationForCurrentItem();

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



    _playlist.addAll(sources.sublist(start, end + 1));

    queue.add(mediaItems);



    try {

      await _player

          .setAudioSource(

            _playlist,

            initialIndex: index - start,

            preload: preload,

          )

          .timeout(const Duration(seconds: 30));

    } on TimeoutException {

      await _player.setAudioSource(

        _playlist,

        initialIndex: index - start,

        preload: false,

      );

    }



    mediaItem.add(mediaItems[index]);

    _publishDurationForCurrentItem();



    unawaited(_expandPlaylistSources(sources, start, end));

  }



  Future<void> _expandPlaylistSources(

    List<AudioSource> sources,

    int start,

    int end,

  ) async {

    for (var i = start - 1; i >= 0; i--) {

      await _playlist.insert(i, sources[i]);

    }

    for (var i = end + 1; i < sources.length; i++) {

      await _playlist.add(sources[i]);

    }

  }



  @override

  Future<void> addQueueItems(List<MediaItem> mediaItems) async {

    // manage Just Audio

    final audioSource = mediaItems.map(_createAudioSource);

    _playlist.addAll(audioSource.toList());



    // notify system

    final newQueue = queue.value..addAll(mediaItems);

    queue.add(newQueue);

  }



  @override

  Future<void> addQueueItem(MediaItem mediaItem) async {

    // manage Just Audio

    final audioSource = _createAudioSource(mediaItem);

    _playlist.add(audioSource);



    // notify system

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



    // Text-only section inside an audio prayer: zero-length clip so the queue

    // index stays aligned without hitting invalid URIs on iOS.

    final fallbackUrl = mediaItem.extras!['fallbackUrl'] as String? ?? '';

    if (fallbackUrl.isNotEmpty) {

      return ClippingAudioSource(

        start: Duration.zero,

        end: const Duration(milliseconds: 1),

        child: AudioSource.uri(Uri.parse(fallbackUrl)),

        tag: mediaItem,

      );

    }



    throw StateError(

      'No playable audio source for media item ${mediaItem.id}',

    );

  }



  @override

  Future<void> removeQueueItemAt(int index) async {

    // manage Just Audio

    _playlist.removeAt(index);



    // notify system

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

    if (index < 0 || index >= queue.value.length) return;

    if (_player.shuffleModeEnabled) {

      index = _player.shuffleIndices![index];

    }

    await _player.seek(Duration.zero, index: index);

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

  @override

  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {

    if (name == 'dispose') {

      await _player.dispose();

      super.stop();

    }

  }



  @override

  Future<void> stop() async {

    await _player.stop();

    await AudioService.stop();

    return super.stop();

  }

}


