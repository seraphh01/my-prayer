// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SavedPrayerDataStruct extends FFFirebaseStruct {
  SavedPrayerDataStruct({
    PrayerStruct? prayer,
    int? page,
    int? audioTime,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _prayer = prayer,
        _page = page,
        _audioTime = audioTime,
        super(firestoreUtilData);

  // "prayer" field.
  PrayerStruct? _prayer;
  PrayerStruct? get prayer => _prayer;
  set prayer(PrayerStruct? val) => _prayer = val;

  void updatePrayer(Function(PrayerStruct) updateFn) {
    updateFn(_prayer ??= PrayerStruct());
  }

  bool hasPrayer() => _prayer != null;

  // "page" field.
  int? _page;
  int get page => _page ?? 0;
  set page(int? val) => _page = val;

  void incrementPage(int amount) => page = page + amount;

  bool hasPage() => _page != null;

  // "audioTime" field.
  int? _audioTime;
  int get audioTime => _audioTime ?? 0;
  set audioTime(int? val) => _audioTime = val;

  void incrementAudioTime(int amount) => audioTime = audioTime + amount;

  bool hasAudioTime() => _audioTime != null;

  static SavedPrayerDataStruct fromMap(Map<String, dynamic> data) =>
      SavedPrayerDataStruct(
        prayer: data['prayer'] is PrayerStruct
            ? data['prayer']
            : PrayerStruct.maybeFromMap(data['prayer']),
        page: castToType<int>(data['page']),
        audioTime: castToType<int>(data['audioTime']),
      );

  static SavedPrayerDataStruct? maybeFromMap(dynamic data) => data is Map
      ? SavedPrayerDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'prayer': _prayer?.toMap(),
        'page': _page,
        'audioTime': _audioTime,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'prayer': serializeParam(
          _prayer,
          ParamType.DataStruct,
        ),
        'page': serializeParam(
          _page,
          ParamType.int,
        ),
        'audioTime': serializeParam(
          _audioTime,
          ParamType.int,
        ),
      }.withoutNulls;

  static SavedPrayerDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      SavedPrayerDataStruct(
        prayer: deserializeStructParam(
          data['prayer'],
          ParamType.DataStruct,
          false,
          structBuilder: PrayerStruct.fromSerializableMap,
        ),
        page: deserializeParam(
          data['page'],
          ParamType.int,
        ),
        audioTime: deserializeParam(
          data['audioTime'],
          ParamType.int,
        ),
      );

  @override
  String toString() => 'SavedPrayerDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SavedPrayerDataStruct &&
        prayer == other.prayer &&
        page == other.page &&
        audioTime == other.audioTime;
  }

  @override
  int get hashCode => const ListEquality().hash([prayer, page, audioTime]);
}

SavedPrayerDataStruct createSavedPrayerDataStruct({
  PrayerStruct? prayer,
  int? page,
  int? audioTime,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SavedPrayerDataStruct(
      prayer: prayer ?? (clearUnsetFields ? PrayerStruct() : null),
      page: page,
      audioTime: audioTime,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SavedPrayerDataStruct? updateSavedPrayerDataStruct(
  SavedPrayerDataStruct? savedPrayerData, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    savedPrayerData
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSavedPrayerDataStructData(
  Map<String, dynamic> firestoreData,
  SavedPrayerDataStruct? savedPrayerData,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (savedPrayerData == null) {
    return;
  }
  if (savedPrayerData.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && savedPrayerData.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final savedPrayerDataData =
      getSavedPrayerDataFirestoreData(savedPrayerData, forFieldValue);
  final nestedData =
      savedPrayerDataData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = savedPrayerData.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSavedPrayerDataFirestoreData(
  SavedPrayerDataStruct? savedPrayerData, [
  bool forFieldValue = false,
]) {
  if (savedPrayerData == null) {
    return {};
  }
  final firestoreData = mapToFirestore(savedPrayerData.toMap());

  // Handle nested data for "prayer" field.
  addPrayerStructData(
    firestoreData,
    savedPrayerData.hasPrayer() ? savedPrayerData.prayer : null,
    'prayer',
    forFieldValue,
  );

  // Add any Firestore field values
  savedPrayerData.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSavedPrayerDataListFirestoreData(
  List<SavedPrayerDataStruct>? savedPrayerDatas,
) =>
    savedPrayerDatas
        ?.map((e) => getSavedPrayerDataFirestoreData(e, true))
        .toList() ??
    [];
