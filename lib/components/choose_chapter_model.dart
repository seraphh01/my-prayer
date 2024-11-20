import '/backend/schema/structs/index.dart';
import '/components/chapter_options_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'choose_chapter_widget.dart' show ChooseChapterWidget;
import 'package:flutter/material.dart';

class ChooseChapterModel extends FlutterFlowModel<ChooseChapterWidget> {
  ///  Local state fields for this component.

  List<ChapterOptionStruct> chapterOptions = [];
  void addToChapterOptions(ChapterOptionStruct item) =>
      chapterOptions.add(item);
  void removeFromChapterOptions(ChapterOptionStruct item) =>
      chapterOptions.remove(item);
  void removeAtIndexFromChapterOptions(int index) =>
      chapterOptions.removeAt(index);
  void insertAtIndexInChapterOptions(int index, ChapterOptionStruct item) =>
      chapterOptions.insert(index, item);
  void updateChapterOptionsAtIndex(
          int index, Function(ChapterOptionStruct) updateFn) =>
      chapterOptions[index] = updateFn(chapterOptions[index]);

  ///  State fields for stateful widgets in this component.

  // Model for ChapterOptionsView component.
  ChapterOptionsViewModel? _chapterOptionsViewModel;
  ChapterOptionsViewModel get chapterOptionsViewModel =>
      _chapterOptionsViewModel ??= ChapterOptionsViewModel();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    chapterOptionsViewModel.dispose();
  }
}
