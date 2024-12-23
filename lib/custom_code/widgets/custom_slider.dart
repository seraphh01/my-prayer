// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class CustomSlider extends StatefulWidget {
  const CustomSlider(
      {super.key,
      this.width,
      this.height,
      this.minValue,
      this.maxValue,
      this.sliderValue,
      this.onValueChange,
      this.onValueChangeEnd});

  final double? width;
  final double? height;
  final double? sliderValue;
  final int? minValue;
  final int? maxValue;
  final Future Function(double newValue)? onValueChange;
  final Future Function(double newValue)? onValueChangeEnd;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  bool _sliding = false;
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Slider(
          activeColor: FlutterFlowTheme.of(context).primary,
          inactiveColor: Color(0x33000000),
          min: valueOrDefault<double>(
            widget.minValue?.toDouble(),
            0,
          ),
          max: valueOrDefault<double>(
            widget.maxValue?.toDouble(),
            300.0,
          ),
          value: _sliding ? _sliderValue : widget.sliderValue ?? 0,
          divisions: 100,
          onChangeStart: (newValue) async {
            setState(() {
              _sliding = true;
              _sliderValue = newValue;
            });
            newValue = double.parse(newValue.toStringAsFixed(0));
            await widget.onValueChange?.call(newValue);
          },
          onChanged: (newValue) async {
            setState(() => _sliderValue = newValue);
            newValue = double.parse(newValue.toStringAsFixed(0));
            await widget.onValueChange?.call(newValue);
          },
          onChangeEnd: (newValue) async {
            _sliding = false;
            newValue = double.parse(newValue.toStringAsFixed(0));
            setState(() => _sliderValue = newValue);
            await widget.onValueChangeEnd?.call(_sliderValue);
          }),
    );
  }
}
