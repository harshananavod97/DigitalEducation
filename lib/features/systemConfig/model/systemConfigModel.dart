import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/features/systemConfig/model/room_code_char_type.dart';

class SystemConfigModel {
  SystemConfigModel({
    required this.adsEnabled,
    required this.adsType,
    required this.androidBannerId,
    required this.androidGameID,
    required this.androidInterstitialId,
    required this.androidRewardedId,
    required this.answerMode,
    required this.appLink,
    required this.appMaintenance,
    required this.appVersion,
    required this.appVersionIos,
    required this.audioQuestionMode,
    required this.audioTimer,
    required this.battleGroupCategoryMode,
    required this.groupBattleMode,
    required this.oneVsOneBattleMode,
    required this.randomBattleCategoryMode,
    required this.coinAmount,
    required this.coinLimit,
    required this.contestMode,
    required this.currencySymbol,
    required this.dailyQuizMode,
    required this.earnCoin,
    required this.examMode,
    required this.falseValue,
    required this.forceUpdate,
    required this.funAndLearnTimer,
    required this.funNLearnMode,
    required this.guessTheWordMaxWinningCoins,
    required this.guessTheWordMode,
    required this.guessTheWordTimer,
    required this.inAppPurchaseMode,
    required this.iosAppLink,
    required this.iosBannerId,
    required this.iosGameID,
    required this.iosInterstitialId,
    required this.iosMoreApps,
    required this.iosRewardedId,
    required this.languageMode,
    required this.lifelineDeductCoins,
    required this.mathQuizMode,
    required this.mathsQuizTimer,
    required this.maxWinningCoins,
    required this.minWinningPercentage,
    required this.quizWinningPercentage,
    required this.moreApps,
    required this.optionEMode,
    required this.paymentMode,
    required this.perCoin,
    required this.quizZoneCorrectAnswerCreditScore,
    required this.quizZoneWrongAnswerDeductScore,
    required this.guessTheWordCorrectAnswerCreditScore,
    required this.guessTheWordWrongAnswerDeductScore,
    required this.quizTimer,
    required this.randomBattleEntryCoins,
    required this.randomBattleTimer,
    required this.referCoin,
    required this.reviewAnswersDeductCoins,
    required this.rewardAdsCoin,
    required this.selfChallengeMode,
    required this.selfChallengeMaxMinutes,
    required this.shareAppText,
    required this.systemTimezone,
    required this.systemTimezoneGmt,
    required this.trueValue,
    required this.truefalseMode,
    required this.botImage,
    required this.score,
    required this.quizZoneMode,
    required this.guessTheWordHintsPerQuiz,
    required this.coinsPerDailyAdView,
    required this.isDailyAdsEnabled,
    required this.totalDailyAds,
    required this.audioQuizWrongAnswerDeductScore,
    required this.audioQuizCorrectAnswerCreditScore,
    required this.groupBattleRoomCodeCharType,
    required this.groupBattleCorrectAnswerCreditScore,
    required this.groupBattleTimer,
    required this.groupBattleWrongAnswerDeductScore,
    required this.oneVsOneBattleCategoryMode,
    required this.oneVsOneBattleRoomCodeCharType,
    required this.oneVsOneBattleTimer,
    required this.randomBattleMode,
    required this.trueAndFalseTimer,
    required this.groupBattleQuickestCorrectAnswerExtraScore,
    required this.groupBattleSecondQuickestCorrectAnswerExtraScore,
    required this.oneVsOneBattleCorrectAnswerCreditScore,
    required this.oneVsOneBattleQuickestCorrectAnswerExtraScore,
    required this.oneVsOneBattleSecondQuickestCorrectAnswerExtraScore,
    required this.oneVsOneBattleWrongAnswerDeductScore,
    required this.randomBattleCorrectAnswerCreditScore,
    required this.randomBattleWrongAnswerDeductScore,
    required this.randomBattleQuickestCorrectAnswerExtraScore,
    required this.randomBattleSecondQuickestCorrectAnswerExtraScore,
    required this.randomBattleOpponentSearchDuration,
    required this.mathsQuizCorrectAnswerCreditScore,
    required this.mathsQuizWrongAnswerDeductScore,
    required this.funAndLearnCorrectAnswerCreditScore,
    required this.funAndLearnWrongAnswerDeductScore,
    required this.trueAndFalseCorrectAnswerCreditScore,
    required this.trueAndFalseWrongAnswerDeductScore,
    required this.selfChallengeMaxQuestions,
    required this.groupBattleMinimumEntryFee,
    required this.oneVsOneBattleMinimumEntryFee,
    required this.resumeExamAfterCloseTimeout,
    required this.contestCorrectAnswerCreditScore,
    required this.contestWrongAnswerDeductScore,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    adsEnabled = json['in_app_ads_mode'] == '1';
    adsType = int.parse(json['ads_type'] as String? ?? '0');
    androidBannerId = json['android_banner_id'] as String? ?? '';
    androidGameID = json['android_game_id'] as String? ?? '';
    androidInterstitialId = json['android_interstitial_id'] as String? ?? '';
    androidRewardedId = json['android_rewarded_id'] as String? ?? '';
    appLink = json['app_link'] as String? ?? '';
    appMaintenance = json['app_maintenance'] == '1';
    appVersion = json['app_version'] as String? ?? '';
    appVersionIos = json['app_version_ios'] as String? ?? '';
    audioQuestionMode = json['audio_mode_question'] == '1';
    audioTimer = int.parse(json['audio_quiz_seconds'] as String? ?? '0');
    battleGroupCategoryMode =
        (json['battle_mode_group_category'] ?? '0') == '1';
    groupBattleMode = json['battle_mode_group'] == '1';
    oneVsOneBattleMode = (json['battle_mode_one'] ?? '0') == '1';
    randomBattleCategoryMode =
        (json['battle_mode_random_category'] ?? '0') == '1';
    oneVsOneBattleCategoryMode =
        (json['battle_mode_one_category'] as String) == '1';

    randomBattleMode = (json['battle_mode_random'] ?? '0') == '1';

    coinAmount = int.parse(json['coin_amount'] as String? ?? '0');
    coinLimit = int.parse(json['coin_limit'] as String? ?? '0');
    contestMode = (json['contest_mode'] ?? '0') == '1';
    currencySymbol = json['currency_symbol'] as String? ?? r'$';
    dailyQuizMode = (json['daily_quiz_mode'] ?? '0') == '1';
    earnCoin = json['earn_coin'] as String? ?? '';
    examMode = (json['exam_module'] ?? '0') == '1';
    falseValue = json['false_value'] as String? ?? '';
    forceUpdate = json['force_update'] == '1';

    trueAndFalseTimer =
        int.parse(json['true_false_quiz_in_seconds'] as String? ?? '0');
    funAndLearnTimer =
        int.parse(json['fun_and_learn_time_in_seconds'] as String? ?? '0');

    funNLearnMode = (json['fun_n_learn_question'] ?? '0') == '1';
    guessTheWordMaxWinningCoins =
        int.parse(json['guess_the_word_max_winning_coin'] as String? ?? '0');

    guessTheWordMode = (json['guess_the_word_question'] ?? '0') == '1';
    guessTheWordTimer =
        int.parse(json['guess_the_word_seconds'] as String? ?? '0');
    inAppPurchaseMode = json['in_app_purchase_mode'] == '1';
    iosAppLink = json['ios_app_link'] as String? ?? '';
    iosBannerId = json['ios_banner_id'] as String? ?? '';
    iosGameID = json['ios_game_id'] as String? ?? '';
    iosInterstitialId = json['ios_interstitial_id'] as String? ?? '';
    iosMoreApps = json['ios_more_apps'] as String? ?? '';
    iosRewardedId = json['ios_rewarded_id'] as String? ?? '';
    languageMode = (json['language_mode'] ?? '0') == '1';
    lifelineDeductCoins =
        int.parse(json['quiz_zone_lifeline_deduct_coin'] as String? ?? '0');
    mathQuizMode = json['maths_quiz_mode'] == '1';
    mathsQuizTimer = int.parse(json['maths_quiz_seconds'] as String? ?? '0');
    maxWinningCoins =
        int.parse(json['maximum_winning_coins'] as String? ?? '0');
    minWinningPercentage = double.parse(
      json['minimum_coins_winning_percentage'] as String? ?? '0',
    );
    quizWinningPercentage = double.parse(
      json['quiz_winning_percentage'] as String? ?? '0',
    );
    moreApps = json['more_apps'] as String? ?? '';
    optionEMode = json['option_e_mode'] as String? ?? '';
    paymentMode = json['payment_mode'] == '1';
    perCoin = int.parse(json['per_coin'] as String? ?? '0');
    quizZoneCorrectAnswerCreditScore = int.parse(
      json['quiz_zone_correct_answer_credit_score'] as String? ?? '0',
    );
    quizZoneWrongAnswerDeductScore = int.parse(
      json['quiz_zone_wrong_answer_deduct_score'] as String? ?? '0',
    );
    guessTheWordCorrectAnswerCreditScore = int.parse(
      json['guess_the_word_correct_answer_credit_score'] as String? ?? '0',
    );
    guessTheWordWrongAnswerDeductScore = int.parse(
      json['guess_the_word_wrong_answer_deduct_score'] as String? ?? '0',
    );
    audioQuizCorrectAnswerCreditScore = int.parse(
      json['audio_quiz_correct_answer_credit_score'] as String? ?? '0',
    );
    audioQuizWrongAnswerDeductScore = int.parse(
      json['audio_quiz_wrong_answer_deduct_score'] as String? ?? '0',
    );
    groupBattleTimer = int.parse(
      json['battle_mode_group_in_seconds'] as String? ?? '0',
    );
    oneVsOneBattleTimer = int.parse(
      json['battle_mode_one_in_seconds'] as String? ?? '0',
    );

    // TODO(J): will require changes in group battle flow. currently unused.
    // groupBattleCorrectAnswerCreditScore = int.parse(
    //   json['battle_mode_group_correct_answer_credit_score'] as String? ?? '0',
    // );
    // groupBattleWrongAnswerDeductScore = int.parse(
    //   json['battle_mode_group_wrong_answer_deduct_score'] as String? ?? '0',
    // );
    // TODO(J): will require changes in group battle flow. currently unused.
    // groupBattleQuickestCorrectAnswerExtraScore = int.parse(
    //   json['battle_mode_group_quickest_correct_answer_extra_score']
    //           as String? ??
    //       '0',
    // );
    // groupBattleSecondQuickestCorrectAnswerExtraScore = int.parse(
    //   json['battle_mode_group_second_quickest_correct_answer_extra_score']
    //           as String? ??
    //       '0',
    // );
    oneVsOneBattleMinimumEntryFee =
        int.parse(json['battle_mode_one_entry_coin'] as String);

    groupBattleMinimumEntryFee =
        int.parse(json['battle_mode_group_entry_coin'] as String);

    quizTimer = int.parse(json['quiz_zone_duration'] as String? ?? '0');
    referCoin = json['refer_coin'] as String? ?? '';
    reviewAnswersDeductCoins =
        int.parse(json['review_answers_deduct_coin'] as String? ?? '0');
    randomBattleTimer =
        int.parse(json['battle_mode_random_in_seconds'] as String? ?? '0');

    rewardAdsCoin = int.parse(json['reward_coin'] as String? ?? '0');
    selfChallengeMode = json['self_challenge_mode'] == '1';
    shareAppText = json['shareapp_text'] as String? ?? '';
    answerMode = AnswerMode.fromString(json['answer_mode'] as String);
    systemTimezone = json['system_timezone'] as String? ?? '';
    systemTimezoneGmt = json['system_timezone_gmt'] as String? ?? '';
    trueValue = json['true_value'] as String? ?? '';
    truefalseMode = (json['true_false_mode'] ?? '0') == '1';
    botImage = json['bot_image'] as String? ?? '';
    coinsPerDailyAdView = json['daily_ads_coins'] as String? ?? '0';
    isDailyAdsEnabled = (json['daily_ads_visibility'] ?? '0') == '1';
    totalDailyAds = int.parse(json['daily_ads_counter'] as String? ?? '0');
    quizZoneMode = (json['quiz_zone_mode'] ?? '0') == '1';
    randomBattleEntryCoins =
        int.parse(json['battle_mode_random_entry_coin'] as String? ?? '0');

    groupBattleRoomCodeCharType = RoomCodeCharType.fromString(
      json['battle_mode_group_code_char'] as String,
    );
    oneVsOneBattleRoomCodeCharType = RoomCodeCharType.fromString(
      json['battle_mode_one_code_char'] as String,
    );
    oneVsOneBattleCorrectAnswerCreditScore = int.parse(
      json['battle_mode_one_correct_answer_credit_score'] as String? ?? '0',
    );
    oneVsOneBattleWrongAnswerDeductScore = int.parse(
      json['battle_mode_one_wrong_answer_deduct_score'] as String? ?? '0',
    );
    oneVsOneBattleQuickestCorrectAnswerExtraScore = int.parse(
      json['battle_mode_one_quickest_correct_answer_extra_score'] as String? ??
          '0',
    );

    oneVsOneBattleSecondQuickestCorrectAnswerExtraScore = int.parse(
      json['battle_mode_one_second_quickest_correct_answer_extra_score']
              as String? ??
          '0',
    );

    randomBattleCorrectAnswerCreditScore = int.parse(
      json['battle_mode_random_correct_answer_credit_score'] as String? ?? '0',
    );
    randomBattleWrongAnswerDeductScore = int.parse(
      json['battle_mode_random_wrong_answer_deduct_score'] as String? ?? '0',
    );
    randomBattleQuickestCorrectAnswerExtraScore = int.parse(
      json['battle_mode_random_quickest_correct_answer_extra_score']
              as String? ??
          '0',
    );
    randomBattleSecondQuickestCorrectAnswerExtraScore = int.parse(
      json['battle_mode_random_second_quickest_correct_answer_extra_score']
              as String? ??
          '0',
    );

    randomBattleOpponentSearchDuration = int.parse(
      json['battle_mode_random_search_duration'] as String? ?? '0',
    );

    contestCorrectAnswerCreditScore = int.parse(
      json['contest_mode_correct_credit_score'] as String? ?? '0',
    );
    contestWrongAnswerDeductScore = int.parse(
      json['contest_mode_wrong_deduct_score'] as String? ?? '0',
    );

    guessTheWordHintsPerQuiz =
        int.parse(json['guess_the_word_max_hints'] as String? ?? '0');
    score = int.parse(json['score'] as String? ?? '0');

    selfChallengeMaxMinutes =
        int.parse(json['self_challenge_max_minutes'] as String? ?? '0');
    selfChallengeMaxQuestions =
        int.parse(json['self_challenge_max_questions'] as String? ?? '0');

    mathsQuizCorrectAnswerCreditScore = int.parse(
      json['maths_quiz_correct_answer_credit_score'] as String? ?? '0',
    );
    mathsQuizWrongAnswerDeductScore = int.parse(
      json['maths_quiz_wrong_answer_deduct_score'] as String? ?? '0',
    );
    funAndLearnCorrectAnswerCreditScore = int.parse(
      json['fun_n_learn_quiz_correct_answer_credit_score'] as String? ?? '0',
    );
    funAndLearnWrongAnswerDeductScore = int.parse(
      json['fun_n_learn_quiz_wrong_answer_deduct_score'] as String? ?? '0',
    );
    trueAndFalseCorrectAnswerCreditScore = int.parse(
      json['true_false_quiz_correct_answer_credit_score'] as String? ?? '0',
    );
    trueAndFalseWrongAnswerDeductScore = int.parse(
      json['true_false_quiz_wrong_answer_deduct_score'] as String? ?? '0',
    );

    resumeExamAfterCloseTimeout =
        int.parse(json['exam_module_resume_exam_timeout'] as String);
  }

  /// to Check if Ads are enabled in whole App or not.
  late bool adsEnabled;
  late int adsType;
  late String androidBannerId;
  late String androidGameID;
  late String androidInterstitialId;
  late String androidRewardedId;
  late AnswerMode answerMode;
  late String appLink;
  late bool appMaintenance;
  late String appVersion;
  late String appVersionIos;
  late bool audioQuestionMode;
  late int audioTimer;
  late bool battleGroupCategoryMode;
  late bool groupBattleMode;
  late bool oneVsOneBattleMode;
  late final bool randomBattleMode;
  late bool randomBattleCategoryMode;
  late int coinAmount;
  late int coinLimit;
  late bool contestMode;
  late String currencySymbol;
  late bool dailyQuizMode;
  late String earnCoin;
  late bool examMode;
  late String falseValue;
  late bool forceUpdate;
  late int funAndLearnTimer;
  late bool funNLearnMode;
  late int guessTheWordMaxWinningCoins;
  late bool guessTheWordMode;
  late int guessTheWordTimer;
  late bool inAppPurchaseMode;
  late String iosAppLink;
  late String iosBannerId;
  late String iosGameID;
  late String iosInterstitialId;
  late String iosMoreApps;
  late String iosRewardedId;
  late bool languageMode;
  late int lifelineDeductCoins;
  late bool mathQuizMode;
  late int mathsQuizTimer;
  late int maxWinningCoins;
  late double minWinningPercentage;
  late double quizWinningPercentage;
  late String moreApps;
  late String optionEMode;
  late bool paymentMode;
  late int perCoin;
  late int quizZoneCorrectAnswerCreditScore;
  late int quizZoneWrongAnswerDeductScore;
  late int guessTheWordCorrectAnswerCreditScore;
  late int guessTheWordWrongAnswerDeductScore;
  late int quizTimer;
  late int randomBattleEntryCoins;
  late int randomBattleTimer;
  late String referCoin;
  late int reviewAnswersDeductCoins;
  late int rewardAdsCoin;
  late bool selfChallengeMode;
  late int selfChallengeMaxMinutes;
  late int selfChallengeMaxQuestions;
  late String shareAppText;
  late String systemTimezone;
  late String systemTimezoneGmt;
  late String trueValue;
  late bool truefalseMode;
  late final String botImage;
  late final bool isDailyAdsEnabled;
  late final String coinsPerDailyAdView;
  late final int totalDailyAds;
  late final bool quizZoneMode;

  late final int guessTheWordHintsPerQuiz;
  late final int score;
  late final int audioQuizCorrectAnswerCreditScore;
  late final int audioQuizWrongAnswerDeductScore;
  late final RoomCodeCharType groupBattleRoomCodeCharType;
  late final RoomCodeCharType oneVsOneBattleRoomCodeCharType;
  late final int oneVsOneBattleTimer;
  late final int trueAndFalseTimer;

  late final int groupBattleTimer;
  late final int groupBattleMinimumEntryFee;
  late final int groupBattleCorrectAnswerCreditScore;
  late final int groupBattleWrongAnswerDeductScore;
  late final int groupBattleQuickestCorrectAnswerExtraScore;
  late final int groupBattleSecondQuickestCorrectAnswerExtraScore;

  late final bool oneVsOneBattleCategoryMode;
  late final int oneVsOneBattleMinimumEntryFee;
  late final int oneVsOneBattleCorrectAnswerCreditScore;
  late final int oneVsOneBattleWrongAnswerDeductScore;
  late final int oneVsOneBattleQuickestCorrectAnswerExtraScore;
  late final int oneVsOneBattleSecondQuickestCorrectAnswerExtraScore;

  late final int randomBattleCorrectAnswerCreditScore;
  late final int randomBattleWrongAnswerDeductScore;
  late final int randomBattleQuickestCorrectAnswerExtraScore;
  late final int randomBattleSecondQuickestCorrectAnswerExtraScore;
  late final int randomBattleOpponentSearchDuration;

  late final int mathsQuizCorrectAnswerCreditScore;
  late final int mathsQuizWrongAnswerDeductScore;
  late final int funAndLearnCorrectAnswerCreditScore;
  late final int funAndLearnWrongAnswerDeductScore;
  late final int trueAndFalseCorrectAnswerCreditScore;
  late final int trueAndFalseWrongAnswerDeductScore;

  late final int contestCorrectAnswerCreditScore;
  late final int contestWrongAnswerDeductScore;

  late final int resumeExamAfterCloseTimeout;
}
