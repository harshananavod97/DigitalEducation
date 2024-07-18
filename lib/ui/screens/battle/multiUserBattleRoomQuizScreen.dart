import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageBoxContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/rectangleUserProfileContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitForOthersContainer.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/internet_connectivity.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MultiUserBattleRoomQuizScreen extends StatefulWidget {
  const MultiUserBattleRoomQuizScreen({super.key});

  @override
  State<MultiUserBattleRoomQuizScreen> createState() =>
      _MultiUserBattleRoomQuizScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateBookmarkCubit>(
            create: (_) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
          BlocProvider<MessageCubit>(
            create: (_) => MessageCubit(BattleRoomRepository()),
          ),
        ],
        child: const MultiUserBattleRoomQuizScreen(),
      ),
    );
  }
}

class _MultiUserBattleRoomQuizScreenState
    extends State<MultiUserBattleRoomQuizScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController timerAnimationController = AnimationController(
    vsync: this,
    duration: Duration(
      seconds: context.read<SystemConfigCubit>().quizTimer(QuizTypes.groupPlay),
    ),
  )
    ..addStatusListener(currentUserTimerAnimationStatusListener)
    ..forward();

  //to animate the question container
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;

  //to slide the question container from right to left
  late Animation<double> questionSlideAnimation;

  //to scale up the second question
  late Animation<double> questionScaleUpAnimation;

  //to scale down the second question
  late Animation<double> questionScaleDownAnimation;

  //to slude the question content from right to left
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

  late List<AnimationController> opponentMessageAnimationControllers = [];
  late List<Animation<double>> opponentMessageAnimations = [];

  late List<AnimationController> opponentProgressAnimationControllers = [];

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

  int currentQuestionIndex = 0;

  //if user has minimized the app
  bool showUserLeftTheGame = false;

  bool showWaitForOthers = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  //current user message timer
  Timer? currentUserMessageDisappearTimer;
  int currentUserMessageDisappearTimeInSeconds = 4;

  List<Timer?> opponentsMessageDisappearTimer = [];
  List<int> opponentsMessageDisappearTimeInSeconds = [];

  late double userDetaislHorizontalPaddingPercentage =
      (1.0 - UiUtils.questionContainerWidthPercentage) * (0.5);

  late List<Message> latestMessagesByUsers = [];
  late int userLength;

  @override
  void initState() {
    super.initState();
    //add empty messages ofr every user
    WakelockPlus.enable();
    for (var i = 0; i < maxUsersInGroupBattle; i++) {
      latestMessagesByUsers.add(Message.empty());
    }

    //deduct coins of entry fee
    Future.delayed(Duration.zero, () {
      context.read<UpdateScoreAndCoinsCubit>().updateCoins(
            coins: context.read<MultiUserBattleRoomCubit>().getEntryFee(),
            addCoin: false,
            title: playedGroupBattleKey,
          );
      context.read<UserDetailsCubit>().updateCoins(
            addCoin: false,
            coins: context.read<MultiUserBattleRoomCubit>().getEntryFee(),
          );
      context.read<MessageCubit>().subscribeToMessages(
            context.read<MultiUserBattleRoomCubit>().getRoomId(),
          );
      //Get join user length
    });
    initializeAnimation();
    initOpponentConfig();
    questionContentAnimationController.forward();
    //add observer to track app lifecycle activity
    WidgetsBinding.instance.addObserver(this);
    userLength = context.read<MultiUserBattleRoomCubit>().getUsers().length;
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    timerAnimationController
      ..removeStatusListener(currentUserTimerAnimationStatusListener)
      ..dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    messageAnimationController.dispose();
    for (final element in opponentMessageAnimationControllers) {
      element.dispose();
    }
    for (final element in opponentProgressAnimationControllers) {
      element.dispose();
    }
    for (final element in opponentsMessageDisappearTimer) {
      element?.cancel();
    }
    messageBoxAnimationController.dispose();
    currentUserMessageDisappearTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  bool appWasPaused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //remove user from room
    if (state == AppLifecycleState.paused) {
      appWasPaused = true;
      final multiUserBattleRoomCubit = context.read<MultiUserBattleRoomCubit>();
      //if user has already won the game then do nothing
      if (multiUserBattleRoomCubit.getUsers().length != 1) {
        deleteMessages(multiUserBattleRoomCubit);
        multiUserBattleRoomCubit
            .deleteUserFromRoom(context.read<UserDetailsCubit>().userId());
      }
      //
    } else if (state == AppLifecycleState.resumed && appWasPaused) {
      final multiUserBattleRoomCubit = context.read<MultiUserBattleRoomCubit>();
      //if user has won the game already
      if (multiUserBattleRoomCubit.getUsers().length == 1 &&
          multiUserBattleRoomCubit.getUsers().first!.uid ==
              context.read<UserDetailsCubit>().userId()) {
        setState(() {
          showUserLeftTheGame = false;
        });
      }
      //
      else {
        setState(() {
          showUserLeftTheGame = true;
        });
      }

      timerAnimationController.stop();
    }
  }

  void deleteMessages(MultiUserBattleRoomCubit battleRoomCubit) {
    //to delete messages by given user
    context.read<MessageCubit>().deleteMessages(
          battleRoomCubit.getRoomId(),
          context.read<UserDetailsCubit>().userId(),
        );
  }

  void initOpponentConfig() {
    //
    for (var i = 0; i < (maxUsersInGroupBattle - 1); i++) {
      opponentMessageAnimationControllers.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        ),
      );
      opponentProgressAnimationControllers
          .add(AnimationController(vsync: this));
      opponentMessageAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: opponentMessageAnimationControllers[i],
            curve: Curves.easeOutBack,
          ),
        ),
      );
      opponentsMessageDisappearTimer.add(null);
      opponentsMessageDisappearTimeInSeconds.add(4);
    }
  }

  //
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

  //update answer locally and on cloud
  Future<void> submitAnswer(String submittedAnswer) async {
    //
    timerAnimationController.stop();
    final battleRoomCubit = context.read<MultiUserBattleRoomCubit>();
    final questions = battleRoomCubit.getQuestions();

    if (!questions[currentQuestionIndex].attempted) {
      //updated answer locally
      battleRoomCubit
        ..updateQuestionAnswer(
          questions[currentQuestionIndex].id!,
          submittedAnswer,
        )
        ..submitAnswer(
          context.read<UserDetailsCubit>().userId(),
          submittedAnswer,
          isCorrectAnswer: submittedAnswer ==
              AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: questions[currentQuestionIndex].correctAnswer!,
              ),
        );

      //change question
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );
      if (currentQuestionIndex == (questions.length - 1)) {
        setState(() {
          showWaitForOthers = true;
        });
      } else {
        changeQuestion();
        await timerAnimationController.forward(from: 0);
      }
    }
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

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<MultiUserBattleRoomCubit>()
        .getQuestions()[currentQuestionIndex]
        .attempted;
  }

  void battleRoomListener(
    BuildContext context,
    MultiUserBattleRoomState state,
    MultiUserBattleRoomCubit battleRoomCubit,
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

    if (state is MultiUserBattleRoomSuccess) {
      //show result only for more than two user
      if (battleRoomCubit.getUsers().length != 1) {
        //if there is more than one user in room
        //navigate to result
        navigateToResultScreen(
          battleRoomCubit.getUsers(),
          state.battleRoom,
          state.questions,
        );
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

  void setOpponentUserMessageDisappearTimer(int opponentUserIndex) {
    //
    if (opponentsMessageDisappearTimeInSeconds[opponentUserIndex] != 4) {
      opponentsMessageDisappearTimeInSeconds[opponentUserIndex] = 4;
    }

    opponentsMessageDisappearTimer[opponentUserIndex] =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (opponentsMessageDisappearTimeInSeconds[opponentUserIndex] == 0) {
        //
        timer.cancel();
        opponentMessageAnimationControllers[opponentUserIndex].reverse();
      } else {
        //
        opponentsMessageDisappearTimeInSeconds[opponentUserIndex] =
            opponentsMessageDisappearTimeInSeconds[opponentUserIndex] - 1;
      }
    });
  }

  Future<void> messagesListener(MessageState state) async {
    if (state is MessageFetchedSuccess) {
      if (state.messages.isNotEmpty) {
        //current user message

        if (context
            .read<MessageCubit>()
            .getUserLatestMessage(
              //fetch user id
              context.read<UserDetailsCubit>().userId(),
              messageId: latestMessagesByUsers[0].messageId,
              //latest user message id
            )
            .messageId
            .isNotEmpty) {
          //Assign latest message
          latestMessagesByUsers[0] =
              context.read<MessageCubit>().getUserLatestMessage(
                    context.read<UserDetailsCubit>().userId(),
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

        //display opponent user messages

        final opponentUsers = context
            .read<MultiUserBattleRoomCubit>()
            .getOpponentUsers(context.read<UserDetailsCubit>().userId());

        for (var i = 0; i < opponentUsers.length; i++) {
          if (context
              .read<MessageCubit>()
              .getUserLatestMessage(
                //opponent user id
                opponentUsers[i]!.uid,
                messageId: latestMessagesByUsers[i + 1].messageId,
                //latest user message id
              )
              .messageId
              .isNotEmpty) {
            //Assign latest message
            latestMessagesByUsers[i + 1] =
                context.read<MessageCubit>().getUserLatestMessage(
                      context.read<UserDetailsCubit>().userId(),
                      messageId: latestMessagesByUsers[i + 1].messageId,
                    );

            //if new message by opponent
            if (opponentsMessageDisappearTimeInSeconds[i] > 0 &&
                opponentsMessageDisappearTimeInSeconds[i] < 4) {
              //
              opponentsMessageDisappearTimer[i]?.cancel();
              setOpponentUserMessageDisappearTimer(i);
            } else {
              await opponentMessageAnimationControllers[i].forward();
              setOpponentUserMessageDisappearTimer(i);
            }
          }
        }
      }
    }
  }

  void navigateToResultScreen(
    List<UserBattleRoomDetails?> users,
    BattleRoom? battleRoom,
    List<Question>? questions,
  ) {
    var navigateToResult = true;

    if (users.isEmpty) {
      return;
    }

    //checking if every user has given all question's answer
    for (final user in users) {
      //if user uid is not empty means user has not left the game so
      //we will check for it's answer completion
      if (user!.uid.isNotEmpty) {
        //if every user has submitted the answer then move user to result screen
        if (user.answers.length != questions!.length) {
          navigateToResult = false;
        }
      }
    }

    //if all users has submitted the answer
    if (navigateToResult) {
      //giving delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        try {
          //delete battle room by creator of this room
          if (battleRoom!.user1!.uid ==
              context.read<UserDetailsCubit>().userId()) {
            context
                .read<MultiUserBattleRoomCubit>()
                .deleteMultiUserBattleRoom();
          }
          deleteMessages(context.read<MultiUserBattleRoomCubit>());

          //
          //navigating result screen twice...
          //Find optimize solution of navigating to result screen
          //https://stackoverflow.com/questions/56519093/bloc-listen-callback-called-multiple-times try this solution
          //https: //stackoverflow.com/questions/52249578/how-to-deal-with-unwanted-widget-build
          //tried with mounted is true but not working as expected
          //so executing this code in try catch
          //

          if (isSettingDialogOpen) {
            Navigator.of(context).pop();
          }
          if (isExitDialogOpen) {
            Navigator.of(context).pop();
          }

          Navigator.pushReplacementNamed(
            context,
            Routes.multiUserBattleRoomQuizResult,
            arguments: {
              'user': context.read<MultiUserBattleRoomCubit>().getUsers(),
              'entryFee': battleRoom.entryFee,
              'totalQuestions': context
                  .read<MultiUserBattleRoomCubit>()
                  .getQuestions()
                  .length,
            },
          );
        } catch (e) {
          rethrow;
        }
      });
    }
  }

  Widget _buildYouWonContainer(MultiUserBattleRoomCubit battleRoomCubit) {
    return BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
      bloc: battleRoomCubit,
      builder: (context, state) {
        if (state is MultiUserBattleRoomSuccess) {
          if (battleRoomCubit.getUsers().length == 1 &&
              state.battleRoom.user1!.uid ==
                  context.read<UserDetailsCubit>().userId()) {
            timerAnimationController.stop();
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              alignment: Alignment.center,
              child: AlertDialog(
                shadowColor: Colors.transparent,
                title: Text(
                  context.tr('youWonLbl')!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                content: Text(
                  context.tr('everyOneLeftLbl')!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      //delete messages
                      deleteMessages(context.read<MultiUserBattleRoomCubit>());

                      //add coins locally

                      context.read<UserDetailsCubit>().updateCoins(
                            addCoin: true,
                            coins: battleRoomCubit.getEntryFee() * userLength,
                          );
                      //add coins in database

                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                            coins: battleRoomCubit.getEntryFee() * userLength,
                            addCoin: true,
                            title: wonGroupBattleKey,
                          );

                      //delete room
                      battleRoomCubit.deleteMultiUserBattleRoom();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      context.tr('okayLbl')!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildUserLeftTheGame() {
    //cancel timer when user left the game
    if (showUserLeftTheGame) {
      return Container(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AlertDialog(
          shadowColor: Colors.transparent,
          content: Text(
            context.tr('youLeftLbl')!,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                context.tr('okayLbl')!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildCurrentUserDetails(
    UserBattleRoomDetails userBattleRoomDetails,
    String totalQues,
  ) {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: MediaQuery.of(context).size.width *
              userDetaislHorizontalPaddingPercentage,
          bottom: MediaQuery.of(context).size.height *
              RectangleUserProfileContainer.userDetailsHeightPercentage *
              0.25,
        ),

        child: ImageCircularProgressIndicator(
          userBattleRoomDetails: userBattleRoomDetails,
          animationController: timerAnimationController,
          totalQues: totalQues,
          // opponentProgressAnimationControllers[opponentUserIndex],
        ),
        // child: RectangleUserProfileContainer(
        //   userBattleRoomDetails: userBattleRoomDetails,
        //   isLeft: true,
        //   progressColor: Theme.of(context).colorScheme.surface,
        // ),
      ),
    );
  }

  Widget _buildOpponentUserDetails({
    required int questionsLength,
    required AlignmentDirectional alignment,
    required List<UserBattleRoomDetails?> opponentUsers,
    required int opponentUserIndex,
  }) {
    final userBattleRoomDetails = opponentUsers[opponentUserIndex]!;
    // double progressPercentage =
    //     (100.0 * userBattleRoomDetails.answers.length) / questionsLength;
    // opponentProgressAnimationControllers[opponentUserIndex].value =
    //     NormalizeNumber.inRange(
    //   currentValue: progressPercentage,
    //   minValue: 0.0,
    //   maxValue: 100.0,
    //   newMaxValue: 1.0,
    //   newMinValue: 0.0,
    // );
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: alignment == AlignmentDirectional.bottomEnd ||
                  alignment == AlignmentDirectional.topEnd
              ? 0
              : MediaQuery.of(context).size.width *
                  userDetaislHorizontalPaddingPercentage,
          end: alignment == AlignmentDirectional.bottomEnd ||
                  alignment == AlignmentDirectional.topEnd
              ? MediaQuery.of(context).size.width *
                  userDetaislHorizontalPaddingPercentage
              : 0,
          bottom: MediaQuery.of(context).size.height *
              RectangleUserProfileContainer.userDetailsHeightPercentage *
              (0.25),
          top: alignment == AlignmentDirectional.topStart ||
                  alignment == AlignmentDirectional.topEnd
              ? 0
              : 0,
        ),
        child: ImageCircularProgressIndicator(
          userBattleRoomDetails: userBattleRoomDetails,
          animationController:
              opponentProgressAnimationControllers[opponentUserIndex],
          totalQues: questionsLength.toString(),
        ),
        // child: RectangleUserProfileContainer(
        //   userBattleRoomDetails: userBattleRoomDetails,
        //   isLeft: alignment == AlignmentDirectional.bottomStart ||
        //       alignment == AlignmentDirectional.topStart,
        //   animationController:
        //       opponentProgressAnimationControllers[opponentUserIndex],
        //   progressColor: Theme.of(context).colorScheme.surface,
        // ),
      ),
    );
  }

  Widget _buildMessageButton() {
    return AnimatedBuilder(
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
            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 4),
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
          quizType: QuizTypes.groupPlay,
          battleRoomId: context.read<MultiUserBattleRoomCubit>().getRoomId(),
          topPadding: MediaQuery.of(context).padding.top,
          closeMessageBox: () {
            messageBoxAnimationController.reverse();
          },
        ),
      ),
    );
  }

  Widget _buildCurrentUserMessageContainer() {
    return PositionedDirectional(
      start: MediaQuery.of(context).size.width *
          userDetaislHorizontalPaddingPercentage,
      bottom: MediaQuery.of(context).size.height *
          RectangleUserProfileContainer.userDetailsHeightPercentage *
          2.9,
      child: ScaleTransition(
        scale: messageAnimation,
        alignment: const Alignment(-0.5, -1),
        child: const MessageContainer(
          quizType: QuizTypes.groupPlay,
          isCurrentUser: true,
        ), //-0.5 left side and 0.5 is right side,
      ),
    );
  }

  Widget _buildOpponentUserMessageContainer(int opponentUserIndex) {
    var alignment = const Alignment(-0.5, 1);
    if (opponentUserIndex == 0) {
      alignment = const Alignment(0.5, 1);
    } else if (opponentUserIndex == 1) {
      alignment = const Alignment(-0.5, -1);
    } else {
      alignment = const Alignment(0.5, -1);
    }

    return PositionedDirectional(
      end: opponentUserIndex == 1
          ? null
          : MediaQuery.of(context).size.width *
              userDetaislHorizontalPaddingPercentage,
      start: opponentUserIndex == 1
          ? MediaQuery.of(context).size.width *
              userDetaislHorizontalPaddingPercentage
          : null,
      top: opponentUserIndex == 0
          ? null
          : (MediaQuery.of(context).size.height *
                  RectangleUserProfileContainer.userDetailsHeightPercentage *
                  3.35) +
              MediaQuery.of(context).padding.top,
      bottom: opponentUserIndex == 0
          ? MediaQuery.of(context).size.height *
              RectangleUserProfileContainer.userDetailsHeightPercentage *
              (2.9)
          : null,
      child: ScaleTransition(
        scale: opponentMessageAnimations[opponentUserIndex],
        alignment: alignment,
        child: MessageContainer(
          quizType: QuizTypes.groupPlay,
          isCurrentUser: false,
          opponentUserIndex: opponentUserIndex,
        ), //-0.5 left side and 0.5 is right side,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final battleRoomCubit = context.read<MultiUserBattleRoomCubit>();

    final opponentUsers = battleRoomCubit
        .getOpponentUsers(context.read<UserDetailsCubit>().userId());

    return PopScope(
      canPop: showUserLeftTheGame,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Close Message Box Before
        if (messageBoxAnimationController.isCompleted) {
          messageBoxAnimationController.reverse();
          return;
        }

        isExitDialogOpen = true;
        showDialog<void>(
          context: context,
          builder: (_) => ExitGameDialog(
            onTapYes: () {
              if (battleRoomCubit.getUsers().length == 1) {
                battleRoomCubit.deleteMultiUserBattleRoom();
              } else {
                //delete user from game room
                battleRoomCubit.deleteUserFromRoom(
                  context.read<UserDetailsCubit>().userId(),
                );
              }
              deleteMessages(battleRoomCubit);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ).then((value) => isExitDialogOpen = true);
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          title: _buildMessageButton(),
          onTapBackButton: () {
            final battleRoomCubit = context.read<MultiUserBattleRoomCubit>();

            //if user hasleft the game
            if (showUserLeftTheGame) {
              Navigator.of(context).pop();
            }
            //
            if (battleRoomCubit.getUsers().length == 1 &&
                battleRoomCubit.getUsers().first!.uid ==
                    context.read<UserDetailsCubit>().userId()) {
              return;
            }

            //if user is playing game then show
            //exit game dialog

            isExitDialogOpen = true;
            showDialog<void>(
              context: context,
              builder: (_) => ExitGameDialog(
                onTapYes: () {
                  if (battleRoomCubit.getUsers().length == 1) {
                    battleRoomCubit.deleteMultiUserBattleRoom();
                  } else {
                    //delete user from game room
                    battleRoomCubit.deleteUserFromRoom(
                      context.read<UserDetailsCubit>().userId(),
                    );
                  }
                  deleteMessages(battleRoomCubit);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ).then((value) => isExitDialogOpen = true);
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: MultiBlocListener(
          listeners: [
            //update ui and do other callback based on changes in MultiUserBattleRoomCubit
            BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
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
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
            ),
          ],
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      EdgeInsets.only(top: opponentUsers.length >= 2 ? 70 : 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: showWaitForOthers
                        ? const WaitForOthersContainer(
                            key: Key('waitForOthers'),
                          )
                        : BlocBuilder<MultiUserBattleRoomCubit,
                            MultiUserBattleRoomState>(
                            bloc: battleRoomCubit,
                            builder: (context, state) {
                              return QuestionsContainer(
                                topPadding: MediaQuery.of(context).size.height *
                                    RectangleUserProfileContainer
                                        .userDetailsHeightPercentage *
                                    3.5,
                                timerAnimationController:
                                    timerAnimationController,
                                quizType: QuizTypes.groupPlay,
                                answerMode: context
                                    .read<SystemConfigCubit>()
                                    .answerMode,
                                lifeLines: const {},
                                guessTheWordQuestionContainerKeys: const [],
                                key: const Key('questions'),
                                guessTheWordQuestions: const [],
                                hasSubmittedAnswerForCurrentQuestion:
                                    hasSubmittedAnswerForCurrentQuestion,
                                questions: battleRoomCubit.getQuestions(),
                                submitAnswer: submitAnswer,
                                questionContentAnimation:
                                    questionContentAnimation,
                                questionScaleDownAnimation:
                                    questionScaleDownAnimation,
                                questionScaleUpAnimation:
                                    questionScaleUpAnimation,
                                questionSlideAnimation: questionSlideAnimation,
                                currentQuestionIndex: currentQuestionIndex,
                                questionAnimationController:
                                    questionAnimationController,
                                questionContentAnimationController:
                                    questionContentAnimationController,
                              );
                            },
                          ),
                  ),
                ),
              ),
              _buildMessageBoxContainer(),
              ...showUserLeftTheGame
                  ? []
                  : [
                      _buildCurrentUserDetails(
                        battleRoomCubit.getUser(
                          context.read<UserDetailsCubit>().userId(),
                        )!,
                        battleRoomCubit.getQuestions().length.toString(),
                      ),
                      _buildCurrentUserMessageContainer(),

                      //Optimize for more user code
                      //use for loop not add manual user like this
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: battleRoomCubit,
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            final opponentUsers =
                                battleRoomCubit.getOpponentUsers(
                              context.read<UserDetailsCubit>().userId(),
                            );
                            return opponentUsers.isNotEmpty
                                ? _buildOpponentUserDetails(
                                    questionsLength: state.questions.length,
                                    alignment: AlignmentDirectional.bottomEnd,
                                    opponentUsers: opponentUsers,
                                    opponentUserIndex: 0,
                                  )
                                : const SizedBox();
                          }
                          return const SizedBox();
                        },
                      ),
                      _buildOpponentUserMessageContainer(0),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: battleRoomCubit,
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            final opponentUsers =
                                battleRoomCubit.getOpponentUsers(
                              context.read<UserDetailsCubit>().userId(),
                            );
                            return opponentUsers.length >= 2
                                ? _buildOpponentUserDetails(
                                    questionsLength: state.questions.length,
                                    alignment: AlignmentDirectional.topStart,
                                    opponentUsers: opponentUsers,
                                    opponentUserIndex: 1,
                                  )
                                : const SizedBox();
                          }
                          return const SizedBox();
                        },
                      ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: battleRoomCubit,
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            final opponentUsers =
                                battleRoomCubit.getOpponentUsers(
                              context.read<UserDetailsCubit>().userId(),
                            );
                            return opponentUsers.length >= 2
                                ? _buildOpponentUserMessageContainer(1)
                                : const SizedBox();
                          }
                          return const SizedBox();
                        },
                      ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: battleRoomCubit,
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            final opponentUsers =
                                battleRoomCubit.getOpponentUsers(
                              context.read<UserDetailsCubit>().userId(),
                            );
                            return opponentUsers.length >= 3
                                ? _buildOpponentUserDetails(
                                    questionsLength: state.questions.length,
                                    alignment: AlignmentDirectional.topEnd,
                                    opponentUsers: opponentUsers,
                                    opponentUserIndex: 2,
                                  )
                                : const SizedBox();
                          }
                          return const SizedBox();
                        },
                      ),
                      BlocBuilder<MultiUserBattleRoomCubit,
                          MultiUserBattleRoomState>(
                        bloc: battleRoomCubit,
                        builder: (context, state) {
                          if (state is MultiUserBattleRoomSuccess) {
                            final opponentUsers =
                                battleRoomCubit.getOpponentUsers(
                              context.read<UserDetailsCubit>().userId(),
                            );
                            return opponentUsers.length >= 3
                                ? _buildOpponentUserMessageContainer(2)
                                : Container();
                          }
                          return Container();
                        },
                      ),
                    ],
              // _buildMessageButton(),
              _buildYouWonContainer(battleRoomCubit),
              _buildUserLeftTheGame(),
              // _buildTopMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageCircularProgressIndicator extends StatelessWidget {
  const ImageCircularProgressIndicator({
    required this.userBattleRoomDetails,
    required this.animationController,
    required this.totalQues,
    super.key,
  });

  final UserBattleRoomDetails userBattleRoomDetails;
  final AnimationController animationController;
  final String totalQues;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 75,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 55,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: QImage.circular(
                      imageUrl: userBattleRoomDetails.profileUrl,
                      height: 48,
                      width: 48,
                    ),
                  ),

                  /// Circle
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CustomPaint(
                        painter: _CircleCustomPainter(
                          color: Theme.of(context).colorScheme.surface,
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                  ),

                  /// Arc
                  Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (_, __) {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomPaint(
                            painter: _ArcCustomPainter(
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 4,
                              sweepDegree: 360 * animationController.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  ///
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 15,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${userBattleRoomDetails.correctAnswers}/$totalQues',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 10,
                          fontWeight: FontWeights.regular,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 8),
            Text(
              userBattleRoomDetails.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeights.bold,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleCustomPainter extends CustomPainter {
  const _CircleCustomPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * 0.5, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArcCustomPainter extends CustomPainter {
  const _ArcCustomPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepDegree,
  });

  final Color color;
  final double strokeWidth;
  final double sweepDegree;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final p = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    /// The PI constant.
    const pi = 3.1415926535897932;

    const startAngle = 3 * (pi / 2);
    final sweepAngle = (sweepDegree * pi) / 180.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.5),
      startAngle,
      sweepAngle,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
