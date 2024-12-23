// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrayerStruct extends FFFirebaseStruct {
  PrayerStruct({
    String? id,
    String? title,
    List<PrayerSectionStruct>? sections,
    String? subtitle,
    int? sequence,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _title = title,
        _sections = sections,
        _subtitle = subtitle,
        _sequence = sequence,
        super(firestoreUtilData);

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "sections" field.
  List<PrayerSectionStruct>? _sections;
  List<PrayerSectionStruct> get sections => _sections ?? const [];
  set sections(List<PrayerSectionStruct>? val) => _sections = val;

  void updateSections(Function(List<PrayerSectionStruct>) updateFn) {
    updateFn(_sections ??= []);
  }

  bool hasSections() => _sections != null;

  // "subtitle" field.
  String? _subtitle;
  String get subtitle => _subtitle ?? '';
  set subtitle(String? val) => _subtitle = val;

  bool hasSubtitle() => _subtitle != null;

  // "sequence" field.
  int? _sequence;
  int get sequence => _sequence ?? 0;
  set sequence(int? val) => _sequence = val;

  void incrementSequence(int amount) => sequence = sequence + amount;

  bool hasSequence() => _sequence != null;

  static PrayerStruct fromMap(Map<String, dynamic> data) => PrayerStruct(
        id: data['id'] as String?,
        title: data['title'] as String?,
        sections: getStructList(
          data['sections'],
          PrayerSectionStruct.fromMap,
        ),
        subtitle: data['subtitle'] as String?,
        sequence: castToType<int>(data['sequence']),
      );

  static PrayerStruct? maybeFromMap(dynamic data) =>
      data is Map ? PrayerStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'title': _title,
        'sections': _sections?.map((e) => e.toMap()).toList(),
        'subtitle': _subtitle,
        'sequence': _sequence,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'sections': serializeParam(
          _sections,
          ParamType.DataStruct,
          isList: true,
        ),
        'subtitle': serializeParam(
          _subtitle,
          ParamType.String,
        ),
        'sequence': serializeParam(
          _sequence,
          ParamType.int,
        ),
      }.withoutNulls;

  static PrayerStruct fromSerializableMap(Map<String, dynamic> data) =>
      PrayerStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        sections: deserializeStructParam<PrayerSectionStruct>(
          data['sections'],
          ParamType.DataStruct,
          true,
          structBuilder: PrayerSectionStruct.fromSerializableMap,
        ),
        subtitle: deserializeParam(
          data['subtitle'],
          ParamType.String,
          false,
        ),
        sequence: deserializeParam(
          data['sequence'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'PrayerStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PrayerStruct &&
        id == other.id &&
        title == other.title &&
        listEquality.equals(sections, other.sections) &&
        subtitle == other.subtitle &&
        sequence == other.sequence;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, title, sections, subtitle, sequence]);
}

PrayerStruct createPrayerStruct({
  String? id,
  String? title,
  String? subtitle,
  int? sequence,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PrayerStruct(
      id: id,
      title: title,
      subtitle: subtitle,
      sequence: sequence,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PrayerStruct? updatePrayerStruct(
  PrayerStruct? prayer, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    prayer
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPrayerStructData(
  Map<String, dynamic> firestoreData,
  PrayerStruct? prayer,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (prayer == null) {
    return;
  }
  if (prayer.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && prayer.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final prayerData = getPrayerFirestoreData(prayer, forFieldValue);
  final nestedData = prayerData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = prayer.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPrayerFirestoreData(
  PrayerStruct? prayer, [
  bool forFieldValue = false,
]) {
  if (prayer == null) {
    return {};
  }
  final firestoreData = mapToFirestore(prayer.toMap());

  // Add any Firestore field values
  prayer.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPrayerListFirestoreData(
  List<PrayerStruct>? prayers,
) =>
    prayers?.map((e) => getPrayerFirestoreData(e, true)).toList() ?? [];
