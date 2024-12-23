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

import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class PlayPauseButton extends StatefulWidget {
  final int? initialAudioTime;
  final String audioUrl;
  final double? width;
  final double? height;
  final Future Function(int currentAudioTime)? incrementTimerAction;
  final Future Function()? onAudioFinished;

  const PlayPauseButton(
      {super.key,
      this.width,
      this.height,
      this.initialAudioTime,
      required this.audioUrl,
      this.incrementTimerAction,
      this.onAudioFinished});

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _lastAudioTime = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Load the audio from network
    _audioPlayer.setSourceUrl(widget.audioUrl).catchError((error) {
      print("Error loading audio: $error");
    });

    _audioPlayer.onPositionChanged.listen((position) {
      widget.incrementTimerAction!(position.inSeconds);
      _lastAudioTime = position.inSeconds;
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      widget.onAudioFinished!();
    });

    if (FFAppState().autoPlayNext &&
        FFAppState().isPlaying &&
        _audioPlayer.state != PlayerState.playing) {
      _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      widget.incrementTimerAction!(-1);
    } else {
      _audioPlayer.resume();
    }
    setState(() {
      FFAppState().update(() {
        FFAppState().isPlaying = !_isPlaying;
      });

      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lastAudioTime != widget.initialAudioTime) {
      _audioPlayer.seek(
          Duration(milliseconds: (widget.initialAudioTime! * 1000).floor()));
      _lastAudioTime = widget.initialAudioTime!;
    }
    return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.circular(16)),
        child: IconButton(
          enableFeedback: false,
          hoverColor: Colors.transparent,
          color: FlutterFlowTheme.of(context).primary,
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: FlutterFlowTheme.of(context).primaryBackground,
            size: 24,
          ),
          onPressed: _togglePlayPause,
        ));
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
