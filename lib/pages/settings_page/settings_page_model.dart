import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/form_field_controller.dart';
import 'settings_page_widget.dart' show SettingsPageWidget;
import 'package:flutter/material.dart';

class SettingsPageModel extends FlutterFlowModel<SettingsPageWidget> {
  ///  Local state fields for this page.

  int? occupiedStorage = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - computeFolderSize] action in SettingsPage widget.
  int? resultedSize;
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;
  // State field(s) for AudioSpeedSlider widget.
  double? audioSpeedSliderValue;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for FontSizeSlider widget.
  double? fontSizeSliderValue;
  // State field(s) for ThemeMode chips.
  AppThemeMode? themeMode;
  // Stores action output result for [Custom Action - deleteFileOrFolder] action in IconButton widget.
  bool? success;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
