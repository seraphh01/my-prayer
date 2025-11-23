import 'package:collection/collection.dart';

enum PrayerType {
  rozariu,
  canonice,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  if (value == null) return null;

  if (T == PrayerType) {
    return PrayerType.values.deserialize(value) as T?;
  } else if (T == TextElementType) {
    return TextElementType.values.deserialize(value) as T?;
  }

  return null; // unsupported type
}


enum TextElementType {
  plainText,
  boldText,
  italicText,
  quoteText,
}
