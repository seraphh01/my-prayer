import '/backend/api_requests/api_calls.dart';
import '/components/app_drawer_widget.dart';
import '/components/sections_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/request_manager.dart';

import 'rosary_page_widget.dart' show RosaryPageWidget;
import 'package:flutter/material.dart';

class RosaryPageModel extends FlutterFlowModel<RosaryPageWidget> {
  ///  Local state fields for this page.

  int? weekDay = 1;

  int? rosaryTabIndex = 0;

  bool playingAudio = false;

  double? currentAudioTime;

  String? currentAudioUrl;

  ///  State fields for stateful widgets in this page.

  // Model for AppDrawer component.
  AppDrawerModel? _appDrawerModel;
  AppDrawerModel get appDrawerModel => _appDrawerModel ??= AppDrawerModel();

  // Model for SectionsView component.
  late SectionsViewModel sectionsViewModel;

  /// Query cache managers for this widget.

  final _prayerSectionsQueryManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> prayerSectionsQuery({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _prayerSectionsQueryManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPrayerSectionsQueryCache() => _prayerSectionsQueryManager.clear();
  void clearPrayerSectionsQueryCacheKey(String? uniqueKey) =>
      _prayerSectionsQueryManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    sectionsViewModel = createModel(context, () => SectionsViewModel());
  }

  @override
  void dispose() {
    appDrawerModel.dispose();
    sectionsViewModel.dispose();

    /// Dispose query cache managers for this widget.

    clearPrayerSectionsQueryCache();
  }
}
