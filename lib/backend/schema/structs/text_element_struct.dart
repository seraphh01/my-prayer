// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TextElementStruct extends BaseStruct {
  TextElementStruct({
    String? text,
    int? sequence,
    double? startTime,
    double? endTime,
  })  : _text = text,
        _sequence = sequence,
        _startTime = startTime,
        _endTime = endTime;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  // "sequence" field.
  int? _sequence;
  int get sequence => _sequence ?? 0;
  set sequence(int? val) => _sequence = val;

  void incrementSequence(int amount) => sequence = sequence + amount;

  bool hasSequence() => _sequence != null;

  // "start_time" field.
  double? _startTime;
  double get startTime => _startTime ?? 0.0;
  set startTime(double? val) => _startTime = val;

  void incrementStartTime(double amount) => startTime = startTime + amount;

  bool hasStartTime() => _startTime != null;

  // "end_time" field.
  double? _endTime;
  double get endTime => _endTime ?? 0.0;
  set endTime(double? val) => _endTime = val;

  void incrementEndTime(double amount) => endTime = endTime + amount;

  bool hasEndTime() => _endTime != null;

  static TextElementStruct fromMap(Map<String, dynamic> data) =>
      TextElementStruct(
        text: data['text'] as String?,
        sequence: castToType<int>(data['sequence']),
        startTime: castToType<double>(data['start_time']),
        endTime: castToType<double>(data['end_time']),
      );

  static TextElementStruct? maybeFromMap(dynamic data) => data is Map
      ? TextElementStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'text': _text,
        'sequence': _sequence,
        'start_time': _startTime,
        'end_time': _endTime,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'sequence': serializeParam(
          _sequence,
          ParamType.int,
        ),
        'start_time': serializeParam(
          _startTime,
          ParamType.double,
        ),
        'end_time': serializeParam(
          _endTime,
          ParamType.double,
        ),
      }.withoutNulls;

  static TextElementStruct fromSerializableMap(Map<String, dynamic> data) =>
      TextElementStruct(
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        sequence: deserializeParam(
          data['sequence'],
          ParamType.int,
          false,
        ),
        startTime: deserializeParam(
          data['start_time'],
          ParamType.double,
          false,
        ),
        endTime: deserializeParam(
          data['end_time'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'TextElementStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TextElementStruct &&
        text == other.text &&
        sequence == other.sequence &&
        startTime == other.startTime &&
        endTime == other.endTime;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([text, sequence, startTime, endTime]);
}

TextElementStruct createTextElementStruct({
  String? text,
  int? sequence,
  double? startTime,
  double? endTime,
}) =>
    TextElementStruct(
      text: text,
      sequence: sequence,
      startTime: startTime,
      endTime: endTime,
    );
