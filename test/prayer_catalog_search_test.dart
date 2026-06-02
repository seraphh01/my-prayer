import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/reminders/prayer_catalog_helper.dart';

PrayerTypeStruct _typeWithPrayers(List<PrayerStruct> prayers) {
  return PrayerTypeStruct(
    id: 1,
    type: 'Root',
    prayers: prayers,
  );
}

PrayerStruct _prayer({
  required String id,
  required String title,
  String subtitle = '',
}) {
  return PrayerStruct(id: id, title: title, subtitle: subtitle);
}

void main() {
  test('search matches title or subtitle case insensitive', () {
    final types = [
      _typeWithPrayers([
        _prayer(id: '1', title: 'Rugăciunea Rozariului', subtitle: 'Mistere'),
        _prayer(id: '2', title: 'Altceva', subtitle: 'Dimineața'),
      ]),
    ];

    final byTitle =
        searchPrayersByTitleOrSubtitle(types, 'rozariului');
    expect(byTitle.map((p) => p.id), ['1']);

    final bySubtitle = searchPrayersByTitleOrSubtitle(types, 'DIMINEA');
    expect(bySubtitle.map((p) => p.id), ['2']);
  });

  test('search ignores path and deduplicates by id', () {
    final prayer = _prayer(id: 'x', title: 'Aceeași', subtitle: '');
    final types = [
      _typeWithPrayers([prayer]),
      _typeWithPrayers([prayer]),
    ];

    final results = searchPrayersByTitleOrSubtitle(types, 'aceea');
    expect(results.length, 1);
    expect(results.first.id, 'x');
  });
}
