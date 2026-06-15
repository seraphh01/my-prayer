import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/calendar/fetch_date_group_prayers.dart';

PrayerStruct _prayer(String id) => PrayerStruct(id: id, sequence: 1);

DateGroupStruct _group(String name, {List<PrayerStruct>? prayers, int? hour}) {
  return DateGroupStruct(name: name, hour: hour, prayers: prayers);
}

void main() {
  test('dayOnlyDateGroupsFromRaw drops hour sections but keeps their prayers', () {
    final filtered = dayOnlyDateGroupsFromRaw([
      _group(
        'Rugăciunile din ziuă',
        prayers: [
          _prayer('rosary'),
          _prayer('canonical'),
        ],
      ),
      _group(
        'Pentru momentul zilei',
        hour: 6,
        prayers: [_prayer('canonical')],
      ),
    ]);

    expect(filtered, hasLength(1));
    expect(filtered.first.name, 'Rugăciunile din ziuă');
    expect(
      filtered.first.prayers.map((p) => p.id).toList(),
      ['rosary', 'canonical'],
    );
  });

  test('dayOnlyDateGroupsFromRaw merges hour-only prayers into day group', () {
    final filtered = dayOnlyDateGroupsFromRaw([
      _group('Rugăciunile din ziuă', prayers: [_prayer('rosary')]),
      _group(
        'Pentru momentul zilei',
        prayers: [_prayer('canonical')],
      ),
    ]);

    expect(filtered, hasLength(1));
    expect(filtered.first.name, 'Rugăciunile din ziuă');
    expect(
      filtered.first.prayers.map((p) => p.id).toList(),
      ['rosary', 'canonical'],
    );
  });

  test('dayOnlyDateGroupsFromRaw merges voices from multiple hour slots', () {
    final filtered = dayOnlyDateGroupsFromRaw([
      _group('Rugăciunile din ziuă', prayers: [_prayer('rosary')]),
      _group(
        'Pentru momentul zilei',
        hour: 6,
        prayers: [_prayer('voice-1')],
      ),
      _group(
        'Pentru momentul zilei',
        hour: 9,
        prayers: [_prayer('voice-2')],
      ),
    ]);

    expect(filtered.single.prayers.map((p) => p.id).toList(),
        ['rosary', 'voice-1', 'voice-2']);
  });
}
