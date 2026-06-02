import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_reminder.dart';

class ReminderStorage {
  ReminderStorage._();

  static const _storageKey = 'ff_prayer_reminders_v1';

  static Future<List<PrayerReminder>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => PrayerReminder.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<PrayerReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> upsert(PrayerReminder reminder) async {
    final all = await loadAll();
    final index = all.indexWhere((r) => r.id == reminder.id);
    if (index >= 0) {
      all[index] = reminder;
    } else {
      all.add(reminder);
    }
    await saveAll(all);
  }

  static Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((r) => r.id == id);
    await saveAll(all);
  }
}
