import 'dart:convert';

import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = const FlutterSecureStorage();
    await _safeInitAsync(() async {
      _autoPlayNext =
          await secureStorage.getBool('ff_autoPlayNext') ?? _autoPlayNext;
    });
    await _safeInitAsync(() async {
      _audioSpeed =
          await secureStorage.getDouble('ff_audioSpeed') ?? _audioSpeed;
    });
    await _safeInitAsync(() async {
      _fontFamily =
          await secureStorage.getString('ff_fontFamily') ?? _fontFamily;
    });
    await _safeInitAsync(() async {
      _fontSizeMultiplier =
          await secureStorage.getDouble('ff_fontSizeMultiplier') ??
              _fontSizeMultiplier;
    });
    await _safeInitAsync(() async {
      var prayers = await secureStorage.getString('ff_favoritePrayers');
      if(prayers == null || prayers.isEmpty) return;

      var prayersList = json.decode(prayers);
      if(prayersList is! List) return;

      _favoritePrayers = prayersList.map((x) {
                    try {
                      return PrayerStruct.fromSerializableMap(x);
                    } catch (e) {
                      print("Can't decode persisted data type. Error: $e.");
                      return null;
                    }
                  })
                  .withoutNulls
                  .toList();
    });
    await _safeInitAsync(() async {
      var prayers = await secureStorage.getString('ff_downloadedPrayers');
      if(prayers == null || prayers.isEmpty) return;

      var prayersList = json.decode(prayers);
      if(prayersList is! List) return;

      _downloadedPrayers = prayersList.map((x) {
                    try {
                      return PrayerStruct.fromSerializableMap(x);
                    } catch (e) {
                      print("Can't decode persisted data type. Error: $e.");
                      return null;
                    }
                  })
                  .withoutNulls
                  .toList();
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_savedPrayer') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_savedPrayer') ?? '{}';
          _savedPrayer = SavedPrayerDataStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  bool _autoPlayNext = true;
  bool get autoPlayNext => _autoPlayNext;
  set autoPlayNext(bool value) {
    _autoPlayNext = value;
    secureStorage.setBool('ff_autoPlayNext', value);
  }

  void deleteAutoPlayNext() {
    secureStorage.delete(key: 'ff_autoPlayNext');
  }

  bool _isDisplayingAudio = true;
  bool get isDisplayingAudio => _isDisplayingAudio;
  set isDisplayingAudio(bool value) {
    _isDisplayingAudio = value;
  }

  bool? _isFirstTime = null;
  bool? get isFirstTime => _isFirstTime;
  set isFirstTime(bool? value) {
    _isFirstTime = value;
  }

  double _audioSpeed = 1.0;
  double get audioSpeed => _audioSpeed;
  set audioSpeed(double value) {
    _audioSpeed = value;
    secureStorage.setDouble('ff_audioSpeed', value);
  }

  void deleteAudioSpeed() {
    secureStorage.delete(key: 'ff_audioSpeed');
  }

  String _fontFamily = 'Georgia';
  String get fontFamily => _fontFamily;
  set fontFamily(String value) {
    _fontFamily = value;
    secureStorage.setString('ff_fontFamily', value);
  }

  void deleteFontFamily() {
    secureStorage.delete(key: 'ff_fontFamily');
  }

  double _fontSizeMultiplier = 1;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  set fontSizeMultiplier(double value) {
    _fontSizeMultiplier = value;
    secureStorage.setDouble('ff_fontSizeMultiplier', value);
  }

  void deleteFontSizeMultiplier() {
    secureStorage.delete(key: 'ff_fontSizeMultiplier');
  }

  List<PrayerStruct> _favoritePrayers = [];
  List<PrayerStruct> get favoritePrayers => _favoritePrayers;
  set favoritePrayers(List<PrayerStruct> value) {
    _favoritePrayers = value;
    secureStorage.setString('ff_favoritePrayers',
        jsonEncode(
      value.map((x) => x.toSerializableMap()).toList(),
    ));
  }

  void deleteFavoritePrayers() {
    secureStorage.delete(key: 'ff_favoritePrayers');
  }

  void addToFavoritePrayers(PrayerStruct value) {
    favoritePrayers.add(value);
    favoritePrayers = favoritePrayers;
  }

  void removeFromFavoritePrayers(PrayerStruct value) {
    favoritePrayers.remove(value);
    favoritePrayers = favoritePrayers;
  }

  void removeAtIndexFromFavoritePrayers(int index) {
    favoritePrayers.removeAt(index);
    favoritePrayers = favoritePrayers;
  }

  void updateFavoritePrayersAtIndex(
    int index,
    PrayerStruct Function(PrayerStruct) updateFn,
  ) {
    favoritePrayers[index] = updateFn(_favoritePrayers[index]);
    favoritePrayers = favoritePrayers;
  }

  void insertAtIndexInFavoritePrayers(int index, PrayerStruct value) {
    favoritePrayers.insert(index, value);
    favoritePrayers = favoritePrayers;
  }

  List<PrayerStruct> _downloadedPrayers = [];
  List<PrayerStruct> get downloadedPrayers => _downloadedPrayers;
  set downloadedPrayers(List<PrayerStruct> value) {
    _downloadedPrayers = value;
    secureStorage.setString(
        'ff_downloadedPrayers', jsonEncode(value.map((x) => x.serialize()).toList()));
  }

  void deleteDownloadedPrayers() {
    secureStorage.delete(key: 'ff_downloadedPrayers');
  }

  void addToDownloadedPrayers(PrayerStruct value) {
    downloadedPrayers.add(value);
    downloadedPrayers = downloadedPrayers;
  }

  void removeFromDownloadedPrayers(PrayerStruct value) {
    downloadedPrayers.remove(value);
    downloadedPrayers = downloadedPrayers;
  }

  void removeAtIndexFromDownloadedPrayers(int index) {
    downloadedPrayers.removeAt(index);
    downloadedPrayers = downloadedPrayers;
  }

  void updateDownloadedPrayersAtIndex(
    int index,
    PrayerStruct Function(PrayerStruct) updateFn,
  ) {
    downloadedPrayers[index] = updateFn(_downloadedPrayers[index]);
    downloadedPrayers = downloadedPrayers;
  }

  void insertAtIndexInDownloadedPrayers(int index, PrayerStruct value) {
    downloadedPrayers.insert(index, value);
    downloadedPrayers = downloadedPrayers;
  }

  bool _isDeviceOnline = false;
  bool get isDeviceOnline => _isDeviceOnline;
  set isDeviceOnline(bool value) {
    _isDeviceOnline = value;
  }

  String _currentPrayerId = '';
  String get currentPrayerId => _currentPrayerId;
  set currentPrayerId(String value) {
    _currentPrayerId = value;
  }

  SavedPrayerDataStruct _savedPrayer = SavedPrayerDataStruct();
  SavedPrayerDataStruct get savedPrayer => _savedPrayer;
  set savedPrayer(SavedPrayerDataStruct value) {
    _savedPrayer = value;
    secureStorage.setString('ff_savedPrayer', value.serialize());
  }

  void deleteSavedPrayer() {
    secureStorage.delete(key: 'ff_savedPrayer');
  }

  void updateSavedPrayerStruct(Function(SavedPrayerDataStruct) updateFn) {
    updateFn(_savedPrayer);
    secureStorage.setString('ff_savedPrayer', _savedPrayer.serialize());
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return const CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(
          key: key, value: const ListToCsvConverter().convert([value]));
}
