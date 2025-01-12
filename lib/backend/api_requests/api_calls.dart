import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start Suapabase Queries Group Code

class SuapabaseQueriesGroup {
  static String getBaseUrl() =>
      'https://nrapqjwyqvwopwoxevlw.supabase.co/rest/v1/rpc';
  static Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
  };
  static GetPrayerTypesCall getPrayerTypesCall = GetPrayerTypesCall();
  static GetPrayerWithSectionsRecursiveCall getPrayerWithSectionsRecursiveCall =
      GetPrayerWithSectionsRecursiveCall();
  static GetPrayersByDateGroupsCall getPrayersByDateGroupsCall =
      GetPrayersByDateGroupsCall();
}

class GetPrayerTypesCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = SuapabaseQueriesGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Prayer Types',
      apiUrl: '$baseUrl/get_prayer_types',
      callType: ApiCallType.GET,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPrayerWithSectionsRecursiveCall {
  Future<ApiCallResponse> call({
    String? requestPrayerId = 'f4a69874-20b2-49f2-9fec-aaa764efddb6',
  }) async {
    final baseUrl = SuapabaseQueriesGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get prayer with sections recursive',
      apiUrl: '$baseUrl/get_prayer_with_sections_recursive',
      callType: ApiCallType.GET,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
      },
      params: {
        'request_prayer_id': requestPrayerId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPrayersByDateGroupsCall {
  Future<ApiCallResponse> call({
    int? dayOfWeek = -1,
    String? specificDate = 'null',
    int? month = -1,
    int? day = -1,
    int? hour = -1,
  }) async {
    final baseUrl = SuapabaseQueriesGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Prayers By Date Groups',
      apiUrl: '$baseUrl/get_prayers_by_date_groups',
      callType: ApiCallType.GET,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
      },
      params: {
        'day_of_week_param': dayOfWeek,
        'specific_date_param': specificDate,
        'month_param': month,
        'day_param': day,
        'hour_param': hour,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End Suapabase Queries Group Code

class PrayerSectionContentCall {
  static Future<ApiCallResponse> call({
    String? prayerSectionId = '916e5a38-55b3-44b8-8027-def2b4a00128',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'PrayerSectionContent',
      apiUrl:
          'https://nrapqjwyqvwopwoxevlw.supabase.co/rest/v1/rpc/get_prayer_section_structure',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yYXBxand5cXZ3b3B3b3hldmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA4MDU2MzQsImV4cCI6MjA0NjM4MTYzNH0.hq-X6YEAD7DG9WIiJhqwRb3ZtMruaEzAbr0Wm4TBoQU',
        'Content-Type': 'application/json',
      },
      params: {
        'request_section_id': prayerSectionId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? prayerSectionId(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.prayer_section_id''',
      ));
  static List? texts(dynamic response) => getJsonField(
        response,
        r'''$.texts''',
        true,
      ) as List?;
  static List<String>? textTitle(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].title''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? textSequence(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].sequence''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? textRepetition(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].repetition''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List? textElements(dynamic response) => getJsonField(
        response,
        r'''$.texts[:].text_elements''',
        true,
      ) as List?;
  static String? audioUrl(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.audio_url''',
      ));
  static String? sectionTitle(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.section_title''',
      ));
  static List<String>? textElementText(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].text_elements[:].text''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? textElementSequence(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].text_elements[:].sequence''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? textEndTime(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].end_time''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? textStartTime(dynamic response) => (getJsonField(
        response,
        r'''$.texts[:].start_time''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
