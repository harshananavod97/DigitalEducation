import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audioQuestionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/latex_answer_options_list.dart';
import 'package:flutterquiz/ui/widgets/optionContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/lifeLine_options.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class QuestionsContainer extends StatefulWidget {
  const QuestionsContainer({
    required this.submitAnswer,
    required this.quizType,
    required this.guessTheWordQuestionContainerKeys,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.currentQuestionIndex,
    required this.guessTheWordQuestions,
    required this.questionAnimationController,
    required this.questionContentAnimationController,
    required this.questionContentAnimation,
    required this.questionScaleDownAnimation,
    required this.questionScaleUpAnimation,
    required this.questionSlideAnimation,
    required this.questions,
    required this.lifeLines,
    required this.timerAnimationController,
    required this.answerMode,
    super.key,
    this.showGuessTheWordHint,
    this.audioQuestionContainerKeys,
    this.level,
    this.topPadding,
  });

  final List<GlobalKey> guessTheWordQuestionContainerKeys;

  final List<GlobalKey>? audioQuestionContainerKeys;
  final QuizTypes quizType;
  final bool Function() hasSubmittedAnswerForCurrentQuestion;
  final int currentQuestionIndex;
  final void Function(String) submitAnswer;
  final AnimationController questionContentAnimationController;
  final AnimationController questionAnimationController;
  final Animation<double> questionSlideAnimation;
  final Animation<double> questionScaleUpAnimation;
  final Animation<double> questionScaleDownAnimation;
  final Animation<double> questionContentAnimation;
  final List<Question> questions;
  final List<GuessTheWordQuestion> guessTheWordQuestions;
  final double? topPadding;
  final String? level;
  final Map<String, LifelineStatus> lifeLines;
  final AnswerMode answerMode;
  final AnimationController timerAnimationController;
  final bool? showGuessTheWordHint;

  @override
  State<QuestionsContainer> createState() => _QuestionsContainerState();
}

class _QuestionsContainerState extends State<QuestionsContainer> {
  final double maxscale = 4;
  final double minscale = 1;
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;
  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  List<AnswerOption> filteredOptions = [];
  List<int> audiencePollPercentages = [];

  late double textSize;

  late final bool _isLatex = widget.quizType == QuizTypes.mathMania ||
      widget.quizType == QuizTypes.quizZone ||
      widget.quizType == QuizTypes.oneVsOneBattle ||
      widget.quizType == QuizTypes.groupPlay ||
      widget.quizType == QuizTypes.dailyQuiz ||
      widget.quizType == QuizTypes.trueAndFalse ||
      widget.quizType == QuizTypes.selfChallenge;

  @override
  void initState() {
    textSize = widget.quizType == QuizTypes.groupPlay
        ? 20
        : context.read<SettingsCubit>().getSettings().playAreaFontSize;
    super.initState();
  }

  //to get question length
  int getQuestionsLength() {
    if (widget.questions.isNotEmpty) {
      return widget.questions.length;
    }
    return widget.guessTheWordQuestions.length;
  }

  Widget _buildOptions(Question question, BoxConstraints constraints) {
    final correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
      rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
      correctAnswer: question.correctAnswer!,
    );

    if (widget.lifeLines.isNotEmpty) {
      if (widget.lifeLines[fiftyFifty] == LifelineStatus.using) {
        if (!question.attempted) {
          filteredOptions = LifeLineOptions.getFiftyFiftyOptions(
            question.answerOptions!,
            correctAnswerId,
          );
        }
        //build lifeline when using 50/50 lifelines
        return LatexAnswerOptions(
          hasSubmittedAnswerForCurrentQuestion:
              widget.hasSubmittedAnswerForCurrentQuestion,
          submitAnswer: widget.submitAnswer,
          constraints: constraints,
          submittedAnswerId: question.submittedAnswerId,
          correctAnswerId: correctAnswerId,
          showAudiencePoll: false,
          answerMode: widget.answerMode,
          audiencePollPercentages: audiencePollPercentages,
          answerOptions: filteredOptions,
        );
      }

      if (widget.lifeLines[audiencePoll] == LifelineStatus.using) {
        if (!question.attempted) {
          audiencePollPercentages = LifeLineOptions.getAudiencePollPercentage(
            question.answerOptions!,
            correctAnswerId,
          );
        }

        //build options when using audience poll lifeline
        return LatexAnswerOptions(
          hasSubmittedAnswerForCurrentQuestion:
              widget.hasSubmittedAnswerForCurrentQuestion,
          submitAnswer: widget.submitAnswer,
          constraints: constraints,
          submittedAnswerId: question.submittedAnswerId,
          correctAnswerId: correctAnswerId,
          showAudiencePoll: true,
          answerMode: widget.answerMode,
          audiencePollPercentages: audiencePollPercentages,
          answerOptions: question.answerOptions!,
        );
      }
    }

    ///
    if (_isLatex) {
      return LatexAnswerOptions(
        hasSubmittedAnswerForCurrentQuestion:
            widget.hasSubmittedAnswerForCurrentQuestion,
        submitAnswer: widget.submitAnswer,
        constraints: constraints,
        submittedAnswerId: question.submittedAnswerId,
        correctAnswerId: correctAnswerId,
        showAudiencePoll: false,
        answerMode: widget.answerMode,
        audiencePollPercentages: audiencePollPercentages,
        answerOptions: question.answerOptions!,
      );
    } else {
      return Column(
        children: question.answerOptions!.map((option) {
          return OptionContainer(
            quizType: widget.quizType,
            submittedAnswerId: question.submittedAnswerId,
            answerMode: widget.answerMode,
            showAudiencePoll: false,
            hasSubmittedAnswerForCurrentQuestion:
                widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: correctAnswerId,
            submitAnswer: widget.submitAnswer,
            trueFalseOption: question.questionType == '2',
          );
        }).toList(),
      );
    }
  }

  Widget _buildCurrentCoins() {
    // if (widget.lifeLines.isEmpty) {
    //   return const SizedBox();
    // }
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      bloc: context.read<UserDetailsCubit>(),
      builder: (context, state) {
        if (state is UserDetailsFetchSuccess) {
          return Align(
            alignment: AlignmentDirectional.topEnd,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${context.tr("coinsLbl")!} : ",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: '${state.userProfile.coins}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCurrentQuestionIndex() {
    final onTertiary = Theme.of(context).colorScheme.onTertiary;
    return Align(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.currentQuestionIndex + 1}',
              style: TextStyle(
                color: onTertiary.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: ' / ${widget.questions.length}',
              style: TextStyle(color: onTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText({
    required String questionText,
    required String questionType,
  }) {
    bool containsImageUrl = questionText.contains(
        'https://s3.ca-central-1.amazonaws.com/storage.digitaleducation/');
    return _isLatex
        ? containsImageUrl
            ? Column(
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      child: Lottie.asset(
                        'assets/animations/hand_Animation.json',
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: minscale,
                    maxScale: maxscale,
                    clipBehavior: Clip.none,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 5, right: 5, top: 20, bottom: 20),
                      decoration: BoxDecoration(color: Colors.white),
                      child: CachedNetworkImage(
                        imageUrl: _extractImageUrl(questionText),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          child: CupertinoActivityIndicator(
                            radius: 15.0, // You can adjust the radius as needed
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              )
            : TeXView(
                onRenderFinished: (_) {
                  if (widget.quizType != QuizTypes.selfChallenge) {
                    widget.timerAnimationController.forward();
                  }
                },
                child: TeXViewDocument(questionText),
                style: TeXViewStyle(
                  contentColor: Theme.of(context).colorScheme.onTertiary,
                  // backgroundColor: Colors.amber,
                  sizeUnit: TeXViewSizeUnit.pixels,
                  textAlign: TeXViewTextAlign.center,
                  fontStyle: TeXViewFontStyle(fontSize: textSize.toInt() + 5),
                ),
              )
        : Text(
            questionText,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                height: 1.125,
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: textSize,
              ),
            ),
          );
  }

  // Function to extract the image URL from the HTML string
  String _extractImageUrl(String htmlString) {
    _transformationController.value = Matrix4.identity();
    // Example: Extract the src attribute from an img tag in the HTML string
    RegExp regex = RegExp(r'<img.+?src="(.+?)".*?>');
    RegExpMatch? match = regex.firstMatch(htmlString); // Use RegExpMatch?

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!; // Return the captured image URL
    } else {
      // Return a default image URL or handle the case where no image URL is found
      return 'default_image_url'; // Replace with your default image URL or handle accordingly
    }
  }

  Widget _buildQuestionContainer(
    double scale,
    int index,
    bool showContent,
    BuildContext context,
  ) {
    final child = LayoutBuilder(
      builder: (context, constraints) {
        if (widget.questions.isEmpty) {
          return GuessTheWordQuestionContainer(
            showHint: widget.showGuessTheWordHint ?? true,
            timerAnimationController: widget.timerAnimationController,
            key: showContent
                ? widget.guessTheWordQuestionContainerKeys[
                    widget.currentQuestionIndex]
                : null,
            submitAnswer: widget.submitAnswer,
            constraints: constraints,
            currentQuestionIndex: widget.currentQuestionIndex,
            questions: widget.guessTheWordQuestions,
          );
        } else {
          if (widget.quizType == QuizTypes.audioQuestions) {
            return AudioQuestionContainer(
              answerMode: widget.answerMode,
              key: widget
                  .audioQuestionContainerKeys![widget.currentQuestionIndex],
              hasSubmittedAnswerForCurrentQuestion:
                  widget.hasSubmittedAnswerForCurrentQuestion,
              constraints: constraints,
              currentQuestionIndex: widget.currentQuestionIndex,
              questions: widget.questions,
              submitAnswer: widget.submitAnswer,
              timerAnimationController: widget.timerAnimationController,
            );
          }

          final question = widget.questions[index];

          final hasImage =
              question.imageUrl != null && question.imageUrl!.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.quizType == QuizTypes.oneVsOneBattle ||
                    widget.quizType == QuizTypes.groupPlay)
                  const SizedBox()
                else
                  Column(
                    children: [
                      const SizedBox(height: 15),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.lifeLines.isNotEmpty) ...[
                      _buildCurrentCoins(),
                    ],
                    if (widget.quizType == QuizTypes.groupPlay) ...[
                      const SizedBox(),
                    ],
                    _buildCurrentQuestionIndex(),
                    if (widget.quizType == QuizTypes.groupPlay) ...[
                      const SizedBox(),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: _buildQuestionText(
                    questionText: question.question!,
                    questionType: question.questionType!,
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight * (hasImage ? .0175 : .02),
                ),
                if (hasImage)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: constraints.maxHeight *
                        (widget.quizType == QuizTypes.groupPlay ? 0.25 : 0.325),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20),
                      child: CachedNetworkImage(
                        placeholder: (_, __) => const Center(
                          child: CircularProgressContainer(),
                        ),
                        imageUrl: question.imageUrl!,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: widget.quizType == QuizTypes.groupPlay
                                    ? BoxFit.contain
                                    : BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                        errorWidget: (_, i, e) {
                          return Center(
                            child: Icon(
                              Icons.error,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                SizedBox(height: constraints.maxHeight * .015),
                _buildOptions(question, constraints),
                const SizedBox(height: 5),
              ],
            ),
          );
        }
      },
    );

    return Container(
      transform: Matrix4.identity()..scale(scale),
      transformAlignment: Alignment.center,
      // padding: const EdgeInsets.symmetric(horizontal: 15.0),
      width: MediaQuery.of(context).size.width *
          UiUtils.questionContainerWidthPercentage,
      height: MediaQuery.of(context).size.height *
          (UiUtils.questionContainerHeightPercentage -
              0.045 * (widget.quizType == QuizTypes.groupPlay ? 1.0 : 0.0)),
      child: showContent
          ? SlideTransition(
              position: widget.questionContentAnimation.drive(
                Tween<Offset>(
                  begin: const Offset(0.5, 0),
                  end: Offset.zero,
                ),
              ),
              child: FadeTransition(
                opacity: widget.questionContentAnimation,
                child: child,
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildQuestion(int questionIndex, BuildContext context) {
    //
    //if current question index is same as question index means
    //it is current question and will be on top
    //so we need to add animation that slide and fade this question
    if (widget.currentQuestionIndex == questionIndex) {
      return FadeTransition(
        opacity: widget.questionSlideAnimation.drive(
          Tween<double>(begin: 1, end: 0),
        ),
        child: SlideTransition(
          position: widget.questionSlideAnimation.drive(
            Tween<Offset>(begin: Offset.zero, end: const Offset(-1.5, 0)),
          ),
          child: _buildQuestionContainer(1, questionIndex, true, context),
        ),
      );
    }
    //if the question is second or after current question
    //so we need to animation that scale this question
    //initial scale of this question is 0.95

    else if (questionIndex > widget.currentQuestionIndex &&
        (questionIndex == widget.currentQuestionIndex + 1)) {
      return AnimatedBuilder(
        animation: widget.questionAnimationController,
        builder: (context, child) {
          final scale = 0.95 +
              widget.questionScaleUpAnimation.value -
              widget.questionScaleDownAnimation.value;
          return _buildQuestionContainer(scale, questionIndex, false, context);
        },
      );
    }
    //to build question except top 2

    else if (questionIndex > widget.currentQuestionIndex) {
      return _buildQuestionContainer(1, questionIndex, false, context);
    }
    //if the question is already animated that show empty container
    return const SizedBox();
  }

  //to build questions
  List<Widget> _buildQuestions(BuildContext context) {
    final children = <Widget>[];

    //loop terminate condition will be questions.length instead of 4
    for (var i = 0; i < getQuestionsLength(); i++) {
      //add question
      children.add(_buildQuestion(i, context));
    }
    //need to reverse the list in order to display 1st question in top

    return children.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    //Font Size change Lister to change questions font size
    return BlocListener<SettingsCubit, SettingsState>(
      bloc: context.read<SettingsCubit>(),
      listener: (context, state) {
        if (state.settingsModel!.playAreaFontSize != textSize) {
          setState(() {
            textSize =
                context.read<SettingsCubit>().getSettings().playAreaFontSize;
          });
        }
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: _buildQuestions(context),
      ),
    );
  }
}
