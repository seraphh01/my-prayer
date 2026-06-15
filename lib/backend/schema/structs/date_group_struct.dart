// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DateGroupStruct extends FFFirebaseStruct {
  DateGroupStruct({
    String? name,
    String? description,
    int? hour,
    List<PrayerStruct>? prayers,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _description = description,
        _hour = hour,
        _prayers = prayers,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  // "hour" field.
  int? _hour;
  int? get hour => _hour;
  set hour(int? val) => _hour = val;

  bool hasHour() => _hour != null;

  // "prayers" field.
  List<PrayerStruct>? _prayers;
  List<PrayerStruct> get prayers => _prayers ?? const [];
  set prayers(List<PrayerStruct>? val) => _prayers = val;

  void updatePrayers(Function(List<PrayerStruct>) updateFn) {
    updateFn(_prayers ??= []);
  }

  bool hasPrayers() => _prayers != null;

  static DateGroupStruct fromMap(Map<String, dynamic> data) => DateGroupStruct(
        name: data['name'] as String?,
        description: data['description'] as String?,
        hour: castToType<int>(data['hour']),
        prayers: getStructList(
          data['prayers'],
          PrayerStruct.fromMap,
        ),
      );

  static DateGroupStruct? maybeFromMap(dynamic data) => data is Map
      ? DateGroupStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'description': _description,
        'hour': _hour,
        'prayers': _prayers?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
        'hour': serializeParam(
          _hour,
          ParamType.int,
        ),
        'prayers': serializeParam(
          _prayers,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static DateGroupStruct fromSerializableMap(Map<String, dynamic> data) =>
      DateGroupStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
        ),
        hour: deserializeParam(
          data['hour'],
          ParamType.int,
        ),
        prayers: deserializeStructParam<PrayerStruct>(
          data['prayers'],
          ParamType.DataStruct,
          true,
          structBuilder: PrayerStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'DateGroupStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is DateGroupStruct &&
        name == other.name &&
        description == other.description &&
        hour == other.hour &&
        listEquality.equals(prayers, other.prayers);
  }

  @override
  int get hashCode =>
      const ListEquality().hash([name, description, hour, prayers]);
}

DateGroupStruct createDateGroupStruct({
  String? name,
  String? description,
  int? hour,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    DateGroupStruct(
      name: name,
      description: description,
      hour: hour,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

DateGroupStruct? updateDateGroupStruct(
  DateGroupStruct? dateGroup, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    dateGroup
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDateGroupStructData(
  Map<String, dynamic> firestoreData,
  DateGroupStruct? dateGroup,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (dateGroup == null) {
    return;
  }
  if (dateGroup.firestoreUtilData.delete) {
    firestoreData[fieldName] = fieldDeleteSentinel;
    return;
  }
  final clearFields =
      !forFieldValue && dateGroup.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final dateGroupData = getDateGroupFirestoreData(dateGroup, forFieldValue);
  final nestedData = dateGroupData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = dateGroup.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDateGroupFirestoreData(
  DateGroupStruct? dateGroup, [
  bool forFieldValue = false,
]) {
  if (dateGroup == null) {
    return {};
  }
  final firestoreData = mapToFirestore(dateGroup.toMap());

  // Add any Firestore field values
  dateGroup.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDateGroupListFirestoreData(
  List<DateGroupStruct>? dateGroups,
) =>
    dateGroups?.map((e) => getDateGroupFirestoreData(e, true)).toList() ?? [];
