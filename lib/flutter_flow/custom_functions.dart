import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        if (section.sectionId.isNotEmpty) {
          flattenedList.add(PrayerSectionStruct(
              sectionId: section.sectionId,
              audioUrl: section.audioUrl,
              title: section.title,
              subtitle: section.subtitle,
              id: section.id));
        }

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
      var index = currentIndex++;
      return ChapterOptionStruct(
          title: section.title,
          childOptions: mapSectionToChapter(section.subsections),
          index: index);
    }).toList();
  }

  return mapSectionToChapter(sections);
}

String extractFileName(String? url) {
  if (url!.isEmpty) {
    return '';
  }

  final uri = Uri.parse(url!);
  return uri.pathSegments.last;
}

String sanitizeFilename(String input) {
  // Step 1: Replace accented characters with ASCII equivalents
  const accents = {
    'ă': 'a', 'â': 'a', 'î': 'i', 'ș': 's', 'ş': 's', 'ț': 't', 'ţ': 't',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'á': 'a', 'à': 'a', 'ä': 'a',
    'ó': 'o', 'ò': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c'
  };

  String txt = input;

  accents.forEach((from, to) {
    txt = txt.replaceAll(from, to);
    txt = txt.replaceAll(from.toUpperCase(), to.toUpperCase());
  });

  // Step 2: Replace forbidden characters
  txt = txt.replaceAll(RegExp(r"[<>:\/\\|?']"), "_");


  // Step 3: Remove commas
  txt = txt.replaceAll(',', '');

  // Step 4: Normalize whitespace
  txt = txt.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Step 5: Replace spaces with underscores
  txt = txt.replaceAll(' ', '_');

  return txt;
}


