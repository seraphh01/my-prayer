import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/prayer_reminder_service.dart';
import '/custom_code/reminders/reminder_storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_reminder_dialog.dart';
import 'reminders_page_model.dart';
export 'reminders_page_model.dart';

class RemindersPageWidget extends StatefulWidget {
  const RemindersPageWidget({super.key});

  @override
  State<RemindersPageWidget> createState() => _RemindersPageWidgetState();
}

class _RemindersPageWidgetState extends State<RemindersPageWidget> {
  late RemindersPageModel _model;

  List<PrayerReminder> _reminders = [];
  List<PrayerTypeStruct> _prayerTypes = [];
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RemindersPageModel());
    _loadData();
  }

  Future<void> _loadData() async {
    if (kIsWeb) {
      setState(() => _model.isLoading = false);
      return;
    }

    _model.notificationsGranted =
        await PrayerReminderService.instance.areNotificationsEnabled();

    _reminders = await ReminderStorage.loadAll();

    try {
      final response = await SuapabaseQueriesGroup.getPrayerTypesCall.call();
      if (response.succeeded) {
        _prayerTypes = (response.jsonBody as List? ?? [])
            .map(PrayerTypeStruct.maybeFromMap)
            .whereType<PrayerTypeStruct>()
            .toList();
      }
    } catch (_) {
      _prayerTypes = [];
    }

    if (mounted) {
      setState(() => _model.isLoading = false);
    }
  }

  Future<void> _refreshNotificationsState() async {
    _model.notificationsGranted =
        await PrayerReminderService.instance.areNotificationsEnabled();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addOrEditReminder({PrayerReminder? existing}) async {
    if (_prayerTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nu s-a putut încărca lista de rugăciuni. Verifică conexiunea.',
          ),
        ),
      );
      return;
    }

    final result = await showAddEditReminderDialog(
      context,
      prayerTypes: _prayerTypes,
      existing: existing,
    );
    if (result == null) {
      return;
    }

    if (existing != null) {
      await PrayerReminderService.instance.cancelReminder(existing);
    }

    await ReminderStorage.upsert(result);
    if (result.enabled) {
      await PrayerReminderService.instance.requestPermissionIfNeeded();
      await PrayerReminderService.instance.scheduleReminder(result);
    } else {
      await PrayerReminderService.instance.cancelReminder(result);
    }

    _reminders = await ReminderStorage.loadAll();
    await _refreshNotificationsState();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleReminder(PrayerReminder reminder, bool enabled) async {
    final updated = reminder.copyWith(enabled: enabled);
    await ReminderStorage.upsert(updated);
    if (enabled) {
      await PrayerReminderService.instance.requestPermissionIfNeeded();
      await PrayerReminderService.instance.scheduleReminder(updated);
    } else {
      await PrayerReminderService.instance.cancelReminder(updated);
    }
    _reminders = await ReminderStorage.loadAll();
    await _refreshNotificationsState();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteReminder(PrayerReminder reminder) async {
    final theme = FlutterFlowTheme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge mementoul?'),
        content: Text(
          'Memento pentru „${reminder.prayerTitle}” la ${reminder.timeLabel} va fi șters.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Șterge',
              style: TextStyle(color: theme.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    await PrayerReminderService.instance.cancelReminder(reminder);
    await ReminderStorage.delete(reminder.id);
    _reminders = await ReminderStorage.loadAll();
    if (_reminders.isEmpty) {
      _isEditMode = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memento rugăciune')),
        body: const Center(
          child: Text('Mementourile sunt disponibile doar pe telefon.'),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            iconTheme: IconThemeData(
              color: FlutterFlowTheme.of(context).alternate,
            ),
            title: Text(
              'Memento rugăciune',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: 'Merriweather',
                    color: FlutterFlowTheme.of(context).alternate,
                    letterSpacing: 0.0,
                  ),
            ),
            centerTitle: true,
            toolbarHeight: 64.0,
            elevation: 0.0,
            actions: [
              if (_reminders.isNotEmpty)
                IconButton(
                  onPressed: () {
                    setState(() => _isEditMode = !_isEditMode);
                  },
                  icon: Icon(
                    _isEditMode ? Icons.check : Icons.edit_outlined,
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                  tooltip: _isEditMode ? 'Gata' : 'Editează',
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addOrEditReminder(),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          foregroundColor: FlutterFlowTheme.of(context).alternate,
          icon: const Icon(Icons.add),
          label: const Text('Adaugă'),
        ),
        body: SafeArea(
          child: _model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                )
              : Column(
                  children: [
                    if (!_model.notificationsGranted)
                      Material(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Activează notificările în setările telefonului.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              TextButton(
                                onPressed: openAppSettings,
                                child: const Text('Setări'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: _reminders.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'Nu ai mementouri. Apasă + pentru a adăuga unul.',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                8.0,
                                8.0,
                                8.0,
                                88.0,
                              ),
                              itemCount: _reminders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 4.0),
                              itemBuilder: (context, index) {
                                final reminder = _reminders[index];
                                final theme = FlutterFlowTheme.of(context);
                                return Card(
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
                                    onTap: _isEditMode
                                        ? null
                                        : () => _addOrEditReminder(
                                              existing: reminder,
                                            ),
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16.0,
                                        12.0,
                                        8.0,
                                        12.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  reminder.prayerTitle,
                                                  style:
                                                      theme.titleMedium.override(
                                                    fontFamily: 'Merriweather',
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                if (reminder
                                                    .prayerSubtitle.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 2.0,
                                                    ),
                                                    child: Text(
                                                      reminder.prayerSubtitle,
                                                      style: theme.bodyMedium
                                                          .override(
                                                        fontFamily: 'Inter',
                                                        letterSpacing: 0.0,
                                                      ),
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: reminder.prayerSubtitle
                                                            .isNotEmpty
                                                        ? 2.0
                                                        : 4.0,
                                                  ),
                                                  child: Text(
                                                    '${reminder.timeLabel} · ${reminder.daysLabel}',
                                                    style: theme.bodyMedium
                                                        .override(
                                                      fontFamily: 'Inter',
                                                      color:
                                                          theme.secondaryText,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          _isEditMode
                                              ? IconButton(
                                                  onPressed: () =>
                                                      _deleteReminder(reminder),
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    color: theme.primary,
                                                  ),
                                                  tooltip: 'Șterge',
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 40.0,
                                                    minHeight: 40.0,
                                                  ),
                                                )
                                              : Switch(
                                                  value: reminder.enabled,
                                                  activeThumbColor:
                                                      theme.primary,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  onChanged: (value) =>
                                                      _toggleReminder(
                                                    reminder,
                                                    value,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
