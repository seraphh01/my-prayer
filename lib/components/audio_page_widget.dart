import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'audio_page_model.dart';
export 'audio_page_model.dart';

class AudioPageWidget extends StatefulWidget {
  const AudioPageWidget({
    super.key,
    String? title,
    String? subtitle,
    required this.onAudioTimeChanged,
    required this.imageUrls,
    required this.imageUrl,
    this.texts,
  })  : title = title ?? 'Titlu',
        subtitle = subtitle ?? 'Subtitlu';

  final String title;
  final String subtitle;
  final Future Function(int selectedAudioTime)? onAudioTimeChanged;
  final String? imageUrl;
  final List<String> imageUrls;
  final List<SectionTextStruct>? texts;

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

  @override
  Widget build(BuildContext context) {
    var currentText = widget.texts
        ?.where((e) =>
            ((e.startTime <= _model.slideAudioTime!) &&
                (e.endTime >= _model.slideAudioTime!) &&
                _model.isSliding) ||
            ((e.startTime <= _model.currentAudioTime) &&
                (e.endTime > _model.currentAudioTime) &&
                !_model.isSliding))
        .firstOrNull;
    return ClipRRect(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'sectionImageHero',
                    child: SizedBox(
                      height: 260,
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
                              width: 260,
                              height: 260,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(80.0),
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
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: 'Merriweather',
                                letterSpacing: 0.0,
                              ),
                        ),
                        if (widget.subtitle != '')
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                      ].divide(const SizedBox(height: 8.0)),
                    ),
                  ),
                ].divide(const SizedBox(height: 32.0)),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 18.0,
                          decoration: const BoxDecoration(),
                          child: Visibility(
                            visible: valueOrDefault<bool>(
                              widget.texts != null &&
                                  (widget.texts)!.isNotEmpty,
                              false,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '> ',
                                  style: TextStyle(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                ),
                                GestureDetector(
                                  child: Text(
                                    valueOrDefault<String>(
                                      currentText?.title,
                                      '-',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: FFAppState().fontFamily,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  onTap: () async {
                                    if (currentText != null) {
                                      await widget.onAudioTimeChanged?.call(
                                        currentText.startTime,
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  ' <',
                                  style: TextStyle(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, -1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: SizedBox(
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
                                  _model.slideAudioTime =
                                      functions.doubleToInt(newValue);
                                  safeSetState(() {});
                                },
                                onValueChangeEnd: (newValue) async {
                                  print('Slider change end: $newValue');
                                  await widget.onAudioTimeChanged?.call(
                                    functions.doubleToInt(newValue),
                                  );
                                  _model.isSliding = false;
                                  _model.slideAudioTime = 0;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 0.0, 24.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            valueOrDefault<String>(
                              (int audioTime) {
                                return "${audioTime >= 3600 ? ("${audioTime ~/ 3600}:") : ""}${((audioTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(audioTime % 60).toString().padLeft(2, '0')}";
                              }(_model.currentAudioTime),
                              '00:00',
                            ),
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                          Text(
                            valueOrDefault<String>(
                              (int totalTime) {
                                return "${totalTime >= 3600 ? ("${totalTime ~/ 3600}:") : ""}${((totalTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(totalTime % 60).toString().padLeft(2, '0')}";
                              }(_model.totalDuration),
                              '07:00',
                            ),
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ].divide(const SizedBox(
              width: 16,
            ))),
      ),
    );
  }
}
