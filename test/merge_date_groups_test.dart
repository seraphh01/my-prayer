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
    expect(merged.first.prayers.firstWhere((p) => p.id == 'b').sequence, 2);
  });

  test('keeps distinct groups when names differ', () {
    final merged = mergeSimilarDateGroups([
      DateGroupStruct(
        name: 'Dimineața',
        prayers: [PrayerStruct(id: 'a', title: 'A', sequence: 1)],
      ),
      DateGroupStruct(
        name: 'Seara',
        prayers: [PrayerStruct(id: 'b', title: 'B', sequence: 1)],
      ),
    ]);

    expect(merged, hasLength(2));
  });

  test('groups prayers with the same title for calendar display', () {
    final groups = groupPrayersByTitle([
      PrayerStruct(
        id: '1',
        title: 'Orele Canonice - Luni',
        subtitle: 'Ora I',
        sequence: 2,
      ),
      PrayerStruct(
        id: '2',
        title: 'Orele Canonice - Luni',
        subtitle: 'Ora a III-a',
        sequence: 3,
      ),
      PrayerStruct(
        id: '3',
        title: 'Vecernia',
        subtitle: 'Luni',
        sequence: 1,
      ),
    ]);

    expect(groups, hasLength(2));
    expect(groups.first.title, 'Vecernia');
    expect(groups[1].title, 'Orele Canonice - Luni');
    expect(groups[1].prayers, hasLength(2));
  });
}
