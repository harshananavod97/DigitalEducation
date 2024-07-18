import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehensionCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/setCategoryPlayedCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/setContestLeaderboardCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/updateLevelCubit.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/statistic/cubits/updateStatisticCubit.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radialResultContainer.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.isPlayed,
    required this.comprehension,
    required this.playWithBot,
    required this.isPremiumCategory,
    super.key,
    this.exam,
    this.correctExamAnswers,
    this.incorrectExamAnswers,
    this.obtainedMarks,
    this.examCompletedInMinutes,
    this.timeTakenToCompleteQuiz,
    this.hasUsedAnyLifeline,
    this.numberOfPlayer,
    this.myPoints,
    this.battleRoom,
    this.questions,
    this.unlockedLevel,
    this.quizType,
    this.subcategoryMaxLevel,
    this.contestId,
    this.guessTheWordQuestions,
    this.entryFee,
    this.categoryId,
    this.subcategoryId,
  });

  final QuizTypes?
      quizType; //to show different kind of result data for different quiz type
  final int?
      numberOfPlayer; //to show different kind of result data for number of player
  final int?
      myPoints; // will be in use when quiz is not type of battle and live battle
  final List<Question>? questions; //to see review answers
  final BattleRoom? battleRoom; //will be in use for battle
  final bool
      playWithBot; // used for random battle with robot, users doesn't get any coins or score for playing with bot.
  final String? contestId;
  final Comprehension comprehension; //
  final List<GuessTheWordQuestion>?
      guessTheWordQuestions; //questions when quiz type is guessTheWord
  final int? entryFee;

  //if quizType is quizZone then it will be in use
  //to determine to show next level button
  //it will be in use if quizType is quizZone
  final String? subcategoryMaxLevel;

  //to determine if we need to update level or not
  //it will be in use if quizType is quizZone
  final int? unlockedLevel;

  //Time taken to complete the quiz in seconds
  final double? timeTakenToCompleteQuiz;

  //has used any lifeline - it will be in use to check badge earned or not for
  //quizZone quiz type
  final bool? hasUsedAnyLifeline;

  //Exam module details
  final Exam? exam; //to get the details related exam
  final int? obtainedMarks;
  final int? examCompletedInMinutes;
  final int? correctExamAnswers;
  final int? incorrectExamAnswers;
  final String? categoryId;
  final String? subcategoryId;

  //This will be in use if quizType is audio questions
  // and guess the word
  final bool isPlayed; //

  final bool isPremiumCategory;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map;
    //keys of map are numberOfPlayer,quizType,questions (required)
    //if quizType is not battle and liveBattle need to pass following args
    //myPoints
    //if quizType is quizZone then need to pass following arguments
    //subcategoryMaxLevel, unlockedLevel
    //if quizType is battle and liveBattle then need to pass following arguments
    //battleRoom
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          //to update unlocked level for given subcategory
          BlocProvider<UpdateLevelCubit>(
            create: (_) => UpdateLevelCubit(QuizRepository()),
          ),
          //to update user score and coins
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          //to update statistic
          BlocProvider<UpdateStatisticCubit>(
            create: (_) => UpdateStatisticCubit(StatisticRepository()),
          ),
          //set ContestLeaderBoard
          BlocProvider<SetContestLeaderboardCubit>(
            create: (_) => SetContestLeaderboardCubit(QuizRepository()),
          ),
          //set quiz category played
          BlocProvider<SetCategoryPlayed>(
            create: (_) => SetCategoryPlayed(QuizRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: ResultScreen(
          battleRoom: args['battleRoom'] as BattleRoom?,
          categoryId: args['categoryId'] as String? ?? '',
          comprehension:
              args['comprehension'] as Comprehension? ?? Comprehension.empty(),
          contestId: args['contestId'] as String?,
          correctExamAnswers: args['correctExamAnswers'] as int?,
          entryFee: args['entryFee'] as int?,
          exam: args['exam'] as Exam?,
          examCompletedInMinutes: args['examCompletedInMinutes'] as int?,
          guessTheWordQuestions:
              args['guessTheWordQuestions'] as List<GuessTheWordQuestion>?,
          hasUsedAnyLifeline: args['hasUsedAnyLifeline'] as bool?,
          incorrectExamAnswers: args['incorrectExamAnswers'] as int?,
          isPlayed: args['isPlayed'] as bool? ?? true,
          myPoints: args['myPoints'] as int?,
          numberOfPlayer: args['numberOfPlayer'] as int?,
          obtainedMarks: args['obtainedMarks'] as int?,
          playWithBot: args['play_with_bot'] as bool? ?? false,
          questions: args['questions'] as List<Question>?,
          quizType: args['quizType'] as QuizTypes?,
          subcategoryId: args['subcategoryId'] as String? ?? '',
          subcategoryMaxLevel: args['subcategoryMaxLevel'] as String?,
          timeTakenToCompleteQuiz: args['timeTakenToCompleteQuiz'] as double?,
          unlockedLevel: args['unlockedLevel'] as int?,
          isPremiumCategory: args['isPremiumCategory'] as bool? ?? false,
        ),
      ),
    );
  }

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<Map<String, dynamic>> usersWithRank = [];
  late final String userName;
  late bool _isWinner;
  int _earnedCoins = 0;
  String? _winnerId;

  bool _displayedAlreadyLoggedInDialog = false;

  late final didSkipQue = widget.quizType == QuizTypes.quizZone &&
      widget.questions!.map((e) => e.submittedAnswerId).contains('0');

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (!widget.isPremiumCategory) {
        context.read<InterstitialAdCubit>().showAd(context);
      }
    });
    if (widget.quizType == QuizTypes.oneVsOneBattle) {
      battleConfiguration();
      userName = '';
    } else {
      //decide winner
      if (winPercentage() >=
          context.read<SystemConfigCubit>().quizWinningPercentage) {
        _isWinner = true;
      } else {
        _isWinner = false;
      }
      //earn coins based on percentage
      earnCoinsBasedOnWinPercentage();
      setContestLeaderboard();
      userName = context.read<UserDetailsCubit>().getUserName();
    }

    //check for badges
    //update score,coins and statistic related details

    Future.delayed(Duration.zero, () {
      //earnBadge will check the condition for unlocking badges and
      //will return true or false
      //we need to return bool value so we can pass this to
      //updateScoreAndCoinsCubit since dashing_debut badge will unlock
      //from set_user_coin_score api
      _earnBadges();
      _updateScoreAndCoinsDetails();
      _updateStatistics();
      fetchUpdateUserDetails();
    });
  }

  Future<void> fetchUpdateUserDetails() async {
    if (widget.quizType == QuizTypes.quizZone ||
        widget.quizType == QuizTypes.funAndLearn ||
        widget.quizType == QuizTypes.guessTheWord ||
        widget.quizType == QuizTypes.audioQuestions ||
        widget.quizType == QuizTypes.mathMania) {
      await context.read<UserDetailsCubit>().fetchUserDetails();
    }
  }

  void _updateStatistics() {
    if (widget.quizType != QuizTypes.selfChallenge &&
        widget.quizType != QuizTypes.exam) {
      context.read<UpdateStatisticCubit>().updateStatistic(
            answeredQuestion: attemptedQuestion(),
            categoryId: getCategoryIdOfQuestion(),
            correctAnswers: correctAnswer(),
            winPercentage: winPercentage(),
          );
    }
  }

  //update stats related to battle, score of user and coins given to winner
  Future<void> battleConfiguration() async {
    var winnerId = '';

    if (widget.battleRoom!.user1!.points == widget.battleRoom!.user2!.points) {
      _isWinner = true;
      _winnerId = winnerId;

      /// No Coins & Score when playing with Robot.
      if (!widget.playWithBot) {
        _updateCoinsAndScoreAndStatisticForBattle(widget.battleRoom!.entryFee!);
      }
    } else {
      if (widget.battleRoom!.user1!.points > widget.battleRoom!.user2!.points) {
        winnerId = widget.battleRoom!.user1!.uid;
      } else {
        winnerId = widget.battleRoom!.user2!.uid;
      }
      await Future<void>.delayed(Duration.zero);
      _isWinner = context.read<UserDetailsCubit>().userId() == winnerId;
      _winnerId = winnerId;

      if (!widget.playWithBot) {
        _updateCoinsAndScoreAndStatisticForBattle(
          widget.battleRoom!.entryFee! * 2,
        );
      }
      //update winner id and _isWinner in ui
      setState(() {});
    }
  }

  void _updateCoinsAndScoreAndStatisticForBattle(int earnedCoins) {
    Future.delayed(
      Duration.zero,
      () {
        //
        final currentUserId = context.read<UserDetailsCubit>().userId();
        final currentUser = widget.battleRoom!.user1!.uid == currentUserId
            ? widget.battleRoom!.user1!
            : widget.battleRoom!.user2!;
        if (_isWinner) {
          //update score and coins for user
          context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
                currentUser.points,
                earnedCoins,
                wonBattleKey,
              );
          //update score locally and database
          context.read<UserDetailsCubit>().updateCoins(
                addCoin: true,
                coins: earnedCoins,
              );
          context.read<UserDetailsCubit>().updateScore(currentUser.points);

          //update battle stats

          context.read<UpdateStatisticCubit>().updateBattleStatistic(
                userId1: currentUserId == widget.battleRoom!.user1!.uid
                    ? widget.battleRoom!.user1!.uid
                    : widget.battleRoom!.user2!.uid,
                userId2: widget.battleRoom!.user1!.uid != currentUserId
                    ? widget.battleRoom!.user1!.uid
                    : widget.battleRoom!.user2!.uid,
                winnerId: _winnerId!,
              );
        } else {
          //if user is not winner then update only score
          context.read<UpdateScoreAndCoinsCubit>().updateScore(
                currentUser.points,
              );
          context.read<UserDetailsCubit>().updateScore(currentUser.points);
        }
      },
    );
  }

  void _earnBadges() {
    final userId = context.read<UserDetailsCubit>().userId();
    final badgesCubit = context.read<BadgesCubit>();
    final config = context.read<SystemConfigCubit>();
    final quickestCorrectAnswerExtraScore =
        config.oneVsOneBattleQuickestCorrectAnswerExtraScore;
    final correctAnswerScore =
        config.quizCorrectAnswerCreditScore(QuizTypes.oneVsOneBattle);
    final languageId = UiUtils.getCurrentQuestionLanguageId(context);

    if (widget.quizType == QuizTypes.oneVsOneBattle) {
      //if badges is locked
      if (badgesCubit.isBadgeLocked('ultimate_player')) {
        final badgeEarnPoints =
            (correctAnswerScore + quickestCorrectAnswerExtraScore) *
                totalQuestions();

        //if user's points is same as highest points
        final currentUser = widget.battleRoom!.user1!.uid == userId
            ? widget.battleRoom!.user1!
            : widget.battleRoom!.user2!;
        if (currentUser.points == badgeEarnPoints) {
          badgesCubit.setBadge(
            badgeType: 'ultimate_player',
            languageId: languageId,
          );
        }
      }
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      //
      //if totalQuestion is less than minimum question then do not check for badges
      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      //funAndLearn is related to flashback
      if (badgesCubit.isBadgeLocked('flashback')) {
        final funNLearnQuestionMinimumTimeForBadge =
            badgesCubit.getBadgeCounterByType('flashback');
        //if badges not loaded some how
        if (funNLearnQuestionMinimumTimeForBadge == -1) {
          return;
        }
        final badgeEarnTimeInSeconds =
            totalQuestions() * funNLearnQuestionMinimumTimeForBadge;
        if (correctAnswer() == totalQuestions() &&
            widget.timeTakenToCompleteQuiz! <=
                badgeEarnTimeInSeconds.toDouble()) {
          badgesCubit.setBadge(
            badgeType: 'flashback',
            languageId: languageId,
          );
        }
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (badgesCubit.isBadgeLocked('dashing_debut')) {
        badgesCubit.setBadge(
          badgeType: 'dashing_debut',
          languageId: languageId,
        );
      }
      //
      //if totalQuestion is less than minimum question then do not check for badges

      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      if (badgesCubit.isBadgeLocked('brainiac')) {
        if (correctAnswer() == totalQuestions() &&
            !widget.hasUsedAnyLifeline!) {
          badgesCubit.setBadge(
            badgeType: 'brainiac',
            languageId: languageId,
          );
        }
      }
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      //if totalQuestion is less than minimum question then do not check for badges
      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      if (badgesCubit.isBadgeLocked('super_sonic')) {
        final guessTheWordQuestionMinimumTimeForBadge =
            badgesCubit.getBadgeCounterByType('super_sonic');

        //if badges not loaded some how
        if (guessTheWordQuestionMinimumTimeForBadge == -1) {
          return;
        }

        //if user has solved the quiz with in badgeEarnTime then they can earn badge
        final badgeEarnTimeInSeconds =
            totalQuestions() * guessTheWordQuestionMinimumTimeForBadge;
        if (correctAnswer() == totalQuestions() &&
            widget.timeTakenToCompleteQuiz! <=
                badgeEarnTimeInSeconds.toDouble()) {
          badgesCubit.setBadge(
            badgeType: 'super_sonic',
            languageId: languageId,
          );
        }
      }
    } else if (widget.quizType == QuizTypes.dailyQuiz) {
      if (badgesCubit.isBadgeLocked('thirsty')) {
        //
        badgesCubit.setBadge(
          badgeType: 'thirsty',
          languageId: languageId,
        );
      }
    }
  }

  Future<void> setContestLeaderboard() async {
    await Future<void>.delayed(Duration.zero);
    if (widget.quizType == QuizTypes.contest) {
      await context.read<SetContestLeaderboardCubit>().setContestLeaderboard(
            questionAttended: attemptedQuestion(),
            correctAns: correctAnswer(),
            contestId: widget.contestId,
            score: widget.myPoints,
          );
    }
  }

  String _getCoinUpdateTypeBasedOnQuizZone() {
    return switch (widget.quizType) {
      QuizTypes.quizZone => wonQuizZoneKey,
      QuizTypes.mathMania => wonMathQuizKey,
      QuizTypes.guessTheWord => wonGuessTheWordKey,
      QuizTypes.trueAndFalse => wonTrueFalseKey,
      QuizTypes.dailyQuiz => wonDailyQuizKey,
      QuizTypes.audioQuestions => wonAudioQuizKey,
      QuizTypes.funAndLearn => wonFunNLearnKey,
      _ => '-',
    };
  }

  void _updateCoinsAndScore() {
    var points = widget.myPoints;
    if (widget.isPremiumCategory) {
      _earnedCoins = _earnedCoins * 2;
      points = widget.myPoints! * 2;
    }

    //update score and coins for user
    context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
          widget.myPoints,
          _earnedCoins,
          _getCoinUpdateTypeBasedOnQuizZone(),
        );
    //update score locally and database
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: _earnedCoins,
        );

    context.read<UserDetailsCubit>().updateScore(points);
  }

  //
  void _updateScoreAndCoinsDetails() {
    //if percentage is more than 30 then update score and coins
    if (_isWinner) {
      //
      //if quizType is quizZone we need to update unlocked level,coins and score
      //only one time
      //
      if (widget.quizType == QuizTypes.quizZone) {
        //if given level is same as unlocked level then update level
        if (int.parse(widget.questions!.first.level!) == widget.unlockedLevel) {
          final updatedLevel = int.parse(widget.questions!.first.level!) + 1;
          //update level

          context.read<UpdateLevelCubit>().updateLevel(
                widget.categoryId!,
                widget.subcategoryId ?? '',
                updatedLevel.toString(),
              );

          _updateCoinsAndScore();
        } else {}
        if (widget.subcategoryId == '0') {
          context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                widget.categoryId!,
                '0',
              );
        } else {
          context.read<SubCategoryCubit>().fetchSubCategory(widget.categoryId!);
        }
      }
      //
      else if (widget.quizType == QuizTypes.funAndLearn &&
          !widget.comprehension.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
              quizType: QuizTypes.funAndLearn,
              categoryId: widget.questions!.first.categoryId!,
              subcategoryId: widget.questions!.first.subcategoryId! == '0'
                  ? ''
                  : widget.questions!.first.subcategoryId!,
              typeId: widget.comprehension.id,
            );
      }
      //
      else if (widget.quizType == QuizTypes.guessTheWord && !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
              quizType: QuizTypes.guessTheWord,
              categoryId: widget.guessTheWordQuestions!.first.category,
              subcategoryId:
                  widget.guessTheWordQuestions!.first.subcategory == '0'
                      ? ''
                      : widget.guessTheWordQuestions!.first.subcategory,
              typeId: '',
            );
      } else if (widget.quizType == QuizTypes.audioQuestions &&
          !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
              quizType: QuizTypes.audioQuestions,
              categoryId: widget.questions!.first.categoryId!,
              subcategoryId: widget.questions!.first.subcategoryId! == '0'
                  ? ''
                  : widget.questions!.first.subcategoryId!,
              typeId: '',
            );
      } else if (widget.quizType == QuizTypes.mathMania && !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
              quizType: QuizTypes.mathMania,
              categoryId: widget.questions!.first.categoryId!,
              subcategoryId: widget.questions!.first.subcategoryId! == '0'
                  ? ''
                  : widget.questions!.first.subcategoryId!,
              typeId: '',
            );
      }
    }
    // fetchUpdateUserDetails();
  }

  void earnCoinsBasedOnWinPercentage() {
    if (_isWinner) {
      final percentage = winPercentage();
      _earnedCoins = UiUtils.coinsBasedOnWinPercentage(
        guessTheWordMaxWinningCoins:
            context.read<SystemConfigCubit>().guessTheWordMaxWinningCoins,
        percentage: percentage,
        quizType: widget.quizType!,
        maxCoinsWinningPercentage:
            context.read<SystemConfigCubit>().maxCoinsWinningPercentage,
        maxWinningCoins: context.read<SystemConfigCubit>().maxWinningCoins,
      );
    }
  }

  //This will execute once user press back button or go back from result screen
  //so respective data of category,sub category and fun n learn can be updated
  void onPageBackCalls() {
    if (widget.quizType == QuizTypes.funAndLearn &&
        _isWinner &&
        !widget.comprehension.isPlayed) {
      context.read<ComprehensionCubit>().getComprehension(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.questions!.first.subcategoryId! == '0'
                ? 'category'
                : 'subcategory',
            typeId: widget.questions!.first.subcategoryId! == '0'
                ? widget.questions!.first.categoryId!
                : widget.questions!.first.subcategoryId!,
          );
    } else if (widget.quizType == QuizTypes.audioQuestions &&
        _isWinner &&
        !widget.isPlayed) {
      //
      if (widget.questions!.first.subcategoryId == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.audioQuestions,
              ),
            );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
              widget.questions!.first.categoryId!,
            );
      }
    } else if (widget.quizType == QuizTypes.guessTheWord &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.guessTheWordQuestions!.first.subcategory == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.guessTheWord,
              ),
            );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
              widget.guessTheWordQuestions!.first.category,
            );
      }
    } else if (widget.quizType == QuizTypes.mathMania &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.questions!.first.subcategoryId == '0') {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.mathMania,
              ),
            );
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
              widget.questions!.first.categoryId!,
            );
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (widget.subcategoryId == '') {
        context.read<UnlockedLevelCubit>().fetchUnlockLevel(
              widget.categoryId!,
              '0',
            );
      } else {
        context.read<SubCategoryCubit>().fetchSubCategory(widget.categoryId!);
      }
    }
    fetchUpdateUserDetails();
  }

  String getCategoryIdOfQuestion() {
    if (widget.quizType == QuizTypes.oneVsOneBattle) {
      return widget.battleRoom!.categoryId!.isEmpty
          ? '0'
          : widget.battleRoom!.categoryId!;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return widget.guessTheWordQuestions!.first.category;
    }
    return widget.questions!.first.categoryId!.isEmpty
        ? '-'
        : widget.questions!.first.categoryId!;
  }

  int correctAnswer() {
    if (widget.quizType == QuizTypes.exam) {
      return widget.correctExamAnswers!;
    }
    var correctAnswer = 0;
    if (widget.quizType == QuizTypes.guessTheWord) {
      for (final question in widget.guessTheWordQuestions!) {
        if (question.answer ==
            UiUtils.buildGuessTheWordQuestionAnswer(question.submittedAnswer)) {
          correctAnswer++;
        }
      }
    } else {
      for (final question in widget.questions!) {
        if (AnswerEncryption.decryptCorrectAnswer(
              rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
              correctAnswer: question.correctAnswer!,
            ) ==
            question.submittedAnswerId) {
          correctAnswer++;
        }
      }
    }
    return correctAnswer;
  }

  int attemptedQuestion() {
    var attemptedQuestion = 0;
    if (widget.quizType == QuizTypes.exam) {
      return 0;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      //
      for (final question in widget.guessTheWordQuestions!) {
        if (question.hasAnswered) {
          attemptedQuestion++;
        }
      }
    } else {
      //
      for (final question in widget.questions!) {
        if (question.attempted) {
          attemptedQuestion++;
        }
      }
    }
    return attemptedQuestion;
  }

  double winPercentage() {
    if (widget.quizType == QuizTypes.oneVsOneBattle) return 0;

    if (widget.quizType == QuizTypes.exam) {
      return (widget.obtainedMarks! * 100.0) /
          int.parse(widget.exam!.totalMarks);
    }

    return (correctAnswer() * 100.0) / totalQuestions();
  }

  bool showCoinsAndScore() {
    if (widget.quizType == QuizTypes.selfChallenge ||
        widget.quizType == QuizTypes.contest ||
        widget.quizType == QuizTypes.exam ||
        widget.quizType == QuizTypes.dailyQuiz) {
      return false;
    }

    if (widget.quizType == QuizTypes.quizZone) {
      return _isWinner &&
          (int.parse(widget.questions!.first.level!) == widget.unlockedLevel);
    }
    if (widget.quizType == QuizTypes.funAndLearn) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.comprehension.isPlayed;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    if (widget.quizType == QuizTypes.audioQuestions) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    if (widget.quizType == QuizTypes.mathMania) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    return _isWinner;
  }

  int totalQuestions() {
    if (widget.quizType == QuizTypes.exam) {
      return widget.correctExamAnswers! + widget.incorrectExamAnswers!;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return widget.guessTheWordQuestions!.length;
    }

    if (didSkipQue) {
      return widget.questions!.length - 1;
    }

    return widget.questions!.length;
  }

  Widget _buildGreetingMessage() {
    final String title;
    final String message;

    if (widget.quizType == QuizTypes.oneVsOneBattle) {
      if (_winnerId!.isEmpty) {
        title = 'matchDrawLbl';
        message = 'congratulationsLbl';
      } else if (_isWinner) {
        title = 'victoryLbl';
        message = 'congratulationsLbl';
      } else {
        title = 'defeatLbl';
        message = 'betterNextLbl';
      }
    } else if (widget.quizType == QuizTypes.exam) {
      title = widget.exam!.title;
      message = examResultKey;
    } else {
      final scorePct = winPercentage();

      if (scorePct <= 30) {
        title = goodEffort;
        message = keepLearning;
      } else if (scorePct <= 50) {
        title = wellDone;
        message = makingProgress;
      } else if (scorePct <= 70) {
        title = greatJob;
        message = closerToMastery;
      } else if (scorePct <= 90) {
        title = excellentWork;
        message = keepGoing;
      } else {
        title = fantasticJob;
        message = achievedMastery;
      }
    }

    final titleStyle = TextStyle(
      fontSize: 26,
      color: Theme.of(context).colorScheme.onTertiary,
      fontWeight: FontWeights.bold,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.quizType == QuizTypes.exam ? title : context.tr(title)!,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              if (widget.quizType != QuizTypes.exam &&
                  widget.quizType != QuizTypes.oneVsOneBattle) ...[
                Flexible(
                  child: Text(
                    " ${userName.split(' ').first}",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 26,
                      color: Theme.of(context).primaryColor,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.shortestSide * .85,
          child: Text(
            context.tr(message)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDataWithIconContainer(
    String title,
    String icon,
    EdgeInsetsGeometry margin,
  ) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      // padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * (0.2125),
      height: 33,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onTertiary,
              BlendMode.srcIn,
            ),
            width: 19,
            height: 19,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeights.bold,
              fontSize: 18,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualResultContainer(String userProfileUrl) {
    final lottieAnimation = _isWinner
        ? 'assets/animations/confetti.json'
        : 'assets/animations/defeats.json';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Don't show any confetti in exam results.
        if (widget.quizType != QuizTypes.exam) ...[
          Align(
            alignment: Alignment.topCenter,
            child: Lottie.asset(lottieAnimation, fit: BoxFit.fill),
          ),
        ],
        Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              var verticalSpacePercentage = 0.0;

              var radialSizePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = 0.015;
                radialSizePercentage = 0.6;
              } else {
                verticalSpacePercentage = 0.035;
                radialSizePercentage = 0.525;
              }

              return Column(
                children: [
                  _buildGreetingMessage(),
                  SizedBox(
                    height: constraints.maxHeight * verticalSpacePercentage,
                  ),
                  if (widget.quizType! == QuizTypes.exam)
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: RadialPercentageResultContainer(
                        percentage: winPercentage(),
                        timeTakenToCompleteQuizInSeconds:
                            widget.examCompletedInMinutes,
                        size: Size(
                          constraints.maxHeight * radialSizePercentage,
                          constraints.maxHeight * radialSizePercentage,
                        ),
                      ),
                    )
                  else
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        QImage.circular(
                          imageUrl: userProfileUrl,
                          width: 107,
                          height: 107,
                        ),
                        SvgPicture.asset(
                          Assets.hexagonFrame,
                          width: 132,
                          height: 132,
                        ),
                      ],
                    ),
                  if (widget.quizType! == QuizTypes.exam)
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Text(
                        '${widget.obtainedMarks}/${widget.exam!.totalMarks} ${context.tr(markKey)!}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(22),
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              );
            },
          ),
        ),

        //incorrect answer
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: _buildResultDataWithIconContainer(
            widget.quizType == QuizTypes.exam
                ? '${widget.incorrectExamAnswers}/${totalQuestions()}'
                : '${totalQuestions() - correctAnswer()}/${totalQuestions()}',
            Assets.wrong,
            EdgeInsetsDirectional.only(
              start: 15,
              bottom: showCoinsAndScore() ? 20.0 : 30.0,
            ),
          ),
        ),
        //correct answer
        if (showCoinsAndScore())
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: _buildResultDataWithIconContainer(
              '${correctAnswer()}/${totalQuestions()}',
              Assets.correct,
              const EdgeInsetsDirectional.only(start: 15, bottom: 60),
            ),
          )
        else
          Align(
            alignment: Alignment.bottomRight,
            child: _buildResultDataWithIconContainer(
              '${correctAnswer()}/${totalQuestions()}',
              Assets.correct,
              const EdgeInsetsDirectional.only(end: 15, bottom: 30),
            ),
          ),

        //points
        if (showCoinsAndScore())
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _buildResultDataWithIconContainer(
              '${widget.myPoints}',
              Assets.score,
              const EdgeInsetsDirectional.only(end: 15, bottom: 60),
            ),
          )
        else
          const SizedBox(),

        //earned coins
        if (showCoinsAndScore())
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _buildResultDataWithIconContainer(
              '$_earnedCoins',
              Assets.earnedCoin,
              const EdgeInsetsDirectional.only(end: 15, bottom: 20),
            ),
          )
        else
          const SizedBox(),

        //build radial percentage container
        if (widget.quizType! == QuizTypes.exam)
          const SizedBox()
        else
          Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                var radialSizePercentage = 0.0;
                if (constraints.maxHeight <
                    UiUtils.profileHeightBreakPointResultScreen) {
                  radialSizePercentage = 0.4;
                } else {
                  radialSizePercentage = 0.325;
                }
                return Transform.translate(
                  offset: const Offset(0, 15),
                  child: RadialPercentageResultContainer(
                    percentage: winPercentage(),
                    timeTakenToCompleteQuizInSeconds:
                        widget.timeTakenToCompleteQuiz?.toInt(),
                    size: Size(
                      constraints.maxHeight * radialSizePercentage,
                      constraints.maxHeight * radialSizePercentage,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBattleResultDetails() {
    final winnerDetails = widget.battleRoom!.user1!.uid == _winnerId
        ? widget.battleRoom!.user1
        : widget.battleRoom!.user2;
    final looserDetails = widget.battleRoom!.user1!.uid != _winnerId
        ? widget.battleRoom!.user1
        : widget.battleRoom!.user2;

    return _winnerId == null
        ? const SizedBox()
        : LayoutBuilder(
            builder: (context, constraints) {
              var verticalSpacePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = _winnerId!.isEmpty ? 0.035 : 0.03;
              } else {
                verticalSpacePercentage = _winnerId!.isEmpty ? 0.075 : 0.05;
              }
              return Column(
                children: [
                  _buildGreetingMessage(),
                  if (widget.entryFee! > 0)
                    context.read<UserDetailsCubit>().userId() == _winnerId
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 10,
                                right: 30,
                                left: 30,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${context.tr("youWin")!} ${widget.entryFee! * 2} ${context.tr("coinsLbl")!}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          )
                        : _winnerId!.isEmpty
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 20,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    right: 30,
                                    left: 30,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${context.tr("youLossLbl")!} ${widget.entryFee} ${context.tr("coinsLbl")!}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                ),
                              )
                  else
                    const SizedBox(height: 50),
                  SizedBox(
                    height:
                        constraints.maxHeight * verticalSpacePercentage - 10.2,
                  ),
                  if (_winnerId!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    QImage.circular(
                                      width: 80,
                                      height: 80,
                                      imageUrl:
                                          widget.battleRoom!.user1!.profileUrl,
                                    ),
                                    Center(
                                      child: SvgPicture.asset(
                                        Assets.hexagonFrame,
                                        height: 90,
                                        width: 90,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.battleRoom!.user1!.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${context.tr(scoreLbl)} ${widget.battleRoom!.user1!.points}',
                                    style: TextStyle(
                                      fontWeight: FontWeights.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Column(
                            children: [
                              SvgPicture.asset(
                                Assets.versus,
                                width: MediaQuery.of(context).size.width * 0.12,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                              const SizedBox(),
                            ],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    QImage.circular(
                                      width: 80,
                                      height: 80,
                                      imageUrl:
                                          widget.battleRoom!.user2!.profileUrl,
                                    ),
                                    Center(
                                      child: SvgPicture.asset(
                                        Assets.hexagonFrame,
                                        width: 90,
                                        height: 90,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.battleRoom!.user2!.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${context.tr(scoreLbl)} ${widget.battleRoom!.user2!.points}',
                                    style: TextStyle(
                                      fontWeight: FontWeights.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    QImage.circular(
                                      width: 80,
                                      height: 80,
                                      imageUrl: winnerDetails!.profileUrl,
                                    ),
                                    Center(
                                      child: SvgPicture.asset(
                                        Assets.hexagonFrame,
                                        width: 90,
                                        height: 90,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  winnerDetails.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${context.tr(scoreLbl)} ${winnerDetails.points}',
                                    style: TextStyle(
                                      fontWeight: FontWeights.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            children: [
                              SvgPicture.asset(
                                Assets.versus,
                                width: MediaQuery.of(context).size.width * 0.12,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                              const SizedBox(),
                            ],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    QImage.circular(
                                      width: 80,
                                      height: 80,
                                      imageUrl: looserDetails!.profileUrl,
                                    ),
                                    Center(
                                      child: SvgPicture.asset(
                                        Assets.hexagonFrame,
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                          BlendMode.srcIn,
                                        ),
                                        width: 90,
                                        height: 90,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  looserDetails.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${context.tr(scoreLbl)} ${looserDetails.points}',
                                    style: TextStyle(
                                      fontWeight: FontWeights.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
  }

  Widget _buildResultDetails(BuildContext context) {
    final userProfileUrl =
        context.read<UserDetailsCubit>().getUserProfile().profileUrl ?? '';

    //build results for 1 user
    if (widget.numberOfPlayer == 1) {
      return _buildIndividualResultContainer(userProfileUrl);
    }
    if (widget.numberOfPlayer == 2) {
      return _buildBattleResultDetails();
    }
    return const SizedBox();
  }

  Widget _buildResultContainer(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        height: MediaQuery.of(context).size.height * (0.560),
        width: MediaQuery.of(context).size.width * (0.90),
        decoration: BoxDecoration(
          color: _isWinner
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.onTertiary.withOpacity(.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildResultDetails(context),
      ),
    );
  }

  Widget _buildButton(
    String buttonTitle,
    Function onTap,
    BuildContext context,
  ) {
    return CustomRoundedButton(
      widthPercentage: 0.90,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle: buttonTitle,
      radius: 8,
      elevation: 5,
      showBorder: false,
      fontWeight: FontWeights.regular,
      height: 50,
      titleColor: Theme.of(context).colorScheme.surface,
      onTap: onTap as VoidCallback,
      textSize: 20,
    );
  }

  //play again button will be build different for every quizType
  Widget _buildPlayAgainButton() {
    if (widget.quizType == QuizTypes.selfChallenge) {
      return const SizedBox();
    } else if (widget.quizType == QuizTypes.audioQuestions) {
      if (_isWinner) {
        return const SizedBox.shrink();
      }

      return _buildButton(
        context.tr('playAgainBtn')!,
        () {
          fetchUpdateUserDetails();
          Navigator.of(context).pushReplacementNamed(
            Routes.quiz,
            arguments: {
              'numberOfPlayer': 1,
              'isPlayed': widget.isPlayed,
              'quizType': QuizTypes.audioQuestions,
              'subcategoryId': widget.questions!.first.subcategoryId == '0'
                  ? ''
                  : widget.questions!.first.subcategoryId,
              'categoryId': widget.questions!.first.subcategoryId == '0'
                  ? widget.questions!.first.categoryId
                  : '',
            },
          );
        },
        context,
      );
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      if (_isWinner) {
        return const SizedBox();
      }

      return _buildButton(
        context.tr('playAgainBtn')!,
        () {
          fetchUpdateUserDetails();
          Navigator.of(context).pushReplacementNamed(
            Routes.guessTheWord,
            arguments: {
              'isPlayed': widget.isPlayed,
              'type': widget.guessTheWordQuestions!.first.subcategory == '0'
                  ? 'category'
                  : 'subcategory',
              'typeId': widget.guessTheWordQuestions!.first.subcategory == '0'
                  ? widget.guessTheWordQuestions!.first.category
                  : widget.guessTheWordQuestions!.first.subcategory,
            },
          );
        },
        context,
      );
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      return Container();
    } else if (widget.quizType == QuizTypes.quizZone) {
      //if user is winner
      if (_isWinner) {
        //we need to check if currentLevel is last level or not
        final maxLevel = int.parse(widget.subcategoryMaxLevel!);
        final currentLevel = int.parse(widget.questions!.first.level!);
        if (maxLevel == currentLevel) {
          return const SizedBox.shrink();
        }
        return _buildButton(
          context.tr('nextLevelBtn')!,
          () {
            //if given level is same as unlocked level then we need to update level
            //else do not update level
            final unlockedLevel = int.parse(widget.questions!.first.level!) ==
                    widget.unlockedLevel
                ? (widget.unlockedLevel! + 1)
                : widget.unlockedLevel;
            //play quiz for next level
            fetchUpdateUserDetails();
            Navigator.of(context).pushReplacementNamed(
              Routes.quiz,
              arguments: {
                'numberOfPlayer': widget.numberOfPlayer,
                'quizType': widget.quizType,
                //if subcategory id is empty for question means we need to fetch question by it's category
                'categoryId': widget.categoryId,
                'subcategoryId': widget.subcategoryId,
                'level': (currentLevel + 1).toString(),
                //increase level
                'subcategoryMaxLevel': widget.subcategoryMaxLevel,
                'unlockedLevel': unlockedLevel,
              },
            );
          },
          context,
        );
      }
      //if user failed to complete this level
      return _buildButton(
        context.tr('playAgainBtn')!,
        () {
          fetchUpdateUserDetails();
          //to play this level again (for quizZone quizType)
          Navigator.of(context).pushReplacementNamed(
            Routes.quiz,
            arguments: {
              'numberOfPlayer': widget.numberOfPlayer,
              'quizType': widget.quizType,
              //if subcategory id is empty for question means we need to fetch questions by it's category
              'categoryId': widget.categoryId,
              'subcategoryId': widget.subcategoryId,
              'level': widget.questions!.first.level,
              'unlockedLevel': widget.unlockedLevel,
              'subcategoryMaxLevel': widget.subcategoryMaxLevel,
            },
          );
        },
        context,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildShareYourScoreButton() {
    return Builder(
      builder: (context) {
        return _buildButton(
          context.tr('shareScoreBtn')!,
          () async {
            try {
              //capturing image
              final image = await screenshotController.capture();
              //root directory path
              final directory = (await getApplicationDocumentsDirectory()).path;

              final fileName = DateTime.now().microsecondsSinceEpoch.toString();
              //create file with given path
              final file = await File('$directory/$fileName.png').create();
              //write as bytes
              await file.writeAsBytes(image!.buffer.asUint8List());

              final appLink = context.read<SystemConfigCubit>().appUrl;

              final referralCode =
                  context.read<UserDetailsCubit>().getUserProfile().referCode ??
                      '';

              final scoreText = '$appName'
                  "\n${context.tr('myScoreLbl')!}"
                  "\n${context.tr("appLink")!}"
                  '\n$appLink'
                  "\n${context.tr("useMyReferral")} $referralCode ${context.tr("toGetCoins")}";

              await UiUtils.share(
                scoreText,
                files: [XFile(file.path)],
                context: context,
              ).onError(
                (e, s) => ShareResult('$e', ShareResultStatus.dismissed),
              );
            } catch (e) {
              if (!mounted) return;

              UiUtils.showSnackBar(
                context.tr(
                  convertErrorCodeToLanguageKey(errorCodeDefaultMessage),
                )!,
                context,
              );
            }
          },
          context,
        );
      },
    );
  }

  bool _unlockedReviewAnswersOnce = false;

  Widget _buildReviewAnswersButton() {
    void onTapYesReviewAnswers() {
      final reviewAnswersDeductCoins =
          context.read<SystemConfigCubit>().reviewAnswersDeductCoins;
      //check if user has enough coins
      if (int.parse(context.read<UserDetailsCubit>().getCoins()!) <
          reviewAnswersDeductCoins) {
        UiUtils.errorMessageDialog(
          context,
          context.tr(notEnoughCoinsKey),
        );
        return;
      }

      /// update coins
      context.read<UpdateScoreAndCoinsCubit>().updateCoins(
            coins: reviewAnswersDeductCoins,
            addCoin: false,
            title: reviewAnswerLbl,
          );
      context.read<UserDetailsCubit>().updateCoins(
            addCoin: false,
            coins: reviewAnswersDeductCoins,
          );

      _unlockedReviewAnswersOnce = true;
      Navigator.of(context).pop();

      Navigator.of(context).pushNamed(
        Routes.reviewAnswers,
        arguments: widget.quizType == QuizTypes.guessTheWord
            ? {
                'quizType': widget.quizType,
                'questions': <Question>[],
                'guessTheWordQuestions': widget.guessTheWordQuestions,
              }
            : {
                'quizType': widget.quizType,
                'questions': widget.questions,
                'guessTheWordQuestions': <GuessTheWordQuestion>[],
              },
      );
    }

    return _buildButton(
      context.tr('reviewAnsBtn')!,
      () {
        if (_unlockedReviewAnswersOnce) {
          Navigator.of(context).pushNamed(
            Routes.reviewAnswers,
            arguments: widget.quizType == QuizTypes.guessTheWord
                ? {
                    'quizType': widget.quizType,
                    'questions': <Question>[],
                    'guessTheWordQuestions': widget.guessTheWordQuestions,
                  }
                : {
                    'quizType': widget.quizType,
                    'questions': widget.questions,
                    'guessTheWordQuestions': <GuessTheWordQuestion>[],
                  },
          );
          return;
        }

        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            actions: [
              TextButton(
                onPressed: onTapYesReviewAnswers,
                child: Text(
                  context.tr(continueLbl)!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),

              /// Cancel Button
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(
                  context.tr(cancelButtonKey)!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
            content: Text(
              '${context.read<SystemConfigCubit>().reviewAnswersDeductCoins} ${context.tr(coinsWillBeDeductedKey)!}',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        );
      },
      context,
    );
  }

  Widget _buildHomeButton() {
    void onTapHomeButton() {
      fetchUpdateUserDetails();
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (_) => false,
        arguments: false,
      );
    }

    return _buildButton(
      context.tr('homeBtn')!,
      onTapHomeButton,
      context,
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    const buttonSpace = SizedBox(height: 15);

    return Column(
      children: [
        if (widget.quizType! != QuizTypes.exam &&
            widget.quizType != QuizTypes.oneVsOneBattle) ...[
          _buildPlayAgainButton(),
          buttonSpace,
        ],
        if (widget.quizType == QuizTypes.quizZone ||
            widget.quizType == QuizTypes.audioQuestions ||
            widget.quizType == QuizTypes.guessTheWord ||
            widget.quizType == QuizTypes.funAndLearn ||
            widget.quizType == QuizTypes.mathMania) ...[
          _buildReviewAnswersButton(),
          buttonSpace,
        ],
        _buildShareYourScoreButton(),
        buttonSpace,
        _buildHomeButton(),
        buttonSpace,
      ],
    );
  }

  String get _appbarTitle {
    final title = switch (widget.quizType) {
      QuizTypes.selfChallenge => 'selfChallengeResult',
      QuizTypes.audioQuestions => 'audioQuizResult',
      QuizTypes.mathMania => 'mathQuizResult',
      QuizTypes.guessTheWord => 'guessTheWordResult',
      QuizTypes.exam => 'examResult',
      QuizTypes.dailyQuiz => 'dailyQuizResult',
      QuizTypes.oneVsOneBattle => 'randomBattleResult',
      QuizTypes.funAndLearn => 'funAndLearnResult',
      QuizTypes.trueAndFalse => 'truefalseQuizResult',
      QuizTypes.bookmarkQuiz => 'bookmarkQuizResult',
      _ => 'quizResultLbl',
    };

    return context.tr(title)!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          context.read<UserDetailsCubit>().state is! UserDetailsFetchInProgress,
      onPopInvoked: (didPop) {
        if (didPop) return;

        onPageBackCalls();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
            listener: (context, state) {
              if (state is UpdateScoreAndCoinsFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    showAlreadyLoggedInDialog(context);
                    return;
                  }
                }
              }
            },
          ),
          BlocListener<UpdateStatisticCubit, UpdateStatisticState>(
            listener: (context, state) {
              if (state is UpdateStatisticFailure) {
                //
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    showAlreadyLoggedInDialog(context);
                    return;
                  }
                }
              }
            },
          ),
          BlocListener<SetContestLeaderboardCubit, SetContestLeaderboardState>(
            listener: (context, state) {
              if (state is SetContestLeaderboardFailure) {
                //
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    showAlreadyLoggedInDialog(context);
                    return;
                  }
                }
              }
              if (state is SetContestLeaderboardSuccess) {
                context.read<ContestCubit>().getContest(
                      languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            title: Text(_appbarTitle),
            onTapBackButton: () {
              onPageBackCalls();
              Navigator.pop(context);
            },
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(child: _buildResultContainer(context)),
                const SizedBox(height: 20),
                _buildResultButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
