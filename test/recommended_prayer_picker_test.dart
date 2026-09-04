import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/recommended_prayer_picker.dart';

PrayerStruct _prayer(
  String id, {
  String title = '',
  String subtitle = '',
}) {
  return PrayerStruct(
    id: id,
    title: title,
    subtitle: subtitle,
    sequence: 1,
  );
}

DateGroupStruct _group(
  String name, {
  List<PrayerStruct>? prayers,
  int? hour,
}) {
  return DateGroupStruct(
    name: name,
    prayers: prayers,
    hour: hour,
  );
}

void main() {
  test('pickTodayPrayers at 00:07 shows all prayers assigned to the day', () {
    final groups = [
      _group('Ora 06', hour: 6, prayers: [_prayer('six', title: 'Ora I')]),
      _group('Ora 09', hour: 9, prayers: [_prayer('nine', title: 'Ora III')]),
      _group(
        'Rugăciunile din ziuă',
        prayers: [
          _prayer('rosary', title: 'Rugaciunea Rozariului'),
          _prayer('six', title: 'Ora I'),
        ],
      ),
    ];

    final entries = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 0, 7),
    );

    expect(
      entries.map((entry) => entry.prayer.id).toList(),
      ['six', 'nine', 'rosary'],
    );
  });

  test('pickTodayPrayers keeps all started hour slots until end of day', () {
    final groups = [
      _group('Ora 06', hour: 6, prayers: [_prayer('six', title: 'Ora I')]),
      _group('Ora 20', hour: 20, prayers: [_prayer('twenty', title: 'Ora XX')]),
    ];

    final entries = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 22, 30),
    );

    expect(
      entries.map((entry) => entry.prayer.id).toList(),
      ['six', 'twenty'],
    );

    final atEndOfDay = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 23, 59),
    );
    expect(
      atEndOfDay.map((entry) => entry.prayer.id).toList(),
      ['six', 'twenty'],
    );
  });

  test('pickTodayPrayers ignores hour schedules when listing daily prayers',
      () {
    final groups = [
      _group(
        'Pentru momentul zilei',
        hour: 12,
        prayers: [_prayer('noon', title: 'Ora a VI-a')],
      ),
      _group(
        'Rugăciunile din ziuă',
        prayers: [_prayer('rosary', title: 'Rugaciunea Rozariului')],
      ),
    ];

    final entries = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 11, 50),
    );

    expect(
        entries.map((entry) => entry.prayer.id).toList(), ['noon', 'rosary']);
  });

  test('pickTodayPrayers groups same-hour variants into one prayer-type entry',
      () {
    final groups = [
      _group(
        'Pentru momentul zilei',
        hour: 15,
        prayers: [
          _prayer('v1', title: 'Ora a IX-a', subtitle: 'Glas I'),
          _prayer('v2', title: 'Ora a IX-a', subtitle: 'Glas II'),
          _prayer('v3', title: 'Ora a IX-a', subtitle: 'Glas III'),
        ],
      ),
    ];

    final entries = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 14, 55),
    );

    expect(entries, hasLength(1));
    expect(entries.single.opensPrayerType, isTrue);
    expect(entries.single.voicePrayers.map((p) => p.id).toList(),
        ['v1', 'v2', 'v3']);
  });

  test('pickTodayPrayers splits different prayer titles at the same hour', () {
    final groups = [
      _group(
        'Pentru momentul zilei',
        hour: 15,
        prayers: [
          _prayer('canonical', title: 'Ora a IX-a'),
          _prayer('other', title: 'Altă rugăciune'),
        ],
      ),
    ];

    final entries = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 14, 55),
    );

    expect(entries, hasLength(2));
    expect(entries.every((entry) => !entry.opensPrayerType), isTrue);
  });

  test('pickTodayPrayers groups entries under the same parent prayer type', () {
    final groups = [
      _group('Ora 06', hour: 6, prayers: [_prayer('morning')]),
      _group('Ora 09', hour: 9, prayers: [_prayer('midmorning')]),
    ];
    final prayerTypes = [
      PrayerTypeStruct(
        id: 1,
        type: 'Ceasurile zilei',
        prayers: [_prayer('morning'), _prayer('midmorning')],
      ),
    ];

    final entries = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 12),
      prayerTypes: prayerTypes,
    );

    expect(entries, hasLength(1));
    expect(entries.single.opensPrayerType, isTrue);
    expect(
      entries.single.voicePrayers.map((prayer) => prayer.id).toList(),
      ['morning', 'midmorning'],
    );
  });

  test('pickTodayPrayers keeps earlier hour slots visible through the day', () {
    final groups = [
      _group('Ora 18',
          hour: 18, prayers: [_prayer('eighteen', title: 'Ora XVIII')]),
      _group('Ora 20', hour: 20, prayers: [_prayer('twenty', title: 'Ora XX')]),
    ];

    final beforeSecondWindow = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 19, 30),
    );
    expect(
      beforeSecondWindow.map((entry) => entry.prayer.id).toList(),
      ['eighteen', 'twenty'],
    );

    final duringOverlap = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 19, 50),
    );
    expect(
      duringOverlap.map((entry) => entry.prayer.id).toList(),
      ['eighteen', 'twenty'],
    );

    final afterFirstWindow = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 21, 0),
    );
    expect(
      afterFirstWindow.map((entry) => entry.prayer.id).toList(),
      ['eighteen', 'twenty'],
    );
  });

  test('non-last hour slot remains visible until the day ends', () {
    final groups = [
      _group('Ora 18',
          hour: 18, prayers: [_prayer('eighteen', title: 'Ora XVIII')]),
      _group('Ora 20', hour: 20, prayers: [_prayer('twenty', title: 'Ora XX')]),
    ];

    final atEnd = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 20, 59),
    );
    expect(
      atEnd.map((entry) => entry.prayer.id).toList(),
      ['eighteen', 'twenty'],
    );

    final afterEnd = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 21, 0),
    );
    expect(
      afterEnd.map((entry) => entry.prayer.id).toList(),
      ['eighteen', 'twenty'],
    );

    final atEndOfDay = pickTodayPrayers(
      groups,
      now: DateTime(2026, 6, 13, 23, 59),
    );
    expect(
      atEndOfDay.map((entry) => entry.prayer.id).toList(),
      ['eighteen', 'twenty'],
    );
  });
}
