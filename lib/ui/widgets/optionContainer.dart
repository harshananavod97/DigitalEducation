import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/sound_constants.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class OptionContainer extends StatefulWidget {
  const OptionContainer({
    required this.quizType,
    required this.answerMode,
    required this.showAudiencePoll,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.constraints,
    required this.answerOption,
    required this.correctOptionId,
    required this.submitAnswer,
    required this.submittedAnswerId,
    this.canResubmitAnswer = false,
    this.audiencePollPercentage,
    this.trueFalseOption = false,
    super.key,
  });

  final bool Function() hasSubmittedAnswerForCurrentQuestion;
  final void Function(String) submitAnswer;
  final AnswerOption answerOption;
  final BoxConstraints constraints;
  final String correctOptionId;
  final String submittedAnswerId;
  final bool showAudiencePoll;
  final int? audiencePollPercentage;
  final AnswerMode answerMode;
  final bool canResubmitAnswer;
  final QuizTypes quizType;
  final bool trueFalseOption;

  @override
  State<OptionContainer> createState() => _OptionContainerState();
}

class _OptionContainerState extends State<OptionContainer>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );
  late Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: animationController, curve: Curves.easeInQuad),
  );

  late AnimationController topContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late Animation<double> topContainerOpacityAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: topContainerAnimationController,
      curve: const Interval(0, 0.25, curve: Curves.easeInQuad),
    ),
  );

  late Animation<double> topContainerAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: topContainerAnimationController,
      curve: const Interval(0, 0.5, curve: Curves.easeInQuad),
    ),
  );

  late Animation<double> answerCorrectnessAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: topContainerAnimationController,
      curve: const Interval(0.5, 1, curve: Curves.easeInQuad),
    ),
  );

  late double heightPercentage = 0.105;
  late final _audioPlayer = AudioPlayer();

  late TextSpan textSpan = TextSpan(
    text: widget.answerOption.title,
    style: GoogleFonts.nunito(
      textStyle: TextStyle(
        color: optionTextColor,
        height: 1,
        fontSize: 16,
      ),
    ),
  );

  @override
  void dispose() {
    animationController.dispose();
    topContainerAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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

  int calculateMaxLines() {
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: widget.constraints.maxWidth * 0.85);

    return textPainter.computeLineMetrics().length;
  }

  bool get isCorrectAnswer => widget.answerOption.id == widget.correctOptionId;

  bool get isSubmittedAnswer =>
      widget.answerOption.id == widget.submittedAnswerId;

  Color get optionTextColor {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.answerMode == AnswerMode.noAnswerCorrectness) {
      return isSubmittedAnswer ? colorScheme.surface : colorScheme.onTertiary;
    }

    if (widget.hasSubmittedAnswerForCurrentQuestion()) {
      if (widget.answerMode ==
              AnswerMode.showAnswerCorrectnessAndCorrectAnswer &&
          (isCorrectAnswer || isSubmittedAnswer)) {
        return colorScheme.surface;

        /// for showAnswerCorrectness
      } else if (isSubmittedAnswer) {
        return colorScheme.surface;
      }
    }

    return colorScheme.onTertiary;
  }

  Color _buildOptionBackgroundColor() {
    if (widget.answerMode == AnswerMode.noAnswerCorrectness) {
      return isSubmittedAnswer
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.surface;
    }

    if (widget.hasSubmittedAnswerForCurrentQuestion()) {
      if (widget.answerMode ==
          AnswerMode.showAnswerCorrectnessAndCorrectAnswer) {
        return isCorrectAnswer
            ? kCorrectAnswerColor
            : isSubmittedAnswer
                ? kWrongAnswerColor
                : Theme.of(context).colorScheme.surface;
      } else {
        return isSubmittedAnswer
            ? isCorrectAnswer
                ? kCorrectAnswerColor
                : kWrongAnswerColor
            : Theme.of(context).colorScheme.surface;
      }
    }

    return Theme.of(context).colorScheme.surface;
  }

  void _onTapOptionContainer() {
    if (widget.answerMode == AnswerMode.noAnswerCorrectness) {
      widget.submitAnswer(widget.answerOption.id!);

      playSound(clickEventSoundTrack);
      playVibrate();
    } else {
      if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
        widget.submitAnswer(widget.answerOption.id!);

        topContainerAnimationController.forward();

        if (widget.correctOptionId == widget.answerOption.id) {
          playSound(correctAnswerSoundTrack);
        } else {
          playSound(wrongAnswerSoundTrack);
        }
        playVibrate();
      }
    }
  }

  Widget _buildOptionDetails(double optionWidth) {
    final maxLines = calculateMaxLines();
    if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
      heightPercentage = maxLines > 2
          ? (heightPercentage + (0.03 * (maxLines - 2)))
          : heightPercentage;
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (_, child) {
        return Transform.scale(
          scale: animation.drive(Tween<double>(begin: 1, end: 0.9)).value,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: widget.constraints.maxHeight * (0.015)),
        height: widget.quizType == QuizTypes.groupPlay
            ? widget.constraints.maxHeight * (heightPercentage * 0.75)
            : widget.constraints.maxHeight * heightPercentage,
        width: optionWidth,
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: maxLines > 2 ? 7.50 : 0,
                ),
                color: _buildOptionBackgroundColor(),
                alignment: AlignmentDirectional.centerStart,
                child:
                    //if question type is 1 means render latex question
                    widget.quizType == QuizTypes.mathMania ||
                            widget.quizType == QuizTypes.quizZone ||
                            widget.quizType == QuizTypes.exam ||
                            widget.quizType == QuizTypes.oneVsOneBattle ||
                            widget.quizType == QuizTypes.groupPlay ||
                            widget.quizType == QuizTypes.dailyQuiz ||
                            widget.quizType == QuizTypes.trueAndFalse ||
                            widget.quizType == QuizTypes.selfChallenge
                        ? TeXView(
                            child: TeXViewInkWell(
                              rippleEffect: false,
                              onTap: (_) => _onTapOptionContainer(),
                              child:
                                  TeXViewDocument(widget.answerOption.title!),
                              id: widget.answerOption.id!,
                            ),
                            style: TeXViewStyle(
                              contentColor: optionTextColor,
                              backgroundColor: Colors.transparent,
                              sizeUnit: TeXViewSizeUnit.pixels,
                              textAlign: TeXViewTextAlign.center,
                              fontStyle: TeXViewFontStyle(fontSize: 21),
                            ),
                          )
                        : Center(
                            child: RichText(
                              text: textSpan,
                              textAlign: TextAlign.center,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textSpan = TextSpan(
      text: widget.answerOption.title,
      style: GoogleFonts.nunito(
        textStyle: TextStyle(
          color: optionTextColor,
          height: 1,
          fontSize: 16,
        ),
      ),
    );
    return GestureDetector(
      onTapCancel: animationController.reverse,
      onTap: () async {
        await animationController.reverse();
        _onTapOptionContainer();
      },
      onTapDown: (_) => animationController.forward(),
      child: widget.showAudiencePoll
          ? Row(
              children: [
                _buildOptionDetails(widget.constraints.maxWidth * .8),
                const SizedBox(width: 10),
                Text(
                  '${widget.audiencePollPercentage}%',
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ],
            )
          : _buildOptionDetails(widget.constraints.maxWidth),
    );
  }
}
