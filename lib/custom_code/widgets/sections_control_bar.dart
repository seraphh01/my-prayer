// Automatic FlutterFlow imports
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

import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class SectionsControlBar extends StatefulWidget {
  final int? initialAudioTime;
  final List<String> playlist;
  final double? width;
  final double? height;
  final Future Function(int currentAudioTime)? onAudioPositionChanged;
  final Future Function()? onAudioFinished;
  final Future Function()? nextText;
  final Future Function()? previousText;
  final Future Function(int pageIndex)? goToPage;

  const SectionsControlBar(
      {super.key,
      this.width,
      this.height,
      this.initialAudioTime,
      required this.playlist,
      this.onAudioPositionChanged,
      this.onAudioFinished,
      this.nextText,
      this.goToPage,
      this.previousText});

  @override
  State<SectionsControlBar> createState() => _SectionsControlBarState();
}

class _SectionsControlBarState extends State<SectionsControlBar> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _lastAudioTime = 0;
  int _currentTrackIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Load the audio from the network
    _audioPlayer
        .setSourceUrl(widget.playlist.isNotEmpty
            ? widget.playlist[_currentTrackIndex]
            : '')
        .catchError((error) {
      print("Error loading audio: $error");
    });

    _audioPlayer.onPositionChanged.listen((position) {
      widget.onAudioPositionChanged?.call(position.inSeconds);
      _lastAudioTime = position.inSeconds;
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      // reset variables - go to next track if autoplay is on
      widget.onAudioFinished?.call();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _chooseChapter() {
    // open bottom sheet
    print("Choose chapter clicked");
  }

  void _nextPage() {
    widget.nextText!();
  }

  void _previousPage() {
    widget.previousText!();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastAudioTime != widget.initialAudioTime) {
      _audioPlayer.seek(Duration(seconds: widget.initialAudioTime ?? 0));
      _lastAudioTime = widget.initialAudioTime ?? 0;
    }
    return Container(
      width: widget.width,
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary),
            color: FlutterFlowTheme.of(context).primary,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24,
            ),
            onPressed: _togglePlayPause,
          ),
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary),
            color: FlutterFlowTheme.of(context).primary,
            icon: Icon(
              Icons.stop,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24,
            ),
            onPressed: _stopAudio,
          ),
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary),
            color: FlutterFlowTheme.of(context).primary,
            icon: Icon(
              Icons.menu_book,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24,
            ),
            onPressed: _chooseChapter,
          ),
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary),
            color: FlutterFlowTheme.of(context).primary,
            icon: Icon(
              Icons.arrow_up,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24,
            ),
            onPressed: _previousPage,
          ),
          IconButton(
            style: IconButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary),
            color: FlutterFlowTheme.of(context).primary,
            icon: Icon(
              Icons.arrow_down,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24,
            ),
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
