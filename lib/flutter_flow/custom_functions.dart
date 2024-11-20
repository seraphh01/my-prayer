import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

double sum(
  double? element1,
  double? element2,
) {
  return (element1 ?? 0) + (element2 ?? 0);
}

double multiply(
  double? first,
  double? second,
) {
  return (first ?? 1) * (second ?? 1);
}

int doubleToInt(double? number) {
  return (number ?? 0).floor();
}

List<PrayerSectionStruct>? flattenSectionsList(
    List<PrayerSectionStruct> sections) {
  List<PrayerSectionStruct> flattenedList = [];

  void collectLeaves(List<PrayerSectionStruct> sections) {
    for (var section in sections) {
      if (section.subsections.isEmpty) {
        flattenedList.add(section); // Add leaf node
      } else {
        collectLeaves(section.subsections); // Recurse into subsections
      }
    }
  }

  collectLeaves(sections);
  return flattenedList;
}

List<ChapterOptionStruct> convertPrayerSectionToChapterOption(
    List<PrayerSectionStruct> sections) {
  int currentIndex = 0;

  List<ChapterOptionStruct> mapSectionToChapter(
      List<PrayerSectionStruct> sections) {
    return sections.map((section) {
      return ChapterOptionStruct(
          title: section.title,
          childOptions: mapSectionToChapter(section.subsections),
          index: currentIndex++);
    }).toList();
  }

  return mapSectionToChapter(sections);
}
