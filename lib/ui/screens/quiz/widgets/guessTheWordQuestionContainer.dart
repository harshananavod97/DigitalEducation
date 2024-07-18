import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:just_audio/just_audio.dart';

class GuessTheWordQuestionContainer extends StatefulWidget {
  const GuessTheWordQuestionContainer({
    required this.currentQuestionIndex,
    required this.showHint,
    required this.questions,
    required this.constraints,
    required this.submitAnswer,
    required this.timerAnimationController,
    super.key,
  });

  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<GuessTheWordQuestion> questions;
  final Function submitAnswer;
  final AnimationController timerAnimationController;
  final bool showHint;

  @override
  GuessTheWordQuestionContainerState createState() =>
      GuessTheWordQuestionContainerState();
}

class GuessTheWordQuestionContainerState
    extends State<GuessTheWordQuestionContainer> with TickerProviderStateMixin {
  final optionBoxContainerHeight = 40.0;
  double textSize = 14;

  //contains ontionIndex.. stroing index so we can lower down the opacity of selected index
  late List<int> submittedAnswer = [];
  late List<String> correctAnswerLetterList = [];

  //to controll the answer text
  late List<AnimationController> controllers = [];
  late List<Animation<double>> animations = [];

  //
  //to control the bottomBorder animation
  late List<AnimationController> bottomBorderAnimationControllers = [];
  late List<Animation<double>> bottomBorderAnimations = [];

  //
  //to control the topContainer animation
  late List<AnimationController> topContainerAnimationControllers = [];
  late List<Animation<double>> topContainerAnimations = [];

  late int currentSelectedIndex = 0;

  late final _audioPlayer = AudioPlayer();

  //total how many times user can see hint per question
  late int hintsCounter =
      context.read<SystemConfigCubit>().guessTheWordHintsPerQuiz;

  @override
  void initState() {
    super.initState();
    initializeAnimation();
    initAds();
  }

  @override
  void dispose() {
    for (final element in controllers) {
      element.dispose();
    }
    for (final element in topContainerAnimationControllers) {
      element.dispose();
    }
    for (final element in bottomBorderAnimationControllers) {
      element.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  void initAds() {
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context);
    });
  }

  List<String> getSubmittedAnswer() {
    return submittedAnswer
        .map(
          (e) => e == -1
              ? ''
              : widget.questions[widget.currentQuestionIndex].options[e],
        )
        .toList();
  }

  void initializeAnimation() {
    //initalize the animation
    for (var i = 0;
        i <
            widget
                .questions[widget.currentQuestionIndex].submittedAnswer.length;
        i++) {
      submittedAnswer.add(-1);
      controllers.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        ),
      );
      animations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controllers[i],
            curve: Curves.linear,
            reverseCurve: Curves.linear,
          ),
        ),
      );
      topContainerAnimationControllers.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        ),
      );
      topContainerAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: topContainerAnimationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );
      bottomBorderAnimationControllers.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        ),
      );
      bottomBorderAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: bottomBorderAnimationControllers[i],
            curve: Curves.linear,
          ),
        ),
      );
    }
    bottomBorderAnimationControllers.first.forward();
  }

  void changeCurrentSelectedAnswerBox(int answerBoxIndex) {
    setState(() {
      currentSelectedIndex = answerBoxIndex;
    });
    bottomBorderAnimationControllers[answerBoxIndex].forward();
    for (final controller in bottomBorderAnimationControllers) {
      if (controller.isCompleted) {
        controller.reverse();
        break;
      }
    }
  }

  Future<void> playSound(String trackName) async {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setAsset(trackName);
      await _audioPlayer.play();
    }
  }

  Future<void> playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  void _addCoinsAfterRewardAd() {
    final rewardAdsCoins = context.read<SystemConfigCubit>().rewardAdsCoins;

    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: rewardAdsCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          coins: rewardAdsCoins,
          addCoin: true,
          title: watchedRewardAdKey,
        );
    widget.timerAnimationController
        .forward(from: widget.timerAnimationController.value);
  }

  void showAdDialog() {
    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      UiUtils.showSnackBar(
        context.tr(
          convertErrorCodeToLanguageKey(errorCodeNotEnoughCoins),
        )!,
        context,
      );
      return;
    }
    //stop timer
    widget.timerAnimationController.stop();
    showDialog<bool>(
      context: context,
      builder: (_) => WatchRewardAdDialog(
        onTapYesButton: () {
          //on tap of yes button show ad
          context.read<RewardedAdCubit>().showAd(
                context: context,
                onAdDismissedCallback: _addCoinsAfterRewardAd,
              );
        },
        onTapNoButton: () {
          //pass true to start timer
          Navigator.of(context).pop(true);
        },
      ),
    ).then((startTimer) {
      //if user do not want to see ad
      if (startTimer != null && startTimer) {
        widget.timerAnimationController
            .forward(from: widget.timerAnimationController.value);
      }
    });
  }

  bool hasEnoughCoinsForLifeline(BuildContext context) {
    final currentCoins =
        int.parse(context.read<UserDetailsCubit>().getCoins()!);
    //cost of using lifeline is 5 coins
    if (currentCoins < context.read<SystemConfigCubit>().lifelinesDeductCoins) {
      return false;
    }
    return true;
  }

  Widget _buildAnswerBox(int answerBoxIndex) {
    return GestureDetector(
      onTap: () {
        changeCurrentSelectedAnswerBox(answerBoxIndex);
      },
      child: AnimatedBuilder(
        animation: bottomBorderAnimationControllers[answerBoxIndex],
        builder: (context, child) {
          final border = bottomBorderAnimations[answerBoxIndex]
              .drive(Tween<double>(begin: 1, end: 2.5))
              .value;

          return Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              /// box bottom border
              border: Border(
                bottom: BorderSide(
                  width: border,
                  color: currentSelectedIndex == answerBoxIndex
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.1),
                ),
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            height: optionBoxContainerHeight,
            width: 35,
            child: AnimatedBuilder(
              animation: controllers[answerBoxIndex],
              builder: (context, child) {
                return controllers[answerBoxIndex].status ==
                        AnimationStatus.reverse
                    ? Opacity(
                        opacity: animations[answerBoxIndex].value,
                        child: FractionalTranslation(
                          translation: Offset(
                            0,
                            1.0 - animations[answerBoxIndex].value,
                          ),
                          child: child,
                        ),
                      )
                    : FractionalTranslation(
                        translation:
                            Offset(0, 1.0 - animations[answerBoxIndex].value),
                        child: child,
                      );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: topContainerAnimationControllers[answerBoxIndex],
                    builder: (context, child) {
                      return Container(
                        height: 2,
                        width: 35.0 *
                            (1.0 -
                                topContainerAnimations[answerBoxIndex].value),
                        color: currentSelectedIndex == answerBoxIndex
                            ? Theme.of(context).colorScheme.onTertiary
                            : Theme.of(context)
                                .colorScheme
                                .onTertiary
                                .withOpacity(0.1),
                      );
                    },
                  ),
                  Text(
                    //submitted answer contains the index of option
                    //length of answerbox is same as submittedAnswer
                    submittedAnswer[answerBoxIndex] == -1
                        ? ''
                        : widget.questions[widget.currentQuestionIndex]
                                    .options[submittedAnswer[answerBoxIndex]] ==
                                ' '
                            ? '-'
                            : widget.questions[widget.currentQuestionIndex]
                                .options[submittedAnswer[answerBoxIndex]], //
                    //
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: currentSelectedIndex == answerBoxIndex
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerBoxes() {
    final children = <Widget>[];
    final submittedAnswers =
        widget.questions[widget.currentQuestionIndex].submittedAnswer;
    for (var i = 0; i < submittedAnswers.length; i++) {
      children.add(_buildAnswerBox(i));
    }
    return Wrap(children: children);
  }

  Widget _optionContainer(String letter, int optionIndex) {
    /// remove back button from options, ! is back btn.
    if (letter == '!') return const SizedBox();

    return GestureDetector(
      onTap: submittedAnswer.contains(optionIndex)
          ? () {}
          : () async {
              await playVibrate();
              if (submittedAnswer[currentSelectedIndex] != -1) {
                await topContainerAnimationControllers[currentSelectedIndex]
                    .reverse();
                await controllers[currentSelectedIndex].reverse();
              }
              await Future<void>.delayed(const Duration(milliseconds: 25));

              //adding new letter
              setState(() {
                submittedAnswer[currentSelectedIndex] = optionIndex;
              });

              await controllers[currentSelectedIndex].forward();
              await topContainerAnimationControllers[currentSelectedIndex]
                  .forward();
              //update currentAnswerBox

              if (currentSelectedIndex !=
                  widget.questions[widget.currentQuestionIndex].submittedAnswer
                          .length -
                      1) {
                changeCurrentSelectedAnswerBox(currentSelectedIndex + 1);
              }
            },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: submittedAnswer.contains(optionIndex)
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.surface,
        ),
        height: optionBoxContainerHeight,
        width: optionBoxContainerHeight,
        padding: EdgeInsets.symmetric(
          horizontal: letter == ' ' ? optionBoxContainerHeight * (0.225) : 0.0,
        ),
        child: letter == ' '
            ? SvgPicture.asset(
                Assets.space,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onTertiary,
                  BlendMode.srcIn,
                ),
              )
            : Text(
                letter == ' ' ? 'Space' : letter,
                style: TextStyle(
                  color: submittedAnswer.contains(optionIndex)
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _buildOptions(List<String> answerOptions) {
    final listOfWidgets = <Widget>[];

    for (var i = 0; i < answerOptions.length; i++) {
      listOfWidgets.add(_optionContainer(answerOptions[i], i));
    }
    // if (widget.showHint) {
    //   listOfWidgets.add(_buildHintButton());
    // }

    return Wrap(children: listOfWidgets);
  }

  int _getRandomIndexForHint() {
    //need to find all empty cells where user have not given answer yet
    final emptyAnswerBoxIndexes = <int>[];
    for (var i = 0; i < submittedAnswer.length; i++) {
      if (submittedAnswer[i] == -1) {
        emptyAnswerBoxIndexes.add(i);
      }
    }
    if (emptyAnswerBoxIndexes.isEmpty) {
      return -1;
    }
    //show hint on any empty answer box
    return emptyAnswerBoxIndexes[
        Random.secure().nextInt(emptyAnswerBoxIndexes.length)];
  }

  Widget _buildHintButton() {
    return GestureDetector(
      onTap: hintsCounter == 0 || !submittedAnswer.contains(-1)
          ? () {}
          : () async {
              if (hasEnoughCoinsForLifeline(context)) {
                //show hints
                final currQuestion =
                    widget.questions[widget.currentQuestionIndex];
                final correctAnswer = currQuestion.answer;

                //build correct answer letter list
                if (correctAnswerLetterList.isEmpty) {
                  for (var i = 0; i < correctAnswer.length; i++) {
                    correctAnswerLetterList
                        .add(correctAnswer.substring(i, i + 1));
                  }
                }

                //get random index
                final hintIndex = _getRandomIndexForHint();

                final lifeLineDeductCoins =
                    context.read<SystemConfigCubit>().lifelinesDeductCoins;

                //deduct coins for using hints
                context.read<UserDetailsCubit>().updateCoins(
                      addCoin: false,
                      coins: lifeLineDeductCoins,
                    );
                await context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                      coins: lifeLineDeductCoins,
                      addCoin: false,
                      title: usedHintLifelineKey,
                    );

                //change current selected answer box
                changeCurrentSelectedAnswerBox(hintIndex);

                //need to find index
                var indexToAdd = -1;
                for (var i = 0; i < currQuestion.options.length; i++) {
                  //need to check this condition to get index for every letter
                  //ex. Cricket if first c is in submit answer list then index of second c will be consider
                  if (currQuestion.options[i] == correctAnswer[hintIndex] &&
                      !submittedAnswer.contains(i)) {
                    indexToAdd = i;
                  }
                }

                //update submitted answer
                setState(() {
                  submittedAnswer[currentSelectedIndex] = indexToAdd;
                  hintsCounter--;
                });
                //start animation

                await controllers[currentSelectedIndex].forward();
                await topContainerAnimationControllers[currentSelectedIndex]
                    .forward();
              } else {
                showAdDialog();
              }
            },
      child: Opacity(
        opacity: hintsCounter == 0 || !submittedAnswer.contains(-1) ? 0.5 : 1.0,
        child: Container(
          height: optionBoxContainerHeight,
          width: optionBoxContainerHeight * 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Text(
            context.tr(hintKey)!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () async {
        await topContainerAnimationControllers[currentSelectedIndex].reverse();
        await controllers[currentSelectedIndex].reverse();
        setState(() {
          submittedAnswer[currentSelectedIndex] = -1;
        });
      },
      child: Container(
        height: optionBoxContainerHeight,
        width: optionBoxContainerHeight * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Text(
          context.tr(backKey)!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerCorrectness() {
    final correctAnswer =
        UiUtils.buildGuessTheWordQuestionAnswer(getSubmittedAnswer()) ==
            widget.questions[widget.currentQuestionIndex].answer;
    if (correctAnswer) {
      playSound(correctAnswerSoundTrack);
    } else {
      playSound(wrongAnswerSoundTrack);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Icon(
            correctAnswer ? Icons.check_rounded : Icons.close_rounded,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          UiUtils.buildGuessTheWordQuestionAnswer(getSubmittedAnswer()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentCoins() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      bloc: context.read<UserDetailsCubit>(),
      builder: (context, state) {
        if (state is UserDetailsFetchSuccess) {
          return Text.rich(
            TextSpan(
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.5),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: "${context.tr("coinsLbl")!} : ",
                ),
                TextSpan(
                  text: '${state.userProfile.coins}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Coins & Que Index
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showHint) _buildCurrentCoins(),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(text: '${widget.currentQuestionIndex + 1}'),
                      TextSpan(
                        text: ' / ${widget.questions.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Question
            Text(
              question.question,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
            SizedBox(height: widget.constraints.maxHeight * (0.025)),

            /// Image
            if (question.image.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                width: MediaQuery.of(context).size.width,
                height: widget.constraints.maxHeight * (0.275),
                alignment: Alignment.center,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20),
                  child: CachedNetworkImage(
                    placeholder: (context, _) {
                      return const Center(
                        child: CircularProgressContainer(),
                      );
                    },
                    imageUrl: question.image,
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                    errorWidget: (_, i, e) => Center(
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: widget.constraints.maxHeight * (0.025)),
            ],

            ///
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.questions[widget.currentQuestionIndex].hasAnswered
                  ? _buildAnswerCorrectness()
                  : _buildAnswerBoxes(),
            ),
            SizedBox(height: widget.constraints.maxHeight * (0.04)),
            _buildOptions(question.options),
            SizedBox(height: widget.constraints.maxHeight * (0.11)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showHint) ...[_buildHintButton()],
                const SizedBox(width: 3),
                _buildBackButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
