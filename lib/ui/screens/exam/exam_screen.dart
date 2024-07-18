import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examQuestionStatusBottomSheetContainer.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examTimerContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/questionContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/ui/widgets/optionContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:wakelock/wakelock.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();

  static Route<ExamScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (context) => const ExamScreen());
  }
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  final timerKey = GlobalKey<ExamTimerContainerState>();

  late final pageController = PageController();

  Timer? canGiveExamAgainTimer;
  bool canGiveExamAgain = true;

  late int canGiveExamAgainTimeInSeconds =
      context.read<SystemConfigCubit>().resumeExamAfterCloseTimeout;

  bool isExitDialogOpen = false;
  bool userLeftTheExam = false;

  bool showYouLeftTheExam = false;
  bool isExamQuestionStatusBottomSheetOpen = false;

  int currentQuestionIndex = 0;

  IosInsecureScreenDetector? _iosInsecureScreenDetector;
  late bool isScreenRecordingInIos = false;

  List<String> iosCapturedScreenshotQuestionIds = [];

  @override
  void initState() {
    super.initState();

    //wake lock enable so phone will not lock automatically after sometime

    WakelockPlus.enable();

    WidgetsBinding.instance.addObserver(this);

    if (Platform.isIOS) {
      initScreenshotAndScreenRecordDetectorInIos();
    } else {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }

    //start timer
    Future.delayed(Duration.zero, () {
      timerKey.currentState?.startTimer();
    });
  }

  Future<void> initScreenshotAndScreenRecordDetectorInIos() async {
    _iosInsecureScreenDetector = IosInsecureScreenDetector();
    await _iosInsecureScreenDetector?.initialize();
    _iosInsecureScreenDetector?.addListener(
      iosScreenshotCallback,
      (b) => iosScreenRecordCallback(isRecording: b),
    );
  }

  void iosScreenshotCallback() {
    iosCapturedScreenshotQuestionIds.add(
      context.read<ExamCubit>().getQuestions()[currentQuestionIndex].id!,
    );
  }

  void iosScreenRecordCallback({required bool isRecording}) {
    setState(() => isScreenRecordingInIos = isRecording);
  }

  void setCanGiveExamTimer() {
    canGiveExamAgainTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (canGiveExamAgainTimeInSeconds == 0) {
          timer.cancel();

          //can give exam again false
          canGiveExamAgain = false;

          //show user left the exam
          setState(() => showYouLeftTheExam = true);
          //submit result
          submitResult();
        } else {
          canGiveExamAgainTimeInSeconds--;
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.paused) {
      setCanGiveExamTimer();
    } else if (appState == AppLifecycleState.resumed) {
      canGiveExamAgainTimer?.cancel();
      //if user can give exam again
      if (canGiveExamAgain) {
        canGiveExamAgainTimeInSeconds =
            context.read<SystemConfigCubit>().resumeExamAfterCloseTimeout;
      }
    }
  }

  @override
  void dispose() {
    canGiveExamAgainTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _iosInsecureScreenDetector?.dispose();
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.dispose();
  }

  void showExamQuestionStatusBottomSheet() {
    isExamQuestionStatusBottomSheetOpen = true;
    showModalBottomSheet<void>(
      isScrollControlled: true,
      elevation: 5,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) => ExamQuestionStatusBottomSheetContainer(
        navigateToResultScreen: navigateToResultScreen,
        pageController: pageController,
      ),
    ).then((_) => isExamQuestionStatusBottomSheetOpen = false);
  }

  bool hasSubmittedAnswerForCurrentQuestion() {
    return context
        .read<ExamCubit>()
        .getQuestions()[currentQuestionIndex]
        .attempted;
  }

  void submitResult() {
    context.read<ExamCubit>().submitResult(
          capturedQuestionIds: iosCapturedScreenshotQuestionIds,
          rulesViolated: iosCapturedScreenshotQuestionIds.isNotEmpty,
          userId: context.read<UserDetailsCubit>().getUserFirebaseId(),
          totalDuration:
              timerKey.currentState?.getCompletedExamDuration().toString() ??
                  '0',
        );
  }

  void submitAnswer(String submittedAnswerId) {
    final examCubit = context.read<ExamCubit>();
    if (hasSubmittedAnswerForCurrentQuestion()) {
      if (examCubit.canUserSubmitAnswerAgainInExam()) {
        examCubit.updateQuestionWithAnswer(
          examCubit.getQuestions()[currentQuestionIndex].id!,
          submittedAnswerId,
        );
      }
    } else {
      examCubit.updateQuestionWithAnswer(
        examCubit.getQuestions()[currentQuestionIndex].id!,
        submittedAnswerId,
      );
    }
  }

  void navigateToResultScreen() {
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    if (isExamQuestionStatusBottomSheetOpen) {
      Navigator.of(context).pop();
    }

    submitResult();

    final userFirebaseId = context.read<UserDetailsCubit>().getUserFirebaseId();
    final examCubit = context.read<ExamCubit>();
    Navigator.of(context).pushReplacementNamed(
      Routes.result,
      arguments: {
        'quizType': QuizTypes.exam,
        'exam': examCubit.getExam(),
        'obtainedMarks': examCubit.obtainedMarks(userFirebaseId),
        'examCompletedInMinutes':
            timerKey.currentState?.getCompletedExamDuration(),
        'correctExamAnswers': examCubit.correctAnswers(userFirebaseId),
        'incorrectExamAnswers': examCubit.incorrectAnswers(userFirebaseId),
        'numberOfPlayer': 1,
      },
    );
  }

  Widget _buildBottomMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            child: Opacity(
              opacity: currentQuestionIndex != 0 ? 1.0 : 0.5,
              child: IconButton(
                onPressed: () {
                  if (currentQuestionIndex != 0) {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: Theme.of(context).colorScheme.onTertiary,
            ),
            padding: const EdgeInsets.only(left: 42, right: 48),
            child: IconButton(
              onPressed: showExamQuestionStatusBottomSheet,
              icon: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Theme.of(context).colorScheme.surface,
                size: 40,
              ),
            ),
          ),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            child: Opacity(
              opacity: (context.read<ExamCubit>().getQuestions().length - 1) !=
                      currentQuestionIndex
                  ? 1.0
                  : 0.5,
              child: IconButton(
                onPressed: () {
                  if (context.read<ExamCubit>().getQuestions().length - 1 !=
                      currentQuestionIndex) {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouLeftTheExam() {
    if (showYouLeftTheExam) {
      return Align(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          child: AlertDialog(
            content: Text(
              context.tr(youLeftTheExamKey)!,
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.tr(okayLbl)!,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildQuestions() {
    return BlocBuilder<ExamCubit, ExamState>(
      bloc: context.read<ExamCubit>(),
      builder: (context, state) {
        if (state is ExamFetchSuccess) {
          return PageView.builder(
            onPageChanged: (index) {
              setState(() => currentQuestionIndex = index);
            },
            controller: pageController,
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    QuestionContainer(
                      isMathQuestion: true,
                      questionColor: Theme.of(context).colorScheme.onTertiary,
                      questionNumber: index + 1,
                      question: state.questions[index],
                    ),
                    const SizedBox(height: 25),
                    ...state.questions[index].answerOptions!.map(
                      (option) => OptionContainer(
                        quizType: QuizTypes.exam,
                        answerMode: AnswerMode.noAnswerCorrectness,
                        showAudiencePoll: false,
                        hasSubmittedAnswerForCurrentQuestion:
                            hasSubmittedAnswerForCurrentQuestion,
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * (0.85),
                          maxHeight: MediaQuery.of(context).size.height *
                              UiUtils.questionContainerHeightPercentage,
                        ),
                        answerOption: option,
                        correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                          rawKey: context
                              .read<UserDetailsCubit>()
                              .getUserFirebaseId(),
                          correctAnswer: state.questions[index].correctAnswer!,
                        ),
                        submitAnswer: submitAnswer,
                        submittedAnswerId:
                            state.questions[index].submittedAnswerId,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: showYouLeftTheExam,
      onPopInvoked: (didPop) {
        if (didPop) return;

        onTapBackButton();
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          title: ExamTimerContainer(
            navigateToResultScreen: navigateToResultScreen,
            examDurationInMinutes:
                int.parse(context.read<ExamCubit>().getExam().duration),
            key: timerKey,
          ),
          onTapBackButton: onTapBackButton,
        ),
        body: Stack(
          children: [
            _buildQuestions(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomMenu(),
            ),
            _buildYouLeftTheExam(),
            if (isScreenRecordingInIos)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const ColoredBox(color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog<void>(
      context: context,
      builder: (_) => ExitGameDialog(
        onTapYes: () {
          submitResult();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    ).then((_) => isExitDialogOpen = false);
  }
}
