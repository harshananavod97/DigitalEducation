import 'package:flutterquiz/features/wallet/models/payoutMethod.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';

export 'api_body_parameter_labels.dart';
export 'assets_constants.dart';
export 'error_message_keys.dart';
export 'fonts.dart';
export 'hive_constants.dart';
export 'sound_constants.dart';
export 'string_labels.dart';

const appName = 'Digital  Education';
const packageName = 'com.harshana.digitaleducation';
const iosAppId = '585027354';

/// Add your database url
// NOTE: make sure to not add '/' at the end of url
// NOTE: make sure to check if admin panel is http or https
const databaseUrl = 'https://www.digitaleducation.tech';

/// Add language code in this list
// visit this to find languageCode for your respective language
// https://developers.google.com/admin-sdk/directory/v1/languages
// NOTE: only languageCodes given mentioned in the above links are supported.
const supportedLocales = ['en', 'hi', 'ur', 'en-GB'];
const defaultLanguageCode = 'en-GB';

// Enter 2 Letter ISO Country Code
const defaultCountryCodeForPhoneLogin = 'LK';

/// Default App Theme : lightThemeKey or darkThemeKey
const defaultThemeKey = lightThemeKey;

//Database related constants
const baseUrl = '$databaseUrl/Api/';

//lifelines
const fiftyFifty = 'fiftyFifty';
const audiencePoll = 'audiencePoll';
const skip = 'skip';
const resetTime = 'resetTime';

//firestore collection names
const battleRoomCollection = 'battleRoom'; //  testBattleRoom
const multiUserBattleRoomCollection =
    'multiUserBattleRoom'; //testMultiUserBattleRoom
const messagesCollection = 'messages'; // testMessages

//api end pos
const addUserUrl = '${baseUrl}user_signup';

const getQuestionForOneToOneBattle = '${baseUrl}get_random_questions';
const getQuestionForMultiUserBattle = '${baseUrl}get_question_by_room_id';
const createMultiUserBattleRoomUrl = '${baseUrl}create_room';
const deleteMultiUserBattleRoom = '${baseUrl}destroy_room_by_room_id';

const getBookmarkUrl = '${baseUrl}get_bookmark';
const updateBookmarkUrl = '${baseUrl}set_bookmark';

const getNotificationUrl = '${baseUrl}get_notifications';

const getUserDetailsByIdUrl = '${baseUrl}get_user_by_id';
const checkUserExistUrl = '${baseUrl}check_user_exists';

const uploadProfileUrl = '${baseUrl}upload_profile_image';
const updateUserCoinsAndScoreUrl = '${baseUrl}set_user_coin_score';
const updateProfileUrl = '${baseUrl}update_profile';

const getCategoryUrl = '${baseUrl}get_categories';
const getQuestionsByLevelUrl = '${baseUrl}get_questions_by_level';
const getQuestionForDailyQuizUrl = '${baseUrl}get_daily_quiz';
const getLevelUrl = '${baseUrl}get_level_data';
const getSubCategoryUrl = '${baseUrl}get_subcategory_by_maincategory';
const getQuestionForSelfChallengeUrl =
    '${baseUrl}get_questions_for_self_challenge';
const updateLevelUrl = '${baseUrl}set_level_data';
const getMonthlyLeaderboardUrl = '${baseUrl}get_monthly_leaderboard';
const getDailyLeaderboardUrl = '${baseUrl}get_daily_leaderboard';
const getAllTimeLeaderboardUrl = '${baseUrl}get_globle_leaderboard';
const getQuestionByTypeUrl = '${baseUrl}get_questions_by_type';
const getQuestionContestUrl = '${baseUrl}get_questions_by_contest';
const setContestLeaderboardUrl = '${baseUrl}set_contest_leaderboard';
const getContestLeaderboardUrl = '${baseUrl}get_contest_leaderboard';

const getFunAndLearnUrl = '${baseUrl}get_fun_n_learn';
const getFunAndLearnQuestionsUrl = '${baseUrl}get_fun_n_learn_questions';

const getStatisticUrl = '${baseUrl}get_users_statistics';
const updateStatisticUrl = '${baseUrl}set_users_statistics';

const getContestUrl = '${baseUrl}get_contest';
const getSystemConfigUrl = '${baseUrl}get_system_configurations';
const getCoinStoreData = '${baseUrl}get_coin_store_data';

const getSupportedQuestionLanguageUrl = '${baseUrl}get_languages';
const getGuessTheWordQuestionUrl = '${baseUrl}get_guess_the_word';
const getAppSettingsUrl = '${baseUrl}get_settings';
const reportQuestionUrl = '${baseUrl}report_question';
const getQuestionsByCategoryOrSubcategory = '${baseUrl}get_questions';
const updateFcmIdUrl = '${baseUrl}update_fcm_id';
const getAudioQuestionUrl = '${baseUrl}get_audio_questions'; //
const getUserBadgesUrl = '${baseUrl}get_user_badges';
const setUserBadgesUrl = '${baseUrl}set_badges';
const setBattleStatisticsUrl = '${baseUrl}set_battle_statistics';
const getBattleStatisticsUrl = '${baseUrl}get_battle_statistics';

const getExamModuleUrl = '${baseUrl}get_exam_module';
const getExamModuleQuestionsUrl = '${baseUrl}get_exam_module_questions';
const setExamModuleResultUrl = '${baseUrl}set_exam_module_result';
const deleteUserAccountUrl = '${baseUrl}delete_user_account';
const getCoinHistoryUrl = '${baseUrl}get_tracker_data';
const makePaymentRequestUrl = '${baseUrl}set_payment_request';
const getTransactionsUrl = '${baseUrl}get_payment_request';
const getLatexQuestionUrl = '${baseUrl}get_maths_questions';
const cancelPaymentRequestUrl = '${baseUrl}delete_pending_payment_request';

const setQuizCategoryPlayedUrl = '${baseUrl}set_quiz_categories';
const unlockPremiumCategoryUrl = '${baseUrl}unlock_premium_category';

const purchaseIAP = '${baseUrl}set_user_in_app';

//
const watchedDailyAdUrl = '${baseUrl}update_daily_ads_counter';

// Phone Number
const maxPhoneNumberLength = 16;

const inBetweenQuestionTimeInSeconds = 1;

//other constants
const defaultQuestionLanguageId = '';

//predefined messages for battle
const predefinedMessages = [
  'Hello..!!',
  'How are you..?',
  'Fine..!!',
  'Have a nice day..',
  'Well played',
  'What a performance..!!',
  'Thanks..',
  'Welcome..',
  'Merry Christmas',
  'Happy new year',
  'Happy Diwali',
  'Good night',
  'Hurry Up',
  'Dudeeee',
];

//constants for badges and rewards
const minimumQuestionsForBadges = 5;

///
///Add your exam rules here
///
const examRules = [
  'I will not copy and give this exam with honesty',
  'If you lock your phone then exam will complete automatically',
  "If you minimize application or open other application and don't come back to application with in 5 seconds then exam will complete automatically",
  'Screen recording is prohibited',
  'In Android screenshot capturing is prohibited',
  'In ios, if you take screenshot then rules will violate and it will inform to examiner',
];

//
//Add notes for wallet request
//

List<String> payoutRequestNotes(
  String payoutRequestCurrency,
  String amount,
  String coins,
) {
  return [
    'Minimum Redeemable amount is $payoutRequestCurrency $amount ($coins Coins).',
    'Payout will take 3 - 5 working days',
  ];
}

//To add more payout methods here
final payoutMethods = [
  //Paypal
  PayoutMethod(
    image: 'assets/images/paypal.svg',
    type: 'Paypal',
    inputs: [
      (
        name: 'Enter paypal id', // Name for the field
        isNumber: false, // If input is number or not
        maxLength: 0, // Leave 0 for no limit for input.
      ),
    ],
  ),

  //Paytm
  PayoutMethod(
    image: 'assets/images/paytm.svg',
    type: 'Paytm',
    inputs: [
      (
        name: 'Enter mobile number',
        isNumber: true,
        maxLength: 10,
      ),
    ],
  ),

  //UPI
  PayoutMethod(
    image: 'assets/images/upi.svg',
    type: 'UPI',
    inputs: [
      (
        name: 'Enter UPI id',
        isNumber: false,
        maxLength: 0, // Leave 0 for no limit for input.
      ),
    ],
  ),

  /// Example: Bank Transfer
  // PayoutMethod(
  //   inputs: [
  //     (
  //       name: 'Enter Bank Name',
  //       isNumber: false,
  //       maxLength: 0,
  //     ),
  //     (
  //       name: 'Enter Account Number',
  //       isNumber: false,
  //       maxLength: 0,
  //     ),
  //     (
  //       name: 'Enter IFSC Code',
  //       isNumber: false,
  //       maxLength: 0,
  //     ),
  //   ],
  //   image: 'assets/images/paytm.svg',
  //   type: 'Bank Transfer',
  // ),
];

// Max Group Battle Players, do not change.
const maxUsersInGroupBattle = 4;
