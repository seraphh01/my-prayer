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
import 'package:my_prayer/service_locator.dart';
import '../audio/page_manager.dart';
import '../audio/notifiers/play_button_notifier.dart';
import 'dart:convert'; // For base64 encoding
import 'package:flutter/services.dart'; // For rootBundle

class SectionsControlBar extends StatefulWidget {
  final double? playbackRate;
  final double? width;
  final double? height;
  final Future Function()? switchContent;
  final Future Function()? chooseChapter;
  final bool showingTextContent;
  final bool hasTextContent;
  final bool hasAudioContent;
  final bool showAudioTimingBar;

  const SectionsControlBar(
      {super.key,
      this.width,
      this.height,
      this.playbackRate,
      required this.showingTextContent,
      required this.hasTextContent,
      required this.hasAudioContent,
      this.showAudioTimingBar = false,
      this.switchContent,
      this.chooseChapter});

  @override
  State<SectionsControlBar> createState() => _SectionsControlBarState();
}

class _SectionsControlBarState extends State<SectionsControlBar> {
  final _pageManager = getIt<PageManager>();
  bool _isSliding = false;
  int _slideAudioTime = 0;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _switchContent() {
    widget.switchContent!();
  }

  String _formatTime(int seconds) {
    final hours = seconds >= 3600 ? '${seconds ~/ 3600}:' : '';
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours$minutes:$secs';
  }

  Widget _buildAudioTimingBar(
    BuildContext context, {
    bool showSlider = true,
    bool showTimestamps = true,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return ValueListenableBuilder<Duration>(
      valueListenable: _pageManager.currentProgressNotifier,
      builder: (context, progress, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: _pageManager.bufferedTimeNotifier,
          builder: (context, buffered, __) {
            return ValueListenableBuilder<Duration>(
              valueListenable: _pageManager.totalDurationNotifier,
              builder: (context, total, ___) {
                final currentSeconds =
                    _isSliding ? _slideAudioTime : progress.inSeconds;
                final totalSeconds = total.inSeconds;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSlider)
                      SizedBox(
                        width: double.infinity,
                        height: 20.0,
                        child: CustomSlider(
                          width: double.infinity,
                          height: 20.0,
                          sliderValue: currentSeconds.toDouble(),
                          bufferValue: buffered.inSeconds,
                          minValue: 0,
                          maxValue: totalSeconds,
                          padding: EdgeInsets.zero,
                          onValueChange: (value) async {
                            setState(() {
                              _isSliding = true;
                              _slideAudioTime = value.round();
                            });
                          },
                          onValueChangeEnd: (value) async {
                            await _pageManager.seek(
                              Duration(seconds: value.round()),
                            );
                            if (mounted) {
                              setState(() {
                                _isSliding = false;
                                _slideAudioTime = 0;
                              });
                            }
                          },
                        ),
                      ),
                    if (showTimestamps)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(currentSeconds),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: 'Merriweather',
                                    color: theme.primary,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            Text(
                              _formatTime(totalSeconds),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: 'Merriweather',
                                    color: theme.primary,
                                    fontSize: 14.0,
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
    );
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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        boxShadow: widget.showAudioTimingBar
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  offset: const Offset(0.0, -3.0),
                  blurRadius: 8.0,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showAudioTimingBar) ...[
                const SizedBox(height: 10.0),
                _buildAudioTimingBar(context, showSlider: false),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 24,
                        buttonSize: 48,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        icon: Icon(
                          Icons.menu_book,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24,
                        ),
                        onPressed: widget.chooseChapter,
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 32,
                        buttonSize: 64,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        icon: Icon(
                          Icons.navigate_before_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 32,
                        ),
                        onPressed: () => _pageManager.previous(),
                      ),
                      SizedBox(
                        width: 8,
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
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                  ),
                                );
                              case ButtonState.paused:
                                return FlutterFlowIconButton(
                                  borderRadius: 30,
                                  buttonSize: 60,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    size: 32,
                                  ),
                                  onPressed: widget.hasAudioContent
                                      ? _pageManager.play
                                      : null,
                                  disabledColor: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                );
                              case ButtonState.playing:
                                return FlutterFlowIconButton(
                                  borderRadius: 30,
                                  buttonSize: 60,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: Icon(
                                    Icons.pause,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    size: 32,
                                  ),
                                  onPressed: widget.hasAudioContent
                                      ? _pageManager.pause
                                      : null,
                                  disabledColor:
                                      FlutterFlowTheme.of(context).secondary,
                                );

                              default:
                                return Container();
                            }
                          }),
                      SizedBox(
                        width: 8,
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 32,
                        buttonSize: 64,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        icon: Icon(
                          Icons.navigate_next_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 32,
                        ),
                        onPressed: () => _pageManager.next(),
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 24,
                        buttonSize: 48,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        icon: Icon(
                          widget.showingTextContent
                              ? widget.hasAudioContent
                                  ? Icons.audiotrack_rounded
                                  : Icons.text_fields_rounded
                              : widget.hasTextContent
                                  ? Icons.text_fields_rounded
                                  : Icons.audiotrack_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 24,
                        ),
                        onPressed: (widget.showingTextContent &&
                                    widget.hasAudioContent) ||
                                (!widget.showingTextContent &&
                                    widget.hasTextContent)
                            ? widget.switchContent
                            : null,
                      )
                    ].divide(SizedBox(width: 4)),
                  ),
                ),
              ),
            ],
          ),
          if (widget.showAudioTimingBar)
            Positioned(
              top: -10.0,
              left: 0.0,
              right: 0.0,
              child: _buildAudioTimingBar(context, showTimestamps: false),
            ),
        ],
      ),
    );
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
