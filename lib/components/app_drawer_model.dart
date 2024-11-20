import '/backend/api_requests/api_calls.dart';
import '/components/sub_types_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/request_manager.dart';

import 'app_drawer_widget.dart' show AppDrawerWidget;
import 'package:flutter/material.dart';

class AppDrawerModel extends FlutterFlowModel<AppDrawerWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SubTypesView component.
  SubTypesViewModel? _subTypesViewModel;
  SubTypesViewModel get subTypesViewModel =>
      _subTypesViewModel ??= SubTypesViewModel();

  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;

  /// Query cache managers for this widget.

  final _prayerTypesQueryManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> prayerTypesQuery({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _prayerTypesQueryManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPrayerTypesQueryCache() => _prayerTypesQueryManager.clear();
  void clearPrayerTypesQueryCacheKey(String? uniqueKey) =>
      _prayerTypesQueryManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    subTypesViewModel.dispose();

    /// Dispose query cache managers for this widget.

    clearPrayerTypesQueryCache();
  }
}
