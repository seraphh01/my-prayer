import 'dart:convert';

import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';

/// SERIALIZATION HELPERS

String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  final startStr = dateTimeRange.start.millisecondsSinceEpoch.toString();
  final endStr = dateTimeRange.end.millisecondsSinceEpoch.toString();
  return '$startStr|$endStr';
}

String placeToString(FFPlace place) => jsonEncode({
      'latLng': place.latLng.serialize(),
      'name': place.name,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'country': place.country,
      'zipCode': place.zipCode,
    });

String uploadedFileToString(FFUploadedFile uploadedFile) =>
    uploadedFile.serialize();

dynamic serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  if (param == null) return null;

  if (isList) {
    final serializedValues = (param as Iterable)
        .map((p) => serializeParam(p, paramType, isList: false))
        .where((p) => p != null)
        .toList();
    return serializedValues;
  }

  switch (paramType) {
    case ParamType.int:
    case ParamType.double:
    case ParamType.String:
    case ParamType.bool:
      return param;
    case ParamType.DateTime:
      return (param as DateTime).millisecondsSinceEpoch;
    case ParamType.DateTimeRange:
      return dateTimeRangeToString(param as DateTimeRange);
    case ParamType.LatLng:
      return (param as LatLng).serialize();
    case ParamType.Color:
      return (param as Color).toCssString();
    case ParamType.FFPlace:
      return placeToString(param as FFPlace);
    case ParamType.FFUploadedFile:
      return uploadedFileToString(param as FFUploadedFile);
    case ParamType.JSON:
      return param; // return Map/List directly
    case ParamType.DataStruct:
      return (param is BaseStruct) ? param.serialize() : null; // Map
    case ParamType.Enum:
      return (param is Enum) ? param.serialize() : null;
    case ParamType.SupabaseRow:
      return (param as SupabaseDataRow).data; // Map
    default:
      return null;
  }
}


/// END SERIALIZATION HELPERS

/// DESERIALIZATION HELPERS

DateTimeRange? dateTimeRangeFromString(String dateTimeRangeStr) {
  final pieces = dateTimeRangeStr.split('|');
  if (pieces.length != 2) {
    return null;
  }
  return DateTimeRange(
    start: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.first)),
    end: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.last)),
  );
}

LatLng? latLngFromString(String? latLngStr) {
  final pieces = latLngStr?.split(',');
  if (pieces == null || pieces.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(pieces.first.trim()),
    double.parse(pieces.last.trim()),
  );
}

FFPlace placeFromString(String placeStr) {
  final serializedData = jsonDecode(placeStr) as Map<String, dynamic>;
  final data = {
    'latLng': serializedData.containsKey('latLng')
        ? latLngFromString(serializedData['latLng'] as String)
        : const LatLng(0.0, 0.0),
    'name': serializedData['name'] ?? '',
    'address': serializedData['address'] ?? '',
    'city': serializedData['city'] ?? '',
    'state': serializedData['state'] ?? '',
    'country': serializedData['country'] ?? '',
    'zipCode': serializedData['zipCode'] ?? '',
  };
  return FFPlace(
    latLng: data['latLng'] as LatLng,
    name: data['name'] as String,
    address: data['address'] as String,
    city: data['city'] as String,
    state: data['state'] as String,
    country: data['country'] as String,
    zipCode: data['zipCode'] as String,
  );
}

FFUploadedFile uploadedFileFromString(String uploadedFileStr) =>
    FFUploadedFile.deserialize(uploadedFileStr);

enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,
  DataStruct,
  Enum,
  SupabaseRow,
}

dynamic deserializeParam<T>(
  dynamic param,
  ParamType paramType,{
  bool isList = false, 
  List<String>? collectionNamePath,
  StructBuilder<T>? structBuilder,
}) {
  if (param == null) return null;

  if (isList) {
    if (param is! Iterable) return null;
    return param
        .map((p) => deserializeParam<T>(
              p,
              paramType,
              isList: false,
              collectionNamePath: collectionNamePath,
              structBuilder: structBuilder,
            ))
        .where((p) => p != null)
        .map((p) => p! as T)
        .toList();
  }

  switch (paramType) {
    case ParamType.int:
      return param is int ? param : int.tryParse(param.toString());
    case ParamType.double:
      return param is double ? param : double.tryParse(param.toString());
    case ParamType.String:
      return param.toString();
    case ParamType.bool:
      if (param is bool) return param;
      return param.toString() == 'true';
    case ParamType.DateTime:
      if (param is int) return DateTime.fromMillisecondsSinceEpoch(param);
      final ms = int.tryParse(param.toString());
      return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
    case ParamType.DateTimeRange:
      return dateTimeRangeFromString(param.toString());
    case ParamType.LatLng:
      return latLngFromString(param.toString());
    case ParamType.Color:
      return fromCssColor(param.toString());
    case ParamType.FFPlace:
      return placeFromString(param.toString());
    case ParamType.FFUploadedFile:
      return uploadedFileFromString(param.toString());
    case ParamType.JSON:
      return param; // Map/List already
    case ParamType.SupabaseRow:
      if (param is Map<String, dynamic>) {
        switch (T) {
          case TextElementsRow:
            return TextElementsRow(param);
          case LiturgicalTextsRow:
            return LiturgicalTextsRow(param);
          case PrayerTypeRow:
            return PrayerTypeRow(param);
          case PrayersSectionsRow:
            return PrayersSectionsRow(param);
          case LiturgicalTextsWithElementsRow:
            return LiturgicalTextsWithElementsRow(param);
          case SectionsRow:
            return SectionsRow(param);
          case PrayersRow:
            return PrayersRow(param);
          case SectionTextsRow:
            return SectionTextsRow(param);
          default:
            return null;
        }
      }
      return null;
    case ParamType.DataStruct:
      if (param is Map<String, dynamic>) {
        return structBuilder != null ? structBuilder(param) : null;
      }
      return null;
    case ParamType.Enum:
      return deserializeEnum<T>(param.toString());
    default:
      return null;
  }
}

