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
    int? currentAudioTime,
    int? totalAudioTime,
    String? title,
    String? subtitle,
    required this.onAudioTimeChanged,
    required this.imageUrl,
    this.texts,
  })  : currentAudioTime = currentAudioTime ?? 0,
        totalAudioTime = totalAudioTime ?? 0,
        title = title ?? 'Titlu',
        subtitle = subtitle ?? 'Subtitlu';

  final int currentAudioTime;
  final int totalAudioTime;
  final String title;
  final String subtitle;
  final Future Function(int selectedAudioTime)? onAudioTimeChanged;
  final String? imageUrl;
  final List<SectionTextStruct>? texts;

  @override
  State<AudioPageWidget> createState() => _AudioPageWidgetState();
}

class _AudioPageWidgetState extends State<AudioPageWidget> {
  late AudioPageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AudioPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
                  child: Container(
                    width: 280.0,
                    height: 280.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/error_image.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Merriweather',
                                  letterSpacing: 0.0,
                                ),
                      ),
                      if (widget.subtitle != '')
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
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
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, -1.0),
                            child: RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '> ',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: valueOrDefault<String>(
                                      widget.texts
                                          ?.where((e) =>
                                              ((e.startTime <=
                                                      _model.slideAudioTime!
                                                          .toDouble()) &&
                                                  (e.endTime >=
                                                      _model.slideAudioTime!
                                                          .toDouble()) &&
                                                  _model.isSliding) ||
                                              ((e.startTime <=
                                                      valueOrDefault<double>(
                                                        widget.currentAudioTime
                                                            .toDouble(),
                                                        0.0,
                                                      )) &&
                                                  (e.endTime >=
                                                      valueOrDefault<double>(
                                                        widget.currentAudioTime
                                                            .toDouble(),
                                                        0.0,
                                                      )) &&
                                                  !_model.isSliding))
                                          .toList()
                                          .firstOrNull
                                          ?.title,
                                      '-',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Merriweather',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  TextSpan(
                                    text: ' <',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  )
                                ],
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Merriweather',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
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
                              sliderValue: widget.currentAudioTime.toDouble(),
                              minValue: 0,
                              maxValue: widget.totalAudioTime,
                              onValueChange: (newValue) async {
                                _model.isSliding = true;
                                _model.slideAudioTime =
                                    functions.doubleToInt(newValue);
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
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            (int audioTime) {
                              return "${audioTime >= 3600 ? ("${audioTime ~/ 3600}:") : ""}${((audioTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(audioTime % 60).toString().padLeft(2, '0')}";
                            }(widget.currentAudioTime),
                            '00:00',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: 'Inter',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            (int totalTime) {
                              return "${totalTime >= 3600 ? ("${totalTime ~/ 3600}:") : ""}${((totalTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(totalTime % 60).toString().padLeft(2, '0')}";
                            }(widget.totalAudioTime),
                            '07:00',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: 'Inter',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ].divide(const SizedBox(height: 32.0)).around(const SizedBox(height: 32.0)),
        ),
      ),
    );
  }
}
