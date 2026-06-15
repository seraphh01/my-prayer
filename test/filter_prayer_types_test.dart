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

  test('resolveTodayPrayerType skips single-subtype wrappers', () {
    final catalog = [
      PrayerTypeStruct(
        id: 1,
        type: 'Slujba zilei',
        sequence: 1,
        subtypes: [
          PrayerTypeStruct(
            id: 2,
            type: 'Ora a IX-a',
            sequence: 1,
            prayers: [
              PrayerStruct(id: 'v1', title: 'Ora a IX-a', subtitle: 'Variant 1'),
              PrayerStruct(id: 'v2', title: 'Ora a IX-a', subtitle: 'Variant 2'),
            ],
          ),
        ],
      ),
    ];

    final resolved = resolveTodayPrayerType(
      catalog,
      catalog.first.subtypes.first.prayers,
    );

    expect(resolved, isNotNull);
    expect(resolved!.displayLabel, 'Slujba zilei - Ora a IX-a');
    expect(resolved.cardTitle, 'Slujba zilei');
    expect(resolved.cardSubtitle, 'Ora a IX-a');
    expect(resolved.entryType.id, 2);
    expect(resolved.entryType.type, 'Ora a IX-a');
  });

  test('resolveTodayPrayerType keeps parent when filtered tree has multiple subtypes', () {
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
            prayers: [PrayerStruct(id: 'a', title: 'A')],
          ),
          PrayerTypeStruct(
            id: 3,
            type: 'Altele',
            sequence: 2,
            prayers: [PrayerStruct(id: 'b', title: 'B')],
          ),
        ],
      ),
    ];

    final resolved = resolveTodayPrayerType(
      catalog,
      [
        PrayerStruct(id: 'a', title: 'A'),
        PrayerStruct(id: 'b', title: 'B'),
      ],
    );

    expect(resolved, isNotNull);
    expect(resolved!.displayLabel, 'Slujba Vecerniei');
    expect(resolved.cardTitle, isNull);
    expect(resolved.cardSubtitle, 'Slujba Vecerniei');
    expect(resolved.entryType.id, 1);
  });

  test('resolveTodayPrayerType collapses when only one subtype matches today', () {
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
            prayers: [PrayerStruct(id: 'a', title: 'A')],
          ),
          PrayerTypeStruct(
            id: 3,
            type: 'Altele',
            sequence: 2,
            prayers: [PrayerStruct(id: 'b', title: 'B')],
          ),
        ],
      ),
    ];

    final resolved = resolveTodayPrayerType(
      catalog,
      [PrayerStruct(id: 'a', title: 'A')],
    );

    expect(resolved, isNotNull);
    expect(resolved!.displayLabel, 'Slujba Vecerniei - Vecernia Mare');
    expect(resolved.cardTitle, 'Slujba Vecerniei');
    expect(resolved.cardSubtitle, 'Vecernia Mare');
    expect(resolved.entryType.id, 2);
  });
}
