import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/calendar/merge_date_groups.dart';

void main() {
  test('merges groups with the same name and deduplicates prayers by id', () {
    final merged = mergeSimilarDateGroups([
      DateGroupStruct(
        name: 'Dimineața',
        prayers: [
          PrayerStruct(id: 'a', title: 'Prayer A', sequence: 1),
          PrayerStruct(id: 'b', title: 'Prayer B', sequence: 2),
        ],
      ),
      DateGroupStruct(
        name: 'Dimineața',
        prayers: [
          PrayerStruct(id: 'b', title: 'Prayer B duplicate', sequence: 5),
          PrayerStruct(id: 'c', title: 'Prayer C', sequence: 3),
        ],
      ),
    ]);

    expect(merged, hasLength(1));
    expect(merged.first.name, 'Dimineața');
    expect(merged.first.prayers.map((p) => p.id), ['a', 'b', 'c']);
  });

  test('merges hour groups with the same name for calendar display', () {
    final merged = mergeSimilarDateGroups([
      DateGroupStruct(
        name: 'Pentru momentul zilei',
        hour: 6,
        prayers: [PrayerStruct(id: 'a', title: 'A', sequence: 1)],
      ),
      DateGroupStruct(
        name: 'Pentru momentul zilei',
        hour: 9,
        prayers: [PrayerStruct(id: 'b', title: 'B', sequence: 1)],
      ),
    ]);

    expect(merged, hasLength(1));
    expect(merged.first.prayers.map((p) => p.id), ['a', 'b']);
  });
}
