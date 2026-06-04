import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/reminders/prayer_reminder_service.dart';
import 'package:my_prayer/custom_code/reminders/reminder_navigation.dart';
import 'package:my_prayer/custom_code/reminders/reminder_storage.dart';
import 'package:my_prayer/custom_code/prayer/downloaded_prayer_repository.dart';
import 'package:my_prayer/service_locator.dart';
import 'package:permission_handler/permission_handler.dart';

import '/custom_code/actions/index.dart' as actions;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await SupaFlow.initialize();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  // Start final custom actions code
  await actions.checkInternetConnection();
  //await actions.initializeAudioHandler();
  // End final custom actions code
  await setupServiceLocator();
  await getIt<DownloadedPrayerRepository>().migrateLegacyEntriesIfNeeded(
    appState.downloadedPrayers,
  );
  try {
      await Permission.notification.request();
      await Permission.mediaLibrary.request();
  } catch (e) {
      print('Error requesting permissions: $e');
  }

  if (!kIsWeb) {
    await _initPrayerReminders();
  }

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: const MyApp(),
  ));
}

Future<void> _initPrayerReminders() async {
  await PrayerReminderService.instance.initialize(
    onPrayerTap: navigateToPrayerFromReminder,
  );
  final reminders = await ReminderStorage.loadAll();
  await PrayerReminderService.instance.rescheduleAll(reminders);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  AppThemeMode _appThemeMode = FlutterFlowTheme.themeMode;
  ThemeMode get _themeMode =>
      FlutterFlowTheme.getFlutterThemeMode(_appThemeMode);

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  bool displaySplashImage = true;

  @override
  void initState() {
    super.initState();

    getIt<PageManager>().init();

    _appStateNotifier = AppStateNotifier.instance;

    // Future.delayed(const Duration(milliseconds: 500),
    //     () => safeSetState(() => _appStateNotifier.stopShowingSplashImage()));
    _router = createRouter(_appStateNotifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      flushPendingReminderNavigation();
    });
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(AppThemeMode mode) => safeSetState(() {
        _appThemeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rugăciuni și Cântări - CMD',
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('ro'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged)) {
              return const Color(0xff790822);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xff790822);
            }
            return const Color(0xff790822);
          }),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged)) {
              return const Color(0xff790822);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xff790822);
            }
            return const Color(0xff790822);
          }),
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (_, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(
                minScaleFactor: 0.5,
                maxScaleFactor: 2.0,
              ),
        ),
        child: child!,
      ),
    );
  }
}
