import 'package:flutter_test/flutter_test.dart';
import 'package:my_prayer/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/prayer/prayer_search_index.dart';

void main() {
  test('displaySubtitle is the catalog path', () {
    final entry = PrayerSearchEntry(
      prayer: PrayerStruct(
        id: '1',
        title: 'Rugăciunea de dimineață',
        subtitle: 'Dimineața',
      ),
      path: 'Rugăciuni zilnice > Dimineața',
      searchHaystack: '',
    );

    expect(entry.displaySubtitle, 'Rugăciuni zilnice > Dimineața');
  });

  test('displaySubtitle is empty when path is empty', () {
    final entry = PrayerSearchEntry(
      prayer: PrayerStruct(
        id: '2',
        title: 'Aceeași',
        subtitle: 'Aceeași',
      ),
      path: '',
      searchHaystack: '',
    );

    expect(entry.displaySubtitle, '');
  });
}
