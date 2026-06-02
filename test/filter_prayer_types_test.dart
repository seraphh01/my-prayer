import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/calendar/filter_prayer_types.dart';

void main() {
  test('preserves nested subtypes that contain allowed prayers', () {
    final catalog = [
      PrayerTypeStruct(
        id: 1,
        type: 'Slujba Vecerniei',
        sequence: 1,
        subtypes: [
          PrayerTypeStruct(
            id: 2,
            type: 'Vecernia Mare',
            sequence: 1,
            prayers: [
              PrayerStruct(id: 'a', title: 'Vecernia Mare', subtitle: 'Glasul 1'),
              PrayerStruct(id: 'b', title: 'Vecernia Mare', subtitle: 'Glasul 2'),
            ],
          ),
          PrayerTypeStruct(
            id: 3,
            type: 'Altele',
            sequence: 2,
            prayers: [
              PrayerStruct(id: 'c', title: 'Other', subtitle: 'X'),
            ],
          ),
        ],
      ),
    ];

    final filtered = filterPrayerTypesForCalendar(catalog, {'a', 'c'});

    expect(filtered, hasLength(1));
    expect(filtered.first.type, 'Slujba Vecerniei');
    expect(filtered.first.subtypes, hasLength(2));
    expect(filtered.first.subtypes[0].prayers.map((p) => p.id), ['a']);
    expect(filtered.first.subtypes[1].prayers.map((p) => p.id), ['c']);
  });
}
