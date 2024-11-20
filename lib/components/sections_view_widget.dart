import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/components/empty_list_component_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sections_view_model.dart';
export 'sections_view_model.dart';

class SectionsViewWidget extends StatefulWidget {
  const SectionsViewWidget({
    super.key,
    this.sections,
  });

  final List<PrayerSectionStruct>? sections;

  @override
  State<SectionsViewWidget> createState() => _SectionsViewWidgetState();
}

class _SectionsViewWidgetState extends State<SectionsViewWidget>
    with TickerProviderStateMixin {
  late SectionsViewModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SectionsViewModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.flattenedSections = functions
          .flattenSectionsList(widget.sections!.toList())!
          .toList()
          .cast<PrayerSectionStruct>();
      _model.currentAudioUrl = _model.flattenedSections.first.audioUrl;
      safeSetState(() {});
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(),
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
                        initialPage: max(0, min(0, prayerSection.length - 1))),
                    onPageChanged: (_) async {
                      _model.currentAudioUrl =
                          prayerSection[_model.pageViewCurrentIndex].audioUrl;
                      _model.currentAudioTime = -1.0;
                      _model.updatePage(() {});
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: prayerSection.length,
                    itemBuilder: (context, prayerSectionIndex) {
                      final prayerSectionItem =
                          prayerSection[prayerSectionIndex];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if ((prayerSectionItem.subsections.isNotEmpty) ==
                              false)
                            Container(
                              height: MediaQuery.sizeOf(context).height * 0.8,
                              decoration: const BoxDecoration(),
                              child: Visibility(
                                visible: (prayerSectionItem
                                        .subsections.isNotEmpty) ==
                                    false,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              prayerSectionItem.title,
                                              'Titlu sectiune',
                                            ),
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  fontFamily: 'Inter Tight',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          if (prayerSectionItem.subtitle != '')
                                            Text(
                                              valueOrDefault<String>(
                                                prayerSectionItem.subtitle,
                                                'Subtitlu sectiune',
                                              ),
                                              textAlign: TextAlign.center,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        letterSpacing: 0.0,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                            ),
                                        ].divide(const SizedBox(height: 4.0)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        child: FutureBuilder<ApiCallResponse>(
                                          future: PrayerSectionContentCall.call(
                                            prayerSectionId:
                                                prayerSectionItem.sectionId,
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return Center(
                                                child: SizedBox(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            final listViewPrayerSectionContentResponse =
                                                snapshot.data!;

                                            return Builder(
                                              builder: (context) {
                                                final texts = (getJsonField(
                                                      listViewPrayerSectionContentResponse
                                                          .jsonBody,
                                                      r'''$.texts''',
                                                      true,
                                                    )
                                                                ?.toList()
                                                                .map<SectionTextStruct?>(
                                                                    SectionTextStruct
                                                                        .maybeFromMap)
                                                                .toList()
                                                            as Iterable<
                                                                SectionTextStruct?>)
                                                        .withoutNulls
                                                        .toList() ??
                                                    [];
                                                if (texts.isEmpty) {
                                                  return const Center(
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      height: 300.0,
                                                      child:
                                                          EmptyListComponentWidget(),
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
                                                                          return Text(
                                                                            '${textsItem.repetition != 1 ? textsItem.repetition.toString() : ''}${textsItem.repetition != 1 ? ' ' : ''}${textsItem.title}',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                FlutterFlowTheme.of(context).titleMedium.override(
                                                                              fontFamily: 'Inter Tight',
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
                                                                            '${textsItem.repetition != 1 ? textsItem.repetition.toString() : ''}${textsItem.repetition != 1 ? ' ' : ''}${textsItem.title}',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                  fontFamily: 'Inter Tight',
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
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
                                                              ].divide(const SizedBox(
                                                                  width: 8.0)),
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
                                                                  return InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      _model.currentAudioTime = functions.sum(
                                                                          textsItem
                                                                              .startTime,
                                                                          textElementItem
                                                                              .startTime);
                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if ((functions.sum(textsItem.startTime, functions.multiply(textElementItem.startTime, textsItem.intervalFactor)) <= _model.currentAudioTime!) &&
                                                                            (functions.sum(textsItem.startTime, functions.multiply(textElementItem.endTime, textsItem.intervalFactor)) >
                                                                                _model.currentAudioTime!)) {
                                                                          return Text(
                                                                            textElementItem.text,
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            style:
                                                                                FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              fontFamily: 'Inter',
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
                                                                            textElementItem.text,
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Inter',
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w300,
                                                                                ),
                                                                          );
                                                                        }
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
                                                          .divide(const SizedBox(
                                                              height: 8.0))
                                                          .around(const SizedBox(
                                                              height: 8.0)),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ]
                                        .divide(const SizedBox(height: 16.0))
                                        .addToStart(const SizedBox(height: 16.0))
                                        .addToEnd(const SizedBox(height: 16.0)),
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
              height: MediaQuery.sizeOf(context).height * 0.1,
              decoration: const BoxDecoration(),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.SectionsControlBar(
                  width: double.infinity,
                  height: double.infinity,
                  initialAudioTime: 0,
                  playlist:
                      _model.flattenedSections.map((e) => e.audioUrl).toList(),
                  onAudioPositionChanged: (currentAudioTime) async {},
                  onAudioFinished: () async {},
                  nextText: () async {},
                  goToPage: (pageIndex) async {},
                  previousText: () async {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
