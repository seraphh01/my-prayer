import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_text_model.dart';
export 'prayer_text_model.dart';

class PrayerTextWidget extends StatefulWidget {
  const PrayerTextWidget({
    super.key,
    bool? isHighlighted,
    required this.textInput,
    bool? isPlaying,
    required this.onTextPressed,
  })  : highlight = isHighlighted ?? false,
        isPlaying = isPlaying ?? false;

  final bool highlight;
  final String? textInput;
  final bool isPlaying;
  final Future Function()? onTextPressed;

  @override
  State<PrayerTextWidget> createState() => _PrayerTextWidgetState();
}

class _PrayerTextWidgetState extends State<PrayerTextWidget> {
  late PrayerTextModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrayerTextModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.onTextPressed?.call();
      },
      child: Container(
        decoration: const BoxDecoration(),
        child: Builder(
          builder: (context) {
            if (valueOrDefault<bool>(
              widget.highlight,
              false,
            )) {
              return Builder(
                builder: (context) {
                  if (valueOrDefault<bool>(
                    widget.isPlaying,
                    false,
                  )) {
                    return RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: valueOrDefault<String>(
                              (widget.textInput!).substring(0, 1),
                              'A',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: 'PlayBall',
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: valueOrDefault<double>(
                                    valueOrDefault<double>(
                                          FFAppState().fontSizeMultiplier,
                                          1.0,
                                        ) *
                                        32,
                                    32.0,
                                  ),
                                  letterSpacing: 0.0,
                                  useGoogleFonts: false,
                                  lineHeight: 0.5,
                                ),
                          ),
                          TextSpan(
                            text: valueOrDefault<String>(
                              (widget.textInput!).substring(1),
                              'a',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  fontSize: valueOrDefault<double>(
                                    valueOrDefault<double>(
                                          FFAppState().fontSizeMultiplier,
                                          1.0,
                                        ) *
                                        18,
                                    18,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: valueOrDefault<String>(
                              (widget.textInput!).substring(0, 1),
                              'A',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                    fontFamily: 'PlayBall',
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    fontSize: valueOrDefault<double>(
                                      valueOrDefault<double>(
                                            FFAppState().fontSizeMultiplier,
                                            1.0,
                                          ) *
                                          32,
                                      32.0,
                                    ),
                                    letterSpacing: 0.0,
                                    useGoogleFonts: false,
                                    lineHeight: 0.5),
                          ),
                          TextSpan(
                            text: valueOrDefault<String>(
                              (widget.textInput!).substring(1),
                              'A',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: valueOrDefault<double>(
                                    valueOrDefault<double>(
                                          FFAppState().fontSizeMultiplier,
                                          1.0,
                                        ) *
                                        18.0,
                                    18,
                                  ),
                                  letterSpacing: 0.17,
                                  fontWeight: FontWeight.w300,
                                ),
                          )
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return Builder(
                builder: (context) {
                  if (widget.isPlaying) {
                    return RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          text: valueOrDefault<String>(
                            widget.textInput,
                            'text',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: valueOrDefault<double>(
                                      valueOrDefault<double>(
                                            FFAppState().fontSizeMultiplier,
                                            1.0,
                                          ) *
                                          18,
                                      18,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ));
                  } else {
                    return RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          text: valueOrDefault<String>(
                            widget.textInput,
                            'text',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: valueOrDefault<double>(
                                      valueOrDefault<double>(
                                            FFAppState().fontSizeMultiplier,
                                            1.0,
                                          ) *
                                          18,
                                      18,
                                    ),
                                    letterSpacing: 0.17,
                                    fontWeight: FontWeight.w300,
                                  ),
                        ));
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
