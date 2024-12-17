// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChapterOptionStruct extends FFFirebaseStruct {
  ChapterOptionStruct({
    String? title,
    List<ChapterOptionStruct>? childOptions,
    int? index,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _childOptions = childOptions,
        _index = index,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "childOptions" field.
  List<ChapterOptionStruct>? _childOptions;
  List<ChapterOptionStruct> get childOptions => _childOptions ?? const [];
  set childOptions(List<ChapterOptionStruct>? val) => _childOptions = val;

  void updateChildOptions(Function(List<ChapterOptionStruct>) updateFn) {
    updateFn(_childOptions ??= []);
  }

  bool hasChildOptions() => _childOptions != null;

  // "index" field.
  int? _index;
  int get index => _index ?? 0;
  set index(int? val) => _index = val;

  void incrementIndex(int amount) => index = index + amount;

  bool hasIndex() => _index != null;

  static ChapterOptionStruct fromMap(Map<String, dynamic> data) =>
      ChapterOptionStruct(
        title: data['title'] as String?,
        childOptions: getStructList(
          data['childOptions'],
          ChapterOptionStruct.fromMap,
        ),
        index: castToType<int>(data['index']),
      );

  static ChapterOptionStruct? maybeFromMap(dynamic data) => data is Map
      ? ChapterOptionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'childOptions': _childOptions?.map((e) => e.toMap()).toList(),
        'index': _index,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'childOptions': serializeParam(
          _childOptions,
          ParamType.DataStruct,
          isList: true,
        ),
        'index': serializeParam(
          _index,
          ParamType.int,
        ),
      }.withoutNulls;

  static ChapterOptionStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChapterOptionStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        childOptions: deserializeStructParam<ChapterOptionStruct>(
          data['childOptions'],
          ParamType.DataStruct,
          true,
          structBuilder: ChapterOptionStruct.fromSerializableMap,
        ),
        index: deserializeParam(
          data['index'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'ChapterOptionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ChapterOptionStruct &&
        title == other.title &&
        listEquality.equals(childOptions, other.childOptions) &&
        index == other.index;
  }

  @override
  int get hashCode => const ListEquality().hash([title, childOptions, index]);
}

ChapterOptionStruct createChapterOptionStruct({
  String? title,
  int? index,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ChapterOptionStruct(
      title: title,
      index: index,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ChapterOptionStruct? updateChapterOptionStruct(
  ChapterOptionStruct? chapterOption, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    chapterOption
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addChapterOptionStructData(
  Map<String, dynamic> firestoreData,
  ChapterOptionStruct? chapterOption,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (chapterOption == null) {
    return;
  }
  if (chapterOption.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && chapterOption.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final chapterOptionData =
      getChapterOptionFirestoreData(chapterOption, forFieldValue);
  final nestedData =
      chapterOptionData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = chapterOption.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getChapterOptionFirestoreData(
  ChapterOptionStruct? chapterOption, [
  bool forFieldValue = false,
]) {
  if (chapterOption == null) {
    return {};
  }
  final firestoreData = mapToFirestore(chapterOption.toMap());

  // Add any Firestore field values
  chapterOption.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getChapterOptionListFirestoreData(
  List<ChapterOptionStruct>? chapterOptions,
) =>
    chapterOptions
        ?.map((e) => getChapterOptionFirestoreData(e, true))
        .toList() ??
    [];
