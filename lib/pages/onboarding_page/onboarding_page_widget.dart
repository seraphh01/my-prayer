import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatefulWidget {
  const OnboardingPageWidget({super.key});

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingStep(
      icon: Icons.search_rounded,
      title: 'Caută sau alege',
      body:
          'Folosește bara de căutare sau navighează prin categorii pentru a găsi rugăciuni și cântări.',
    ),
    _OnboardingStep(
      icon: Icons.text_fields_rounded,
      title: 'Mărește textul',
      body:
          'Din Setări poți mări fontul, alege sepia pentru citit confortabil și viteza audio.',
    ),
    _OnboardingStep(
      icon: Icons.notifications_outlined,
      title: 'Memento și favorite',
      body:
          'Salvează rugăciunile la favorite ♡ și programează memento ca să nu uiți dimineața sau seara.',
    ),
  ];

  void _finish() {
    FFAppState().isFirstTime = false;
    context.goNamed('HomePage');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Sari peste',
                  style: theme.labelLarge.override(
                    fontFamily: 'Inter',
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final step = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(step.icon, size: 80.0, color: theme.primary),
                        const SizedBox(height: 32.0),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.headlineMedium.override(
                            fontFamily: 'Merriweather',
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          step.body,
                          textAlign: TextAlign.center,
                          style: theme.bodyLarge.override(
                            fontFamily: 'Inter',
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page
                        ? theme.primary
                        : theme.secondaryBackground,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_page < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.alternate,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    _page < _pages.length - 1 ? 'Continuă' : 'Începe',
                    style: theme.titleSmall.override(
                      fontFamily: 'Inter',
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
