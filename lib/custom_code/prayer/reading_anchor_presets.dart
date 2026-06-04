import 'package:flutter/material.dart';

enum ReadingAnchorPreset {
  high,
  standard,
  low,
}

class ReadingAnchorPresets {
  ReadingAnchorPresets._();

  static const double highAlignment = 0.05;
  static const double standardAlignment = 0.25;
  static const double lowAlignment = 0.5;

  static const List<ReadingAnchorPreset> values = ReadingAnchorPreset.values;

  static double alignmentFor(ReadingAnchorPreset preset) {
    switch (preset) {
      case ReadingAnchorPreset.high:
        return highAlignment;
      case ReadingAnchorPreset.standard:
        return standardAlignment;
      case ReadingAnchorPreset.low:
        return lowAlignment;
    }
  }

  static ReadingAnchorPreset presetForAlignment(double alignment) {
    var closest = ReadingAnchorPreset.standard;
    var smallestDistance = double.infinity;

    for (final preset in values) {
      final distance = (alignmentFor(preset) - alignment).abs();
      if (distance < smallestDistance) {
        smallestDistance = distance;
        closest = preset;
      }
    }

    return closest;
  }

  static String labelFor(ReadingAnchorPreset preset) {
    switch (preset) {
      case ReadingAnchorPreset.high:
        return 'Mai sus';
      case ReadingAnchorPreset.standard:
        return 'Sus';
      case ReadingAnchorPreset.low:
        return 'Mijloc';
    }
  }

  static IconData iconFor(ReadingAnchorPreset preset) {
    switch (preset) {
      case ReadingAnchorPreset.high:
        return Icons.vertical_align_top;
      case ReadingAnchorPreset.standard:
        return Icons.vertical_align_center;
      case ReadingAnchorPreset.low:
        return Icons.vertical_align_bottom;
    }
  }
}
