import 'package:my_prayer/backend/schema/enums/enums.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_text_model.dart';
export 'prayer_text_model.dart';

class PrayerTextWidget extends StatefulWidget {
  const PrayerTextWidget(
      {super.key,
      bool? isHighlighted,
      required this.textInput,
      required this.type,
      bool? isPlaying,
      required this.onTextPressed,
      required this.quoteSource,
      required this.hasPassed})
      : highlight = isHighlighted ?? false,
        isPlaying = isPlaying ?? false;

  final TextElementType type;
  final bool highlight;
  final String? textInput;
  final String? quoteSource;
  final bool isPlaying;
  final bool hasPassed;
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

  TextStyle firstLetterStyle() {
    return FlutterFlowTheme.of(context).headlineLarge.override(
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
          letterSpacing: 2,
          useGoogleFonts: false,
          lineHeight: 0.5,
        );
  }

  TextStyle restOfTextPlayingStyle() {
    return FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: FFAppState().fontFamily,
          fontSize: valueOrDefault<double>(
            valueOrDefault<double>(
                  FFAppState().fontSizeMultiplier,
                  1.0,
                ) *
                18,
            18,
          ),
          
          fontWeight: widget.hasPassed ? FontWeight.w200 : FontWeight.w500,
          fontStyle: switch (widget.type) {
            TextElementType.italicText => FontStyle.italic,
            _ => FontStyle.normal,
          },
          lineHeight: 1.35,
          color: widget.isPlaying || !widget.hasPassed
              ? FlutterFlowTheme.of(context).primaryText
              : FlutterFlowTheme.of(context).secondaryText,
          shadows: widget.isPlaying 
              ? [
                                  Shadow(
                    blurRadius: 1,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    offset: Offset(-0.5, 0),
                  ),
                  Shadow(
                    blurRadius: 0.6,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    offset: Offset(-0.3, 0),
                  ),
                                    Shadow(
                    blurRadius: 0.6,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    offset: Offset(0.3, 0),
                  ),
                                    Shadow(
                    blurRadius: 0.6,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    offset: Offset(0, -0.1),
                    
                  ),
                                    Shadow(
                    blurRadius: 0.6,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    offset: Offset(0, 0.1),
                  ),
                ] 
              :  null,
        );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    var firstLetter =
        widget.highlight ? widget.textInput!.substring(0, 1) : null;
    var restOfText =
        widget.highlight ? widget.textInput!.substring(1) : widget.textInput;

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
          child: RichText(
            textScaler: MediaQuery.of(context).textScaler,
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: [
                if (widget.type == TextElementType.quoteText)
                  TextSpan(text: "«", style: restOfTextPlayingStyle()),
                if (firstLetter != null && firstLetter.isNotEmpty)
                  TextSpan(
                    text: firstLetter,
                    style: firstLetterStyle(),
                  ),
                TextSpan(
                  text: valueOrDefault<String>(
                    restOfText,
                    'Textul va fi adăugat curând.',
                  ),
                  style: restOfTextPlayingStyle(),
                ),
                if (widget.type == TextElementType.quoteText)
                  TextSpan(
                    children: [
                      TextSpan(text: "»", style: restOfTextPlayingStyle()),
                      TextSpan(
                          text: widget.quoteSource,
                          style: restOfTextPlayingStyle())
                    ],
                  ),
              ],
            ),
          )),
    );
  }
}
