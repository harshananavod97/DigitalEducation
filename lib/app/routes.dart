import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/screens/about_app_screen.dart';
import 'package:flutterquiz/ui/screens/app_settings_screen.dart';
import 'package:flutterquiz/ui/screens/auth/otp_screen.dart';
import 'package:flutterquiz/ui/screens/auth/sign_in_screen.dart';
import 'package:flutterquiz/ui/screens/auth/sign_up_screen.dart';
import 'package:flutterquiz/ui/screens/badgesScreen.dart';
import 'package:flutterquiz/ui/screens/battle/battleRoomFindOpponentScreen.dart';
import 'package:flutterquiz/ui/screens/battle/battleRoomQuizScreen.dart';
import 'package:flutterquiz/ui/screens/battle/multiUserBattleRoomQuizScreen.dart';
import 'package:flutterquiz/ui/screens/battle/multiUserBattleRoomResultScreen.dart';
import 'package:flutterquiz/ui/screens/battle/random_battle_screen.dart';
import 'package:flutterquiz/ui/screens/bookmarkScreen.dart';
import 'package:flutterquiz/ui/screens/coinHistoryScreen.dart';
import 'package:flutterquiz/ui/screens/exam/exam_screen.dart';
import 'package:flutterquiz/ui/screens/exam/exams_screen.dart';
import 'package:flutterquiz/ui/screens/home/MainHome.dart';
import 'package:flutterquiz/ui/screens/home/home_screen.dart';
import 'package:flutterquiz/ui/screens/home/leaderboard_screen.dart';
import 'package:flutterquiz/ui/screens/home/setting_screen.dart';
import 'package:flutterquiz/ui/screens/inapp_coin_store_screen.dart';
import 'package:flutterquiz/ui/screens/initial_language_selection_screen.dart';
import 'package:flutterquiz/ui/screens/menu/menu_screen.dart';
import 'package:flutterquiz/ui/screens/notifications_screen.dart';
import 'package:flutterquiz/ui/screens/onboarding_screen.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/bookmarkQuizScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/categoryScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/contestLeaderboardScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/contest_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/funAndLearnScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/funAndLearnTitleScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/guess_the_word_quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/levels_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/resultScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/reviewAnswersScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/selfChallengeQuestionsScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/selfChallengeScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/subCategoryAndLevelScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/subCategoryScreen.dart';
import 'package:flutterquiz/ui/screens/refer_and_earn_screen.dart';
import 'package:flutterquiz/ui/screens/rewards/rewardsScreen.dart';
import 'package:flutterquiz/ui/screens/splash_screen.dart';
import 'package:flutterquiz/ui/screens/statisticsScreen.dart';
import 'package:flutterquiz/ui/screens/wallet/walletScreen.dart';

class Routes {
  static const home = '/';
  static const login = 'login';
  static const splash = 'splash';
  static const signUp = 'signUp';
  static const introSlider = 'introSlider';
  static const selectProfile = 'selectProfile';
  static const quiz = '/quiz';
  static const subcategoryAndLevel = '/subcategoryAndLevel';
  static const subCategory = '/subCategory';

  static const referAndEarn = '/referAndEarn';
  static const notification = '/notification';
  static const bookmark = '/bookmark';
  static const bookmarkQuiz = '/bookmarkQuiz';
  static const coinStore = '/coinStore';
  static const rewards = '/rewards';
  static const result = '/result';
  static const selectRoom = '/selectRoom';
  static const category = '/category';
  static const profile = '/profile';
  static const editProfile = '/editProfile';
  static const leaderBoard = '/leaderBoard';
  static const settings = '/settings';

  static const reviewAnswers = '/reviewAnswers';
  static const selfChallenge = '/selfChallenge';
  static const selfChallengeQuestions = '/selfChallengeQuestions';
  static const battleRoomQuiz = '/battleRoomQuiz';
  static const battleRoomFindOpponent = '/battleRoomFindOpponent';

  static const logOut = '/logOut';
  static const trueFalse = '/trueFalse';
  static const multiUserBattleRoomQuiz = '/multiUserBattleRoomQuiz';
  static const multiUserBattleRoomQuizResult = '/multiUserBattleRoomQuizResult';

  static const contest = '/contest';
  static const contestLeaderboard = '/contestLeaderboard';
  static const funAndLearnTitle = '/funAndLearnTitle';
  static const funAndLearn = 'funAndLearn';
  static const guessTheWord = '/guessTheWord';
  static const appSettings = '/appSettings';
  static const levels = '/levels';
  static const aboutApp = '/aboutApp';
  static const badges = '/badges';
  static const exams = '/exams';
  static const exam = '/exam';
  static const otpScreen = '/otpScreen';
  static const statistics = '/statistics';
  static const coinHistory = '/coinHistory';
  static const wallet = '/wallet';
  static const menuScreen = '/menuScreen';
  static const randomBattle = '/randomBattle';
  static const languageSelect = '/language-select';

  static String currentRoute = splash;

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? '';

    log(name: 'Current Route', currentRoute);

    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MainHomeScreen.route(routeSettings);
      case introSlider:
        return CupertinoPageRoute(builder: (_) => const IntroSliderScreen());
      case login:
        return CupertinoPageRoute(builder: (_) => const SignInScreen());
      case signUp:
        return CupertinoPageRoute(builder: (_) => const SignUpScreen());
      case otpScreen:
        return OtpScreen.route(routeSettings);
      case subcategoryAndLevel:
        return SubCategoryAndLevelScreen.route(routeSettings);
      case selectProfile:
        return CreateOrEditProfileScreen.route(routeSettings);
      case quiz:
        return QuizScreen.route(routeSettings);
      case wallet:
        return WalletScreen.route(routeSettings);
      case menuScreen:
        return MenuScreen.route(routeSettings);
      case coinStore:
        return CoinStoreScreen.route(routeSettings);
      case rewards:
        return RewardsScreen.route(routeSettings);
      case referAndEarn:
        return CupertinoPageRoute(builder: (_) => const ReferAndEarnScreen());
      case result:
        return ResultScreen.route(routeSettings);
      case reviewAnswers:
        return ReviewAnswersScreen.route(routeSettings);
      case selfChallenge:
        return SelfChallengeScreen.route(routeSettings);
      case selfChallengeQuestions:
        return SelfChallengeQuestionsScreen.route(routeSettings);
      case category:
        return CategoryScreen.route(routeSettings);
      case leaderBoard:
        return LeaderBoardScreen.route();
      case settings:
        return SettingScreen.route(routeSettings);
      case bookmark:
        return CupertinoPageRoute(builder: (_) => const BookmarkScreen());
      case bookmarkQuiz:
        return BookmarkQuizScreen.route(routeSettings);
      case battleRoomQuiz:
        return BattleRoomQuizScreen.route(routeSettings);
      case notification:
        return NotificationScreen.route(routeSettings);
      case funAndLearnTitle:
        return FunAndLearnTitleScreen.route(routeSettings);
      case funAndLearn:
        return FunAndLearnScreen.route(routeSettings);
      case multiUserBattleRoomQuiz:
        return MultiUserBattleRoomQuizScreen.route(routeSettings);
      case contest:
        return ContestScreen.route(routeSettings);
      case guessTheWord:
        return GuessTheWordQuizScreen.route(routeSettings);
      case multiUserBattleRoomQuizResult:
        return MultiUserBattleRoomResultScreen.route(routeSettings);
      case contestLeaderboard:
        return ContestLeaderBoardScreen.route(routeSettings);
      case battleRoomFindOpponent:
        return BattleRoomFindOpponentScreen.route(routeSettings);
      case appSettings:
        return AppSettingsScreen.route(routeSettings);
      case levels:
        return LevelsScreen.route(routeSettings);
      case coinHistory:
        return CoinHistoryScreen.route(routeSettings);
      case aboutApp:
        return CupertinoPageRoute(builder: (_) => const AboutAppScreen());
      case subCategory:
        return SubCategoryScreen.route(routeSettings);
      case badges:
        return BadgesScreen.route(routeSettings);
      case exams:
        return ExamsScreen.route();
      case exam:
        return ExamScreen.route(routeSettings);
      case statistics:
        return StatisticsScreen.route();
      case randomBattle:
        return RandomBattleScreen.route(routeSettings);
      case languageSelect:
        return InitialLanguageSelectionScreen.route();
      default:
        return CupertinoPageRoute(builder: (_) => const Scaffold());
    }
  }
}
