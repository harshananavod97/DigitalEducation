import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/guessTheWordQuizCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/ui/widgets/text_circular_timer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class GuessTheWordQuizScreen extends StatefulWidget {
  const GuessTheWordQuizScreen({
    required this.type,
    required this.typeId,
    required this.isPlayed,
    super.key,
  });

  final String type; //category or subcategory
  final String typeId; //id of category or subcategory
  final bool isPlayed;

  @override
  State<GuessTheWordQuizScreen> createState() => _GuessTheWordQuizScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateBookmarkCubit>(
            create: (_) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
          BlocProvider<GuessTheWordQuizCubit>(
            create: (_) => GuessTheWordQuizCubit(QuizRepository()),
          ),
        ],
        child: GuessTheWordQuizScreen(
          isPlayed: arguments['isPlayed'] as bool,
          type: arguments['type'] as String,
          typeId: arguments['typeId'] as String,
        ),
      ),
    );
  }
}

class _GuessTheWordQuizScreenState extends State<GuessTheWordQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController timerAnimationController = AnimationController(
    vsync: this,
    duration: Duration(
      seconds:
          context.read<SystemConfigCubit>().quizTimer(QuizTypes.guessTheWord),
    ),
  )..addStatusListener(currentUserTimerAnimationStatusListener);

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

  int _currentQuestionIndex = 0;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  //
  double timeTakenToCompleteQuiz = 0;

  bool isExitDialogOpen = false;

  late List<GlobalKey<GuessTheWordQuestionContainerState>>
      questionContainerKeys = [];

  @override
  void initState() {
    super.initState();
    initializeAnimation();
    //fetching question for quiz
    _getQuestions();
  }

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<GuessTheWordQuizCubit>().getQuestion(
            questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.type,
            typeId: widget.typeId,
          );
    });
  }

  @override
  void dispose() {
    timerAnimationController
      ..removeStatusListener(currentUserTimerAnimationStatusListener)
      ..dispose();
    questionContentAnimationController.dispose();
    questionAnimationController.dispose();

    super.dispose();
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
      updateBookmarkAnswer();
      submitAnswer(
        questionContainerKeys[_currentQuestionIndex]
            .currentState!
            .getSubmittedAnswer(),
      );
    }
  }

  void navigateToResultScreen() {
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushReplacementNamed(
      Routes.result,
      arguments: {
        'myPoints': context.read<GuessTheWordQuizCubit>().getCurrentPoints(),
        'quizType': QuizTypes.guessTheWord,
        'isPlayed': widget.isPlayed,
        'numberOfPlayer': 1,
        'timeTakenToCompleteQuiz': timeTakenToCompleteQuiz,
        'guessTheWordQuestions':
            context.read<GuessTheWordQuizCubit>().getQuestions(),
      },
    );
  }

  Future<void> submitAnswer(List<String> submittedAnswer) async {
    timerAnimationController.stop();
    updateTimeTakenToCompleteQuiz();
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    //if answer not submitted then submit answer
    if (!guessTheWordQuizCubit
        .getQuestions()[_currentQuestionIndex]
        .hasAnswered) {
      //submitted answer
      guessTheWordQuizCubit.submitAnswer(
        guessTheWordQuizCubit.getQuestions()[_currentQuestionIndex].id,
        submittedAnswer,
        context
            .read<SystemConfigCubit>()
            .quizCorrectAnswerCreditScore(QuizTypes.guessTheWord),
        context
            .read<SystemConfigCubit>()
            .quizWrongAnswerDeductScore(QuizTypes.guessTheWord),
      );
      //wait for some seconds
      await Future<void>.delayed(
        const Duration(seconds: inBetweenQuestionTimeInSeconds),
      );
      //if currentQuestion is last then move user to result screen
      if (_currentQuestionIndex ==
          (guessTheWordQuizCubit.getQuestions().length - 1)) {
        navigateToResultScreen();
      } else {
        //change question
        changeQuestion();
        await timerAnimationController.forward(from: 0);
      }
    }
  }

  void updateTimeTakenToCompleteQuiz() {
    timeTakenToCompleteQuiz = timeTakenToCompleteQuiz +
        UiUtils.timeTakenToSubmitAnswer(
          animationControllerValue: timerAnimationController.value,
          quizTimer: context
              .read<SystemConfigCubit>()
              .quizTimer(QuizTypes.guessTheWord),
        );
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
        _currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //
  void updateBookmarkAnswer() {
    //update bookmark answer
    if (context.read<GuessTheWordBookmarkCubit>().hasQuestionBookmarked(
          context
              .read<GuessTheWordQuizCubit>()
              .getQuestions()[_currentQuestionIndex]
              .id,
        )) {
      context.read<GuessTheWordBookmarkCubit>().updateSubmittedAnswer(
            questionId: context
                .read<GuessTheWordQuizCubit>()
                .getQuestions()[_currentQuestionIndex]
                .id,
            submittedAnswer: UiUtils.buildGuessTheWordQuestionAnswer(
              questionContainerKeys[_currentQuestionIndex]
                  .currentState!
                  .getSubmittedAnswer(),
            ),
            userId: context.read<UserDetailsCubit>().userId(),
          );
    }
  }

  Widget _buildQuestions(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      builder: (context, state) {
        if (state is GuessTheWordQuizIntial ||
            state is GuessTheWordQuizFetchInProgress) {
          return const Center(
            child: CircularProgressContainer(whiteLoader: true),
          );
        }

        if (state is GuessTheWordQuizFetchSuccess) {
          return Align(
            alignment: Alignment.topCenter,
            child: QuestionsContainer(
              timerAnimationController: timerAnimationController,
              quizType: QuizTypes.guessTheWord,
              answerMode: AnswerMode.showAnswerCorrectness,
              lifeLines: const {},
              guessTheWordQuestionContainerKeys: questionContainerKeys,
              topPadding: MediaQuery.of(context).size.height *
                  UiUtils.getQuestionContainerTopPaddingPercentage(
                    MediaQuery.of(context).size.height,
                  ),
              guessTheWordQuestions: state.questions,
              hasSubmittedAnswerForCurrentQuestion: () {
                return false;
              },
              questions: const [],
              submitAnswer: (_) {},
              questionContentAnimation: questionContentAnimation,
              questionScaleDownAnimation: questionScaleDownAnimation,
              questionScaleUpAnimation: questionScaleUpAnimation,
              questionSlideAnimation: questionSlideAnimation,
              currentQuestionIndex: _currentQuestionIndex,
              questionAnimationController: questionAnimationController,
              questionContentAnimationController:
                  questionContentAnimationController,
            ),
          );
        }

        if (state is GuessTheWordQuizFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageColor: Theme.of(context).colorScheme.surface,
              showBackButton: true,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: _getQuestions,
              showErrorImage: true,
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSubmitButton(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      bloc: guessTheWordQuizCubit,
      builder: (context, state) {
        if (state is GuessTheWordQuizFetchSuccess) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * (0.025),
              ),
              child: CustomRoundedButton(
                widthPercentage: 0.5,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('submitBtn'),
                elevation: 5,
                shadowColor: Colors.black45,
                titleColor: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.bold,
                onTap: () {
                  //
                  updateBookmarkAnswer();
                  submitAnswer(
                    questionContainerKeys[_currentQuestionIndex]
                        .currentState!
                        .getSubmittedAnswer(),
                  );
                },
                radius: 10,
                showBorder: false,
                height: 45,
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog<void>(context: context, builder: (_) => const ExitGameDialog())
        .then((value) => isExitDialogOpen = false);
  }

  Widget _buildBookmarkButton(GuessTheWordQuizCubit guessTheWordQuizCubit) {
    return BlocBuilder<GuessTheWordQuizCubit, GuessTheWordQuizState>(
      bloc: guessTheWordQuizCubit,
      builder: (context, state) {
        if (state is GuessTheWordQuizFetchSuccess) {
          //

          final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
          final updateBookmarkCubit = context.read<UpdateBookmarkCubit>();
          return BlocListener<UpdateBookmarkCubit, UpdateBookmarkState>(
            bloc: updateBookmarkCubit,
            listener: (context, state) {
              //if failed to update bookmark status
              if (state is UpdateBookmarkFailure) {
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  timerAnimationController.stop();
                  showAlreadyLoggedInDialog(context);
                  return;
                }

                //remove bookmark question
                if (state.failedStatus == '0') {
                  //if unable to remove question from bookmark then add question
                  //add again
                  bookmarkCubit.addBookmarkQuestion(
                    guessTheWordQuizCubit.getQuestions()[_currentQuestionIndex],
                    context.read<UserDetailsCubit>().userId(),
                  );
                } else {
                  //remove again
                  //if unable to add question to bookmark then remove question
                  bookmarkCubit.removeBookmarkQuestion(
                    guessTheWordQuizCubit
                        .getQuestions()[_currentQuestionIndex]
                        .id,
                    context.read<UserDetailsCubit>().userId(),
                  );
                }
                UiUtils.showSnackBar(
                  context.tr(
                    convertErrorCodeToLanguageKey(
                      errorCodeUpdateBookmarkFailure,
                    ),
                  )!,
                  context,
                );
              }
            },
            child: BlocBuilder<GuessTheWordBookmarkCubit,
                GuessTheWordBookmarkState>(
              bloc: context.read<GuessTheWordBookmarkCubit>(),
              builder: (context, state) {
                if (state is GuessTheWordBookmarkFetchSuccess) {
                  return InkWell(
                    onTap: () {
                      if (bookmarkCubit.hasQuestionBookmarked(
                        guessTheWordQuizCubit
                            .getQuestions()[_currentQuestionIndex]
                            .id,
                      )) {
                        //remove
                        bookmarkCubit.removeBookmarkQuestion(
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex]
                              .id,
                          context.read<UserDetailsCubit>().userId(),
                        );
                        updateBookmarkCubit.updateBookmark(
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex]
                              .id,
                          '0',
                          '3', //type is 3 for guess the word questions
                        );
                      } else {
                        //add
                        bookmarkCubit.addBookmarkQuestion(
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex],
                          context.read<UserDetailsCubit>().userId(),
                        );
                        updateBookmarkCubit.updateBookmark(
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex]
                              .id,
                          '1',
                          '3',
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Icon(
                        bookmarkCubit.hasQuestionBookmarked(
                          guessTheWordQuizCubit
                              .getQuestions()[_currentQuestionIndex]
                              .id,
                        )
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 20,
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final guessTheWordQuizCubit = context.read<GuessTheWordQuizCubit>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        onTapBackButton();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<GuessTheWordQuizCubit, GuessTheWordQuizState>(
            bloc: guessTheWordQuizCubit,
            listener: (context, state) {
              if (state is GuessTheWordQuizFetchSuccess) {
                if (_currentQuestionIndex == 0 &&
                    !state.questions[_currentQuestionIndex].hasAnswered) {
                  for (final _ in state.questions) {
                    questionContainerKeys
                        .add(GlobalKey<GuessTheWordQuestionContainerState>());
                  }
                  //start timer
                  timerAnimationController.forward();
                  questionContentAnimationController.forward();
                }
              } else if (state is GuessTheWordQuizFetchFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                }
              }
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
        child: Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            onTapBackButton: onTapBackButton,
            title: TextCircularTimer(
              animationController: timerAnimationController,
              arcColor: Theme.of(context).primaryColor,
              color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
            ),
            actions: [_buildBookmarkButton(guessTheWordQuizCubit)],
          ),
          body: Stack(
            children: [
              _buildQuestions(guessTheWordQuizCubit),
              _buildSubmitButton(guessTheWordQuizCubit),
            ],
          ),
        ),
      ),
    );
  }
}
