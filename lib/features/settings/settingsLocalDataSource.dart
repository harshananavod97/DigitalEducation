import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsLocalDataSource {
  Box<dynamic> get _box => Hive.box<dynamic>(settingsBox);

  bool get showIntroSlider =>
      _box.get(showIntroSliderKey, defaultValue: true) as bool;

  set showIntroSlider(bool value) => _box.put(showIntroSliderKey, value);

  bool get sound => _box.get(soundKey, defaultValue: true) as bool;

  set sound(bool value) => _box.put(soundKey, value);

  bool get vibration => _box.get(vibrationKey, defaultValue: true) as bool;

  set vibration(bool value) => _box.put(vibrationKey, value);

  String get languageCode =>
      _box.get(languageCodeKey, defaultValue: defaultLanguageCode) as String;

  set languageCode(String value) => _box.put(languageCodeKey, value);

  double get playAreaFontSize =>
      _box.get(fontSizeKey, defaultValue: 16.0) as double;

  set playAreaFontSize(double value) => _box.put(fontSizeKey, value);

  bool get rewardEarned =>
      _box.get(rewardEarnedKey, defaultValue: false) as bool;

  set rewardEarned(bool value) => _box.put(rewardEarnedKey, value);

  String get theme =>
      _box.get(settingsThemeKey, defaultValue: defaultThemeKey) as String;

  set theme(String value) => _box.put(settingsThemeKey, value);
}
