import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/audio/services/service_locator.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/audio_page_widget.dart';
import '/components/empty_list_component_widget.dart';
import '/components/prayer_text_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'sections_view_model.dart';
export 'sections_view_model.dart';

class SectionsViewWidget extends StatefulWidget {
  const SectionsViewWidget({
    super.key,
    this.sections,
    int? initialPage,
    double? initialAudioTime,
    bool? continueAudio,
  })  : initialPage = initialPage ?? 0,
        continueAudio = continueAudio ?? false,
        initialAudioTime = initialAudioTime ?? 0.0;

  final List<PrayerSectionStruct>? sections;
  final int initialPage;
  final double initialAudioTime;
  final bool continueAudio;

  @override
  State<SectionsViewWidget> createState() => _SectionsViewWidgetState();
}

class _SectionsViewWidgetState extends State<SectionsViewWidget>
    with TickerProviderStateMixin {
  late SectionsViewModel _model;

  final animationsMap = <String, AnimationInfo>{};
  final _pageManager = getIt<PageManager>();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  void onTrackIndexChanged() async {
    await _model.pageViewController?.animateToPage(
      _pageManager.trackIndexNotifier.value,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SectionsViewModel());

    _pageManager.trackIndexNotifier.addListener(onTrackIndexChanged);

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.flattenedSections = functions
          .flattenSectionsList(widget.sections!.toList())!
          .toList()
          .cast<PrayerSectionStruct>();
      _model.currentAudioTime = widget.initialAudioTime;
      safeSetState(() {});
      if ((_model.flattenedSections
                      .elementAtOrNull(valueOrDefault<int>(
                        widget.initialPage,
                        0,
                      ))
                      ?.texts !=
                  null &&
              (_model.flattenedSections
                      .elementAtOrNull(valueOrDefault<int>(
                        widget.initialPage,
                        0,
                      ))
                      ?.texts)!
                  .isNotEmpty) ==
          true) {
        _model.currentSection =
            _model.flattenedSections.elementAtOrNull(valueOrDefault<int>(
          widget.initialPage,
          0,
        ));
        _model.isLoading = false;
        safeSetState(() {});
      } else {
        _model.prayerSectionInitialDataResult =
            await PrayerSectionContentCall.call(
          prayerSectionId: _model.flattenedSections
              .elementAtOrNull(valueOrDefault<int>(
                widget.initialPage,
                0,
              ))
              ?.sectionId,
        );

        if ((_model.prayerSectionInitialDataResult?.succeeded ?? false)) {
          _model.currentSection = PrayerSectionStruct.maybeFromMap(
              (_model.prayerSectionInitialDataResult?.jsonBody ?? ''));
          _model.isLoading = false;
          safeSetState(() {});
        } else {
          _model.isLoading = false;
          safeSetState(() {});
        }
      }
    });

    animationsMap.addAll({
      'pageViewOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    _pageManager.trackIndexNotifier.removeListener(onTrackIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                final prayerSection = _model.flattenedSections.toList();
                if (prayerSection.isEmpty) {
                  return const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: EmptyListComponentWidget(),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _model.pageViewController ??= PageController(
                        initialPage: max(
                            0,
                            min(
                                valueOrDefault<int>(
                                  widget.initialPage,
                                  0,
                                ),
                                prayerSection.length - 1))),
                    onPageChanged: (_) async {
                      _model.currentAudioTime = 0.0;
                      _model.isLoading = true;
                      safeSetState(() {});
                      if ((_model.flattenedSections
                                      .elementAtOrNull(valueOrDefault<int>(
                                        _model.pageViewCurrentIndex,
                                        0,
                                      ))
                                      ?.texts !=
                                  null &&
                              (_model.flattenedSections
                                      .elementAtOrNull(valueOrDefault<int>(
                                        _model.pageViewCurrentIndex,
                                        0,
                                      ))
                                      ?.texts)!
                                  .isNotEmpty) ==
                          true) {
                        _model.currentSection = _model.flattenedSections
                            .elementAtOrNull(valueOrDefault<int>(
                          _model.pageViewCurrentIndex,
                          0,
                        ));
                        _model.isLoading = false;
                        safeSetState(() {});
                      } else {
                        _model.prayerSectionDataResult =
                            await PrayerSectionContentCall.call(
                          prayerSectionId: _model.flattenedSections
                              .elementAtOrNull(valueOrDefault<int>(
                                _model.pageViewCurrentIndex,
                                0,
                              ))
                              ?.sectionId,
                        );

                        if ((_model.prayerSectionDataResult?.succeeded ??
                            true)) {
                          _model.currentSection =
                              PrayerSectionStruct.maybeFromMap(
                                  (_model.prayerSectionDataResult?.jsonBody ??
                                      ''));
                          _model.isLoading = false;
                          safeSetState(() {});
                        } else {
                          _model.isLoading = false;
                          safeSetState(() {});
                        }
                      }

                      safeSetState(() {});
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: prayerSection.length,
                    itemBuilder: (context, prayerSectionIndex) {
                      final prayerSectionItem =
                          prayerSection[prayerSectionIndex];
                      return Stack(
                        children: [
                          Builder(
                            builder: (context) {
                              if (!_model.displayAudioPage) {
                                return Container(
                                  height: double.infinity,
                                  decoration: const BoxDecoration(),
                                  child: RefreshIndicator(
                                    key: const Key('RefreshIndicator_zatxzwlf'),
                                    color: FlutterFlowTheme.of(context).primary,
                                    onRefresh: () async {
                                      safeSetState(() {});
                                    },
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              AutoSizeText(
                                                valueOrDefault<String>(
                                                  _model.currentSection?.title,
                                                  'Titlu sectiune',
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                minFontSize: 24.0,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              'Merriweather',
                                                          fontSize: 24.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                              if (prayerSectionItem.subtitle !=
                                                  '')
                                                AutoSizeText(
                                                  valueOrDefault<String>(
                                                    _model.currentSection
                                                        ?.subtitle,
                                                    'Subtitlu sectiune',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  minFontSize: 14.0,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        fontSize:
                                                            valueOrDefault<
                                                                double>(
                                                          valueOrDefault<
                                                                  double>(
                                                                FFAppState()
                                                                    .fontSizeMultiplier,
                                                                1.0,
                                                              ) *
                                                              14,
                                                          32.0,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                ),
                                            ].divide(
                                                const SizedBox(height: 4.0)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                            child: Builder(
                                              builder: (context) {
                                                final texts = _model
                                                        .currentSection?.texts
                                                        .toList() ??
                                                    [];
                                                if (texts.isEmpty) {
                                                  return const Center(
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      height: 300.0,
                                                      child:
                                                          EmptyListComponentWidget(
                                                        title:
                                                            'Textul nu a putut fi încărcat!',
                                                        subtitle:
                                                            'Vă rugăm încercați mai târziu.',
                                                      ),
                                                    ),
                                                  );
                                                }

                                                return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: texts.length,
                                                  itemBuilder:
                                                      (context, textsIndex) {
                                                    final textsItem =
                                                        texts[textsIndex];
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              _model.currentAudioTime =
                                                                  textsItem
                                                                      .startTime;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                if ((textsItem
                                                                            .startTime <=
                                                                        _model
                                                                            .currentAudioTime!) &&
                                                                    (textsItem
                                                                            .endTime >
                                                                        _model
                                                                            .currentAudioTime!))
                                                                  Icon(
                                                                    Icons
                                                                        .chevron_right,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    size: 16.0,
                                                                  ),
                                                                Flexible(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if ((textsItem.startTime <= _model.currentAudioTime!) &&
                                                                            (textsItem.endTime >
                                                                                _model.currentAudioTime!)) {
                                                                          return AutoSizeText(
                                                                            '${textsItem.repetition != 1 ? textsItem.repetition.toString() : ''}${textsItem.repetition != 1 ? ' ' : ''}${textsItem.title}',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            maxLines:
                                                                                1,
                                                                            minFontSize:
                                                                                16.0,
                                                                            style:
                                                                                FlutterFlowTheme.of(context).titleSmall.override(
                                                                              fontFamily: 'Merriweather',
                                                                              fontSize: FFAppState().fontSizeMultiplier * 16,
                                                                              letterSpacing: 0.0,
                                                                              shadows: [
                                                                                Shadow(
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  offset: const Offset(0.0, 0.0),
                                                                                  blurRadius: 0.5,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          );
                                                                        } else {
                                                                          return Text(
                                                                            '${textsItem.repetition > 1 ? textsItem.repetition.toString() : ''}${textsItem.repetition > 1 ? ' ' : ''}${textsItem.title}',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: 'Merriweather',
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  fontSize: valueOrDefault<double>(
                                                                                    valueOrDefault<double>(
                                                                                          FFAppState().fontSizeMultiplier,
                                                                                          1.0,
                                                                                        ) *
                                                                                        16,
                                                                                    32.0,
                                                                                  ),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                if ((textsItem
                                                                            .startTime <=
                                                                        _model
                                                                            .currentAudioTime!) &&
                                                                    (textsItem
                                                                            .endTime >
                                                                        _model
                                                                            .currentAudioTime!))
                                                                  Icon(
                                                                    Icons
                                                                        .chevron_left,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    size: 16.0,
                                                                  ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        if ((textsItem
                                                                .textElements
                                                                .isNotEmpty) ==
                                                            false)
                                                          Text(
                                                            'Textul va fi adăugat curând.',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                          ),
                                                        if ((textsItem
                                                                .textElements
                                                                .isNotEmpty) ==
                                                            true)
                                                          Builder(
                                                            builder: (context) {
                                                              final textElement =
                                                                  textsItem
                                                                      .textElements
                                                                      .toList();

                                                              return Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: List.generate(
                                                                    textElement
                                                                        .length,
                                                                    (textElementIndex) {
                                                                  final textElementItem =
                                                                      textElement[
                                                                          textElementIndex];
                                                                  return wrapWithModel(
                                                                    model: _model
                                                                        .prayerTextModels
                                                                        .getModel(
                                                                      textElementItem
                                                                          .text,
                                                                      textElementIndex,
                                                                    ),
                                                                    updateCallback: () =>
                                                                        safeSetState(
                                                                            () {}),
                                                                    child:
                                                                        PrayerTextWidget(
                                                                      key: Key(
                                                                        'Keywwi_${textElementItem.text}',
                                                                      ),
                                                                      isFirstInList:
                                                                          textElementIndex ==
                                                                              0,
                                                                      textInput:
                                                                          textElementItem
                                                                              .text,
                                                                      isHighlighted: (functions.sum(textsItem.startTime, functions.multiply(textElementItem.startTime, textsItem.intervalFactor)) <=
                                                                              _model
                                                                                  .currentAudioTime!) &&
                                                                          (functions.sum(textsItem.startTime, functions.multiply(textElementItem.endTime, textsItem.intervalFactor)) >
                                                                              _model.currentAudioTime!),
                                                                      onTextPressed:
                                                                          () async {
                                                                        final newAudioTime = functions.sum(
                                                                            textsItem.startTime,
                                                                            functions.multiply(
                                                                                textElementItem.startTime,
                                                                                valueOrDefault<double>(
                                                                                  textsItem.intervalFactor,
                                                                                  1.0,
                                                                                )));
                                                                        getIt<PageManager>().seek(Duration(
                                                                            seconds:
                                                                                newAudioTime.toInt()));
                                                                        _model.currentAudioTime =
                                                                            newAudioTime;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                    ),
                                                                  );
                                                                }).divide(
                                                                    const SizedBox(
                                                                        height:
                                                                            4.0)),
                                                              );
                                                            },
                                                          ),
                                                      ]
                                                          .divide(
                                                              const SizedBox(
                                                                  height: 8.0))
                                                          .around(
                                                              const SizedBox(
                                                                  height: 8.0)),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ]
                                            .divide(
                                                const SizedBox(height: 16.0))
                                            .addToStart(
                                                const SizedBox(height: 16.0))
                                            .addToEnd(
                                                const SizedBox(height: 16.0)),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  height: double.infinity,
                                  decoration: const BoxDecoration(),
                                  child: wrapWithModel(
                                    model: _model.audioPageModels.getModel(
                                      prayerSectionItem.id,
                                      prayerSectionIndex,
                                    ),
                                    updateCallback: () => safeSetState(() {}),
                                    updateOnChange: true,
                                    child: AudioPageWidget(
                                      key: Key(
                                        'Keyvha_${prayerSectionItem.id}',
                                      ),
                                      title: valueOrDefault<String>(
                                        prayerSectionItem.title,
                                        'Titlu',
                                      ),
                                      subtitle: prayerSectionItem.subtitle,
                                      imageUrl: prayerSectionItem.imageUrl,
                                      texts: _model.currentSection?.texts,
                                      onAudioTimeChanged:
                                          (selectedAudioTime) async {
                                        getIt<PageManager>().seek(Duration(
                                            seconds: selectedAudioTime));
                                        _model.currentAudioTime =
                                            selectedAudioTime.toDouble();
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          if (_model.isLoading)
                            Visibility(
                              visible: _model.isLoading,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                child: Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: SizedBox(
                                    width: 64.0,
                                    height: 64.0,
                                    child: custom_widgets
                                        .CustomCircularProgressIndicator(
                                      width: 64.0,
                                      height: 64.0,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ).animateOnPageLoad(
                    animationsMap['pageViewOnPageLoadAnimation']!);
              },
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Container(
              height: 80.0,
              decoration: const BoxDecoration(),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.SectionsControlBar(
                  width: double.infinity,
                  height: double.infinity,
                  initialAudioTime: valueOrDefault<int>(
                    functions.doubleToInt(_model.currentAudioTime),
                    0,
                  ),
                  playlist:
                      _model.flattenedSections.map((e) => e.audioUrl).toList(),
                  continueAudio: widget.continueAudio,
                  sections: widget.sections!,
                  flattenedSections: _model.flattenedSections,
                  showingTextContent: !_model.displayAudioPage,
                  initialTrackIndex: valueOrDefault<int>(
                    widget.initialPage,
                    0,
                  ),
                  playbackRate: valueOrDefault<double>(
                    FFAppState().audioSpeed,
                    1.0,
                  ),
                  switchContent: () async {
                    _model.displayAudioPage = !_model.displayAudioPage;
                    safeSetState(() {});
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
