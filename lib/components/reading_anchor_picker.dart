import '/app_state.dart';
import '/custom_code/prayer/reading_anchor_presets.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class ReadingAnchorPicker extends StatelessWidget {
  const ReadingAnchorPicker({
    super.key,
    this.showTitle = false,
    this.showHint = false,
    this.compact = false,
  });

  final bool showTitle;
  final bool showHint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selectedPreset = ReadingAnchorPresets.presetForAlignment(
      FFAppState().readingAnchorAlignment,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              compact ? 0.0 : 24.0,
              0.0,
              0.0,
              0.0,
            ),
            child: Text(
              'Poziție derulare automată text',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        if (showHint)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              compact ? 0.0 : 24.0,
              0.0,
              compact ? 0.0 : 24.0,
              0.0,
            ),
            child: Text(
              'Unde se derulează automat textul când asculti o rugăciune',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            compact ? 16.0 : 24.0,
            showTitle || showHint ? 12.0 : 0.0,
            compact ? 16.0 : 24.0,
            compact ? 0.0 : 0.0,
          ),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              for (final preset in ReadingAnchorPresets.values)
                buildThemeChip(
                  context: context,
                  label: ReadingAnchorPresets.labelFor(preset),
                  icon: ReadingAnchorPresets.iconFor(preset),
                  isSelected: selectedPreset == preset,
                  onSelected: () {
                    FFAppState().readingAnchorAlignment =
                        ReadingAnchorPresets.alignmentFor(preset);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
