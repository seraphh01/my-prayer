import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class TextAutoScrollToggle extends StatelessWidget {
  const TextAutoScrollToggle({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = FFAppState().textAutoScrollEnabled;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        compact ? 16.0 : 24.0,
        compact ? 8.0 : 0.0,
        compact ? 16.0 : 24.0,
        0.0,
      ),
      child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: enabled,
            activeThumbColor: FlutterFlowTheme.of(context).primary,
            title: Text(
              'Derulare automată text',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    letterSpacing: 0.0,
                  ),
            ),
            subtitle: Text(
              'Textul urmărește automat redarea audio',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            onChanged: (value) {
              FFAppState().textAutoScrollEnabled = value;
            },
          ),
    );
  }
}
