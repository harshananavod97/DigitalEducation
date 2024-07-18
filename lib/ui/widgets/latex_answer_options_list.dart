import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/constants/sound_constants.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:just_audio/just_audio.dart';

const _borderRadius = TeXViewBorderRadius.all(10);
const _textAlign = TeXViewTextAlign.center;
const _padding = TeXViewPadding.only(
  top: 16,
  bottom: 16,
  left: 4,
  right: 4,
);

class LatexAnswerOptions extends StatefulWidget {
  const LatexAnswerOptions({
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.submitAnswer,
    required this.answerMode,
    required this.constraints,
    required this.correctAnswerId,
    required this.showAudiencePoll,
    required this.audiencePollPercentages,
    required this.answerOptions,
    required this.submittedAnswerId,
    super.key,
  });

  final List<AnswerOption> answerOptions;
  final String submittedAnswerId;
  final String correctAnswerId;
  final BoxConstraints constraints;

  final bool Function() hasSubmittedAnswerForCurrentQuestion;
  final void Function(String) submitAnswer;

  final AnswerMode answerMode;
  final bool showAudiencePoll;
  final List<int> audiencePollPercentages;

  @override
  State<LatexAnswerOptions> createState() => _LatexAnswerOptionsState();
}

class _LatexAnswerOptionsState extends State<LatexAnswerOptions> {
  late final _audioPlayer = AudioPlayer();

  late final _margin =
      TeXViewMargin.only(bottom: (widget.constraints.maxHeight * .015).toInt());

  TeXViewStyle _teXViewStyle(String id, {required bool isLast}) => TeXViewStyle(
        borderRadius: _borderRadius,
        fontStyle: TeXViewFontStyle(fontSize: 21),
        padding: widget.showAudiencePoll ? null : _padding,
        contentColor: _optionTextColor(id),
        backgroundColor: _optionBackgroundColor(id),
        margin: isLast ? null : _margin,
      );

  Color _optionTextColor(String id) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.answerMode == AnswerMode.noAnswerCorrectness) {
      return isSubmittedAnswer(id)
          ? colorScheme.surface
          : colorScheme.onTertiary;
    }

    if (widget.hasSubmittedAnswerForCurrentQuestion()) {
      if (widget.answerMode ==
              AnswerMode.showAnswerCorrectnessAndCorrectAnswer &&
          isCorrectAnswer(id)) {
        return colorScheme.surface;
      }
      if (isSubmittedAnswer(id)) {
        return colorScheme.surface;
      }
    }

    return colorScheme.onTertiary;
  }

  Color _optionBackgroundColor(String id) {
    final background = Theme.of(context).colorScheme.surface;

    if (widget.answerMode == AnswerMode.noAnswerCorrectness) {
      return isSubmittedAnswer(id)
          ? Theme.of(context).primaryColor
          : background;
    }

    if (widget.hasSubmittedAnswerForCurrentQuestion()) {
      if (widget.answerMode ==
          AnswerMode.showAnswerCorrectnessAndCorrectAnswer) {
        return isCorrectAnswer(id)
            ? kCorrectAnswerColor
            : isSubmittedAnswer(id)
                ? kWrongAnswerColor
                : background;
      } else {
        return isSubmittedAnswer(id)
            ? isCorrectAnswer(id)
                ? kCorrectAnswerColor
                : kWrongAnswerColor
            : background;
      }
    }

    return background;
  }

  bool isCorrectAnswer(String id) => id == widget.correctAnswerId;

  bool isSubmittedAnswer(String id) => id == widget.submittedAnswerId;

  void _onTapOption(String id) {
    if (widget.answerMode == AnswerMode.noAnswerCorrectness) {
      widget.submitAnswer(id);

      playSound(clickEventSoundTrack);
      playVibrate();
    } else {
      if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
        widget.submitAnswer(id);

        if (widget.correctAnswerId == id) {
          playSound(correctAnswerSoundTrack);
        } else {
          playSound(wrongAnswerSoundTrack);
        }
        playVibrate();
      }
    }
  }

  // TODO(J): Investigate the issue where the sound stops playing after some time.
  // If related to the just_audio package, perform a thorough check.
  // Ensure that the sound continues playing for subsequent levels.
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

  @override
  Widget build(BuildContext context) {
    final options = widget.answerOptions;
    return TeXView(
      renderingEngine: const TeXViewRenderingEngine.katex(),
      child: TeXViewGroup(
        children: List.generate(
          options.length,
          (i) => TeXViewGroupItem(
            rippleEffect: false,
            id: options[i].id!,
            child: !widget.showAudiencePoll
                ? TeXViewDocument(
                    options[i].title!,
                    style: _teXViewStyle(
                      options[i].id!,
                      isLast: i == options.length - 1,
                    ),
                  )
                : TeXViewColumn(
                    children: [
                      if (widget.showAudiencePoll) ...[
                        TeXViewDocument(
                          '${widget.audiencePollPercentages[i]}%',
                          style: TeXViewStyle(
                            fontStyle: TeXViewFontStyle(
                              fontWeight: TeXViewFontWeight.w500,
                            ),
                            textAlign: TeXViewTextAlign.left,
                          ),
                        ),
                      ],
                      TeXViewDocument(
                        options[i].title!,
                        style: _teXViewStyle(
                          options[i].id!,
                          isLast: i == options.length - 1,
                        ),
                      ),
                    ],
                    style: TeXViewStyle(
                      borderRadius: _borderRadius,
                      fontStyle: TeXViewFontStyle(fontSize: 21),
                      padding: const TeXViewPadding.only(
                        top: 16,
                        bottom: 16,
                        left: 8,
                        right: 8,
                      ),
                      contentColor: _optionTextColor(options[i].id!),
                      backgroundColor: _optionBackgroundColor(options[i].id!),
                      margin: i == options.length - 1 ? null : _margin,
                    ),
                  ),
          ),
          growable: false,
        ),
        onTap: _onTapOption,
      ),
      style: const TeXViewStyle(
        textAlign: _textAlign,
        sizeUnit: TeXViewSizeUnit.pixels,
      ),
    );
  }
}
