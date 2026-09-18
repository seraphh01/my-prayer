import '/custom_code/journal/prayer_journal_entry.dart';
import '/custom_code/journal/prayer_journal_storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class PrayerJournalPageWidget extends StatefulWidget {
  const PrayerJournalPageWidget({super.key});

  @override
  State<PrayerJournalPageWidget> createState() =>
      _PrayerJournalPageWidgetState();
}

class _PrayerJournalPageWidgetState extends State<PrayerJournalPageWidget> {
  Map<DateTime, List<PrayerJournalEntry>> _byDay = {};
  List<PrayerJournalEntry> _today = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final byDay = await PrayerJournalStorage.entriesByDay();
    final today = await PrayerJournalStorage.entriesForDay(DateTime.now());
    if (mounted) {
      setState(() {
        _byDay = byDay;
        _today = today;
        _loading = false;
      });
    }
  }

  String _formatDay(BuildContext context, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(day.year, day.month, day.day);
    if (d == today) {
      return AppLocalizations.of(context).journalToday;
    }
    if (d == yesterday) {
      return AppLocalizations.of(context).journalYesterday;
    }
    return dateTimeFormat('d MMMM yyyy', d, locale: 'ro');
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        iconTheme: IconThemeData(color: theme.alternate),
        title: Text(
          AppLocalizations.of(context).journalPageTitle,
          style: theme.titleLarge.override(
            fontFamily: 'Merriweather',
            color: theme.alternate,
            letterSpacing: 0.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.primary),
              ),
            )
          : _byDay.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded,
                            size: 64, color: theme.secondaryText),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).journalEmptyTitle,
                          style: theme.titleMedium.override(
                            fontFamily: 'Merriweather',
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).journalEmptySubtitle,
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium.override(
                            fontFamily: 'Inter',
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: theme.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_today.isNotEmpty) ...[
                        Text(
                          AppLocalizations.of(context)
                              .journalTodayCount(_today.length),
                          style: theme.labelLarge.override(
                            fontFamily: 'Inter',
                            color: theme.primary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._today.map((e) => _EntryTile(entry: e)),
                        const SizedBox(height: 20),
                        Divider(color: theme.secondaryBackground),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        AppLocalizations.of(context).journalHistoryTitle,
                        style: theme.titleSmall.override(
                          fontFamily: 'Merriweather',
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._byDay.entries.map((entry) {
                        final day = entry.key;
                        final items = entry.value;
                        if (_isSameDay(day, DateTime.now()) &&
                            _today.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 4),
                              child: Text(
                                '${_formatDay(context, day)} — ${items.length}',
                                style: theme.labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...items.map((e) => _EntryTile(entry: e)),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final PrayerJournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final time = dateTimeFormat('HH:mm', entry.completedAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.primary.withValues(alpha: 0.12),
        child: Icon(Icons.check_rounded, color: theme.primary, size: 20),
      ),
      title: Text(
        entry.prayerTitle.isNotEmpty ? entry.prayerTitle : entry.prayerSubtitle,
        style: theme.bodyLarge.override(
          fontFamily: 'Merriweather',
          letterSpacing: 0.0,
        ),
      ),
      subtitle: entry.prayerSubtitle.isNotEmpty &&
              entry.prayerTitle != entry.prayerSubtitle
          ? Text(
              entry.prayerSubtitle,
              style: theme.bodySmall.override(
                fontFamily: 'Inter',
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            )
          : null,
      trailing: Text(
        time,
        style: theme.labelMedium.override(
          fontFamily: 'Inter',
          color: theme.secondaryText,
          letterSpacing: 0.0,
        ),
      ),
      onTap: () {
        context.openPrayer(entry.prayerId);
      },
    );
  }
}
