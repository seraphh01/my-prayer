import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/custom_code/calendar/filter_prayer_types.dart';
import '/custom_code/calendar/merge_date_groups.dart';
import '/components/section_text/cached_section_image.dart';
import '/components/section_text/section_text_block_widget.dart';
import '/components/section_text/prayer_text_styles.dart';
import '/custom_code/prayer/playback_highlight_state.dart';
import '/custom_code/prayer/prayer_typography.dart';
import '/custom_code/onboarding/onboarding_section_audio.dart';
import '/custom_code/audio/notifiers/play_button_notifier.dart';
import '/custom_code/audio/page_manager.dart';
import '/custom_code/debug/simulated_clock.dart';
import '/custom_code/prayer/prayer_types_cache.dart';
import '/custom_code/reminders/prayer_catalog_helper.dart';
import '/custom_code/reminders/prayer_date_group_prefill.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/prayer_reminder_service.dart';
import '/custom_code/reminders/reminder_storage.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/service_locator.dart';
import 'package:auto_size_text/auto_size_text.dart';

class OnboardingPageWidget extends StatefulWidget {
  const OnboardingPageWidget({super.key});

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _fontChipController = FormFieldController<List<String>>([]);
  int _page = 0;
  late final AnimationController _introAnimationController;
  late final Animation<double> _introLogoOpacity;
  late final Animation<double> _introLogoScale;
  late final Animation<double> _introTitleOpacity;
  late final Animation<Offset> _introTitleSlide;
  late final Animation<double> _introCreditOpacity;

  static const _appTitle = 'Rugăciuni și cântări';
  static const _congregationTitle =
      'Congregația Surorilor Maicii Domnului';
  static const _gradientEnd = Color(0xFF3C010C);
  static const _fontOptions = [
    'Crimson Pro',
    'Patrick Hand',
    'Tinos',
    'Inter',
  ];
  static const _favoriteSearchHints = [
    'rozari',
    'înger',
    'diminea',
    'seară',
    'benedict',
  ];

  late double _fontSizeDemo;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);
  final Set<int> _reminderDays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  };
  List<PrayerStruct> _favoriteOptions = [];
  PrayerStruct? _selectedFavorite;
  bool _loadingFavorites = true;
  List<DateGroupStruct> _todayDateGroups = [];
  List<PrayerTypeStruct> _prayerTypesCatalog = [];
  PrayerStruct? _selectedReminderPrayer;
  bool _loadingTodayPrayers = true;
  final Set<String> _collapsedReminderGroups = {};
  OnboardingAudioPreview? _audioPreview;
  bool _loadingAudioPreview = true;
  bool _audioQueueReady = false;
  final PlaybackHighlightNotifier _audioHighlight = PlaybackHighlightNotifier();
  VoidCallback? _audioProgressListener;
  VoidCallback? _audioPlayStateListener;

  static const _pageCount = 7;
  static const _welcomePage = 1;
  static const _audioPage = 2;
  static const _favoritesPage = 4;
  static const _reminderPage = 5;
  static const _closingPage = 6;

  @override
  void initState() {
    super.initState();
    _introAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _introLogoOpacity = CurvedAnimation(
      parent: _introAnimationController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _introLogoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _introAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _introTitleOpacity = CurvedAnimation(
      parent: _introAnimationController,
      curve: const Interval(0.28, 0.68, curve: Curves.easeOut),
    );
    _introTitleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introAnimationController,
        curve: const Interval(0.28, 0.68, curve: Curves.easeOut),
      ),
    );
    _introCreditOpacity = CurvedAnimation(
      parent: _introAnimationController,
      curve: const Interval(0.52, 0.92, curve: Curves.easeOut),
    );
    _introAnimationController.forward();
    _fontSizeDemo = FFAppState().fontSizeMultiplier;
    _fontChipController.value = [FFAppState().fontFamily];
    unawaited(_loadFavoriteOptions());
    unawaited(_loadTodayPrayerOptions());
    unawaited(_loadAudioPreview());
    _audioProgressListener = _syncAudioTextHighlight;
    _audioPlayStateListener = _syncAudioTextHighlight;
    getIt<PageManager>().currentProgressNotifier.addListener(
      _audioProgressListener!,
    );
    getIt<PageManager>().playButtonNotifier.addListener(
      _audioPlayStateListener!,
    );
  }

  void _syncAudioTextHighlight() {
    final preview = _audioPreview;
    if (preview == null || preview.previewText == null) {
      return;
    }

    final pageManager = getIt<PageManager>();
    final isPlaying =
        pageManager.playButtonNotifier.value == ButtonState.playing;

    _audioHighlight.updateFromTexts(
      texts: preview.texts,
      audioTimeSeconds: pageManager.currentProgressNotifier.value.inSeconds,
      isAudioSynced: isPlaying && _audioQueueReady,
    );
  }

  Future<void> _loadAudioPreview() async {
    try {
      final preview = await OnboardingSectionAudio.loadPreview(
        OnboardingSectionAudio.demoSectionId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _audioPreview = preview;
        _loadingAudioPreview = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingAudioPreview = false);
    }
  }

  Future<void> _ensureAudioQueueReady() async {
    if (_audioQueueReady || kIsWeb) {
      return;
    }
    final preview = _audioPreview;
    if (preview == null || !preview.hasAudio) {
      return;
    }

    final ready = await OnboardingSectionAudio.prepareQueue(preview);
    if (!mounted) {
      return;
    }
    setState(() => _audioQueueReady = ready);
    if (ready) {
      _syncAudioTextHighlight();
    }
  }

  Future<void> _toggleOnboardingAudio() async {
    await _ensureAudioQueueReady();
    if (!_audioQueueReady) {
      return;
    }
    await OnboardingSectionAudio.togglePlayback();
  }

  Future<void> _stopOnboardingAudio() async {
    await OnboardingSectionAudio.stop();
    _audioHighlight.reset();
    if (!mounted) {
      return;
    }
    setState(() => _audioQueueReady = false);
  }

  Future<void> _loadTodayPrayerOptions() async {
    try {
      final now = effectiveNow();
      final selectedDate = DateTime(now.year, now.month, now.day);
      final groups = await fetchCalendarPrayersForDate(selectedDate);
      final catalog = await getIt<PrayerTypesCache>().load();

      if (!mounted) {
        return;
      }

      setState(() {
        _todayDateGroups = groups;
        _prayerTypesCatalog = catalog;
        _loadingTodayPrayers = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingTodayPrayers = false);
    }
  }

  bool get _hasTodayPrayers =>
      _todayDateGroups.any((group) => group.prayers.isNotEmpty);

  (String, String?) _reminderPrayerCardLines(PrayerStruct prayer) {
    final title = prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;
    final subtitle = prayer.title.isNotEmpty &&
            prayer.subtitle.isNotEmpty &&
            prayer.subtitle != title
        ? prayer.subtitle
        : null;
    return (title, subtitle);
  }

  Widget _buildReminderPrayerTile(
    BuildContext context,
    PrayerStruct prayer,
  ) {
    final theme = FlutterFlowTheme.of(context);
    final selected = _selectedReminderPrayer?.id == prayer.id;
    final lines = _reminderPrayerCardLines(prayer);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: selected
            ? theme.primary.withValues(alpha: 0.1)
            : theme.alternate,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => unawaited(_applyReminderPrefill(prayer)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: theme.primary,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lines.$1,
                        style: theme.titleSmall.override(
                          fontFamily: 'Merriweather',
                          letterSpacing: 0.0,
                        ),
                      ),
                      if (lines.$2 != null)
                        Text(
                          lines.$2!,
                          style: theme.bodySmall.override(
                            fontFamily: 'Inter',
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleReminderGroup(String groupKey) {
    setState(() {
      if (_collapsedReminderGroups.contains(groupKey)) {
        _collapsedReminderGroups.remove(groupKey);
      } else {
        _collapsedReminderGroups.add(groupKey);
      }
    });
  }

  Widget _buildCollapsibleGroupCard({
    required BuildContext context,
    required Set<String> collapsedGroups,
    required void Function(String groupKey) onToggleGroup,
    required String groupKey,
    required String title,
    required List<Widget> children,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final expanded = !collapsedGroups.contains(groupKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: theme.alternate,
        borderRadius: BorderRadius.circular(12.0),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 8.0, 0.0, 4.0),
                      child: Text(
                        title,
                        style: theme.titleSmall.override(
                          fontFamily: 'Merriweather',
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8.0),
                    tooltip: expanded ? 'Restrânge' : 'Extinde',
                    icon: Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.primary,
                    ),
                    onPressed: () => onToggleGroup(groupKey),
                  ),
                ],
              ),
              if (expanded) ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderGroupCard({
    required BuildContext context,
    required String groupKey,
    required String title,
    required List<Widget> children,
  }) {
    return _buildCollapsibleGroupCard(
      context: context,
      collapsedGroups: _collapsedReminderGroups,
      onToggleGroup: _toggleReminderGroup,
      groupKey: groupKey,
      title: title,
      children: children,
    );
  }

  List<Widget> _buildReminderTitleGroups(
    BuildContext context,
    DateGroupStruct group,
  ) {
    final prayerGroups = groupPrayersByTitle(
      group.prayers
          .sortedList(keyOf: (prayer) => prayer.sequence, desc: false)
          .toList(),
    );

    return prayerGroups.map((prayerGroup) {
      if (prayerGroup.prayers.length == 1) {
        return _buildReminderPrayerTile(context, prayerGroup.prayers.first);
      }

      return _buildReminderGroupCard(
        context: context,
        groupKey: 'reminder_title_${prayerGroup.title.hashCode}',
        title: prayerGroup.title,
        children: prayerGroup.prayers
            .map((prayer) => _buildReminderPrayerTile(context, prayer))
            .toList(),
      );
    }).toList();
  }

  List<Widget> _buildReminderTypeRows(
    BuildContext context,
    List<PrayerTypeStruct> types, {
    int depth = 0,
  }) {
    final sortedTypes = types.toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return sortedTypes.expand((type) {
      final prayers = type.prayers
          .sortedList(keyOf: (prayer) => prayer.sequence, desc: false)
          .toList();
      final hasSubtypes = type.subtypes.isNotEmpty;

      if (prayers.length == 1 && !hasSubtypes) {
        return [_buildReminderPrayerTile(context, prayers.first)];
      }

      final typeLabel = type.type.isNotEmpty ? type.type : 'Rugăciune';
      final children = <Widget>[
        ...prayers.map((prayer) => _buildReminderPrayerTile(context, prayer)),
        if (hasSubtypes)
          Padding(
            padding: EdgeInsets.only(left: depth > 0 ? 8.0 : 0.0),
            child: Column(
              children: _buildReminderTypeRows(
                context,
                type.subtypes,
                depth: depth + 1,
              ),
            ),
          ),
      ];

      return [
        _buildReminderGroupCard(
          context: context,
          groupKey: 'reminder_type_${type.id}_$depth',
          title: typeLabel,
          children: children,
        ),
      ];
    }).toList();
  }

  Widget _buildReminderDateGroupSection(
    BuildContext context,
    DateGroupStruct group,
  ) {
    final theme = FlutterFlowTheme.of(context);
    final prayerIds = group.prayers
        .map((prayer) => prayer.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    final nestedTypes =
        filterPrayerTypesForCalendar(_prayerTypesCatalog, prayerIds);

    if (group.prayers.isEmpty && nestedTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.name.isNotEmpty)
          Text(
            group.name,
            textAlign: TextAlign.center,
            style: theme.titleSmall.override(
              fontFamily: 'Merriweather',
              letterSpacing: 0.0,
            ),
          ),
        if (group.description.isNotEmpty)
          Text(
            group.description,
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(
              fontFamily: 'Inter',
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
        if (group.name.isNotEmpty || group.description.isNotEmpty)
          Divider(
            height: 8.0,
            thickness: 1.0,
            color: theme.secondaryBackground,
          ),
        if (nestedTypes.isNotEmpty)
          ..._buildReminderTypeRows(context, nestedTypes)
        else
          ..._buildReminderTitleGroups(context, group),
      ],
    );
  }

  void _clearReminderPrayerSelection() {
    setState(() => _selectedReminderPrayer = null);
  }

  Widget _buildSelectedReminderPrayerCard(BuildContext context) {
    final prayer = _selectedReminderPrayer!;
    final theme = FlutterFlowTheme.of(context);
    final lines = _reminderPrayerCardLines(prayer);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 0.0, 4.0),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: theme.primary,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lines.$1,
                      style: theme.titleSmall.override(
                        fontFamily: 'Merriweather',
                        letterSpacing: 0.0,
                      ),
                    ),
                    if (lines.$2 != null)
                      Text(
                        lines.$2!,
                        style: theme.bodySmall.override(
                          fontFamily: 'Inter',
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(8.0),
                tooltip: 'Alegeți altă rugăciune',
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.secondaryText,
                ),
                onPressed: _clearReminderPrayerSelection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderPrayerPicker(BuildContext context) {
    if (_selectedReminderPrayer != null) {
      return _buildSelectedReminderPrayerCard(context);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320.0),
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('onboarding_reminder_scroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _todayDateGroups.length; i++)
              _buildReminderDateGroupSection(
                context,
                _todayDateGroups[i],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyReminderPrefill(PrayerStruct prayer) async {
    final prefill = await fetchReminderPrefillForPrayer(prayer.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedReminderPrayer = prayer;
      _reminderTime = prefill.time ?? const TimeOfDay(hour: 8, minute: 0);
      _reminderDays
        ..clear()
        ..addAll(
          prefill.daysOfWeek.isNotEmpty
              ? prefill.daysOfWeek
              : {effectiveNow().weekday},
        );
    });
  }

  Future<void> _loadFavoriteOptions() async {
    try {
      final types = await getIt<PrayerTypesCache>().load();
      final catalog = flattenPrayerCatalog(types);
      final picked = <PrayerStruct>[];
      for (final hint in _favoriteSearchHints) {
        final match = catalog.firstWhereOrNull(
          (item) => item.searchHaystack.contains(hint),
        );
        if (match != null &&
            match.prayer.id.isNotEmpty &&
            picked.every((p) => p.id != match.prayer.id)) {
          picked.add(match.prayer);
        }
      }
      if (picked.length < 3) {
        for (final item in catalog) {
          if (item.prayer.id.isEmpty) {
            continue;
          }
          if (picked.every((p) => p.id != item.prayer.id)) {
            picked.add(item.prayer);
          }
          if (picked.length >= 5) {
            break;
          }
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _favoriteOptions = picked.take(5).toList();
        _loadingFavorites = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingFavorites = false);
    }
  }

  BoxDecoration _homeGradient(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [theme.primary, _gradientEnd],
        stops: const [0.0, 1.0],
        begin: const AlignmentDirectional(0.0, -1.0),
        end: const AlignmentDirectional(0, 1.0),
      ),
    );
  }

  void _finish() {
    unawaited(_stopOnboardingAudio());
    FFAppState().isFirstTime = false;
    context.goNamed('HomePage');
  }

  Future<void> _onContinue() async {
    if (_page == _audioPage) {
      await _stopOnboardingAudio();
    }
    if (_page == _favoritesPage && _selectedFavorite != null) {
      FFAppState().addToFavoritePrayers(_selectedFavorite!);
    }
    if (_page == _reminderPage) {
      await _saveReminder();
    }

    if (_page < _pageCount - 1) {
      final nextPage = _page + 1;
      await _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _onBack() {
    if (_page <= 0) {
      return;
    }
    if (_page == _audioPage) {
      unawaited(_stopOnboardingAudio());
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveReminder() async {
    if (kIsWeb || _reminderDays.isEmpty) {
      return;
    }

    final prayer = _selectedReminderPrayer;
    if (prayer == null || prayer.id.isEmpty) {
      return;
    }

    final title =
        prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;

    final reminder = PrayerReminder(
      id: const Uuid().v4(),
      prayerId: prayer.id,
      prayerTitle: title,
      prayerSubtitle: prayer.subtitle,
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      daysOfWeek: _reminderDays.toList()..sort(),
    );

    await ReminderStorage.upsert(reminder);
    await PrayerReminderService.instance.requestPermissionIfNeeded();
    await PrayerReminderService.instance.scheduleReminder(reminder);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Alegeți ora amintirii',
      cancelText: 'Anulați',
      confirmText: 'Confirmați',
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  @override
  void dispose() {
    final pageManager = getIt<PageManager>();
    if (_audioProgressListener != null) {
      pageManager.currentProgressNotifier.removeListener(
        _audioProgressListener!,
      );
    }
    if (_audioPlayStateListener != null) {
      pageManager.playButtonNotifier.removeListener(
        _audioPlayStateListener!,
      );
    }
    _audioHighlight.dispose();
    unawaited(OnboardingSectionAudio.stop());
    _introAnimationController.dispose();
    _pageController.dispose();
    _fontChipController.dispose();
    super.dispose();
  }

  Widget _buildCongregationTitle(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final style = theme.titleMedium.override(
      fontFamily: 'PlayBall',
      color: theme.alternate.withValues(alpha: 0.92),
      fontSize: 24.0,
      letterSpacing: 0.0,
      useGoogleFonts: false,
    );
    const lineOne = 'Congregația Surorilor';
    const lineTwo = 'Maicii Domnului';

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: _congregationTitle, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(
            _congregationTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: style,
          );
        }

        return Column(
          children: [
            Text(lineOne, textAlign: TextAlign.center, style: style),
            Text(lineTwo, textAlign: TextAlign.center, style: style),
          ],
        );
      },
    );
  }

  Widget _buildIntroStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              FadeTransition(
                opacity: _introLogoOpacity,
                child: ScaleTransition(
                  scale: _introLogoScale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.0),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 168.0,
                      height: 168.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              FadeTransition(
                opacity: _introTitleOpacity,
                child: SlideTransition(
                  position: _introTitleSlide,
                  child: AutoSizeText(
                    _appTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 20.0,
                    style: theme.headlineMedium.override(
                      fontFamily: 'Merriweather',
                      color: theme.alternate,
                      letterSpacing: 0.0,
                      useGoogleFonts: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28.0),
              FadeTransition(
                opacity: _introCreditOpacity,
                child: Column(
                  children: [
                    Text(
                      'Realizată de',
                      textAlign: TextAlign.center,
                      style: theme.labelLarge.override(
                        fontFamily: 'Inter',
                        color: theme.alternate.withValues(alpha: 0.75),
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    _buildCongregationTitle(context),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildWelcomeStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    const heading = 'Cuvânt de bun venit';
    const address =
        'Surorile Congregației Surorilor Maicii Domnului vă întâmpină cu bucurie și vă invită, pentru câteva clipe, la liniștea rugăciunii.';
    const body =
        'Această aplicație vă aduce aproape rugăciuni și cântări interpretate și înregistrate chiar de surorile din Congregație — un sprijin firesc pentru rugăciunea de fiecare zi.';
    const guide =
        'Vă vom arăta pe scurt câteva informații de folos pentru a vă ajuta să folosiți aplicația în modul cel mai potrivit pentru dumneavoastră.';
    const blessing =
        'Fie ca Domnul să vă binecuvânteze, iar Preacurata Maica Sa să vă ocrotească.';
    const signOff =
        'Cu dragoste în Hristos,\nCongregația Surorilor Maicii Domnului';

    TextStyle merriweatherBody({double? size, FontStyle? style, double alpha = 0.95}) {
      return theme.bodyMedium.override(
        fontFamily: 'Merriweather',
        color: theme.alternate.withValues(alpha: alpha),
        fontSize: size,
        letterSpacing: 0.0,
        lineHeight: 1.6,
        fontStyle: style,
        useGoogleFonts: false,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        children: [

            const SizedBox(height: 12.0),
            Text(
              heading,
              textAlign: TextAlign.center,
              style: theme.headlineSmall.override(
                fontFamily: 'Merriweather',
                color: theme.alternate,
                letterSpacing: 0.0,
                useGoogleFonts: false,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              address,
              textAlign: TextAlign.center,
              style: merriweatherBody(),
            ),
            const SizedBox(height: 18.0),
            Text(
              body,
              textAlign: TextAlign.center,
              style: merriweatherBody(alpha: 0.92),
            ),
            const SizedBox(height: 18.0),
            Text(
              guide,
              textAlign: TextAlign.center,
              style: merriweatherBody(
                style: FontStyle.italic,
                alpha: 0.85,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              blessing,
              textAlign: TextAlign.center,
              style: merriweatherBody(
                style: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              signOff,
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                fontFamily: 'Merriweather',
                color: theme.alternate.withValues(alpha: 0.8),
                letterSpacing: 0.0,
                lineHeight: 1.5,
                fontStyle: FontStyle.italic,
                useGoogleFonts: false,
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
    );
  }

  Widget _buildStepShell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    required Widget child,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, size: 56.0, color: theme.primary),
          const SizedBox(height: 20.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.headlineSmall.override(
              fontFamily: 'Merriweather',
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: 'Inter',
              color: theme.secondaryText,
              letterSpacing: 0.0,
              lineHeight: 1.5,
            ),
          ),
          const SizedBox(height: 24.0),
          child,
        ],
      ),
    );
  }

  Widget _buildTextPreview(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final fontFamily = FFAppState().fontFamily;
    final multiplier = FFAppState().fontSizeMultiplier;
    final baseSize = 18.0 * multiplier;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.alternate,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        '„Tatăl nostru, care ești în ceruri, sfințească-se numele Tău…”',
        style: theme.bodyMedium.override(
          fontFamily: fontFamily,
          fontSize: baseSize,
          color: theme.primaryText,
          letterSpacing: 0.0,
          lineHeight: 1.55,
          useGoogleFonts: fontFamily != 'PlayBall',
        ),
      ),
    );
  }

  Widget _buildTextSettingsStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ListenableBuilder(
      listenable: FFAppState(),
      builder: (context, _) {
        return _buildStepShell(
          context: context,
          icon: Icons.text_fields_rounded,
          title: 'Personalizați textul',
          body:
              'Adaptați fontul și mărimea textului acum sau oricând din Setări.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Exemplu de citire',
                style: theme.labelLarge.override(
                  fontFamily: 'Inter',
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 8.0),
              _buildTextPreview(context),
              const SizedBox(height: 20.0),
              Text(
                'Stil font',
                style: theme.bodyMedium.override(
                  fontFamily: 'Inter',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 8.0),
              FlutterFlowChoiceChips(
                options: _fontOptions.map(ChipData.new).toList(),
                onChanged: (val) {
                  final selected = val?.firstOrNull;
                  if (selected == null) {
                    return;
                  }
                  _fontChipController.value = [selected];
                  FFAppState().fontFamily = selected;
                  setState(() {});
                },
                selectedChipStyle: ChipStyle(
                  backgroundColor: theme.primary,
                  textStyle: theme.bodyMedium.override(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
                  iconColor: Colors.white,
                  iconSize: 18.0,
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                unselectedChipStyle: ChipStyle(
                  backgroundColor: Colors.transparent,
                  textStyle: theme.bodySmall.override(
                    fontFamily: 'Inter',
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                  iconColor: Colors.white,
                  iconSize: 18.0,
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                chipSpacing: 12.0,
                rowSpacing: 8.0,
                multiselect: false,
                initialized: true,
                alignment: WrapAlignment.start,
                controller: _fontChipController,
                wrapped: true,
              ),
              const SizedBox(height: 20.0),
              Text(
                'Mărime font',
                style: theme.bodyMedium.override(
                  fontFamily: 'Inter',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.format_size, size: 16.0, color: theme.primaryText),
                  Expanded(
                    child: Slider.adaptive(
                      activeColor: theme.primary,
                      inactiveColor: theme.secondaryBackground,
                      min: 0.75,
                      max: 2.0,
                      divisions: 10,
                      value: _fontSizeDemo,
                      label: _fontSizeDemo.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() => _fontSizeDemo = value);
                        FFAppState().fontSizeMultiplier = value;
                      },
                    ),
                  ),
                  Icon(Icons.format_size, size: 24.0, color: theme.primaryText),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderScheduleControls(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8.0),
        OutlinedButton.icon(
          onPressed: _pickReminderTime,
          icon: const Icon(Icons.schedule_rounded),
          label: Text(
            'Ora: ${_reminderTime.format(context)}',
            style: theme.bodyMedium.override(
              fontFamily: 'Inter',
              letterSpacing: 0.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Zile',
          style: theme.bodyMedium.override(
            fontFamily: 'Inter',
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: PrayerReminder.weekdayLabelsRo.entries.map((entry) {
            final selected = _reminderDays.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _reminderDays.add(entry.key);
                  } else {
                    _reminderDays.remove(entry.key);
                  }
                });
              },
              selectedColor: theme.primary.withValues(alpha: 0.18),
              checkmarkColor: theme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return _buildStepShell(
      context: context,
      icon: Icons.notifications_outlined,
      title: 'Memento de rugăciune',
      body: kIsWeb
          ? 'Amintirile sunt disponibile doar din aplicație. Pe web puteți continua; le veți putea configura din Setări pe dispozitivul mobil.'
          : 'Opțional: setați o amintire pentru o rugăciune de astăzi. Ora și zilele sunt completate automat, și le puteți modifica ulterior.',
      child: kIsWeb
          ? const SizedBox.shrink()
          : _loadingTodayPrayers
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : !_hasTodayPrayers
                  ? Text(
                      'Nu am găsit rugăciuni pentru astăzi. Puteți adăuga o amintire mai târziu din aplicație.',
                      style: theme.bodyMedium.override(
                        fontFamily: 'Inter',
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildReminderPrayerPicker(context),
                        if (_selectedReminderPrayer != null)
                          _buildReminderScheduleControls(context),
                      ],
                    ),
    );
  }

  Widget _buildFavoritesStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return _buildStepShell(
      context: context,
      icon: Icons.favorite_outline_rounded,
      title: 'Rugăciuni favorite',
      body:
          'Dacă doriți, alegeți o rugăciune favorită pentru început. Rugăciunile favorite sunt mai ușor de găsit și ascultat.',
      child: _loadingFavorites
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          : _favoriteOptions.isEmpty
              ? Text(
                  'Nu am putut încărca lista acum. Puteți adăuga favorite mai târziu din aplicație.',
                  style: theme.bodyMedium.override(
                    fontFamily: 'Inter',
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                )
              : Column(
                  children: _favoriteOptions.map((prayer) {
                    final selected = _selectedFavorite?.id == prayer.id;
                    final title = prayer.title.isNotEmpty
                        ? prayer.title
                        : prayer.subtitle;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Material(
                        color: selected
                            ? theme.primary.withValues(alpha: 0.1)
                            : theme.alternate,
                        borderRadius: BorderRadius.circular(12.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () => setState(() => _selectedFavorite = prayer),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: theme.primary,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.titleSmall.override(
                                          fontFamily: 'Merriweather',
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      if (prayer.subtitle.isNotEmpty &&
                                          prayer.subtitle != title)
                                        Text(
                                          prayer.subtitle,
                                          style: theme.bodySmall.override(
                                            fontFamily: 'Inter',
                                            color: theme.secondaryText,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  Widget _buildClosingDiscoverRow({
    required BuildContext context,
    required Widget leading,
    required String title,
    String? subtitle,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.titleSmall.override(
                    fontFamily: 'Merriweather',
                    color: theme.alternate,
                    letterSpacing: 0.0,
                    useGoogleFonts: false,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: theme.bodySmall.override(
                      fontFamily: 'Inter',
                      color: theme.alternate.withValues(alpha: 0.82),
                      letterSpacing: 0.0,
                      lineHeight: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingLogoBadge(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: Image.asset(
        'assets/images/logo.jpg',
        width: 52.0,
        height: 52.0,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildClosingIconBadge(BuildContext context, IconData icon) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        color: theme.alternate.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Icon(
        icon,
        color: theme.alternate,
        size: 28.0,
      ),
    );
  }

  Widget _buildAudioStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final typography = PrayerTypography.of(context);
    final preview = _audioPreview;
    final title = preview?.title ?? OnboardingSectionAudio.fallbackTitle;
    const sectionTitleSize = 20.0;
    const sectionSubtitleSize = 15.0;

    return _buildStepShell(
      context: context,
      icon: Icons.headphones_rounded,
      title: 'Ascultați rugăciunile',
      body: 'Majoritatea rugăciunilor pot fi ascultate în aplicație. Apăsați redare pentru un scurt exemplu — primul mister din Rozariul de durere.',
      child: _loadingAudioPreview
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : preview == null || !preview.hasAudio
                  ? Text(
                      'Nu am putut încărca exemplul audio acum. Puteți asculta rugăciuni din aplicație.',
                      style: theme.bodyMedium.override(
                        fontFamily: 'Inter',
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CachedSectionImage(
                            imageUrl: preview.imageUrl,
                            width: 132.0,
                            height: 132.0,
                            borderRadius: BorderRadius.circular(39.6),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: typography.style(
                            theme.headlineSmall,
                            fontSize: sectionTitleSize,
                            scaleFontSize: false,
                            letterSpacing: 0.0,
                          ),
                        ),
                        if (preview.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6.0),
                          Text(
                            preview.subtitle,
                            textAlign: TextAlign.center,
                            style: typography.style(
                              theme.bodyLarge,
                              fontSize: sectionSubtitleSize,
                              scaleFontSize: false,
                              color: theme.secondaryText,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                        if (preview.previewText != null) ...[
                          const SizedBox(height: 16.0),
                          ValueListenableBuilder<ButtonState>(
                            valueListenable:
                                getIt<PageManager>().playButtonNotifier,
                            builder: (context, buttonState, _) {
                              final previewText = preview.previewText!;
                              final textIndex =
                                  preview.texts.indexOf(previewText);
                              final isSynced = _audioQueueReady &&
                                  buttonState == ButtonState.playing;

                              return SectionTextBlockWidget(
                                blockKey: ValueKey(
                                  'onboarding_preview_text_$textIndex',
                                ),
                                text: previewText,
                                textIndex: textIndex,
                                highlightListenable: _audioHighlight,
                                isAudioSynced: isSynced,
                                initiallyExpanded: true,
                                styles: PrayerTextStyles.of(context),
                                onSeekBlock: () {},
                                onSeekElement: (_) {},
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 20.0),
                        Center(
                          child: ValueListenableBuilder<ButtonState>(
                            valueListenable:
                                getIt<PageManager>().playButtonNotifier,
                            builder: (context, buttonState, _) {
                              final isPlaying =
                                  buttonState == ButtonState.playing;
                              final isLoading =
                                  buttonState == ButtonState.loading;

                              return FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => unawaited(_toggleOnboardingAudio()),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: theme.alternate,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28.0,
                                    vertical: 16.0,
                                  ),
                                ),
                                icon: isLoading
                                    ? SizedBox(
                                        width: 20.0,
                                        height: 20.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: theme.alternate,
                                        ),
                                      )
                                    : Icon(
                                        isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                      ),
                                label: Text(
                                  isPlaying ? 'Pauză' : 'Redare',
                                  style: theme.titleSmall.override(
                                    fontFamily: 'Inter',
                                    color: theme.alternate,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildClosingStep(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const blessing =
        'Vă dorim să aveți un timp binecuvântat de rugăciune!';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 56.0,
            color: theme.alternate.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Multe de descoperit',
            textAlign: TextAlign.center,
            style: theme.headlineSmall.override(
              fontFamily: 'Merriweather',
              color: theme.alternate,
              letterSpacing: 0.0,
              useGoogleFonts: false,
            ),),
      
          const SizedBox(height: 20.0),
          _buildClosingDiscoverRow(
            context: context,
            leading: _buildClosingIconBadge(
              context,
              Icons.calendar_today_rounded,
            ),
            title: 'Calendar',
            subtitle: 'Rugăciunile din fiecare zi'
          ),
                    _buildClosingDiscoverRow(
            context: context,
            leading: _buildClosingIconBadge(
              context,
              Icons.download_rounded
            ),
            title: 'Descărcări',
            subtitle: 'Descarcă rugăciuni și cântări pentru a le asculta offline.',
          ),

          _buildClosingDiscoverRow(
            context: context,
            leading: _buildClosingIconBadge(
              context,
              Icons.edit_note_rounded,
            ),
            title: 'Jurnal de rugăciune',
          ),
          _buildClosingDiscoverRow(
            context: context,
            leading: _buildClosingLogoBadge(context),
            title: 'Și multe altele...',
          ),
          const SizedBox(height: 12.0),
          Text(
            blessing,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: 'Merriweather',
              color: theme.alternate.withValues(alpha: 0.95),
              letterSpacing: 0.0,
              lineHeight: 1.5,
              fontStyle: FontStyle.italic,
              useGoogleFonts: false,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrayerTypographyScope(
      child: Builder(
        builder: (context) {
          final theme = FlutterFlowTheme.of(context);
          final onGradientPage =
              _page == 0 || _page == _welcomePage || _page == _closingPage;
          final showSkip = _page >= 1 && _page < _closingPage;
          final continueButtonBg =
              onGradientPage ? theme.alternate : theme.primary;
          final continueButtonFg =
              onGradientPage ? theme.primary : theme.alternate;

          final body = SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      if (_page > 0)
                        TextButton.icon(
                          onPressed: _onBack,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: onGradientPage
                                ? theme.alternate
                                : theme.primary,
                          ),
                          label: Text(
                            'Înapoi',
                            style: theme.labelLarge.override(
                              fontFamily: 'Inter',
                              color: onGradientPage
                                  ? theme.alternate.withValues(alpha: 0.9)
                                  : theme.primary,
                              letterSpacing: 0.0,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 8.0),
                      const Spacer(),
                      if (showSkip)
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Sari peste',
                            style: theme.labelLarge.override(
                              fontFamily: 'Inter',
                              color: onGradientPage
                                  ? theme.alternate.withValues(alpha: 0.85)
                                  : theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 8.0),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    key: const PageStorageKey<String>('onboarding-pages'),
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) {
                      if (_page == i) {
                        return;
                      }
                      setState(() => _page = i);
                      if (i == 0) {
                        _introAnimationController
                          ..reset()
                          ..forward();
                      }
                    },
                    children: [
                      _buildIntroStep(context),
                      _buildWelcomeStep(context),
                      _buildAudioStep(context),
                      _buildTextSettingsStep(context),
                      _buildFavoritesStep(context),
                      _buildReminderStep(context),
                      _buildClosingStep(context),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pageCount,
                    (i) => Container(
                      width: 10.0,
                      height: 10.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? (onGradientPage
                                ? theme.alternate
                                : theme.primary)
                            : (onGradientPage
                                ? theme.alternate.withValues(alpha: 0.35)
                                : theme.secondaryBackground),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: continueButtonBg,
                        foregroundColor: continueButtonFg,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        _page < _pageCount - 1 ? 'Continuă' : 'Începe',
                        style: theme.titleSmall.override(
                          fontFamily: 'Inter',
                          color: continueButtonFg,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          return Scaffold(
            backgroundColor:
                onGradientPage ? _gradientEnd : theme.primaryBackground,
            body: Container(
              key: const ValueKey<String>('onboarding-shell'),
              width: double.infinity,
              height: double.infinity,
              decoration: onGradientPage
                  ? _homeGradient(context)
                  : BoxDecoration(color: theme.primaryBackground),
              child: body,
            ),
          );
        },
      ),
    );
  }
}
