import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'empty_downloaded_prayers_list_model.dart';
export 'empty_downloaded_prayers_list_model.dart';

class EmptyDownloadedPrayersListWidget extends StatefulWidget {
  const EmptyDownloadedPrayersListWidget({super.key});

  @override
  State<EmptyDownloadedPrayersListWidget> createState() =>
      _EmptyDownloadedPrayersListWidgetState();
}

class _EmptyDownloadedPrayersListWidgetState
    extends State<EmptyDownloadedPrayersListWidget> {
  late EmptyDownloadedPrayersListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyDownloadedPrayersListModel());

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
              'Încă nu ai nimic aici',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Merriweather',
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Text(
                  'Descarcă rugăciunile dorite apâsând pe ',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Icon(
                Icons.download_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 16.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
