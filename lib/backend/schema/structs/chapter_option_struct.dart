// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChapterOptionStruct extends BaseStruct {
  ChapterOptionStruct({
    String? title,
    List<ChapterOptionStruct>? childOptions,
    int? index,
  })  : _title = title,
        _childOptions = childOptions,
        _index = index;

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
}) =>
    ChapterOptionStruct(
      title: title,
      index: index,
    );
