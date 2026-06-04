import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/prayer/section_text_formatting.dart';

SectionTextStruct _textBlock({
  required int startTime,
  required int endTime,
  required List<TextElementStruct> elements,
}) {
  return SectionTextStruct(
    startTime: startTime,
    endTime: endTime,
    textElements: elements,
  );
}

TextElementStruct _element({
  required int startTime,
  required int endTime,
  String text = 'line',
}) {
  return TextElementStruct(
    text: text,
    startTime: startTime,
    endTime: endTime,
  );
}

void main() {
  group('findActiveTextIndex', () {
    test('returns -1 for empty list', () {
      expect(findActiveTextIndex([], 10), -1);
    });

    test('finds block containing audio time', () {
      final texts = [
        _textBlock(startTime: 0, endTime: 10, elements: const []),
        _textBlock(startTime: 10, endTime: 20, elements: const []),
        _textBlock(startTime: 20, endTime: 30, elements: const []),
      ];

      expect(findActiveTextIndex(texts, 0), 0);
      expect(findActiveTextIndex(texts, 9), 0);
      expect(findActiveTextIndex(texts, 10), 1);
      expect(findActiveTextIndex(texts, 19), 1);
      expect(findActiveTextIndex(texts, 29), 2);
    });

    test('returns -1 before first block and after last block', () {
      final texts = [
        _textBlock(startTime: 5, endTime: 10, elements: const []),
      ];

      expect(findActiveTextIndex(texts, 4), -1);
      expect(findActiveTextIndex(texts, 10), -1);
    });
  });

  group('findActiveElementIndex', () {
    test('returns -1 when block has no elements', () {
      final text = _textBlock(startTime: 0, endTime: 10, elements: const []);
      expect(findActiveElementIndex(text, 5), -1);
    });

    test('finds element relative to block start time', () {
      final text = _textBlock(
        startTime: 100,
        endTime: 130,
        elements: [
          _element(startTime: 0, endTime: 10),
          _element(startTime: 10, endTime: 20),
          _element(startTime: 20, endTime: 30),
        ],
      );

      expect(findActiveElementIndex(text, 100), 0);
      expect(findActiveElementIndex(text, 109), 0);
      expect(findActiveElementIndex(text, 110), 1);
      expect(findActiveElementIndex(text, 129), 2);
    });

    test('returns -1 between elements and after block ends', () {
      final text = _textBlock(
        startTime: 0,
        endTime: 20,
        elements: [
          _element(startTime: 0, endTime: 5),
          _element(startTime: 10, endTime: 15),
        ],
      );

      expect(findActiveElementIndex(text, 7), -1);
      expect(findActiveElementIndex(text, 20), -1);
    });
  });

  group('isElementPlaying and hasElementPassed', () {
    test('tracks playback window for an element', () {
      final text = _textBlock(
        startTime: 50,
        endTime: 80,
        elements: [
          _element(startTime: 0, endTime: 10),
        ],
      );
      final element = text.textElements.first;

      expect(
        isElementPlaying(
          text: text,
          element: element,
          audioTimeSeconds: 55,
        ),
        isTrue,
      );
      expect(
        isElementPlaying(
          text: text,
          element: element,
          audioTimeSeconds: 60,
        ),
        isFalse,
      );
      expect(
        hasElementPassed(
          text: text,
          element: element,
          audioTimeSeconds: 61,
        ),
        isTrue,
      );
    });
  });
}
