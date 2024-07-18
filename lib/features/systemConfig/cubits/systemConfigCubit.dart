//State
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/features/systemConfig/model/room_code_char_type.dart';
import 'package:flutterquiz/features/systemConfig/model/supportedQuestionLanguage.dart';
import 'package:flutterquiz/features/systemConfig/model/systemConfigModel.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';

abstract class SystemConfigState {}

class SystemConfigInitial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  SystemConfigFetchSuccess({
    required this.systemConfigModel,
    required this.defaultProfileImages,
    required this.supportedLanguages,
    required this.emojis,
  });

  final SystemConfigModel systemConfigModel;
  final List<SupportedLanguage> supportedLanguages;
  final List<String> emojis;

  final List<String> defaultProfileImages;
}

class SystemConfigFetchFailure extends SystemConfigState {
  SystemConfigFetchFailure(this.errorCode);

  final String errorCode;
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  SystemConfigCubit(this._systemConfigRepository)
      : super(SystemConfigInitial());
  final SystemConfigRepository _systemConfigRepository;

  Future<void> getSystemConfig() async {
    emit(SystemConfigFetchInProgress());
    try {
      var supportedLanguages = <SupportedLanguage>[];
      final systemConfig = await _systemConfigRepository.getSystemConfig();
      final defaultProfileImages = await _systemConfigRepository
          .getImagesFromFile('assets/files/defaultProfileImages.json');

      final emojis = await _systemConfigRepository
          .getImagesFromFile('assets/files/emojis.json');

      if (systemConfig.languageMode) {
        supportedLanguages =
            await _systemConfigRepository.getSupportedQuestionLanguages();
      }
      emit(
        SystemConfigFetchSuccess(
          systemConfigModel: systemConfig,
          defaultProfileImages: defaultProfileImages,
          supportedLanguages: supportedLanguages,
          emojis: emojis,
        ),
      );
    } catch (e) {
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }

  List<SupportedLanguage> getSupportedLanguages() =>
      state is SystemConfigFetchSuccess
          ? (state as SystemConfigFetchSuccess).supportedLanguages
          : [];

  List<String> getEmojis() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).emojis
      : [];

  SystemConfigModel? get systemConfigModel => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel
      : null;

  String get shareAppText => systemConfigModel?.shareAppText ?? '';

  bool get isLanguageModeEnabled => systemConfigModel?.languageMode ?? false;

  bool get isCategoryEnabledForRandomBattle =>
      systemConfigModel?.randomBattleCategoryMode ?? false;

  bool get isCategoryEnabledForOneVsOneBattle =>
      systemConfigModel?.oneVsOneBattleCategoryMode ?? false;

  bool get isCategoryEnabledForGroupBattle =>
      systemConfigModel?.battleGroupCategoryMode ?? false;

  int get oneVsOneBattleMinimumEntryFee =>
      systemConfigModel?.oneVsOneBattleMinimumEntryFee ?? 0;

  int get groupBattleMinimumEntryFee =>
      systemConfigModel?.groupBattleMinimumEntryFee ?? 0;

  AnswerMode get answerMode =>
      systemConfigModel?.answerMode ?? AnswerMode.showAnswerCorrectness;

  bool get isDailyQuizEnabled => systemConfigModel?.dailyQuizMode ?? false;

  bool get isTrueFalseQuizEnabled => systemConfigModel?.truefalseMode ?? false;

  bool get isContestEnabled => systemConfigModel?.contestMode ?? false;

  bool get isFunNLearnEnabled => systemConfigModel?.funNLearnMode ?? false;

  bool get isOneVsOneBattleEnabled =>
      systemConfigModel?.oneVsOneBattleMode ?? false;

  bool get isRandomBattleEnabled =>
      systemConfigModel?.randomBattleMode ?? false;

  bool get isGroupBattleEnabled => systemConfigModel?.groupBattleMode ?? false;

  bool get isExamQuizEnabled => systemConfigModel?.examMode ?? false;

  bool get isGuessTheWordEnabled =>
      systemConfigModel?.guessTheWordMode ?? false;

  bool get isAudioQuizEnabled => systemConfigModel?.audioQuestionMode ?? false;

  bool get isQuizZoneEnabled => systemConfigModel?.quizZoneMode ?? false;

  int get selfChallengeMaxMinutes =>
      systemConfigModel?.selfChallengeMaxMinutes ?? 0;

  int get selfChallengeMaxQuestions =>
      systemConfigModel?.selfChallengeMaxQuestions ?? 0;

  String get appVersion => Platform.isIOS
      ? systemConfigModel?.appVersionIos ?? '1.0.0+1'
      : systemConfigModel?.appVersion ?? '1.0.0+1';

  String get appUrl => Platform.isIOS
      ? systemConfigModel?.iosAppLink ?? ''
      : systemConfigModel?.appLink ?? '';

  String get googleBannerId => Platform.isIOS
      ? systemConfigModel?.iosBannerId ?? ''
      : systemConfigModel?.androidBannerId ?? '';

  String get googleInterstitialAdId => Platform.isIOS
      ? systemConfigModel?.iosInterstitialId ?? ''
      : systemConfigModel?.androidInterstitialId ?? '';

  String get googleRewardedAdId => Platform.isIOS
      ? systemConfigModel?.iosRewardedId ?? ''
      : systemConfigModel?.androidRewardedId ?? '';

  bool get isForceUpdateEnable => systemConfigModel?.forceUpdate ?? false;

  bool get isAppUnderMaintenance => systemConfigModel?.appMaintenance ?? false;

  String get referrerEarnCoin => systemConfigModel?.earnCoin ?? '0';

  String get refereeEarnCoin => systemConfigModel?.referCoin ?? '0';

  bool get isAdsEnable => systemConfigModel?.adsEnabled ?? false;

  bool get isDailyAdsEnabled => systemConfigModel?.isDailyAdsEnabled ?? false;

  String get coinsPerDailyAdView =>
      systemConfigModel?.coinsPerDailyAdView ?? '0';

  bool get isPaymentRequestEnabled => systemConfigModel?.paymentMode ?? false;

  bool get isSelfChallengeQuizEnabled =>
      systemConfigModel?.selfChallengeMode ?? false;

  // bool isQuizEnabled(QuizTypes type) {
  //   final m = systemConfigModel;
  //   return switch (type) {
  //         QuizTypes.dailyQuiz => m?.dailyQuizMode,
  //         QuizTypes.contest => m?.contestMode,
  //         QuizTypes.groupPlay => m?.groupBattleMode,
  //         QuizTypes.oneVsOneBattle => m?.oneVsOneBattleMode,
  //         QuizTypes.funAndLearn => m?.funNLearnMode,
  //         QuizTypes.trueAndFalse => m?.truefalseMode,
  //         QuizTypes.selfChallenge => m?.selfChallengeMode,
  //         QuizTypes.guessTheWord => m?.guessTheWordMode,
  //         QuizTypes.quizZone => m?.quizZoneMode,
  //         QuizTypes.mathMania => m?.mathQuizMode,
  //         QuizTypes.audioQuestions => m?.audioQuestionMode,
  //         QuizTypes.exam => m?.examMode,
  //         QuizTypes.randomBattle => m?.randomBattleMode,
  //         _ => false,
  //       } ??
  //       false;
  // }

  RoomCodeCharType get oneVsOneBattleRoomCodeCharType =>
      systemConfigModel?.oneVsOneBattleRoomCodeCharType ??
      RoomCodeCharType.onlyNumbers;

  RoomCodeCharType get groupBattleRoomCodeCharType =>
      systemConfigModel?.groupBattleRoomCodeCharType ??
      RoomCodeCharType.onlyNumbers;

  bool get isCoinStoreEnabled => systemConfigModel?.inAppPurchaseMode ?? false;

  bool get isMathQuizEnabled => systemConfigModel?.mathQuizMode ?? false;

  int get perCoin => systemConfigModel?.perCoin ?? 0;

  int get coinAmount => systemConfigModel?.coinAmount ?? 0;

  int get minimumCoinLimit => systemConfigModel?.coinLimit ?? 0;

  int get adsType => systemConfigModel?.adsType ?? 0;

  String get unityGameId => Platform.isIOS
      ? systemConfigModel?.iosGameID ?? ''
      : systemConfigModel?.androidGameID ?? '';

  double get maxCoinsWinningPercentage =>
      systemConfigModel?.minWinningPercentage ?? 0;

  double get quizWinningPercentage =>
      systemConfigModel?.quizWinningPercentage ?? 0;

  int get maxWinningCoins => systemConfigModel?.maxWinningCoins ?? 0;

  int get guessTheWordMaxWinningCoins =>
      systemConfigModel?.guessTheWordMaxWinningCoins ?? 0;

  int get randomBattleEntryCoins =>
      systemConfigModel?.randomBattleEntryCoins ?? 0;

  int get reviewAnswersDeductCoins =>
      systemConfigModel?.reviewAnswersDeductCoins ?? 0;

  int get lifelinesDeductCoins => systemConfigModel?.lifelineDeductCoins ?? 0;

  List<String> get defaultAvatarImages => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).defaultProfileImages
      : [];

  String get botImage => systemConfigModel?.botImage ?? '';

  String get payoutRequestCurrency => systemConfigModel?.currencySymbol ?? '';

  int get rewardAdsCoins => systemConfigModel?.rewardAdsCoin ?? 0;

  int get randomBattleOpponentSearchDuration =>
      systemConfigModel?.randomBattleOpponentSearchDuration ?? 0;

  int get guessTheWordHintsPerQuiz =>
      systemConfigModel?.guessTheWordHintsPerQuiz ?? 0;

  int get oneVsOneBattleQuickestCorrectAnswerExtraScore =>
      systemConfigModel?.oneVsOneBattleQuickestCorrectAnswerExtraScore ?? 0;

  int get oneVsOneBattleSecondQuickestCorrectAnswerExtraScore =>
      systemConfigModel?.oneVsOneBattleSecondQuickestCorrectAnswerExtraScore ??
      0;

  int get randomBattleQuickestCorrectAnswerExtraScore =>
      systemConfigModel?.randomBattleQuickestCorrectAnswerExtraScore ?? 0;

  int get randomBattleSecondQuickestCorrectAnswerExtraScore =>
      systemConfigModel?.randomBattleSecondQuickestCorrectAnswerExtraScore ?? 0;

  int get resumeExamAfterCloseTimeout =>
      systemConfigModel?.resumeExamAfterCloseTimeout ?? 0;

  int quizTimer(QuizTypes type) {
    final m = systemConfigModel;
    return switch (type) {
          QuizTypes.groupPlay => m?.groupBattleTimer,
          QuizTypes.oneVsOneBattle => m?.oneVsOneBattleTimer,
          QuizTypes.funAndLearn => m?.funAndLearnTimer,
          QuizTypes.trueAndFalse => m?.trueAndFalseTimer,
          QuizTypes.guessTheWord => m?.guessTheWordTimer,
          QuizTypes.quizZone => m?.quizTimer,
          QuizTypes.mathMania => m?.mathsQuizTimer,
          QuizTypes.audioQuestions => m?.audioTimer,
          QuizTypes.randomBattle => m?.randomBattleTimer,
          _ => m?.quizTimer,
        } ??
        0;
  }

  int quizCorrectAnswerCreditScore(QuizTypes type) {
    final m = systemConfigModel;
    return switch (type) {
          QuizTypes.oneVsOneBattle => m?.oneVsOneBattleCorrectAnswerCreditScore,
          QuizTypes.funAndLearn => m?.funAndLearnCorrectAnswerCreditScore,
          QuizTypes.trueAndFalse => m?.trueAndFalseCorrectAnswerCreditScore,
          QuizTypes.guessTheWord => m?.guessTheWordCorrectAnswerCreditScore,
          QuizTypes.quizZone => m?.quizZoneCorrectAnswerCreditScore,
          QuizTypes.mathMania => m?.mathsQuizCorrectAnswerCreditScore,
          QuizTypes.audioQuestions => m?.audioQuizCorrectAnswerCreditScore,
          QuizTypes.randomBattle => m?.randomBattleCorrectAnswerCreditScore,
          QuizTypes.contest => m?.contestCorrectAnswerCreditScore,
          _ => m?.score,
        } ??
        0;
  }

  int quizWrongAnswerDeductScore(QuizTypes type) {
    final m = systemConfigModel;
    return switch (type) {
          QuizTypes.oneVsOneBattle => m?.oneVsOneBattleWrongAnswerDeductScore,
          QuizTypes.funAndLearn => m?.funAndLearnWrongAnswerDeductScore,
          QuizTypes.trueAndFalse => m?.trueAndFalseWrongAnswerDeductScore,
          QuizTypes.guessTheWord => m?.guessTheWordWrongAnswerDeductScore,
          QuizTypes.quizZone => m?.quizZoneWrongAnswerDeductScore,
          QuizTypes.mathMania => m?.mathsQuizWrongAnswerDeductScore,
          QuizTypes.audioQuestions => m?.audioQuizWrongAnswerDeductScore,
          QuizTypes.randomBattle => m?.randomBattleWrongAnswerDeductScore,
          QuizTypes.contest => m?.contestWrongAnswerDeductScore,
          _ => m?.score,
        } ??
        0;
  }
}
