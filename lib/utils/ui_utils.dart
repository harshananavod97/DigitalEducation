import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/errorMessageDialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

//Need to optimize and separate the ui and other logic related process

class UiUtils {
  static const questionContainerHeightPercentage = 0.785;

  static const questionContainerWidthPercentage = 0.90;

  static const profileHeightBreakPointResultScreen = 355.0;
  static const appBarHeightPercentage = 0.16;
  static const bottomMenuPercentage = 0.075;

  /// Dialog
  static const dialogBlurSigma = 9.0;

  /// Bottom Sheet
  static const bottomSheetTopRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  /// Badges
  static List<String> needToUpdateBadgesLocally = [];

  /// Global
  // Margin Percentage for Screen Content
  static const hzMarginPct = 0.04;
  static const vtMarginPct = 0.02;

  // Space in-between List Tiles
  static const listTileGap = 12.0;

  static String buildGuessTheWordQuestionAnswer(List<String> submittedAnswer) {
    var answer = '';
    for (final element in submittedAnswer) {
      if (element.isNotEmpty) answer = answer + element;
    }
    return answer;
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    //
    final msgType = message.data['type'].toString();
    if (msgType == 'badges') {
      needToUpdateBadgesLocally.add(message.data['badge_type'].toString());
    } else if (msgType == 'payment_request') {
      await ProfileManagementLocalDataSource.updateReversedCoins(
        double.parse(message.data['coins'].toString()).toInt(),
      );
    }
  }

  static void updateBadgesLocally(BuildContext context) {
    for (final badgeType in needToUpdateBadgesLocally) {
      context.read<BadgesCubit>().unlockBadge(badgeType);
    }
    needToUpdateBadgesLocally.clear();
  }

  static Future<void> needToUpdateCoinsLocally(BuildContext context) async {
    final coins =
        await ProfileManagementLocalDataSource.getUpdateReversedCoins();

    if (coins != 0) {
      context.read<UserDetailsCubit>().updateCoins(addCoin: true, coins: coins);
    }
  }

  static void showSnackBar(
    String msg,
    BuildContext context, {
    bool showAction = false,
    Function? onPressedAction,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: showAction ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeights.regular,
              fontSize: 16,
            ),
          ),
        ),
        behavior: SnackBarBehavior.fixed,
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
        action: showAction
            ? SnackBarAction(
                label: 'Retry',
                onPressed: onPressedAction! as void Function(),
                textColor: Theme.of(context).colorScheme.surface,
              )
            : null,
        elevation: 2,
      ),
    );
  }

  static void errorMessageDialog(BuildContext context, String? errorMessage) {
    showDialog<void>(
      context: context,
      builder: (_) => ErrorMessageDialog(errorMessage: errorMessage),
    );
  }

  static BoxShadow buildBoxShadow({
    Offset? offset,
    double? blurRadius,
    Color? color,
  }) {
    return BoxShadow(
      color: color ?? Colors.black.withOpacity(0.1),
      blurRadius: blurRadius ?? 10.0,
      offset: offset ?? const Offset(5, 5),
    );
  }

  static String getCurrentQuestionLanguageId(BuildContext context) {
    final currentLanguage = context.read<AppLocalizationCubit>().state.language;
    if (context.read<SystemConfigCubit>().isLanguageModeEnabled) {
      final supportedLanguage =
          context.read<SystemConfigCubit>().getSupportedLanguages();
      final supportedLanguageIndex = supportedLanguage.indexWhere(
        (element) =>
            getLocaleFromLanguageCode(element.languageCode) == currentLanguage,
      );

      return supportedLanguageIndex == -1
          ? defaultLanguageCode
          : supportedLanguage[supportedLanguageIndex].id;
    }

    return defaultQuestionLanguageId;
  }

  static String getCurrentQuestionLanguagecode(BuildContext context) {
    final currentLanguage = context.read<AppLocalizationCubit>().state.language;
    if (context.read<SystemConfigCubit>().isLanguageModeEnabled) {
      final supportedLanguage =
          context.read<SystemConfigCubit>().getSupportedLanguages();
      final supportedLanguageIndex = supportedLanguage.indexWhere(
        (element) =>
            getLocaleFromLanguageCode(element.languageCode) == currentLanguage,
      );

      return supportedLanguageIndex == -1
          ? defaultLanguageCode
          : supportedLanguage[supportedLanguageIndex].languageCode;
    }

    return defaultQuestionLanguageId;
  }

  static double getTransactionContainerHeight(double dheight) {
    if (dheight >= 800) {
      return 0.1;
    }
    if (dheight >= 700) {
      return 0.145;
    }
    if (dheight >= 600) {
      return 0.165;
    }
    return 0.1775;
  }

  static double getQuestionContainerTopPaddingPercentage(double dheight) {
    if (dheight >= 800) {
      return 0.06;
    }
    if (dheight >= 700) {
      return 0.065;
    }
    if (dheight >= 600) {
      return 0.07;
    }
    return 0.075;
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    final result = languageCode.split('-');

    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static String formatNumber(int number) {
    return NumberFormat.compact().format(number).toLowerCase();
  }

  //This method will determine how much coins will user get after
  //completing the quiz
  static int coinsBasedOnWinPercentage({
    required double percentage,
    required QuizTypes quizType,
    required double maxCoinsWinningPercentage,
    required int guessTheWordMaxWinningCoins,
    required int maxWinningCoins,
  }) {
    //if percentage is more than maxCoinsWinningPercentage then user will earn maxWinningCoins
    //
    //if percentage is less than maxCoinsWinningPercentage
    //coin value will deduct from maxWinning coins
    //earned coins = (maxWinningCoins - ((maxCoinsWinningPercentage - percentage)/ 10))

    //For example: if percentage is 70 then user will
    //earn 3 coins if maxWinningCoins is 4

    var earnedCoins = 0;
    if (percentage >= maxCoinsWinningPercentage) {
      earnedCoins = quizType == QuizTypes.guessTheWord
          ? guessTheWordMaxWinningCoins
          : maxWinningCoins;
    } else {
      final maxCoins = quizType == QuizTypes.guessTheWord
          ? guessTheWordMaxWinningCoins
          : maxWinningCoins;

      earnedCoins =
          (maxCoins - ((maxCoinsWinningPercentage - percentage) / 10)).toInt();
    }

    return earnedCoins < 0 ? 0 : earnedCoins;
  }

  static String getCategoryTypeNumberFromQuizType(QuizTypes quizType) {
    return switch (quizType) {
      QuizTypes.mathMania => '5',
      QuizTypes.audioQuestions => '4',
      QuizTypes.guessTheWord => '3',
      QuizTypes.funAndLearn => '2',
      _ => '1', // Quiz Zone
    };
  }

  static String subTypeFromQuizType(QuizTypes type) => switch (type) {
        QuizTypes.groupPlay => '3',
        QuizTypes.oneVsOneBattle => '2',
        QuizTypes.selfChallenge => '1',
        _ => '',
      };

  //calculate amount per coins based on users coins
  static double calculateAmountPerCoins({
    required int userCoins,
    required int amount,
    required int coins,
  }) {
    return (amount * userCoins) / coins;
  }

  //calculate coins based on entered amount
  static int calculateDeductedCoinsForRedeemableAmount({
    required double userEnteredAmount,
    required int amount,
    required int coins,
  }) {
    return (coins * userEnteredAmount) ~/ amount;
  }

  static Future<bool> forceUpdate(String updatedVersion) async {
    if (updatedVersion.isEmpty) {
      return false;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    final updateBasedOnVersion = _shouldUpdateBasedOnVersion(
      currentVersion.split('+').first,
      updatedVersion.split('+').first,
    );

    if (updatedVersion.split('+').length == 1 ||
        currentVersion.split('+').length == 1) {
      return updateBasedOnVersion;
    }

    final updateBasedOnBuildNumber = _shouldUpdateBasedOnBuildNumber(
      currentVersion.split('+').last,
      updatedVersion.split('+').last,
    );

    return updateBasedOnVersion || updateBasedOnBuildNumber;
  }

  static bool _shouldUpdateBasedOnVersion(
    String currentVersion,
    String updatedVersion,
  ) {
    final currentVersionList =
        currentVersion.split('.').map(int.parse).toList();
    final updatedVersionList =
        updatedVersion.split('.').map(int.parse).toList();

    if (updatedVersionList[0] > currentVersionList[0]) {
      return true;
    }
    if (updatedVersionList[1] > currentVersionList[1]) {
      return true;
    }
    if (updatedVersionList[2] > currentVersionList[2]) {
      return true;
    }

    return false;
  }

  static bool _shouldUpdateBasedOnBuildNumber(
    String currentBuildNumber,
    String updatedBuildNumber,
  ) {
    return int.parse(updatedBuildNumber) > int.parse(currentBuildNumber);
  }

  static void vibrate() {
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  static void fetchBookmarkAndBadges({
    required BuildContext context,
    required String userId,
  }) {
    //fetch bookmark quiz zone
    if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
      context.read<BookmarkCubit>().getBookmark(userId);
      //delete any unused group battle room which is created by this user
      // BattleRoomRepository().deleteUnusedBattleRoom(userId);
    }

    //fetch guess the word bookmark
    if (context.read<GuessTheWordBookmarkCubit>().state
        is! GuessTheWordBookmarkFetchSuccess) {
      context.read<GuessTheWordBookmarkCubit>().getBookmark(userId);
    }

    //fetch audio question bookmark
    if (context.read<AudioQuestionBookmarkCubit>().state
        is! AudioQuestionBookmarkFetchSuccess) {
      context.read<AudioQuestionBookmarkCubit>().getBookmark(userId);
    }

    if (context.read<BadgesCubit>().state is! BadgesFetchSuccess) {
      //get badges for given user
      context.read<BadgesCubit>().getBadges(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          );
    }

    //complete any pending exam
    context.read<ExamCubit>().completePendingExams();
  }

  static int determineBattleCorrectAnswerPoints(
    double animationControllerValue,
    int questionDurationInSeconds,
    int correctAnswerScore,
    int quickestExtraScore,
    int secondQuickestExtraScore,
  ) {
    final secondsTakenToAnswer =
        questionDurationInSeconds * animationControllerValue;

    //improve points system here if needed
    if (secondsTakenToAnswer <= 2) {
      return correctAnswerScore + quickestExtraScore;
    } else if (secondsTakenToAnswer <= 4) {
      return correctAnswerScore + secondQuickestExtraScore;
    }
    return correctAnswerScore;
  }

  static double timeTakenToSubmitAnswer({
    required double animationControllerValue,
    required int quizTimer,
  }) =>
      quizTimer * animationControllerValue;

  /// Use Builder on top of the widget you use it. to get the correct context.
  /// and size of the widget.
  static Future<void> share(
    String text, {
    required BuildContext context,
    List<XFile>? files,
    String? subject,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    if (files != null) {
      await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    } else {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
