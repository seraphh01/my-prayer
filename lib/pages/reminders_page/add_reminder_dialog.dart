import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/reminders/prayer_catalog_helper.dart';
import '/custom_code/reminders/prayer_date_group_prefill.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/reminder_prayer_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';

ThemeData _reminderSheetTheme(BuildContext context) {
  final theme = FlutterFlowTheme.of(context);
  return Theme.of(context).copyWith(
    colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: theme.primary,
          onPrimary: theme.alternate,
          secondary: theme.secondary,
          onSecondary: theme.alternate,
          onSurface: theme.primaryText,
          onSurfaceVariant: theme.secondaryText,
          surface: theme.primaryBackground,
        ),
  );
}

const _sheetMaxHeightFactor = 0.9;
const _pickerListMaxHeight = 400.0;

Future<PrayerReminder?> showAddEditReminderDialog(
  BuildContext context, {
  required List<PrayerTypeStruct> prayerTypes,
  PrayerReminder? existing,
  PrayerStruct? lockedPrayer,
  TimeOfDay? initialTime,
  Set<int>? initialDays,
  bool schedulePrefilledFromCalendar = false,
}) {
  return showModalBottomSheet<PrayerReminder>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (sheetContext) {
      final maxHeight =
          MediaQuery.sizeOf(sheetContext).height * _sheetMaxHeightFactor;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: _AddEditReminderSheet(
            prayerTypes: prayerTypes,
            existing: existing,
            lockedPrayer: lockedPrayer,
            initialTime: initialTime,
            initialDays: initialDays,
            schedulePrefilledFromCalendar: schedulePrefilledFromCalendar,
          ),
        ),
      );
    },
  );
}

class _AddEditReminderSheet extends StatefulWidget {
  const _AddEditReminderSheet({
    required this.prayerTypes,
    this.existing,
    this.lockedPrayer,
    this.initialTime,
    this.initialDays,
    this.schedulePrefilledFromCalendar = false,
  });

  final List<PrayerTypeStruct> prayerTypes;
  final PrayerReminder? existing;
  final PrayerStruct? lockedPrayer;
  final TimeOfDay? initialTime;
  final Set<int>? initialDays;
  final bool schedulePrefilledFromCalendar;

  bool get isPrayerLocked => lockedPrayer != null;

  @override
  State<_AddEditReminderSheet> createState() => _AddEditReminderSheetState();
}

class _AddEditReminderSheetState extends State<_AddEditReminderSheet> {
  PrayerCatalogItem? _selectedItem;
  late TimeOfDay _time;
  final Set<int> _selectedDays = {};
  String? _prayerError;
  String? _daysError;
  bool _schedulePrefilledFromCalendar = false;

  bool get _hasPrayer => _selectedItem != null || widget.isPrayerLocked;

  bool get _showScheduleSections => _hasPrayer;

  PrayerStruct? get _selectedPrayer =>
      widget.lockedPrayer ?? _selectedItem?.prayer;

  List<PrayerCatalogItem> get _catalog =>
      flattenPrayerCatalog(widget.prayerTypes);

  PrayerCatalogItem? _itemForPrayerId(String prayerId) {
    return _catalog
        .where((item) => item.prayer.id == prayerId)
        .firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final existing = widget.existing!;
      _time = TimeOfDay(hour: existing.hour, minute: existing.minute);
      _selectedDays.addAll(existing.daysOfWeek);
      if (!existing.isDynamicLiturgical) {
        _selectedItem = _itemForPrayerId(existing.prayerId);
      }
    } else if (widget.lockedPrayer != null) {
      _time = widget.initialTime ?? const TimeOfDay(hour: 8, minute: 0);
      _selectedDays.addAll(widget.initialDays ?? const {});
      _schedulePrefilledFromCalendar = widget.schedulePrefilledFromCalendar;
      _selectedItem = PrayerCatalogItem(
        prayer: widget.lockedPrayer!,
        path: '',
      );
    } else {
      _time = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  void _applySchedulePrefill(PrayerReminderPrefill prefill) {
    if (prefill.daysOfWeek.isNotEmpty) {
      _selectedDays
        ..clear()
        ..addAll(prefill.daysOfWeek);
    } else {
      _selectedDays.clear();
    }
    if (prefill.time != null) {
      _time = prefill.time!;
    }
    _schedulePrefilledFromCalendar = prefill.hasScheduleHint;
    _daysError = null;
  }

  Future<void> _selectPrayer(PrayerStruct prayer) async {
    final prayerChanged = _selectedItem?.prayer.id != prayer.id;
    setState(() {
      _selectedItem = PrayerCatalogItem(prayer: prayer, path: '');
      _prayerError = null;
      if (prayerChanged) {
        _selectedDays.clear();
        _time = const TimeOfDay(hour: 8, minute: 0);
        _schedulePrefilledFromCalendar = false;
        _daysError = null;
      }
    });

    final prefill = await fetchReminderPrefillForPrayer(prayer.id);
    if (!mounted) {
      return;
    }

    setState(() => _applySchedulePrefill(prefill));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: _reminderSheetTheme(context),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  void _clearSelectedPrayer() {
    setState(() {
      _selectedItem = null;
      _selectedDays.clear();
      _time = const TimeOfDay(hour: 8, minute: 0);
      _schedulePrefilledFromCalendar = false;
      _prayerError = null;
      _daysError = null;
    });
  }

  Widget _buildSelectedPrayerCard(
    BuildContext context,
    PrayerStruct prayer, {
    VoidCallback? onClear,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final title =
        prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;

    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 4.0, 8.0),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.primary, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodyLarge.override(
                    fontFamily: 'Merriweather',
                    color: theme.primary,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (prayer.subtitle.isNotEmpty && prayer.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      prayer.subtitle,
                      style: theme.bodySmall.override(
                        fontFamily: 'Inter',
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close, color: theme.primary),
              tooltip: 'Schimbă rugăciunea',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 36.0,
                minHeight: 36.0,
              ),
            ),
        ],
      ),
    );
  }

  void _save() {
    var valid = true;
    if (!_hasPrayer) {
      _prayerError = 'Selectează o rugăciune';
      valid = false;
    } else {
      _prayerError = null;
    }
    if (_selectedDays.isEmpty) {
      _daysError = 'Selectează cel puțin o zi';
      valid = false;
    } else {
      _daysError = null;
    }
    if (!valid) {
      setState(() {});
      return;
    }

    final prayer = _selectedPrayer!;
    final reminder = PrayerReminder(
      id: widget.existing?.id ?? const Uuid().v4(),
      prayerId: prayer.id,
      prayerTitle: prayer.title,
      prayerSubtitle: prayer.subtitle,
      hour: _time.hour,
      minute: _time.minute,
      daysOfWeek: _selectedDays.toList()..sort(),
      enabled: widget.existing?.enabled ?? true,
    );
    Navigator.of(context).pop(reminder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isEditing = widget.existing != null;

    return Theme(
      data: _reminderSheetTheme(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.paddingOf(context).bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Editează mementoul' : 'Memento nou',
                    style: theme.titleLarge.override(
                      fontFamily: 'Merriweather',
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.primary),
                  tooltip: 'Închide',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36.0,
                    minHeight: 36.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selectedPrayer != null) ...[
                      _buildSelectedPrayerCard(
                        context,
                        _selectedPrayer!,
                        onClear: !widget.isPrayerLocked && _selectedItem != null
                            ? _clearSelectedPrayer
                            : null,
                      ),
                      if (_schedulePrefilledFromCalendar)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Ora și zilele au fost completate din calendarul liturgic.',
                            style: theme.bodySmall.override(
                              fontFamily: 'Inter',
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12.0),
                    ],
                    if (_showScheduleSections) ...[
                      Text(
                        'Ora',
                        style: theme.labelLarge.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Zile din săptămână',
                        style: theme.labelLarge.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                      ),
                      if (_daysError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _daysError!,
                            style: theme.bodySmall.override(
                              fontFamily: 'Inter',
                              color: theme.error,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            PrayerReminder.weekdayLabelsRo.entries.map((entry) {
                          final selected = _selectedDays.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedDays.add(entry.key);
                                } else {
                                  _selectedDays.remove(entry.key);
                                }
                                _daysError = null;
                              });
                            },
                            selectedColor:
                                theme.secondary.withValues(alpha: 0.25),
                            checkmarkColor: theme.primary,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12.0),
                    ],
                    if (!widget.isPrayerLocked && !_hasPrayer)
                      ReminderPrayerPicker(
                        prayerTypes: widget.prayerTypes,
                        selectedPrayerId: _selectedItem?.prayer.id,
                        errorText: _prayerError,
                        onPrayerSelected: _selectPrayer,
                        maxListHeight: _pickerListMaxHeight,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Anulează'),
                  ),
                ),
                if (_showScheduleSections) ...[
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: theme.alternate,
                      ),
                      child: const Text('Salvează'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
