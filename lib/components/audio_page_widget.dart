import 'dart:math' as math;



import 'package:auto_size_text/auto_size_text.dart';

import 'package:my_prayer/custom_code/audio/page_manager.dart';

import 'package:my_prayer/service_locator.dart';



import '/backend/schema/structs/index.dart';

import '/flutter_flow/flutter_flow_theme.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/custom_code/widgets/index.dart' as custom_widgets;

import '/flutter_flow/custom_functions.dart' as functions;

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'audio_page_model.dart';

export 'audio_page_model.dart';



class AudioPageWidget extends StatefulWidget {

  const AudioPageWidget({

    super.key,

    String? title,

    String? subtitle,

    String? audioUrl,

    required this.onAudioTimeChanged,

    required this.imageUrls,

    required this.imageUrl,

    this.texts,

  })  : title = title ?? 'Titlu',

        subtitle = subtitle ?? 'Subtitlu',

        audioUrl = audioUrl ?? '';



  final String title;

  final String subtitle;

  final Future Function(int selectedAudioTime)? onAudioTimeChanged;

  final String? imageUrl;

  final List<String> imageUrls;

  final List<SectionTextStruct>? texts;

  final String? audioUrl;



  @override

  State<AudioPageWidget> createState() => _AudioPageWidgetState();

}



class _AudioPageWidgetState extends State<AudioPageWidget> {

  late AudioPageModel _model;

  final _pageManager = getIt<PageManager>();

  int currentSection = 0;

  PageController? pageViewController;



  @override

  void setState(VoidCallback callback) {

    super.setState(callback);

    _model.onUpdate();

  }



  @override

  void initState() {

    super.initState();

    _model = createModel(context, () => AudioPageModel());

    handleTotalDurationChanged();

    _model.currentAudioTime =

        _pageManager.currentProgressNotifier.value.inSeconds;

    _model.bufferedTime = _pageManager.bufferedTimeNotifier.value.inSeconds;

    pageViewController =

        PageController(initialPage: _pageManager.trackIndexNotifier.value);



    _pageManager.totalDurationNotifier.addListener(onTotalDurationChanged);

    _pageManager.currentProgressNotifier.addListener(onCurrentProgressChanged);

    _pageManager.bufferedTimeNotifier.addListener(onBufferedTimeChanged);

    _pageManager.trackIndexNotifier.addListener(onTrackIndexChanged);



    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

  }



  void onCurrentProgressChanged() {

    _model.currentAudioTime =

        _pageManager.currentProgressNotifier.value.inSeconds;

    safeSetState(() {});

  }



  void onBufferedTimeChanged() {

    _model.bufferedTime = _pageManager.bufferedTimeNotifier.value.inSeconds;

    safeSetState(() {});

  }



  void onTotalDurationChanged() {

    handleTotalDurationChanged();

    safeSetState(() {});

  }



  void handleTotalDurationChanged() {

    var totalDuration = _pageManager.totalDurationNotifier.value.inSeconds;

    if (totalDuration > 0) {

      _model.totalDuration = totalDuration;

    }

  }



  void onTrackIndexChanged() {

    if (currentSection == _pageManager.trackIndexNotifier.value) {

      return;

    }

    currentSection = _pageManager.trackIndexNotifier.value;

    var currentPageIndex = pageViewController?.page?.toInt() ?? 0;



    var indexDifference = (currentSection - currentPageIndex).abs();



    if (indexDifference > 5) {

      pageViewController?.jumpToPage(currentSection);

    } else {

      pageViewController?.animateToPage(

        currentSection,

        duration: const Duration(milliseconds: 500),

        curve: Curves.ease,

      );

    }



    safeSetState(() {});

  }



  @override

  void dispose() {

    _model.maybeDispose();



    _pageManager.currentProgressNotifier

        .removeListener(onCurrentProgressChanged);

    _pageManager.bufferedTimeNotifier.removeListener(onBufferedTimeChanged);

    _pageManager.totalDurationNotifier.removeListener(onTotalDurationChanged);

    _pageManager.trackIndexNotifier.removeListener(onTrackIndexChanged);



    super.dispose();

  }



  SectionTextStruct? _currentPlayingText() {

    final audioTime = _model.isSliding

        ? (_model.slideAudioTime ?? _model.currentAudioTime)

        : _model.currentAudioTime;



    return widget.texts

        ?.where(

          (text) =>

              text.startTime <= audioTime && text.endTime > audioTime,

        )

        .firstOrNull;

  }



  String _previewFromTextElements(SectionTextStruct text) {
    final body = text.textElements
        .map((element) => element.text.trim())
        .where((elementText) => elementText.isNotEmpty)
        .join(' ');
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return '-';
    }
    final words = normalized.split(' ');
    final preview = words.length <= 3 ? words.join(' ') : words.take(3).join(' ');
    return '$preview...';
  }

  String _displayTitle(SectionTextStruct text) {
    final repetitionPrefix =
        text.repetition > 1 ? '${text.repetition} ' : '';

    if (text.title.isNotEmpty) {
      if (text.repetition > 1) {
        return '$repetitionPrefix${text.title}';
      }
      return text.title;
    }

    final preview = _previewFromTextElements(text);
    if (preview == '-') {
      return preview;
    }
    return '$repetitionPrefix$preview';
  }



  double _headerImageSize(BuildContext context) {

    final fontMultiplier = FFAppState().fontSizeMultiplier;

    final screenHeight = MediaQuery.sizeOf(context).height;

    final base = screenHeight * (fontMultiplier > 1.25 ? 0.2 : 0.26);

    return math.min(base, fontMultiplier > 1.25 ? 180.0 : 260.0);

  }



  Widget _buildSectionHeader(BuildContext context) {

    final imageSize = _headerImageSize(context);

    final fontMultiplier = FFAppState().fontSizeMultiplier;



    return Column(

      mainAxisAlignment: MainAxisAlignment.center,

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        Hero(

          tag: 'sectionImageHero',

          child: SizedBox(

            height: imageSize,

            child: PageView.builder(

              controller: pageViewController ??= PageController(),

              onPageChanged: (pageIndex) async {

                currentSection = pageIndex;

                await _pageManager.skipToIndex(pageIndex);

              },

              itemCount: widget.imageUrls.length,

              itemBuilder: (context, index) {

                final imageUrl = widget.imageUrls[index];

                return Center(

                  child: SizedBox(

                    width: imageSize,

                    height: imageSize,

                    child: ClipRRect(

                      borderRadius: BorderRadius.circular(imageSize * 0.3),

                      child: imageUrl.isNotEmpty

                          ? Image.network(

                              imageUrl,

                              width: double.infinity,

                              height: double.infinity,

                              fit: BoxFit.cover,

                            )

                          : Image.asset(

                              'assets/images/error_image.jpg',

                              width: double.infinity,

                              height: double.infinity,

                              fit: BoxFit.cover,

                            ),

                    ),

                  ),

                );

              },

            ),

          ),

        ),

        const SizedBox(height: 32.0),

        Text(

          widget.title,

          textAlign: TextAlign.center,

          style: FlutterFlowTheme.of(context).headlineSmall.override(

                fontFamily: 'Merriweather',

                fontSize: 22.0 * fontMultiplier,

                letterSpacing: 0.0,

              ),

        ),

        if (widget.subtitle.isNotEmpty) ...[

          const SizedBox(height: 6.0),

          Text(

            widget.subtitle,

            textAlign: TextAlign.center,

            style: FlutterFlowTheme.of(context).bodyLarge.override(

                  fontFamily: 'Inter',

                  color: FlutterFlowTheme.of(context).secondaryText,

                  fontSize: 16.0 * fontMultiplier,

                  letterSpacing: 0.0,

                  fontStyle: FontStyle.italic,

                ),

          ),

        ],

      ],

    );

  }



  Widget _buildTextNavigationRow(

    BuildContext context, {

    required SectionTextStruct currentText,

    required List<SectionTextStruct> texts,

    required int currentIndex,

    required bool hasPrev,

    required bool hasNext,

  }) {

    final theme = FlutterFlowTheme.of(context);
    final iconButtonStyle = IconButton.styleFrom(
      foregroundColor: theme.secondary,
      disabledForegroundColor: theme.secondaryText.withValues(alpha: 0.45),
      minimumSize: const Size(32.0, 32.0),
      padding: EdgeInsets.zero,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          IconButton(
            style: iconButtonStyle,
            onPressed: hasPrev
                ? () async {
                    await widget.onAudioTimeChanged?.call(
                      texts[currentIndex - 1].startTime,
                    );
                  }
                : null,
            icon: const Icon(
              Icons.skip_previous_rounded,
              size: 24.0,
            ),
          ),

          Expanded(

            child: GestureDetector(

              onTap: () async {

                await widget.onAudioTimeChanged?.call(currentText.startTime);

              },

              child: AutoSizeText(

                _displayTitle(currentText),

                textAlign: TextAlign.center,

                maxLines: 2,

                style: theme.titleSmall.override(

                  fontFamily: FFAppState().fontFamily,

                  color: theme.secondary,

                  letterSpacing: 0.0,

                  fontWeight: FontWeight.w600,

                ),

              ),

            ),

          ),

          IconButton(
            style: iconButtonStyle,
            onPressed: hasNext
                ? () async {
                    await widget.onAudioTimeChanged?.call(
                      texts[currentIndex + 1].startTime,
                    );
                  }
                : null,
            icon: const Icon(
              Icons.skip_next_rounded,
              size: 24.0,
            ),
          ),

        ],

      ),

    );

  }



  String _formatTime(int seconds) {

    final hours = seconds >= 3600 ? '${seconds ~/ 3600}:' : '';

    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');

    final secs = (seconds % 60).toString().padLeft(2, '0');

    return '$hours$minutes:$secs';

  }



  Widget _buildAudioControls(BuildContext context) {

    final texts = widget.texts ?? <SectionTextStruct>[];

    final currentText = _currentPlayingText();

    final currentIndex = currentText == null

        ? -1

        : texts.indexWhere(

            (text) =>

                text.startTime == currentText.startTime &&

                text.endTime == currentText.endTime,

          );

    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex >= 0 && currentIndex < texts.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentText != null)
          _buildTextNavigationRow(
            context,
            currentText: currentText,
            texts: texts,
            currentIndex: currentIndex,
            hasPrev: hasPrev,
            hasNext: hasNext,
          ),

        SizedBox(

          width: double.infinity,

          height: 32.0,

          child: custom_widgets.CustomSlider(

            width: double.infinity,

            height: 32.0,

            sliderValue: _model.currentAudioTime.toDouble(),

            bufferValue: _model.bufferedTime,

            minValue: 0,

            maxValue: _model.totalDuration,

            onValueChange: (newValue) async {

              _model.isSliding = true;

              _model.slideAudioTime = functions.doubleToInt(newValue);

              safeSetState(() {});

            },

            onValueChangeEnd: (newValue) async {

              await widget.onAudioTimeChanged?.call(

                functions.doubleToInt(newValue),

              );

              _model.isSliding = false;

              _model.slideAudioTime = 0;

              safeSetState(() {});

            },

          ),

        ),

        Padding(

          padding: const EdgeInsets.symmetric(horizontal: 24.0),

          child: Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                _formatTime(_model.currentAudioTime),

                style: FlutterFlowTheme.of(context).bodySmall.override(

                      fontFamily: 'Inter',

                      color: FlutterFlowTheme.of(context).secondaryText,

                      letterSpacing: 0.0,

                    ),

              ),

              Text(

                _formatTime(_model.totalDuration),

                style: FlutterFlowTheme.of(context).bodySmall.override(

                      fontFamily: 'Inter',

                      color: FlutterFlowTheme.of(context).secondaryText,

                      letterSpacing: 0.0,

                    ),

              ),

            ],

          ),

        ),

      ],

    );

  }



  @override

  Widget build(BuildContext context) {

    context.watch<FFAppState>();



    final hasAudio = widget.audioUrl != null && widget.audioUrl!.isNotEmpty;



    return Container(

      width: double.infinity,

      height: double.infinity,

      color: FlutterFlowTheme.of(context).primaryBackground,

      child: Padding(

        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Expanded(

              child: Center(

                child: SingleChildScrollView(

                  child: _buildSectionHeader(context),

                ),

              ),

            ),

            if (hasAudio) _buildAudioControls(context),

          ],

        ),

      ),

    );

  }

}


