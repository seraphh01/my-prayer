import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import '/components/section_text/cached_section_image.dart';

class PrayerTypeCardWidget extends StatefulWidget {
  const PrayerTypeCardWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.trailingIcons,
    this.prefixIcon,
    this.leadingImageUrl,
    this.onLightBackground = false,
  });

  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final List<IconData>? trailingIcons;
  final IconData? prefixIcon;
  final String? leadingImageUrl;
  /// Use on pages with a light scaffold background (e.g. favorites, downloads).
  final bool onLightBackground;

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
    final theme = FlutterFlowTheme.of(context);
    // Cream surface on all pages; light pages add border/shadow for white scaffolds.
    final surfaceColor = theme.alternate;

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
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16.0),
            border: widget.onLightBackground
                ? Border.all(
                    color: theme.primary.withValues(alpha: 0.12),
                    width: 1.0,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.onLightBackground
                    ? theme.primary.withValues(alpha: 0.08)
                    : const Color(0x1A000000),
                blurRadius: 8.0,
                offset: const Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.leadingImageUrl != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: CachedSectionImage(
                    imageUrl: widget.leadingImageUrl!,
                    width: 44.0,
                    height: 44.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                )
              else if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(
                    widget.prefixIcon,
                    size: 24.0,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
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
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context)
                                    .primary
                                    .withValues(alpha: 0.62),
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                lineHeight: 1.35,
                                fontWeight: FontWeight.w400,
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
                if(widget.trailingIcons != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.trailingIcons!.map((icon) => Icon(
                  icon,
                  size: 24.0,
                  color: FlutterFlowTheme.of(context).primary,
                )).toList().divide(const SizedBox(width: 4.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
