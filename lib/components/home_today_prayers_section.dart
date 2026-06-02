import '/backend/schema/structs/index.dart';
import '/custom_code/calendar/fetch_date_group_prayers.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Single subtle row: opens Calendar with a one-line summary of today.
class HomeTodayPrayersTile extends StatefulWidget {
  const HomeTodayPrayersTile({super.key});

  @override
  State<HomeTodayPrayersTile> createState() => _HomeTodayPrayersTileState();
}

class _HomeTodayPrayersTileState extends State<HomeTodayPrayersTile> {
  late Future<String> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<String> _loadSummary() async {
    final groups = await fetchPrayersForDate(DateTime.now());
    return summarizeTodayPrayers(groups);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return FutureBuilder<String>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data ?? 'Se încarcă…';

        return Material(
          color: Colors.transparent,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.calendar_today_rounded,
              color: theme.primary,
              size: 22.0,
            ),
            title: Text(
              'Rugăciuni de azi',
              style: theme.titleSmall.override(
                fontFamily: 'Merriweather',
                letterSpacing: 0.0,
              ),
            ),
            subtitle: Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.labelMedium.override(
                fontFamily: 'Inter',
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.0,
              color: theme.secondaryText,
            ),
            onTap: () => context.pushNamed('CalendarPage'),
          ),
        );
      },
    );
  }
}
