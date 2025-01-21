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
  final List<PrayerSectionStruct> sections;
  final List<String> playlist;
  final double? width;
  final double? height;
  final Future Function()? switchContent;
  final bool? showingTextContent;

  const SectionsControlBar(
      {super.key,
      this.width,
      this.height,
      this.playbackRate,
      required this.playlist,
      this.showingTextContent,
      this.switchContent,
      required this.sections});

  @override
  State<SectionsControlBar> createState() => _SectionsControlBarState();
}

class _SectionsControlBarState extends State<SectionsControlBar> {
  final _pageManager = getIt<PageManager>();

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

  Future<void> _chooseChapter(BuildContext content) async {
    final index = await showModalBottomSheet<int>(
        isDismissible: true,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return ChooseChapterWidget(
              currentChapterIndex: _pageManager.trackIndexNotifier.value,
              chapterOptions:
                  convertPrayerSectionToChapterOption(widget.sections));
        });
    if (index == null) {
      return;
    }
    print(index);

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FlutterFlowIconButton(
            borderRadius: 24,
            buttonSize: 48,
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
            icon: Icon(
              Icons.menu_book,
              color: FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
            onPressed: () => _chooseChapter(context),
          ),
          FlutterFlowIconButton(
            borderRadius: 32,
            buttonSize: 64,
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
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
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
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
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
            icon: Icon(
              widget.showingTextContent!
                  ? Icons.audiotrack_rounded
                  : Icons.text_fields_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
            onPressed: widget.switchContent,
          )
        ],
      ),
    );
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
