// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/scheduler.dart';
import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'dart:async';

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'dart:isolate';

import 'index.dart'; // Imports other custom widgets

import '/components/choose_chapter_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:audio_service/audio_service.dart';
import '../audio/services/service_locator.dart';
import '../audio/page_manager.dart';
import '../audio/notifiers/play_button_notifier.dart';
import 'dart:convert'; // For base64 encoding
import 'package:flutter/services.dart'; // For rootBundle

class SectionsControlBar extends StatefulWidget {
  final int? initialAudioTime;
  final double? playbackRate;
  final int? initialTrackIndex;
  final List<PrayerSectionStruct> sections;
  final List<PrayerSectionStruct> flattenedSections;
  final List<String> playlist;
  final double? width;
  final double? height;
  final Future Function(int currentAudioTime)? onAudioPositionChanged;
  final Future Function(int currentAudioDuration)? onAudioDurationChanged;
  final Future Function(double currentBufferTime)? onBufferTimeChanged;
  final Future Function()? onAudioFinished;
  final Future Function()? nextPage;
  final Future Function(int pageIndex)? goToPage;
  final Future Function()? switchContent;
  final bool? showingTextContent;

  const SectionsControlBar(
      {super.key,
      this.width,
      this.height,
      this.playbackRate,
      this.initialAudioTime,
      this.initialTrackIndex,
      required this.playlist,
      this.showingTextContent,
      this.onAudioPositionChanged,
      this.onAudioFinished,
      this.nextPage,
      this.goToPage,
      this.switchContent,
      this.onAudioDurationChanged,
      this.onBufferTimeChanged,
      required this.flattenedSections,
      required this.sections});

  @override
  State<SectionsControlBar> createState() => _SectionsControlBarState();
}

class _SectionsControlBarState extends State<SectionsControlBar> {
  final _audioHandler = getIt<AudioHandler>();
  final _pageManager = getIt<PageManager>();
  bool _isPlaying = false;
  bool _isLoading = false;
  int _lastAudioTime = 0;
  int _currentTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentTrackIndex = widget.initialTrackIndex ?? 0;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final mediaItems = await Future.wait(widget.sections.map((section) async {
        final artUri = section.imageUrl.isNotEmpty
            ? Uri.parse(section.imageUrl)
            : Uri.parse(
                'https://nrapqjwyqvwopwoxevlw.supabase.co/storage/v1/object/public/images/logo.jpg');

        final filePath = await retrieveAudioFile(section.audioUrl);

        return MediaItem(
          id: section.id,
          album: section.subtitle,
          title: section.title,
          artUri: artUri,
          extras: {
            'url': section.audioUrl,
            'isDownloaded': filePath != null,
            'filePath': filePath
          },
        );
      }).toList());

      _pageManager.setQueue(mediaItems);

      _pageManager.progressNotifier.addListener(onTrackProgressChanged);

      _pageManager.trackIndexNotifier.addListener(onTrackIndexChanged);
    });
  }

  @override
  void dispose() {
    _pageManager.clearQueue();
    _pageManager.trackIndexNotifier.removeListener(onTrackIndexChanged);
    _pageManager.progressNotifier.removeListener(onTrackProgressChanged);
    super.dispose();
  }

  void onTrackProgressChanged() {
    final progress = _pageManager.progressNotifier.value;
    widget.onAudioPositionChanged?.call(progress.current.inSeconds);
    widget.onAudioDurationChanged?.call(progress.total.inSeconds);
    widget.onBufferTimeChanged?.call(progress.buffered.inSeconds.toDouble());
  }

  void onTrackIndexChanged() {
    _currentTrackIndex = _pageManager.trackIndexNotifier.value;
    widget.goToPage?.call(_currentTrackIndex);
  }

  Future<void> _chooseChapter(BuildContext content) async {
    final index = await showModalBottomSheet<int>(
        isDismissible: true,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return ChooseChapterWidget(
              currentChapterIndex: _currentTrackIndex,
              chapterOptions:
                  convertPrayerSectionToChapterOption(widget.sections));
        });
    if (index == null) {
      return;
    }

    widget.goToPage!.call(index);
    _currentTrackIndex = index;
    await _pageManager.skipToIndex(index);
  }

  void _switchContent() {
    widget.switchContent!();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playbackRate != null &&
        _pageManager.playBackStateNotifier.value != widget.playbackRate) {
      _pageManager.setPlaybackSpeed(widget.playbackRate ?? 1.0);
    }
    return Container(
      width: widget.width,
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FlutterFlowIconButton(
            borderRadius: 20,
            buttonSize: 40,
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
            icon: Icon(
              Icons.menu_book,
              color: FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
            onPressed: () => _chooseChapter(context),
          ),
          ValueListenableBuilder(
              valueListenable: _pageManager.playButtonNotifier,
              builder: (_, value, __) {
                switch (value) {
                  case ButtonState.loading:
                    return Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                    );
                  case ButtonState.paused:
                    return FlutterFlowIconButton(
                      borderRadius: 30,
                      buttonSize: 60,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.play_arrow,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 32,
                      ),
                      onPressed: _pageManager.play,
                    );
                  case ButtonState.playing:
                    return FlutterFlowIconButton(
                      borderRadius: 30,
                      buttonSize: 60,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      icon: Icon(
                        Icons.pause,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 32,
                      ),
                      onPressed: _pageManager.pause,
                    );
                }
              }),
          FlutterFlowIconButton(
            borderRadius: 20,
            buttonSize: 40,
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
            icon: Icon(
              widget.showingTextContent!
                  ? Icons.audiotrack_rounded
                  : Icons.text_fields_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
            onPressed: _switchContent,
          )
        ],
      ),
    );
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
