// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrayerSectionStruct extends FFFirebaseStruct {
  PrayerSectionStruct({
    String? id,
    String? title,
    int? sequence,
    String? audioUrl,
    String? subtitle,
    List<PrayerSectionStruct>? subsections,
    String? sectionId,
    int? duration,
    String? imageUrl,
    List<SectionTextStruct>? texts,
    bool? showTitle,
    bool? showSubtitle,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _title = title,
        _sequence = sequence,
        _audioUrl = audioUrl,
        _subtitle = subtitle,
        _subsections = subsections,
        _sectionId = sectionId,
        _imageUrl = imageUrl,
        _texts = texts,
        _showTitle = showTitle,
        _showSubtitle = showSubtitle,
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

  // "showTitle" field.
  bool? _showTitle;
  bool get showTitle => _showTitle ?? false;
  set showTitle(bool? val) => _showTitle = val;

  // "showSubtitle" field.
  bool? _showSubtitle;
  bool get showSubtitle => _showSubtitle ?? false;
  set showSubtitle(bool? val) => _showSubtitle = val;

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

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  // "texts" field.
  List<SectionTextStruct>? _texts;
  List<SectionTextStruct> get texts => _texts ?? const [];
  set texts(List<SectionTextStruct>? val) => _texts = val;

  void updateTexts(Function(List<SectionTextStruct>) updateFn) {
    updateFn(_texts ??= []);
  }

  bool hasTexts() => _texts != null;

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
        duration: castToType<int>(data['duration']),
        imageUrl: data['image_url'] as String?,
        texts: getStructList(
          data['texts'],
          SectionTextStruct.fromMap,
        ),
        showTitle: castToType<bool>(data['show_title']),
        showSubtitle: castToType<bool>(data['show_subtitle']),
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
        'image_url': _imageUrl,
        'texts': _texts?.map((e) => e.toMap()).toList(),
        'show_title': _showTitle,
        'show_subtitle': _showSubtitle,
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
        'image_url': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'texts': serializeParam(
          _texts,
          ParamType.DataStruct,
          isList: true,
        ),
        'show_title': serializeParam(
          _showTitle,
          ParamType.bool,
        ),
        'show_subtitle': serializeParam(
          _showSubtitle,
          ParamType.bool,
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
        duration: deserializeParam(
          data['duration'],
          ParamType.int,
          false,
        ),
        imageUrl: deserializeParam(
          data['image_url'],
          ParamType.String,
          false,
        ),
        texts: deserializeStructParam<SectionTextStruct>(
          data['texts'],
          ParamType.DataStruct,
          true,
          structBuilder: SectionTextStruct.fromSerializableMap,
        ),
        showTitle: deserializeParam(
          data['show_title'],
          ParamType.bool,
          false,
        ),
        showSubtitle: deserializeParam(
          data['show_subtitle'],
          ParamType.bool,
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
        sectionId == other.sectionId &&
        imageUrl == other.imageUrl &&
        showTitle == other.showTitle &&
        showSubtitle == other.showSubtitle &&
        listEquality.equals(texts, other.texts);
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        title,
        sequence,
        audioUrl,
        subtitle,
        subsections,
        sectionId,
        imageUrl,
        texts,
        showTitle,
        showSubtitle,
      ]);
}

PrayerSectionStruct createPrayerSectionStruct({
  String? id,
  String? title,
  bool? showTitle,
  bool? showSubtitle,
  int? sequence,
  String? audioUrl,
  String? subtitle,
  String? sectionId,
  int? duration,
  String? imageUrl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PrayerSectionStruct(
      id: id,
      title: title,
      sequence: sequence,
      audioUrl: audioUrl,
      subtitle: subtitle,
      sectionId: sectionId,
      duration: duration,
      imageUrl: imageUrl,
      showSubtitle: showSubtitle,
      showTitle: showTitle,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PrayerSectionStruct? updatePrayerSectionStruct(
  PrayerSectionStruct? prayerSection, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    prayerSection
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPrayerSectionStructData(
  Map<String, dynamic> firestoreData,
  PrayerSectionStruct? prayerSection,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (prayerSection == null) {
    return;
  }
  if (prayerSection.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && prayerSection.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final prayerSectionData =
      getPrayerSectionFirestoreData(prayerSection, forFieldValue);
  final nestedData =
      prayerSectionData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = prayerSection.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPrayerSectionFirestoreData(
  PrayerSectionStruct? prayerSection, [
  bool forFieldValue = false,
]) {
  if (prayerSection == null) {
    return {};
  }
  final firestoreData = mapToFirestore(prayerSection.toMap());

  // Add any Firestore field values
  prayerSection.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPrayerSectionListFirestoreData(
  List<PrayerSectionStruct>? prayerSections,
) =>
    prayerSections
        ?.map((e) => getPrayerSectionFirestoreData(e, true))
        .toList() ??
    [];
