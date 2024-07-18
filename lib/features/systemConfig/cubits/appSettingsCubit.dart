import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';

abstract class AppSettingsState {}

class AppSettingsIntial extends AppSettingsState {}

class AppSettingsFetchInProgress extends AppSettingsState {}

class AppSettingsFetchSuccess extends AppSettingsState {
  AppSettingsFetchSuccess(this.settingsData);

  final String settingsData;
}

class AppSettingsFetchFailure extends AppSettingsState {
  AppSettingsFetchFailure(this.errorCode);

  final String errorCode;
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._systemConfigRepository) : super(AppSettingsIntial());
  final SystemConfigRepository _systemConfigRepository;

  void getAppSetting(String type) {
    emit(AppSettingsFetchInProgress());
    _systemConfigRepository
        .getAppSettings(type)
        .then((value) => emit(AppSettingsFetchSuccess(value)))
        .catchError((Object e) {
      emit(AppSettingsFetchFailure(e.toString()));
    });
  }
}
