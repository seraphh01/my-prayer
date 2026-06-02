import '/backend/schema/structs/index.dart';
import '/custom_code/journal/prayer_journal_storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// One favorite row: the most-used prayer from the journal (or first favorite).
class HomeTopFavoriteTile extends StatefulWidget {
  const HomeTopFavoriteTile({super.key});

  @override
  State<HomeTopFavoriteTile> createState() => _HomeTopFavoriteTileState();
}

class _HomeTopFavoriteTileState extends State<HomeTopFavoriteTile> {
  PrayerStruct? _prayer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final favorites = FFAppState().favoritePrayers;
    if (favorites.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _prayer = null;
        });
      }
      return;
    }

    final topId = await PrayerJournalStorage.mostPlayedPrayerId(
      favorites.map((p) => p.id),
      fallbackId: favorites.first.id,
    );

    final prayer = favorites
        .where((p) => p.id == topId)
        .firstOrNull ?? favorites.first;

    if (mounted) {
      setState(() {
        _prayer = prayer;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final favorites = FFAppState().favoritePrayers;

    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!_loading &&
        _prayer != null &&
        favorites.none((p) => p.id == _prayer!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
    }

    if (_loading || _prayer == null) {
      return const SizedBox.shrink();
    }

    final prayer = _prayer!;
    final theme = FlutterFlowTheme.of(context);
    final title =
        prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.favorite_rounded,
          color: theme.primary,
          size: 22.0,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.titleSmall.override(
            fontFamily: 'Merriweather',
            letterSpacing: 0.0,
          ),
        ),
        subtitle: Text(
          'Favorite',
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
        onTap: () {
          context.pushNamed(
            'RosaryPage',
            queryParameters: {'prayerId': prayer.id},
          );
        },
      ),
    );
  }
}
