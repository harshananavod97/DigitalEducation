import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class AppLocalizationState {
  AppLocalizationState(this.language);

  final Locale language;
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  AppLocalizationCubit(this.settingsLocalDataSource)
      : super(
          AppLocalizationState(
            UiUtils.getLocaleFromLanguageCode(defaultLanguageCode),
          ),
        ) {
    changeLanguage(settingsLocalDataSource.languageCode);
  }

  final SettingsLocalDataSource settingsLocalDataSource;

  void changeLanguage(String languageCode) {
    settingsLocalDataSource.languageCode = languageCode;
    emit(AppLocalizationState(UiUtils.getLocaleFromLanguageCode(languageCode)));
  }
}
