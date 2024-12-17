import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_text_model.dart';
export 'prayer_text_model.dart';

class PrayerTextWidget extends StatefulWidget {
  const PrayerTextWidget({
    super.key,
    bool? isFirstInList,
    required this.textInput,
    bool? isHighlighted,
    required this.onTextPressed,
  })  : isFirstInList = isFirstInList ?? false,
        isHighlighted = isHighlighted ?? false;

  final bool isFirstInList;
  final String? textInput;
  final bool isHighlighted;
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

    return Container(
      decoration: const BoxDecoration(),
      child: Builder(
        builder: (context) {
          if (valueOrDefault<bool>(
            widget.isFirstInList,
            false,
          )) {
            return Builder(
              builder: (context) {
                if (valueOrDefault<bool>(
                  widget.isHighlighted,
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
                              ),
                        ),
                        TextSpan(
                          text: valueOrDefault<String>(
                            (widget.textInput!).substring(1),
                            'A',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
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
                        )
                      ],
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    ),
                  );
                } else {
                  return InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await widget.onTextPressed?.call();
                    },
                    child: RichText(
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
                                  color: FlutterFlowTheme.of(context).secondary,
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
                                ),
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
                                        16,
                                    32.0,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w300,
                                ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  );
                }
              },
            );
          } else {
            return Builder(
              builder: (context) {
                if (widget.isHighlighted) {
                  return Text(
                    valueOrDefault<String>(
                      widget.textInput,
                      'text',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).primaryText,
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
                } else {
                  return InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await widget.onTextPressed?.call();
                    },
                    child: Text(
                      valueOrDefault<String>(
                        widget.textInput,
                        'text',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            fontSize: valueOrDefault<double>(
                              valueOrDefault<double>(
                                    FFAppState().fontSizeMultiplier,
                                    1.0,
                                  ) *
                                  16,
                              32.0,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
