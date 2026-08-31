import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  static const Color _gradientEnd = Color(0xFF3C010C);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Material(
      color: theme.primary,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primary,
              _gradientEnd,
            ],
            begin: const AlignmentDirectional(0.0, -1.0),
            end: const AlignmentDirectional(0, 1.0),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image.asset(
                      'assets/images/app_launcher_icon.jpg',
                      width: 120.0,
                      height: 120.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  AutoSizeText(
                    'Rugăciuni și cântări Greco-Catolice',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 16.0,
                    style: theme.titleLarge.override(
                      fontFamily: 'Merriweather',
                      color: theme.alternate,
                      letterSpacing: 0.0,
                      useGoogleFonts: false,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  AutoSizeText(
                    'Congregația Surorilor Maicii Domnului',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    minFontSize: 12.0,
                    style: theme.titleSmall.override(
                      fontFamily: 'PlayBall',
                      color: theme.alternate.withValues(alpha: 0.92),
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      useGoogleFonts: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
