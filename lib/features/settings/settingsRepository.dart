import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';

class SettingsRepository {
  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  static final SettingsRepository _settingsRepository =
      SettingsRepository._internal();
  late SettingsLocalDataSource _settingsLocalDataSource;

  Map<String, dynamic> getCurrentSettings() {
    return {
      'showIntroSlider': _settingsLocalDataSource.showIntroSlider,
      'sound': _settingsLocalDataSource.sound,
      'rewardEarned': _settingsLocalDataSource.rewardEarned,
      'vibration': _settingsLocalDataSource.vibration,
      'languageCode': _settingsLocalDataSource.languageCode,
      'theme': _settingsLocalDataSource.theme,
      'playAreaFontSize': _settingsLocalDataSource.playAreaFontSize,
    };
  }

  bool get showIntroSlider => _settingsLocalDataSource.showIntroSlider;

  set showIntroSlider(bool value) =>
      _settingsLocalDataSource.showIntroSlider = value;

  bool get sound => _settingsLocalDataSource.sound;

  set sound(bool value) => _settingsLocalDataSource.sound = value;

  bool get vibration => _settingsLocalDataSource.vibration;

  set vibration(bool value) => _settingsLocalDataSource.vibration = value;

  String get languageCode => _settingsLocalDataSource.languageCode;

  set languageCode(String value) =>
      _settingsLocalDataSource.languageCode = value;

  double get playAreaFontSize => _settingsLocalDataSource.playAreaFontSize;

  set playAreaFontSize(double value) =>
      _settingsLocalDataSource.playAreaFontSize = value;
}
