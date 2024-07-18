//State
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsModel.dart';
import 'package:flutterquiz/features/settings/settingsRepository.dart';

class SettingsState {
  SettingsState({this.settingsModel});

  final SettingsModel? settingsModel;
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settingsRepository) : super(SettingsState()) {
    _getCurrentSettings();
  }

  final SettingsRepository _settingsRepository;

  void _getCurrentSettings() {
    emit(
      SettingsState(
        settingsModel:
            SettingsModel.fromJson(_settingsRepository.getCurrentSettings()),
      ),
    );
  }

  SettingsModel getSettings() {
    return state.settingsModel!;
  }

  void changeShowIntroSlider() {
    _settingsRepository.showIntroSlider = false;
    emit(
      SettingsState(
        settingsModel: state.settingsModel!.copyWith(showIntroSlider: false),
      ),
    );
  }

  bool get sound => _settingsRepository.sound;

  set sound(bool value) {
    _settingsRepository.sound = value;
    emit(
      SettingsState(
        settingsModel: state.settingsModel!.copyWith(sound: value),
      ),
    );
  }

  bool get vibration => _settingsRepository.vibration;

  set vibration(bool value) {
    _settingsRepository.vibration = value;
    emit(
      SettingsState(
        settingsModel: state.settingsModel!.copyWith(vibration: value),
      ),
    );
  }

  void changeFontSize(double value) {
    _settingsRepository.playAreaFontSize = value;
    emit(
      SettingsState(
        settingsModel: state.settingsModel!.copyWith(playAreaFontSize: value),
      ),
    );
  }

  String? getLanguageCode() {
    return state.settingsModel!.languageCode;
  }
}
