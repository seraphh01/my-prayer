// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrayerTypeStruct extends FFFirebaseStruct {
  PrayerTypeStruct({
    int? id,
    String? type,
    int? sequence,
    List<PrayerTypeStruct>? subtypes,
    List<PrayerStruct>? prayers,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _type = type,
        _sequence = sequence,
        _subtypes = subtypes,
        _prayers = prayers,
        super(firestoreUtilData);

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "sequence" field.
  int? _sequence;
  int get sequence => _sequence ?? 0;
  set sequence(int? val) => _sequence = val;

  void incrementSequence(int amount) => sequence = sequence + amount;

  bool hasSequence() => _sequence != null;

  // "subtypes" field.
  List<PrayerTypeStruct>? _subtypes;
  List<PrayerTypeStruct> get subtypes => _subtypes ?? const [];
  set subtypes(List<PrayerTypeStruct>? val) => _subtypes = val;

  void updateSubtypes(Function(List<PrayerTypeStruct>) updateFn) {
    updateFn(_subtypes ??= []);
  }

  bool hasSubtypes() => _subtypes != null;

  // "prayers" field.
  List<PrayerStruct>? _prayers;
  List<PrayerStruct> get prayers => _prayers ?? const [];
  set prayers(List<PrayerStruct>? val) => _prayers = val;

  void updatePrayers(Function(List<PrayerStruct>) updateFn) {
    updateFn(_prayers ??= []);
  }

  bool hasPrayers() => _prayers != null;

  static PrayerTypeStruct fromMap(Map<String, dynamic> data) =>
      PrayerTypeStruct(
        id: castToType<int>(data['id']),
        type: data['type'] as String?,
        sequence: castToType<int>(data['sequence']),
        subtypes: getStructList(
          data['subtypes'],
          PrayerTypeStruct.fromMap,
        ),
        prayers: getStructList(
          data['prayers'],
          PrayerStruct.fromMap,
        ),
      );

  static PrayerTypeStruct? maybeFromMap(dynamic data) => data is Map
      ? PrayerTypeStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'type': _type,
        'sequence': _sequence,
        'subtypes': _subtypes?.map((e) => e.toMap()).toList(),
        'prayers': _prayers?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'sequence': serializeParam(
          _sequence,
          ParamType.int,
        ),
        'subtypes': serializeParam(
          _subtypes,
          ParamType.DataStruct,
          isList: true,
        ),
        'prayers': serializeParam(
          _prayers,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static PrayerTypeStruct fromSerializableMap(Map<String, dynamic> data) =>
      PrayerTypeStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        sequence: deserializeParam(
          data['sequence'],
          ParamType.int,
          false,
        ),
        subtypes: deserializeStructParam<PrayerTypeStruct>(
          data['subtypes'],
          ParamType.DataStruct,
          true,
          structBuilder: PrayerTypeStruct.fromSerializableMap,
        ),
        prayers: deserializeStructParam<PrayerStruct>(
          data['prayers'],
          ParamType.DataStruct,
          true,
          structBuilder: PrayerStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'PrayerTypeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PrayerTypeStruct &&
        id == other.id &&
        type == other.type &&
        sequence == other.sequence &&
        listEquality.equals(subtypes, other.subtypes) &&
        listEquality.equals(prayers, other.prayers);
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, type, sequence, subtypes, prayers]);
}

PrayerTypeStruct createPrayerTypeStruct({
  int? id,
  String? type,
  int? sequence,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PrayerTypeStruct(
      id: id,
      type: type,
      sequence: sequence,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PrayerTypeStruct? updatePrayerTypeStruct(
  PrayerTypeStruct? prayerType, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    prayerType
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPrayerTypeStructData(
  Map<String, dynamic> firestoreData,
  PrayerTypeStruct? prayerType,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (prayerType == null) {
    return;
  }
  if (prayerType.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && prayerType.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final prayerTypeData = getPrayerTypeFirestoreData(prayerType, forFieldValue);
  final nestedData = prayerTypeData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = prayerType.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPrayerTypeFirestoreData(
  PrayerTypeStruct? prayerType, [
  bool forFieldValue = false,
]) {
  if (prayerType == null) {
    return {};
  }
  final firestoreData = mapToFirestore(prayerType.toMap());

  // Add any Firestore field values
  prayerType.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPrayerTypeListFirestoreData(
  List<PrayerTypeStruct>? prayerTypes,
) =>
    prayerTypes?.map((e) => getPrayerTypeFirestoreData(e, true)).toList() ?? [];
