// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SectionTextStruct extends FFFirebaseStruct {
  SectionTextStruct({
    String? title,
    int? sequence,
    int? repetition,
    List<TextElementStruct>? textElements,
    int? startTime,
    int? endTime,
    int? audioTime,
    bool? italic,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _sequence = sequence,
        _repetition = repetition,
        _textElements = textElements,
        _startTime = startTime,
        _endTime = endTime,
        _audioTime = audioTime,
        _italic = italic,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "sequence" field.
  int? _sequence;
  int get sequence => _sequence ?? 0;
  set sequence(int? val) => _sequence = val;

  bool? _italic;
  bool get italic => _italic ?? false;
  set italic(bool? val) => _italic = val;

  void incrementSequence(int amount) => sequence = sequence + amount;

  bool hasSequence() => _sequence != null;

  // "repetition" field.
  int? _repetition;
  int get repetition => _repetition ?? 0;
  set repetition(int? val) => _repetition = val;

  void incrementRepetition(int amount) => repetition = repetition + amount;

  bool hasRepetition() => _repetition != null;

  // "text_elements" field.
  List<TextElementStruct>? _textElements;
  List<TextElementStruct> get textElements => _textElements ?? const [];
  set textElements(List<TextElementStruct>? val) => _textElements = val;

  void updateTextElements(Function(List<TextElementStruct>) updateFn) {
    updateFn(_textElements ??= []);
  }

  bool hasTextElements() => _textElements != null;

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

  // "audio_time" field.
  int? _audioTime;
  int get audioTime => _audioTime ?? 0;
  set audioTime(int? val) => _audioTime = val;

  void incrementAudioTime(int amount) => audioTime = audioTime + amount;

  bool hasAudioTime() => _audioTime != null;

  static SectionTextStruct fromMap(Map<String, dynamic> data) =>
      SectionTextStruct(
        title: data['title'] as String?,
        sequence: castToType<int>(data['sequence']),
        repetition: castToType<int>(data['repetition']),
        textElements: getStructList(
          data['text_elements'],
          TextElementStruct.fromMap,
        ),
        startTime: castToType<int>(data['start_time']),
        endTime: castToType<int>(data['end_time']),
        audioTime: castToType<int>(data['audio_time']),
        italic: castToType<bool>(data['italic']),
      );

  static SectionTextStruct? maybeFromMap(dynamic data) => data is Map
      ? SectionTextStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'sequence': _sequence,
        'repetition': _repetition,
        'text_elements': _textElements?.map((e) => e.toMap()).toList(),
        'start_time': _startTime,
        'end_time': _endTime,
        'audio_time': _audioTime,
        'italic': _italic,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'sequence': serializeParam(
          _sequence,
          ParamType.int,
        ),
        'repetition': serializeParam(
          _repetition,
          ParamType.int,
        ),
        'text_elements': serializeParam(
          _textElements,
          ParamType.DataStruct,
          isList: true,
        ),
        'start_time': serializeParam(
          _startTime,
          ParamType.int,
        ),
        'end_time': serializeParam(
          _endTime,
          ParamType.int,
        ),
        'audio_time': serializeParam(
          _audioTime,
          ParamType.int,
        ),
        'italic': serializeParam(
          _italic,
          ParamType.bool,
        ),
      }.withoutNulls;

  static SectionTextStruct fromSerializableMap(Map<String, dynamic> data) =>
      SectionTextStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
        ),
        sequence: deserializeParam(
          data['sequence'],
          ParamType.int,
        ),
        repetition: deserializeParam(
          data['repetition'],
          ParamType.int,
        ),
        textElements: deserializeStructParam<TextElementStruct>(
          data['text_elements'],
          ParamType.DataStruct,
          true,
          structBuilder: TextElementStruct.fromSerializableMap,
        ),
        startTime: deserializeParam(
          data['start_time'],
          ParamType.int,
        ),
        endTime: deserializeParam(
          data['end_time'],
          ParamType.int,
        ),
        audioTime: deserializeParam(
          data['audio_time'],
          ParamType.int,
        ),
        italic: deserializeParam(
          data['italic'],
          ParamType.bool,
        ),
      );

  @override
  String toString() => 'SectionTextStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is SectionTextStruct &&
        title == other.title &&
        sequence == other.sequence &&
        repetition == other.repetition &&
        listEquality.equals(textElements, other.textElements) &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        italic == other.italic &&
        audioTime == other.audioTime;
  }

  @override
  int get hashCode => const ListEquality().hash([
        title,
        sequence,
        repetition,
        textElements,
        startTime,
        endTime,
        audioTime,
        italic
      ]);
}

SectionTextStruct createSectionTextStruct({
  String? title,
  int? sequence,
  int? repetition,
  int? startTime,
  int? endTime,
  int? audioTime,
  bool? italic,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SectionTextStruct(
      title: title,
      sequence: sequence,
      repetition: repetition,
      startTime: startTime,
      endTime: endTime,
      audioTime: audioTime,
      italic: italic,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SectionTextStruct? updateSectionTextStruct(
  SectionTextStruct? sectionText, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    sectionText
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSectionTextStructData(
  Map<String, dynamic> firestoreData,
  SectionTextStruct? sectionText,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (sectionText == null) {
    return;
  }
  if (sectionText.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && sectionText.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final sectionTextData =
      getSectionTextFirestoreData(sectionText, forFieldValue);
  final nestedData =
      sectionTextData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = sectionText.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSectionTextFirestoreData(
  SectionTextStruct? sectionText, [
  bool forFieldValue = false,
]) {
  if (sectionText == null) {
    return {};
  }
  final firestoreData = mapToFirestore(sectionText.toMap());

  // Add any Firestore field values
  sectionText.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSectionTextListFirestoreData(
  List<SectionTextStruct>? sectionTexts,
) =>
    sectionTexts?.map((e) => getSectionTextFirestoreData(e, true)).toList() ??
    [];
