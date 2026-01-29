import 'package:my_prayer/flutter_flow/flutter_flow_theme.dart';
import 'package:my_prayer/flutter_flow/form_field_controller.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'prayer_options_widget.dart' show PrayerOptionsWidget;
import 'package:flutter/material.dart';

class PrayerOptionsModel extends FlutterFlowModel<PrayerOptionsWidget> {
  ///  Local state fields for this component.

  double? downloadProgress = 0.0;

  bool isDownloading = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for FontSizeSlider widget.
  double? fontSizeSliderValue;
  // State field(s) for AudioSpeedSlider widget.
  double? audioSpeedSliderValue;

  // State field(s) for ThemeMode chips.
  AppThemeMode? themeMode;

  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
