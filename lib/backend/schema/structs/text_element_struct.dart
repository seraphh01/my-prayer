// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_prayer/backend/schema/enums/enums.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class TextElementStruct extends FFFirebaseStruct {
  TextElementStruct({
    String? text,
    int? sequence,
    int? startTime,
    int? endTime,
    bool? highlight,
    String? quoteSource,
    TextElementType? type,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _text = text,
        _sequence = sequence,
        _startTime = startTime,
        _endTime = endTime,
        _highlight = highlight ?? false,
        _type = type ?? TextElementType.plainText,
        _quoteSource = quoteSource,
        super(firestoreUtilData);

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  // "sequence" field.
  int? _sequence;
  int get sequence => _sequence ?? 0;
  set sequence(int? val) => _sequence = val;

  bool _highlight;
  bool get highlight => _highlight;
  set highlight(bool val) => _highlight = val;

  String? _quoteSource;
  String get quoteSource => _quoteSource ?? '';
  set quoteSource(String? val) => _quoteSource = val;

  TextElementType _type;
  TextElementType get type => _type;
  set type(TextElementType val) => _type = val;

  void incrementSequence(int amount) => sequence = sequence + amount;

  bool hasSequence() => _sequence != null;

  // "start_time" field.
  int? _startTime;
  int get startTime => _startTime ?? 0;
  set startTime(int? val) => _startTime = val;

  void incrementStartTime(int amount) => startTime = startTime + amount;

  bool hasStartTime() => _startTime != null;

  // "end_time" field.
  int? _endTime;
  int get endTime => _endTime ?? 0;
  set endTime(int? val) => _endTime = val;

  void incrementEndTime(int amount) => endTime = endTime + amount;

  bool hasEndTime() => _endTime != null;

  static TextElementStruct fromMap(Map<String, dynamic> data) =>
      TextElementStruct(
          text: data['text'] as String?,
          sequence: castToType<int>(data['sequence']),
          startTime: castToType<int>(data['start_time']),
          endTime: castToType<int>(data['end_time']),
          highlight: castToType<bool>(data['highlight']),
          type: castToType<TextElementType>(data['type']),
          quoteSource: data['quote_source'] as String?);

  static TextElementStruct? maybeFromMap(dynamic data) => data is Map
      ? TextElementStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'text': _text,
        'sequence': _sequence,
        'start_time': _startTime,
        'end_time': _endTime,
        'type': _type.serialize(),
        'highlight': _highlight,
        'quote_source': _quoteSource
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'sequence': serializeParam(
          _sequence,
          ParamType.int,
        ),
        'start_time': serializeParam(
          _startTime,
          ParamType.int,
        ),
        'end_time': serializeParam(
          _endTime,
          ParamType.int,
        ),
        'highlight': serializeParam(
          _highlight,
          ParamType.bool,
        ),
        'type': serializeParam(
          _type.serialize(),
          ParamType.String,
        ),
        'quote_source': serializeParam(_quoteSource, ParamType.String)
      }.withoutNulls;

  static TextElementStruct fromSerializableMap(Map<String, dynamic> data) =>
      TextElementStruct(
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        sequence: deserializeParam(
          data['sequence'],
          ParamType.int,
          false,
        ),
        startTime: deserializeParam(
          data['start_time'],
          ParamType.int,
          false,
        ),
        endTime: deserializeParam(
          data['end_time'],
          ParamType.int,
          false,
        ),
        highlight: deserializeParam(
          data['highlight'],
          ParamType.bool,
          false,
        ),
        type: deserializeEnum<TextElementType>(
          data['type'],
        )!,
        quoteSource: deserializeParam(
          data['quote_source'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'TextElementStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TextElementStruct &&
        text == other.text &&
        sequence == other.sequence &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        highlight == other.highlight &&
        type == other.type &&
        quoteSource == other.quoteSource;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([text, sequence, startTime, endTime, highlight, type, quoteSource]);
}

TextElementStruct createTextElementStruct({
  String? text,
  int? sequence,
  int? startTime,
  int? endTime,
  bool? highlight,
  TextElementType? type,
  String? quoteSource,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    TextElementStruct(
      text: text,
      sequence: sequence,
      startTime: startTime,
      endTime: endTime,
      highlight: highlight,
      type: type,
      quoteSource: quoteSource,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

TextElementStruct? updateTextElementStruct(
  TextElementStruct? textElement, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    textElement
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addTextElementStructData(
  Map<String, dynamic> firestoreData,
  TextElementStruct? textElement,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (textElement == null) {
    return;
  }
  if (textElement.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && textElement.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final textElementData =
      getTextElementFirestoreData(textElement, forFieldValue);
  final nestedData =
      textElementData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = textElement.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getTextElementFirestoreData(
  TextElementStruct? textElement, [
  bool forFieldValue = false,
]) {
  if (textElement == null) {
    return {};
  }
  final firestoreData = mapToFirestore(textElement.toMap());

  // Add any Firestore field values
  textElement.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getTextElementListFirestoreData(
  List<TextElementStruct>? textElements,
) =>
    textElements?.map((e) => getTextElementFirestoreData(e, true)).toList() ??
    [];
