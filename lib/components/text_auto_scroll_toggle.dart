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
    return ListenableBuilder(
      listenable: Listenable.merge([
        FFAppState(),
        FlutterFlowTheme.themeModeNotifier,
      ]),
      builder: (context, _) {
        final enabled = FFAppState().textAutoScrollEnabled;
        final theme = FlutterFlowTheme.of(context);

        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            compact ? 16.0 : 24.0,
            compact ? 8.0 : 0.0,
            compact ? 16.0 : 24.0,
            0.0,
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: enabled,
            activeThumbColor: theme.primary,
            activeTrackColor: theme.primary.withValues(alpha: 0.5),
            inactiveThumbColor: theme.alternate,
            inactiveTrackColor: theme.secondaryText.withValues(alpha: 0.35),
            title: Text(
              'Derulare automată text',
              style: theme.bodyMedium.override(
                fontFamily: 'Inter',
                letterSpacing: 0.0,
              ),
            ),
            subtitle: Text(
              'Textul urmărește automat redarea audio',
              style: theme.bodySmall.override(
                fontFamily: 'Inter',
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
            onChanged: (value) {
              FFAppState().textAutoScrollEnabled = value;
            },
          ),
        );
      },
    );
  }
}
