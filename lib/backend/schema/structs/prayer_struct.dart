// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrayerStruct extends BaseStruct {
  PrayerStruct({
    String? id,
    String? title,
    List<PrayerSectionStruct>? sections,
    String? subtitle,
  })  : _id = id,
        _title = title,
        _sections = sections,
        _subtitle = subtitle;

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

  static PrayerStruct fromMap(Map<String, dynamic> data) => PrayerStruct(
        id: data['id'] as String?,
        title: data['title'] as String?,
        sections: getStructList(
          data['sections'],
          PrayerSectionStruct.fromMap,
        ),
        subtitle: data['subtitle'] as String?,
      );

  static PrayerStruct? maybeFromMap(dynamic data) =>
      data is Map ? PrayerStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'title': _title,
        'sections': _sections?.map((e) => e.toMap()).toList(),
        'subtitle': _subtitle,
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
        subtitle == other.subtitle;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, title, sections, subtitle]);
}

PrayerStruct createPrayerStruct({
  String? id,
  String? title,
  String? subtitle,
}) =>
    PrayerStruct(
      id: id,
      title: title,
      subtitle: subtitle,
    );
