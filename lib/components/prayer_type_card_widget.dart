import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class PrayerTypeCardWidget extends StatefulWidget {
  const PrayerTypeCardWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.trailingIcon,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  @override
  State<PrayerTypeCardWidget> createState() => _PrayerTypeCardWidgetState();
}

class _PrayerTypeCardWidgetState extends State<PrayerTypeCardWidget>
    with SingleTickerProviderStateMixin {
  static const _pressedScale = 0.98;
  static const _animationDuration = Duration(milliseconds: 90);

  double _scale = 1.0;

  void _setPressed(bool pressed) {
    if (!mounted) {
      return;
    }
    setState(() {
      _scale = pressed ? _pressedScale : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      alignment: Alignment.center,
      duration: _animationDuration,
      curve: Curves.easeOut,
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: Container(
          padding:
              const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).alternate,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8.0,
                offset: Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Merriweather',
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                          ),
                    ),
                    if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 4.0),
                        child: Text(
                          widget.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.trailingText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Text(
                    widget.trailingText!,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              Icon(
                widget.trailingIcon ?? Icons.chevron_right_rounded,
                size: 24.0,
                color: FlutterFlowTheme.of(context).primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
