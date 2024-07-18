import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageBoxContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageContainer.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/ui/widgets/userDetailsWithTimerContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/internet_connectivity.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BattleRoomQuizScreen extends StatefulWidget {
  const BattleRoomQuizScreen({
    required this.playWithBot,
    required this.quizType,
    super.key,
  });

  final QuizTypes quizType;
  final bool playWithBot;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateBookmarkCubit>(
            create: (_) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
          BlocProvider<MessageCubit>(
            create: (_) => MessageCubit(BattleRoomRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
        ],
        child: BattleRoomQuizScreen(
          playWithBot: args['play_with_bot'] as bool? ?? false,
          quizType: args['quiz_type'] as QuizTypes,
        ),
      ),
    );
  }

  @override
  State<BattleRoomQuizScreen> createState() => _BattleRoomQuizScreenState();
}

class _BattleRoomQuizScreenState extends State<BattleRoomQuizScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController timerAnimationController = AnimationController(
    vsync: this,
    duration: Duration(
      seconds: context.read<SystemConfigCubit>().quizTimer(widget.quizType),
    ),
  )
    ..addStatusListener(currentUserTimerAnimationStatusListener)
    ..forward();

  late AnimationController opponentUserTimerAnimationController =
      AnimationController(
    vsync: this,
    duration: Duration(
      seconds: context.read<SystemConfigCubit>().quizTimer(widget.quizType),
    ),
  )..forward();

  //to animate the question container
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;

  //to slide the question container from right to left
  late Animation<double> questionSlideAnimation;

  //to scale up the second question
  late Animation<double> questionScaleUpAnimation;

  //to scale down the second question
  late Animation<double> questionScaleDownAnimation;

  //to slide the question content from right to left
  late Animation<double> questionContentAnimation;

  late AnimationController messageAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );
  late Animation<double> messageAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: messageAnimationController,
      curve: Curves.easeOutBack,
    ),
  );

  late AnimationController opponentMessageAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );
  late Animation<double> opponentMessageAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: opponentMessageAnimationController,
      curve: Curves.easeOutBack,
    ),
  );

  late AnimationController messageBoxAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late Animation<double> messageBoxAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: messageBoxAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  late int currentQuestionIndex = 0;

  //if user left the by pressing home button or lock screen
  //this will be true
  bool showYouLeftQuiz = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  final double bottomPadding = 10;

  //current user message timer
  Timer? currentUserMessageDisappearTimer;
  int currentUserMessageDisappearTimeInSeconds = 4;

  //opponent user message timer
  Timer? opponentUserMessageDisappearTimer;
  int opponentUserMessageDisappearTimeInSeconds = 4;

  //To track users latest message

  List<Message> latestMessagesByUsers = [];

  late final _currUserId = context.read<UserDetailsCubit>().userId();

  final List<String> botSubmittedAnswers = [];

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();

    //Add empty latest messages
    latestMessagesByUsers
      ..add(Message.empty())
      ..add(Message.empty());
    //

    Future.delayed(Duration.zero, () {
      if (!widget.playWithBot) {
        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
              coins: context.read<BattleRoomCubit>().getEntryFee(),
              title: playedBattleKey,
              addCoin: false,
            );
        context.read<UserDetailsCubit>().updateCoins(
              addCoin: false,
              coins: context.read<BattleRoomCubit>().getEntryFee(),
            );
      }
    });

    initializeAnimation();
    initMessageListener();
    questionContentAnimationController.forward();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    timerAnimationController
      ..removeStatusListener(currentUserTimerAnimationStatusListener)
      ..dispose();
    opponentUserTimerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    messageAnimationController.dispose();
    opponentMessageAnimationController.dispose();
    currentUserMessageDisappearTimer?.cancel();
    opponentUserMessageDisappearTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool appWasPaused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //delete battle room
    if (state == AppLifecycleState.paused) {
      appWasPaused = true;
      //if user minimize or change the app

      deleteMessages(context.read<BattleRoomCubit>().getRoomId());
      context.read<BattleRoomCubit>().deleteUserFromRoom(_currUserId);
      context.read<BattleRoomCubit>().deleteBattleRoom(isGroupBattle: false);
    }
    //show you left the game
    if (state == AppLifecycleState.resumed && appWasPaused) {
      if (!context.read<BattleRoomCubit>().opponentLeftTheGame(_currUserId)) {
        setState(() {
          showYouLeftQuiz = true;
        });
      }

      timerAnimationController.stop();
      opponentUserTimerAnimationController.stop();
    }
  }

  void initMessageListener() {
    //to set listener for opponent message
    Future.delayed(Duration.zero, () {
      final roomId = context.read<BattleRoomCubit>().getRoomId();
      context.read<MessageCubit>().subscribeToMessages(roomId);
    });
  }

  void initializeAnimation() {
    questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    questionContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    questionSlideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    questionScaleUpAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0, 0.5, curve: Curves.easeInQuad),
      ),
    );
    questionScaleDownAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0.5, 1, curve: Curves.easeOutQuad),
      ),
    );
    questionContentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: questionContentAnimationController,
        curve: Curves.easeInQuad,
      ),
    );
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer('-1');
    }
  }

  void updateSubmittedAnswerForBookmark(Question question) {
    if (context.read<BookmarkCubit>().hasQuestionBookmarked(question.id)) {
      context
          .read<BookmarkCubit>()
          .updateSubmittedAnswerId(question, _currUserId);
    }
  }

  //to submit the answer
  Future<void> submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();

    //submitted answer will be id of the answerOption
    final battleRoomCubit = context.read<BattleRoomCubit>();
    final questions = battleRoomCubit.getQuestions();

    if (!questions[currentQuestionIndex].attempted) {
      //update answer locally
      battleRoomCubit.updateQuestionAnswer(
        questions[currentQuestionIndex].id,
        submittedAnswer,
      );

      updateSubmittedAnswerForBookmark(questions[currentQuestionIndex]);

      //need to give the delay so user can see the correct answer or incorrect
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );

      /// update answer and current points in database
      final correctAnswer = AnswerEncryption.decryptCorrectAnswer(
        rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
        correctAnswer: questions[currentQuestionIndex].correctAnswer!,
      );

      final sysConfig = context.read<SystemConfigCubit>();
      battleRoomCubit.submitAnswer(
        _currUserId,
        submittedAnswer,
        isAnswerCorrect: submittedAnswer == correctAnswer,
        UiUtils.determineBattleCorrectAnswerPoints(
          timerAnimationController.value,
          sysConfig.quizTimer(widget.quizType),
          sysConfig.quizCorrectAnswerCreditScore(widget.quizType),
          widget.quizType == QuizTypes.oneVsOneBattle
              ? sysConfig.oneVsOneBattleQuickestCorrectAnswerExtraScore
              : sysConfig.randomBattleQuickestCorrectAnswerExtraScore,
          widget.quizType == QuizTypes.oneVsOneBattle
              ? sysConfig.oneVsOneBattleSecondQuickestCorrectAnswerExtraScore
              : sysConfig.randomBattleSecondQuickestCorrectAnswerExtraScore,
        ),
      );

      if (widget.playWithBot) {
        submitRobotAnswer();
      }
    }
  }

  void submitRobotAnswer() {
    opponentUserTimerAnimationController.stop();

    //submitted answer will be id of the answerOption
    final battleRoomCubit = context.read<BattleRoomCubit>();
    final questions = battleRoomCubit.getQuestions();

    final correctAnswer = AnswerEncryption.decryptCorrectAnswer(
      rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
      correctAnswer: questions[currentQuestionIndex].correctAnswer!,
    );

    final options = questions[currentQuestionIndex].answerOptions!.toList();
    final randomIdx = Random.secure().nextInt(options.length);
    final submittedAnswer = options[randomIdx].id!;

    botSubmittedAnswers.add(submittedAnswer);

    final sysConfig = context.read<SystemConfigCubit>();
    battleRoomCubit.submitAnswer(
      context.read<BattleRoomCubit>().getOpponentUserDetails(_currUserId).uid,
      submittedAnswer,
      isAnswerCorrect: submittedAnswer == correctAnswer,
      UiUtils.determineBattleCorrectAnswerPoints(
        opponentUserTimerAnimationController.value,
        sysConfig.quizTimer(QuizTypes.randomBattle),
        sysConfig.quizCorrectAnswerCreditScore(QuizTypes.randomBattle),
        widget.quizType == QuizTypes.oneVsOneBattle
            ? sysConfig.oneVsOneBattleQuickestCorrectAnswerExtraScore
            : sysConfig.randomBattleQuickestCorrectAnswerExtraScore,
        widget.quizType == QuizTypes.oneVsOneBattle
            ? sysConfig.oneVsOneBattleSecondQuickestCorrectAnswerExtraScore
            : sysConfig.randomBattleSecondQuickestCorrectAnswerExtraScore,
      ),
    );
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<BattleRoomCubit>()
        .getQuestions()[currentQuestionIndex]
        .attempted;
  }

  //next question
  void changeQuestion() {
    questionAnimationController.forward(from: 0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  void deleteMessages(String battleRoomId) {
    //to delete messages by given user
    context.read<MessageCubit>().deleteMessages(battleRoomId, _currUserId);
  }

  //for changing ui and other trigger other actions based on realtime changes that occurred in game
  void battleRoomListener(
    BuildContext context,
    BattleRoomState state,
    BattleRoomCubit battleRoomCubit,
  ) {
    Future.delayed(Duration.zero, () async {
      if (await InternetConnectivity.isUserOffline()) {
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shadowColor: Colors.transparent,
            actions: [
              TextButton(
                onPressed: () async {
                  if (!await InternetConnectivity.isUserOffline()) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text(
                  context.tr('retryLbl')!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
            content: Text(
              context.tr('noInternet')!,
            ),
          ),
        );
      }
    });

    if (state is BattleRoomUserFound) {
      final opponentUserDetails =
          battleRoomCubit.getOpponentUserDetails(_currUserId);
      final currentUserDetails =
          battleRoomCubit.getCurrentUserDetails(_currUserId);

      //if user has left the game
      if (state.hasLeft) {
        timerAnimationController.stop();
        opponentUserTimerAnimationController.stop();
      } else {
        //check if opponent user has submitted the answer
        if (opponentUserDetails.answers.length == (currentQuestionIndex + 1)) {
          opponentUserTimerAnimationController.stop();
        }
        //if both users submitted the answer then change question
        if (state.battleRoom.user1!.answers.length ==
            state.battleRoom.user2!.answers.length) {
          //
          //if user has not submitted the answers for all questions then move to next question
          //
          if (state.battleRoom.user1!.answers.length !=
              state.questions.length) {
            //
            //since submitting answer locally will change the cubit state
            //to avoid calling changeQuestion() called twice
            //need to add this condition
            //
            if (!state.questions[currentUserDetails.answers.length].attempted) {
              //stop any timer
              timerAnimationController.stop();
              opponentUserTimerAnimationController.stop();
              //change the question
              changeQuestion();
              //run timer again
              timerAnimationController.forward(from: 0);
              opponentUserTimerAnimationController.forward(from: 0);
            }
          }
          //else move to result screen
          else {
            //stop timers if any running
            timerAnimationController.stop();
            opponentUserTimerAnimationController.stop();

            //delete messages by current user
            deleteMessages(battleRoomCubit.getRoomId());
            //navigate to result
            if (isSettingDialogOpen) {
              Navigator.of(context).pop();
            }
            if (isExitDialogOpen) {
              Navigator.of(context).pop();
            }
            Navigator.of(context).pushReplacementNamed(
              Routes.result,
              arguments: {
                'questions': state.questions,
                'battleRoom': state.battleRoom,
                'numberOfPlayer': 2,
                'play_with_bot': widget.playWithBot,
                'quizType': QuizTypes.oneVsOneBattle,
                'entryFee': state.battleRoom.entryFee,
              },
            );

            battleRoomCubit.deleteBattleRoom(isGroupBattle: false);
          }
        }
      }
    }
  }

  void setCurrentUserMessageDisappearTimer() {
    if (currentUserMessageDisappearTimeInSeconds != 4) {
      currentUserMessageDisappearTimeInSeconds = 4;
    }

    currentUserMessageDisappearTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentUserMessageDisappearTimeInSeconds == 0) {
        //
        timer.cancel();
        messageAnimationController.reverse();
      } else {
        currentUserMessageDisappearTimeInSeconds--;
      }
    });
  }

  void setOpponentUserMessageDisappearTimer() {
    if (opponentUserMessageDisappearTimeInSeconds != 4) {
      opponentUserMessageDisappearTimeInSeconds = 4;
    }

    opponentUserMessageDisappearTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (opponentUserMessageDisappearTimeInSeconds == 0) {
        //
        timer.cancel();
        opponentMessageAnimationController.reverse();
      } else {
        opponentUserMessageDisappearTimeInSeconds--;
      }
    });
  }

  Future<void> messagesListener(MessageState state) async {
    if (state is MessageFetchedSuccess) {
      //current user message

      if (context
          .read<MessageCubit>()
          .getUserLatestMessage(
            //fetch user id
            _currUserId,
            messageId: latestMessagesByUsers[0].messageId,
            //latest user message id
          )
          .messageId
          .isNotEmpty) {
        //Assign latest message
        latestMessagesByUsers[0] =
            context.read<MessageCubit>().getUserLatestMessage(
                  _currUserId,
                  messageId: latestMessagesByUsers[0].messageId,
                );

        //Display latest message by current user
        //means timer is running
        if (currentUserMessageDisappearTimeInSeconds > 0 &&
            currentUserMessageDisappearTimeInSeconds < 4) {
          currentUserMessageDisappearTimer?.cancel();
          setCurrentUserMessageDisappearTimer();
        } else {
          await messageAnimationController.forward();
          setCurrentUserMessageDisappearTimer();
        }
      }

      // opponent user message

      if (context
          .read<MessageCubit>()
          .getUserLatestMessage(
            //fetch opponent user id
            context
                .read<BattleRoomCubit>()
                .getOpponentUserDetails(_currUserId)
                .uid,
            messageId: latestMessagesByUsers[1].messageId,
            //latest user message id
          )
          .messageId
          .isNotEmpty) {
        //Assign latest message
        latestMessagesByUsers[1] =
            context.read<MessageCubit>().getUserLatestMessage(
                  context
                      .read<BattleRoomCubit>()
                      .getOpponentUserDetails(_currUserId)
                      .uid,
                  messageId: latestMessagesByUsers[1].messageId,
                );

        //Display latest message by opponent user
        //means timer is running

        //means timer is running
        if (opponentUserMessageDisappearTimeInSeconds > 0 &&
            opponentUserMessageDisappearTimeInSeconds < 4) {
          opponentUserMessageDisappearTimer?.cancel();
          setOpponentUserMessageDisappearTimer();
        } else {
          await opponentMessageAnimationController.forward();
          setOpponentUserMessageDisappearTimer();
        }
      }
    }
  }

  Widget _buildCurrentUserMessageContainer() {
    return PositionedDirectional(
      start: 10,
      bottom: (bottomPadding * 2.5) +
          MediaQuery.of(context).size.width * timerHeightAndWidthPercentage,
      child: ScaleTransition(
        scale: messageAnimation,
        alignment: const Alignment(-0.5, 1),
        child: const MessageContainer(
          quizType: QuizTypes.oneVsOneBattle,
          isCurrentUser: true,
        ), //-0.5 left side nad 0.5 is right side,
      ),
    );
  }

  Widget _buildOpponentUserMessageContainer() {
    return PositionedDirectional(
      end: 10,
      bottom: (bottomPadding * 2.5) +
          MediaQuery.of(context).size.width * timerHeightAndWidthPercentage,
      child: ScaleTransition(
        scale: opponentMessageAnimation,
        alignment: const Alignment(0.5, 1),
        child: const MessageContainer(
          quizType: QuizTypes.oneVsOneBattle,
          isCurrentUser: false,
        ), //-0.5 left side nad 0.5 is right side,
      ),
    );
  }

  Widget _buildCurrentUserDetailsContainer() {
    final battleRoomCubit = context.read<BattleRoomCubit>();
    return battleRoomCubit.getCurrentUserDetails(_currUserId).uid.isEmpty
        ? const SizedBox()
        : PositionedDirectional(
            bottom: bottomPadding,
            start: 10,
            child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
              bloc: battleRoomCubit,
              builder: (context, state) {
                if (state is BattleRoomUserFound) {
                  final currentUserDetails =
                      battleRoomCubit.getCurrentUserDetails(_currUserId);

                  return UserDetailsWithTimerContainer(
                    correctAnswers:
                        currentUserDetails.correctAnswers.toString(),
                    isCurrentUser: true,
                    name: currentUserDetails.name,
                    timerAnimationController: timerAnimationController,
                    profileUrl: currentUserDetails.profileUrl,
                    totalQues: battleRoomCubit.getQuestions().length.toString(),
                  );
                }
                return const SizedBox();
              },
            ),
          );
  }

  Widget _buildOpponentUserDetailsContainer() {
    final battleRoomCubit = context.read<BattleRoomCubit>();
    return battleRoomCubit.getOpponentUserDetails(_currUserId).uid.isEmpty
        ? const SizedBox()
        : PositionedDirectional(
            bottom: bottomPadding,
            end: 10,
            child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
              bloc: battleRoomCubit,
              builder: (context, state) {
                if (state is BattleRoomUserFound) {
                  final opponent =
                      battleRoomCubit.getOpponentUserDetails(_currUserId);
                  return UserDetailsWithTimerContainer(
                    correctAnswers: opponent.correctAnswers.toString(),
                    isCurrentUser: false,
                    name: opponent.name,
                    timerAnimationController:
                        opponentUserTimerAnimationController,
                    profileUrl: opponent.profileUrl,
                    totalQues: battleRoomCubit.getQuestions().length.toString(),
                  );
                }
                return const SizedBox();
              },
            ),
          );
  }

  Widget _buildYouWonContainer(VoidCallback onPressed) {
    final textStyle = GoogleFonts.nunito(
      textStyle: TextStyle(color: Theme.of(context).primaryColor),
    );
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AlertDialog(
        shadowColor: Colors.transparent,
        title: Text(
          context.tr('youWonLbl')!,
          style: textStyle,
        ),
        content: Text(
          context.tr('opponentLeftLbl')!,
          style: textStyle,
        ),
        actions: [
          CupertinoButton(
            onPressed: onPressed,
            child: Text(
              context.tr('okayLbl')!,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  //if opponent user has left the game this dialog will be shown
  Widget _buildYouWonGameDialog() {
    return showYouLeftQuiz
        ? const SizedBox()
        : BlocBuilder<BattleRoomCubit, BattleRoomState>(
            bloc: context.read<BattleRoomCubit>(),
            builder: (context, state) {
              if (state is BattleRoomUserFound) {
                //show you won game only opponent user has left the game
                if (context
                    .read<BattleRoomCubit>()
                    .opponentLeftTheGame(_currUserId)) {
                  return _buildYouWonContainer(() {
                    deleteMessages(context.read<BattleRoomCubit>().getRoomId());

                    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                          coins:
                              context.read<BattleRoomCubit>().getEntryFee() * 2,
                          title: wonBattleKey,
                          addCoin: true,
                        );
                    context.read<UserDetailsCubit>().updateCoins(
                          addCoin: true,
                          coins:
                              context.read<BattleRoomCubit>().getEntryFee() * 2,
                        );
                    Navigator.of(context).pop();
                  });
                }
              }
              return const SizedBox();
            },
          );
  }

  //if currentUser has left the game
  Widget _buildCurrentUserLeftTheGame() {
    return showYouLeftQuiz
        ? ColoredBox(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.12),
            child: Center(
              child: AlertDialog(
                shadowColor: Colors.transparent,
                content: Text(
                  context.tr('youLeftLbl')!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                actions: [
                  CupertinoButton(
                    child: Text(
                      context.tr('okayLbl')!,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildMessageButton() {
    return widget.playWithBot
        ? const SizedBox.shrink()
        : AnimatedBuilder(
            animation: messageBoxAnimationController,
            builder: (context, child) {
              return InkWell(
                onTap: () {
                  if (messageBoxAnimationController.isCompleted) {
                    messageBoxAnimationController.reverse();
                  } else {
                    messageBoxAnimationController.forward();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.5, vertical: 4),
                  child: Icon(
                    CupertinoIcons.ellipses_bubble_fill,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              );
            },
          );
  }

  Widget _buildMessageBoxContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: messageBoxAnimation.drive(
          Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero),
        ),
        child: MessageBoxContainer(
          quizType: QuizTypes.oneVsOneBattle,
          topPadding: MediaQuery.of(context).padding.top,
          battleRoomId: context.read<BattleRoomCubit>().getRoomId(),
          closeMessageBox: messageBoxAnimationController.reverse,
        ),
      ),
    );
  }

  void onBackPressed(BattleRoomCubit battleRoomCubit) {
    isExitDialogOpen = true;
    //show warning
    showDialog<void>(
      context: context,
      builder: (context) {
        return ExitGameDialog(
          onTapYes: () {
            timerAnimationController.stop();
            opponentUserTimerAnimationController.stop();

            //delete messages
            deleteMessages(battleRoomCubit.getRoomId());
            battleRoomCubit
              ..deleteUserFromRoom(_currUserId)
              ..deleteBattleRoom(isGroupBattle: false);

            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    ).then((value) => isExitDialogOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    final battleRoomCubit = context.read<BattleRoomCubit>();
    return PopScope(
      canPop: showYouLeftQuiz &&
          !messageBoxAnimationController.isCompleted &&
          !battleRoomCubit.opponentLeftTheGame(_currUserId),
      onPopInvoked: (didPop) {
        if (didPop) return;

        //if user left the game
        // if (showYouLeftQuiz) {
        //   return Future.value(true);
        // }
        // //if message sending box is open
        // if (messageBoxAnimationController.isCompleted) {
        //   messageBoxAnimationController.reverse();
        //   return Future.value(false);
        // }
        // //if user already won the game
        // if (battleRoomCubit.opponentLeftTheGame(_currUserId)) {
        //   return Future.value(false);
        // }

        onBackPressed(battleRoomCubit);
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          title: _buildMessageButton(),
          onTapBackButton: () {
            //if user left the game
            if (showYouLeftQuiz) {
              Navigator.pop(context);
            }

            //if user already won the game
            if (battleRoomCubit.opponentLeftTheGame(_currUserId)) {
              return;
            }

            onBackPressed(battleRoomCubit);
          },
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<BattleRoomCubit, BattleRoomState>(
              bloc: battleRoomCubit,
              listener: (context, state) {
                battleRoomListener(context, state, battleRoomCubit);
              },
            ),
            BlocListener<MessageCubit, MessageState>(
              bloc: context.read<MessageCubit>(),
              listener: (context, state) {
                //this listener will be call everytime when new message will add
                messagesListener(state);
              },
            ),
            BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
              listener: (context, state) {
                if (state is UpdateScoreAndCoinsFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    timerAnimationController.stop();
                    opponentUserTimerAnimationController.stop();
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
            ),
          ],
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
                  bloc: battleRoomCubit,
                  builder: (context, state) {
                    return QuestionsContainer(
                      topPadding: MediaQuery.of(context).size.height *
                          UiUtils.getQuestionContainerTopPaddingPercentage(
                            MediaQuery.of(context).size.height,
                          ),
                      timerAnimationController: timerAnimationController,
                      quizType: QuizTypes.oneVsOneBattle,
                      answerMode: context.read<SystemConfigCubit>().answerMode,
                      lifeLines: const {},
                      guessTheWordQuestionContainerKeys: const [],
                      guessTheWordQuestions: const [],
                      hasSubmittedAnswerForCurrentQuestion:
                          hasSubmittedAnswerForCurrentQuestion,
                      questions: battleRoomCubit.getQuestions(),
                      submitAnswer: submitAnswer,
                      questionContentAnimation: questionContentAnimation,
                      questionScaleDownAnimation: questionScaleDownAnimation,
                      questionScaleUpAnimation: questionScaleUpAnimation,
                      questionSlideAnimation: questionSlideAnimation,
                      currentQuestionIndex: currentQuestionIndex,
                      questionAnimationController: questionAnimationController,
                      questionContentAnimationController:
                          questionContentAnimationController,
                    );
                  },
                ),
              ),
              _buildMessageBoxContainer(),
              _buildCurrentUserDetailsContainer(),
              _buildCurrentUserMessageContainer(),
              _buildOpponentUserDetailsContainer(),
              _buildOpponentUserMessageContainer(),
              _buildYouWonGameDialog(),
              _buildCurrentUserLeftTheGame(),
            ],
          ),
        ),
      ),
    );
  }
}
