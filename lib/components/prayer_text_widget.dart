import 'package:my_prayer/backend/schema/enums/enums.dart';

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
    required this.type,
    bool? isPlaying,
    required this.onTextPressed,
  })  : highlight = isHighlighted ?? false,
        isPlaying = isPlaying ?? false;

  final TextElementType type;
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
          letterSpacing: 0.0,
          useGoogleFonts: false,
          lineHeight: 0.5,
        );
  }

  TextStyle restOfTextPlayingStyle() {
    return FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Inter',
          fontSize: valueOrDefault<double>(
            valueOrDefault<double>(
                  FFAppState().fontSizeMultiplier,
                  1.0,
                ) *
                18,
            18,
          ),
          letterSpacing: widget.isPlaying ? 0.0 : 0.17,
          fontWeight: widget.isPlaying ? FontWeight.w500 : FontWeight.w300,
          fontStyle: switch (widget.type) {
            TextElementType.quoteText => FontStyle.italic,
            _ => FontStyle.normal,
          },
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
            text: TextSpan(
              children: [
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
                )
              ],
            ),
          )),
    );
  }
}
