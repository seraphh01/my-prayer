import 'package:auto_size_text/auto_size_text.dart';
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
    final texts = widget.texts ?? <SectionTextStruct>[];
    final currentIndex = currentText == null
      ? -1
      : texts.indexWhere((e) =>
        e.startTime == currentText.startTime &&
        e.endTime == currentText.endTime);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex >= 0 && currentIndex < texts.length - 1;
    
    return ClipRRect(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context)
                            .secondaryBackground,
                        FlutterFlowTheme.of(context)
                            .primaryBackground,
                        
                      ],
                      begin: Alignment.bottomRight  * 5.0,
                      end: Alignment.topLeft * 5.0,
                      
                    ),
                    borderRadius: BorderRadius.circular(36.0),

                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 16.0, 16.0, 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 6.0, 10.0, 6.0),
                              child: Text(
                                'Acum se redă',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      fontFamily: 'Inter',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'sectionImageHero',
                          child: SizedBox(
                            height: 240,
                            child: PageView.builder(
                              controller:
                                  pageViewController ??= PageController(),
                              onPageChanged: (pageIndex) async {
                                currentSection = pageIndex;
                                await _pageManager.skipToIndex(pageIndex);
                              },
                              itemCount: widget.imageUrls.length,
                              itemBuilder: (context, index) {
                                final imageUrl = widget.imageUrls[index];
                                return Center(
                                  child: SizedBox(
                                    width: 240,
                                    height: 240,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(72.0),
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
                              8.0, 0.0, 8.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Inter',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ].divide(const SizedBox(height: 20.0)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: valueOrDefault<bool>(
                            widget.texts != null &&
                                (widget.texts)!.isNotEmpty,
                            false,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ],
                                  begin: Alignment.bottomRight  * 5.0,
                                  end: Alignment.topLeft * 5.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          8.0, 6.0, 8.0, 8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: !hasPrev
                                                ? null
                                                : () async {
                                                    await widget
                                                        .onAudioTimeChanged
                                                        ?.call(
                                                      texts[currentIndex - 1]
                                                          .startTime,
                                                    );
                                                  },
                                            constraints: const BoxConstraints(
                                              minWidth: 32.0,
                                              minHeight: 32.0,
                                            ),
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.skip_previous_rounded,
                                              size: 20.0,
                                              color: hasPrev
                                                  ? FlutterFlowTheme.of(context)
                                                      .secondary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              child: AutoSizeText(
                                                valueOrDefault<String>(
                                                  currentText?.title,
                                                  '-',
                                                ),
                                                textAlign: TextAlign.center,
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.visible,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FFAppState()
                                                                  .fontFamily,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                              onTap: () async {
                                                if (currentText != null) {
                                                  await widget
                                                      .onAudioTimeChanged
                                                      ?.call(
                                                    currentText.startTime,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: !hasNext
                                                ? null
                                                : () async {
                                                    await widget
                                                        .onAudioTimeChanged
                                                        ?.call(
                                                      texts[currentIndex + 1]
                                                          .startTime,
                                                    );
                                                  },
                                            constraints: const BoxConstraints(
                                              minWidth: 32.0,
                                              minHeight: 32.0,
                                            ),
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.skip_next_rounded,
                                              size: 20.0,
                                              color: hasNext
                                                  ? FlutterFlowTheme.of(context)
                                                      .secondary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 28.0,
                                        child: custom_widgets.CustomSlider(
                                          width: double.infinity,
                                          height: 28.0,
                                          sliderValue:
                                              _model.currentAudioTime.toDouble(),
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
                                            await widget
                                                .onAudioTimeChanged
                                                ?.call(
                                              functions.doubleToInt(newValue),
                                            );
                                            _model.isSliding = false;
                                            _model.slideAudioTime = 0;
                                            safeSetState(() {});
                                          },
                                        ),
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
                              ),
                            ].divide(const SizedBox(height: 6.0)),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ].divide(const SizedBox(
              width: 16,
            ))),
      ),
    ));
  }
}
