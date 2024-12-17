import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/sections_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'rosary_page_widget.dart' show RosaryPageWidget;
import 'package:flutter/material.dart';

class RosaryPageModel extends FlutterFlowModel<RosaryPageWidget> {
  ///  Local state fields for this page.

  int? weekDay = 1;

  int? rosaryTabIndex = 0;

  bool playingAudio = false;

  double? currentAudioTime;

  String? currentAudioUrl;

  int? test = 12;

  bool isDownloading = false;

  double downloadProgress = 0.0;

  bool isLoadingDownload = false;

  int? downloadedSize = 0;

  int? totalSize = 0;

  PrayerStruct? currentPrayer;
  void updateCurrentPrayerStruct(Function(PrayerStruct) updateFn) {
    updateFn(currentPrayer ??= PrayerStruct());
  }

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Get prayer with sections recursive)] action in RosaryPage widget.
  ApiCallResponse? prayerResponse;
  // Stores action output result for [Bottom Sheet - PrayerOptions] action in IconButton widget.
  String? pressedButton;
  // Model for SectionsView component.
  late SectionsViewModel sectionsViewModel;

  @override
  void initState(BuildContext context) {
    sectionsViewModel = createModel(context, () => SectionsViewModel());
  }

  @override
  void dispose() {
    sectionsViewModel.dispose();
  }

  /// Action blocks.
  Future downloadPrayer(
    BuildContext context, {
    required String? prayerId,
  }) async {
    ApiCallResponse? prayerResponse;
    bool? success;

    prayerResponse =
        await SuapabaseQueriesGroup.getPrayerWithSectionsRecursiveCall.call(
      requestPrayerId: widget!.prayerId,
    );

    if ((prayerResponse.succeeded ?? true)) {
      success = await actions.savePrayerData(
        PrayerStruct.maybeFromMap((prayerResponse.jsonBody ?? ''))!,
      );
      if (success) {
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return AlertDialog(
              title: const Text('Descarcarea rugaciunii'),
              content: const Text('S-a finalizat cu succes!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return AlertDialog(
              title: const Text('Descarcarea rugaciunii'),
              content: const Text('S-a finalizat cu eroare!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    } else {
      await showDialog(
        context: context,
        builder: (alertDialogContext) {
          return AlertDialog(
            title: const Text('A apa[rut o eroare'),
            content: const Text('Vă rugăm încercați mai târziu!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }
}
