import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'empty_favorite_prayers_list_model.dart';
export 'empty_favorite_prayers_list_model.dart';

class EmptyFavoritePrayersListWidget extends StatefulWidget {
  const EmptyFavoritePrayersListWidget({super.key});

  @override
  State<EmptyFavoritePrayersListWidget> createState() =>
      _EmptyFavoritePrayersListWidgetState();
}

class _EmptyFavoritePrayersListWidgetState
    extends State<EmptyFavoritePrayersListWidget> {
  late EmptyFavoritePrayersListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyFavoritePrayersListModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            Icons.report,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 72.0,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
            child: Text(
              AppLocalizations.of(context).emptyStateTitle,
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Merriweather',
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
            child: Text(
              AppLocalizations.of(context).emptyFavoriteHint,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Inter',
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
