// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrayerSectionStruct extends BaseStruct {
  PrayerSectionStruct({
    String? id,
    String? title,
    int? sequence,
    String? audioUrl,
    String? subtitle,
    List<PrayerSectionStruct>? subsections,
    String? sectionId,
  })  : _id = id,
        _title = title,
        _sequence = sequence,
        _audioUrl = audioUrl,
        _subtitle = subtitle,
        _subsections = subsections,
        _sectionId = sectionId;

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

  // "sequence" field.
  int? _sequence;
  int get sequence => _sequence ?? 0;
  set sequence(int? val) => _sequence = val;

  void incrementSequence(int amount) => sequence = sequence + amount;

  bool hasSequence() => _sequence != null;

  // "audio_url" field.
  String? _audioUrl;
  String get audioUrl => _audioUrl ?? '';
  set audioUrl(String? val) => _audioUrl = val;

  bool hasAudioUrl() => _audioUrl != null;

  // "subtitle" field.
  String? _subtitle;
  String get subtitle => _subtitle ?? '';
  set subtitle(String? val) => _subtitle = val;

  bool hasSubtitle() => _subtitle != null;

  // "subsections" field.
  List<PrayerSectionStruct>? _subsections;
  List<PrayerSectionStruct> get subsections => _subsections ?? const [];
  set subsections(List<PrayerSectionStruct>? val) => _subsections = val;

  void updateSubsections(Function(List<PrayerSectionStruct>) updateFn) {
    updateFn(_subsections ??= []);
  }

  bool hasSubsections() => _subsections != null;

  // "section_id" field.
  String? _sectionId;
  String get sectionId => _sectionId ?? '';
  set sectionId(String? val) => _sectionId = val;

  bool hasSectionId() => _sectionId != null;

  static PrayerSectionStruct fromMap(Map<String, dynamic> data) =>
      PrayerSectionStruct(
        id: data['id'] as String?,
        title: data['title'] as String?,
        sequence: castToType<int>(data['sequence']),
        audioUrl: data['audio_url'] as String?,
        subtitle: data['subtitle'] as String?,
        subsections: getStructList(
          data['subsections'],
          PrayerSectionStruct.fromMap,
        ),
        sectionId: data['section_id'] as String?,
      );

  static PrayerSectionStruct? maybeFromMap(dynamic data) => data is Map
      ? PrayerSectionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'title': _title,
        'sequence': _sequence,
        'audio_url': _audioUrl,
        'subtitle': _subtitle,
        'subsections': _subsections?.map((e) => e.toMap()).toList(),
        'section_id': _sectionId,
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
        'sequence': serializeParam(
          _sequence,
          ParamType.int,
        ),
        'audio_url': serializeParam(
          _audioUrl,
          ParamType.String,
        ),
        'subtitle': serializeParam(
          _subtitle,
          ParamType.String,
        ),
        'subsections': serializeParam(
          _subsections,
          ParamType.DataStruct,
          isList: true,
        ),
        'section_id': serializeParam(
          _sectionId,
          ParamType.String,
        ),
      }.withoutNulls;

  static PrayerSectionStruct fromSerializableMap(Map<String, dynamic> data) =>
      PrayerSectionStruct(
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
        sequence: deserializeParam(
          data['sequence'],
          ParamType.int,
          false,
        ),
        audioUrl: deserializeParam(
          data['audio_url'],
          ParamType.String,
          false,
        ),
        subtitle: deserializeParam(
          data['subtitle'],
          ParamType.String,
          false,
        ),
        subsections: deserializeStructParam<PrayerSectionStruct>(
          data['subsections'],
          ParamType.DataStruct,
          true,
          structBuilder: PrayerSectionStruct.fromSerializableMap,
        ),
        sectionId: deserializeParam(
          data['section_id'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PrayerSectionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PrayerSectionStruct &&
        id == other.id &&
        title == other.title &&
        sequence == other.sequence &&
        audioUrl == other.audioUrl &&
        subtitle == other.subtitle &&
        listEquality.equals(subsections, other.subsections) &&
        sectionId == other.sectionId;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([id, title, sequence, audioUrl, subtitle, subsections, sectionId]);
}

PrayerSectionStruct createPrayerSectionStruct({
  String? id,
  String? title,
  int? sequence,
  String? audioUrl,
  String? subtitle,
  String? sectionId,
}) =>
    PrayerSectionStruct(
      id: id,
      title: title,
      sequence: sequence,
      audioUrl: audioUrl,
      subtitle: subtitle,
      sectionId: sectionId,
    );
