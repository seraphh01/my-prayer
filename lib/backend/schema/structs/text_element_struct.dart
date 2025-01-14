// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class TextElementStruct extends FFFirebaseStruct {
  TextElementStruct({
    String? text,
    int? sequence,
    int? startTime,
    int? endTime,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _text = text,
        _sequence = sequence,
        _startTime = startTime,
        _endTime = endTime,
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
      );

  static TextElementStruct? maybeFromMap(dynamic data) => data is Map
      ? TextElementStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'text': _text,
        'sequence': _sequence,
        'start_time': _startTime,
        'end_time': _endTime,
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
      );

  @override
  String toString() => 'TextElementStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TextElementStruct &&
        text == other.text &&
        sequence == other.sequence &&
        startTime == other.startTime &&
        endTime == other.endTime;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([text, sequence, startTime, endTime]);
}

TextElementStruct createTextElementStruct({
  String? text,
  int? sequence,
  int? startTime,
  int? endTime,
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
