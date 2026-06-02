import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/reminders/prayer_date_group_prefill.dart';
import '/custom_code/reminders/prayer_reminder.dart';
import '/custom_code/reminders/prayer_reminder_service.dart';
import '/custom_code/reminders/reminder_storage.dart';
import '/flutter_flow/nav/nav.dart';
import '/pages/reminders_page/add_reminder_dialog.dart';

Future<bool> _confirmDuplicateReminder(
  BuildContext context,
  List<PrayerReminder> existing,
) async {
  final lines = existing
      .map((reminder) => '• ${reminder.timeLabel} · ${reminder.daysLabel}')
      .join('\n');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Memento existent'),
      content: Text(
        existing.length == 1
            ? 'Ai deja un memento pentru această rugăciune:\n$lines\n\nVrei să adaugi încă unul?'
            : 'Ai deja ${existing.length} mementouri pentru această rugăciune:\n$lines\n\nVrei să adaugi încă unul?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Anulează'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Adaugă'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

/// Opens the reminder sheet for [prayer], with optional schedule prefill from date groups.
Future<void> openPrayerReminderFlow(
  BuildContext context, {
  required PrayerStruct prayer,
}) async {
  var hostContext = context;
  if (!hostContext.mounted) {
    hostContext = appNavigatorKey.currentContext ?? context;
  }
  if (!hostContext.mounted) {
    return;
  }

  if (kIsWeb) {
    ScaffoldMessenger.of(hostContext).showSnackBar(
      const SnackBar(
        content: Text('Mementourile sunt disponibile doar pe telefon.'),
      ),
    );
    return;
  }

  final existing = (await ReminderStorage.loadAll())
      .where(
        (reminder) =>
            reminder.prayerId == prayer.id && !reminder.isDynamicLiturgical,
      )
      .toList();

  if (existing.isNotEmpty) {
    if (!hostContext.mounted) {
      return;
    }
    final proceed = await _confirmDuplicateReminder(hostContext, existing);
    if (!proceed || !hostContext.mounted) {
      return;
    }
  }

  final prefill = await fetchReminderPrefillForPrayer(prayer.id);
  if (!hostContext.mounted) {
    return;
  }

  final result = await showAddEditReminderDialog(
    hostContext,
    prayerTypes: const [],
    lockedPrayer: prayer,
    initialTime: prefill.time,
    initialDays: prefill.daysOfWeek,
    schedulePrefilledFromCalendar: prefill.hasScheduleHint,
  );

  if (result == null || !hostContext.mounted) {
    return;
  }

  await ReminderStorage.upsert(result);
  if (result.enabled) {
    await PrayerReminderService.instance.requestPermissionIfNeeded();
    await PrayerReminderService.instance.scheduleReminder(result);
  }

  if (!hostContext.mounted) {
    return;
  }

  ScaffoldMessenger.of(hostContext).showSnackBar(
    SnackBar(
      content: Text('Memento salvat pentru „${prayer.title}”.'),
    ),
  );
}
