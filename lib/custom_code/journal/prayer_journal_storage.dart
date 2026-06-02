import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_journal_entry.dart';

const _storageKey = 'prayer_journal_entries_v1';
const _retentionDays = 31;

class PrayerJournalStorage {
  PrayerJournalStorage._();

  static Future<List<PrayerJournalEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final list = json.decode(raw) as List<dynamic>;
      final entries = list
          .map((e) => PrayerJournalEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      final pruned = _pruneOld(entries);
      if (pruned.length != entries.length) {
        await _save(pruned);
      }
      return pruned..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> addEntry(PrayerJournalEntry entry) async {
    final entries = await loadAll();
    entries.add(entry);
    await _save(_pruneOld(entries));
  }

  /// Logs an open unless it would duplicate the previous journal entry.
  static Future<bool> recordPrayerOpen({
    required String prayerId,
    required String prayerTitle,
    String prayerSubtitle = '',
  }) async {
    if (prayerId.isEmpty) {
      return false;
    }

    final existing = await loadAll();
    if (existing.isNotEmpty && existing.last.prayerId == prayerId) {
      return false;
    }

    await addEntry(
      PrayerJournalEntry(
        prayerId: prayerId,
        prayerTitle: prayerTitle,
        prayerSubtitle: prayerSubtitle,
        completedAt: DateTime.now(),
      ),
    );
    return true;
  }

  static Future<void> _save(List<PrayerJournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static List<PrayerJournalEntry> _pruneOld(List<PrayerJournalEntry> entries) {
    final cutoff = DateTime.now().subtract(const Duration(days: _retentionDays));
    return entries.where((e) => !e.completedAt.isBefore(cutoff)).toList();
  }

  /// Entries for [day] (local date), in completion order.
  static Future<List<PrayerJournalEntry>> entriesForDay(DateTime day) async {
    final all = await loadAll();
    return all.where((e) => _isSameDay(e.completedAt, day)).toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Group entries by calendar day (newest days first).
  static Future<Map<DateTime, List<PrayerJournalEntry>>> entriesByDay() async {
    final all = await loadAll();
    final map = <DateTime, List<PrayerJournalEntry>>{};
    for (final entry in all) {
      final day = DateTime(
        entry.completedAt.year,
        entry.completedAt.month,
        entry.completedAt.day,
      );
      map.putIfAbsent(day, () => []).add(entry);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }

  /// Favorite prayer id with the most journal entries; [fallbackId] if none.
  static Future<String?> mostPlayedPrayerId(
    Iterable<String> candidateIds, {
    String? fallbackId,
  }) async {
    final ids = candidateIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) {
      return fallbackId;
    }

    final counts = <String, int>{};
    for (final entry in await loadAll()) {
      if (ids.contains(entry.prayerId)) {
        counts[entry.prayerId] = (counts[entry.prayerId] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) {
      return fallbackId ?? ids.first;
    }

    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
