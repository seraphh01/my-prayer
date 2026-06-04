import 'dart:convert';

import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';
import '/custom_code/prayer/reading_anchor_presets.dart';

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
      _readingAnchorAlignment =
          await secureStorage.getDouble('ff_readingAnchorAlignment') ??
              _readingAnchorAlignment;
    });
    await _safeInitAsync(() async {
      final stored = await secureStorage.getBool('ff_textAutoScrollEnabled');
      if (stored != null) {
        _textAutoScrollEnabled = stored;
      }
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
    await _safeInitAsync(() async {
      final stored = await secureStorage.getBool('ff_isFirstTime');
      if (stored != null) {
        _isFirstTime = stored;
      } else {
        // Existing installs: skip onboarding if user already has data.
        final hasPriorUse = _favoritePrayers.isNotEmpty ||
            (_savedPrayer.prayer?.id.isNotEmpty ?? false);
        _isFirstTime = !hasPriorUse;
      }
    });
    await _safeInitAsync(() async {
      _homeHeaderCollapsed =
          await secureStorage.getBool('ff_homeHeaderCollapsed') ??
              _homeHeaderCollapsed;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  bool _isDisplayingAudio = true;
  bool get isDisplayingAudio => _isDisplayingAudio;
  set isDisplayingAudio(bool value) {
    if (_isDisplayingAudio == value) {
      return;
    }
    _isDisplayingAudio = value;
    notifyListeners();
  }

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;
  set isFirstTime(bool value) {
    _isFirstTime = value;
    secureStorage.setBool('ff_isFirstTime', value);
    notifyListeners();
  }

  bool _homeHeaderCollapsed = false;
  bool get homeHeaderCollapsed => _homeHeaderCollapsed;
  set homeHeaderCollapsed(bool value) {
    if (_homeHeaderCollapsed == value) {
      return;
    }
    _homeHeaderCollapsed = value;
    secureStorage.setBool('ff_homeHeaderCollapsed', value);
    notifyListeners();
  }

  void toggleHomeHeaderCollapsed() {
    homeHeaderCollapsed = !homeHeaderCollapsed;
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

  String _fontFamily = 'Crimson Pro';
  String get fontFamily => _fontFamily;
  set fontFamily(String value) {
    if (_fontFamily == value) {
      return;
    }
    _fontFamily = value;
    secureStorage.setString('ff_fontFamily', value);
    notifyListeners();
  }

  void deleteFontFamily() {
    secureStorage.delete(key: 'ff_fontFamily');
  }

  double _fontSizeMultiplier = 1;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  set fontSizeMultiplier(double value) {
    if (_fontSizeMultiplier == value) {
      return;
    }
    _fontSizeMultiplier = value;
    secureStorage.setDouble('ff_fontSizeMultiplier', value);
    notifyListeners();
  }

  void deleteFontSizeMultiplier() {
    secureStorage.delete(key: 'ff_fontSizeMultiplier');
  }

  double _readingAnchorAlignment = ReadingAnchorPresets.standardAlignment;
  double get readingAnchorAlignment => _readingAnchorAlignment;
  set readingAnchorAlignment(double value) {
    if (_readingAnchorAlignment == value) {
      return;
    }
    _readingAnchorAlignment = value;
    secureStorage.setDouble('ff_readingAnchorAlignment', value);
    notifyListeners();
  }

  void deleteReadingAnchorAlignment() {
    secureStorage.delete(key: 'ff_readingAnchorAlignment');
  }

  bool _textAutoScrollEnabled = true;
  bool get textAutoScrollEnabled => _textAutoScrollEnabled;
  set textAutoScrollEnabled(bool value) {
    if (_textAutoScrollEnabled == value) {
      return;
    }
    _textAutoScrollEnabled = value;
    secureStorage.setBool('ff_textAutoScrollEnabled', value);
    notifyListeners();
  }

  void deleteTextAutoScrollEnabled() {
    secureStorage.delete(key: 'ff_textAutoScrollEnabled');
  }

  List<PrayerStruct> _favoritePrayers = [];
  List<PrayerStruct> get favoritePrayers => _favoritePrayers;
  set favoritePrayers(List<PrayerStruct> value) {
    _favoritePrayers = value;
    secureStorage.setString('ff_favoritePrayers',
        jsonEncode(
      value.map((x) => x.toSerializableMap()).toList(),
    ));
    notifyListeners();
  }

  void deleteFavoritePrayers() {
    secureStorage.delete(key: 'ff_favoritePrayers');
  }

  void addToFavoritePrayers(PrayerStruct value) {
    if (isFavoritePrayerId(value.id)) {
      return;
    }
    favoritePrayers.add(_compactFavorite(value));
    favoritePrayers = favoritePrayers;
    notifyListeners();
  }

  void removeFromFavoritePrayers(PrayerStruct value) {
    removeFavoriteById(value.id);
  }

  void removeFavoriteById(String prayerId) {
    favoritePrayers =
        favoritePrayers.where((p) => p.id != prayerId).toList();
    notifyListeners();
  }

  bool isFavoritePrayerId(String prayerId) {
    if (prayerId.isEmpty) {
      return false;
    }
    return favoritePrayers.any((p) => p.id == prayerId);
  }

  bool isFavoritePrayer(PrayerStruct prayer) =>
      isFavoritePrayerId(prayer.id);

  /// Store minimal prayer data in favorites (no sections).
  PrayerStruct _compactFavorite(PrayerStruct value) {
    return PrayerStruct(
      id: value.id,
      title: value.title,
      subtitle: value.subtitle,
      mode: value.mode,
      sequence: value.sequence,
    );
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
      'ff_downloadedPrayers',
      jsonEncode(value.map((x) => _compactDownloaded(x).toSerializableMap()).toList()),
    );
    notifyListeners();
  }

  void deleteDownloadedPrayers() {
    secureStorage.delete(key: 'ff_downloadedPrayers');
  }

  void addToDownloadedPrayers(PrayerStruct value) {
    removeDownloadedById(value.id);
    downloadedPrayers = [...downloadedPrayers, _compactDownloaded(value)];
  }

  void removeFromDownloadedPrayers(PrayerStruct value) {
    removeDownloadedById(value.id);
  }

  void removeDownloadedById(String prayerId) {
    if (prayerId.isEmpty) {
      return;
    }
    downloadedPrayers =
        downloadedPrayers.where((p) => p.id != prayerId).toList();
  }

  PrayerStruct _compactDownloaded(PrayerStruct value) {
    return PrayerStruct(
      id: value.id,
      title: value.title,
      subtitle: value.subtitle,
      mode: value.mode,
      sequence: value.sequence,
    );
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
    secureStorage.setString('ff_savedPrayer', jsonEncode(value.serialize()));
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
