import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_prayer/pages/privacy_policy_page/privacy_policy_page_widget.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

import '/index.dart';
import '/components/app_splash_screen.dart';
import '/flutter_flow/flutter_flow_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

class AppSplashGate extends StatelessWidget {
  const AppSplashGate({
    super.key,
    required this.notifier,
  });

  final AppStateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        if (notifier.showSplashImage) {
          return const AppSplashScreen();
        }
        return const HomePageWidget();
      },
    );
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => AppSplashGate(
            notifier: appStateNotifier,
          ),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => AppSplashGate(
                notifier: appStateNotifier,
              ),
        ),
        FFRoute(
          name: 'HomePage',
          path: '/homePage',
          builder: (context, params) => const HomePageWidget(),
        ),
        FFRoute(
          name: 'SettingsPage',
          path: '/settingsPage',
          builder: (context, params) => const SettingsPageWidget(),
        ),
        FFRoute(
          name: 'RosaryPage',
          path: '/rosaryPage',
          builder: (context, params) => RosaryPageWidget(
            prayerId: params.getParam(
              'prayerId',
              ParamType.String,
            ),
            page: params.getParam(
              'page',
              ParamType.int,
            ),
            continueAudio: params.getParam(
              'continueAudio',
              ParamType.bool,
            ),
            initialAudioTime: params.getParam(
              'initialAudioTime',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: 'FavoritePrayersPage',
          path: '/favoritePrayersPage',
          builder: (context, params) => const FavoritePrayersPageWidget(),
        ),
        FFRoute(
          name: 'DownloadedPrayersPage',
          path: '/downloadedPrayersPage',
          builder: (context, params) => const DownloadedPrayersPageWidget(),
        ),
        FFRoute(
          name: 'AllPrayersPage',
          path: '/allPrayersPage',
          builder: (context, params) => const AllPrayersPageWidget(),
        ),
        FFRoute(
          name: 'CalendarPage',
          path: '/calendarPage',
          builder: (context, params) => const CalendarPageWidget(),
        ),
        FFRoute(
          name: 'RemindersPage',
          path: '/remindersPage',
          builder: (context, params) => const RemindersPageWidget(),
        ),
        FFRoute(
          name: 'OnboardingPage',
          path: '/onboardingPage',
          builder: (context, params) => const OnboardingPageWidget(),
        ),
        FFRoute(
          name: 'PrayerJournalPage',
          path: '/prayerJournalPage',
          builder: (context, params) => const PrayerJournalPageWidget(),
        ),
        FFRoute(
          name: 'PrivacyPolicyPage',
          path: '/privacyPolicyPage',
          builder: (context, params) => const PrivacyPolicyPageWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }

  /// Replaces the navigation stack with the home page.
  void goHomeReplacingStack() {
    go('/');
  }

  /// Opens [RosaryPage] with [HomePage] as the only route below it, so home
  /// and system back skip intermediate pages (calendar, journal, etc.).
  void openPrayerWithHomeOnStack(String prayerId) {
    goHomeReplacingStack();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = appNavigatorKey.currentContext;
      if (context == null || !context.mounted) {
        return;
      }
      context.pushNamed(
        'RosaryPage',
        queryParameters: {'prayerId': prayerId}.withoutNulls,
      );
    });
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList: isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 250),
      );
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
