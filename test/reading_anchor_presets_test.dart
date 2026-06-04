import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/custom_code/prayer/reading_anchor_presets.dart';

void main() {
  group('ReadingAnchorPresets', () {
    test('alignmentFor maps presets to expected values', () {
      expect(
        ReadingAnchorPresets.alignmentFor(ReadingAnchorPreset.high),
        0.04,
      );
      expect(
        ReadingAnchorPresets.alignmentFor(ReadingAnchorPreset.standard),
        0.35,
      );
      expect(
        ReadingAnchorPresets.alignmentFor(ReadingAnchorPreset.low),
        0.5,
      );
    });

    test('labelFor uses Mai sus, Sus, Mijloc', () {
      expect(
        ReadingAnchorPresets.labelFor(ReadingAnchorPreset.high),
        'Mai sus',
      );
      expect(
        ReadingAnchorPresets.labelFor(ReadingAnchorPreset.standard),
        'Sus',
      );
      expect(
        ReadingAnchorPresets.labelFor(ReadingAnchorPreset.low),
        'Mijloc',
      );
    });

    test('presetForAlignment snaps to nearest preset', () {
      expect(
        ReadingAnchorPresets.presetForAlignment(0.35),
        ReadingAnchorPreset.standard,
      );
      expect(
        ReadingAnchorPresets.presetForAlignment(0.04),
        ReadingAnchorPreset.high,
      );
      expect(
        ReadingAnchorPresets.presetForAlignment(0.5),
        ReadingAnchorPreset.low,
      );
      expect(
        ReadingAnchorPresets.presetForAlignment(0.40),
        ReadingAnchorPreset.standard,
      );
    });
  });
}
