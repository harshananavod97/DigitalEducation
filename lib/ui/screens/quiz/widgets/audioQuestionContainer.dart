import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/model/answer_mode.dart';
import 'package:flutterquiz/ui/widgets/optionContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:just_audio/just_audio.dart';

class AudioQuestionContainer extends StatefulWidget {
  const AudioQuestionContainer({
    required this.constraints,
    required this.answerMode,
    required this.currentQuestionIndex,
    required this.questions,
    required this.submitAnswer,
    required this.timerAnimationController,
    required this.hasSubmittedAnswerForCurrentQuestion,
    super.key,
  });

  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<Question> questions;
  final void Function(String) submitAnswer;
  final bool Function() hasSubmittedAnswerForCurrentQuestion;
  final AnswerMode answerMode;

  final AnimationController timerAnimationController;

  @override
  AudioQuestionContainerState createState() => AudioQuestionContainerState();
}

class AudioQuestionContainerState extends State<AudioQuestionContainer> {
  double questionTextSize = 20;
  late bool _showOption = false;
  late AudioPlayer _audioPlayer;
  late StreamSubscription<ProcessingState> _processingStateStreamSubscription;
  late bool _isPlaying = false;
  late Duration _audioDuration = Duration.zero;
  late bool _hasCompleted = false;
  late bool _hasError = false;
  late bool _isBuffering = false;
  late bool _isLoading = true;

  //
  @override
  void initState() {
    initializeAudio();
    super.initState();
  }

  Future<void> initializeAudio() async {
    _audioPlayer = AudioPlayer();

    try {
      final result = await _audioPlayer
          .setUrl(widget.questions[widget.currentQuestionIndex].audio!);
      _audioDuration = result ?? Duration.zero;
      _processingStateStreamSubscription =
          _audioPlayer.processingStateStream.listen(_processingStateListener);
    } catch (e) {
      _hasError = true;
    }
    setState(() {});
  }

  void _processingStateListener(ProcessingState event) {
    if (event == ProcessingState.ready) {
      if (_isLoading) {
        _isLoading = false;
      }

      _audioPlayer.play();
      _isPlaying = true;
      _isBuffering = false;
      _hasCompleted = false;
    } else if (event == ProcessingState.buffering) {
      _isBuffering = true;
    } else if (event == ProcessingState.completed) {
      if (!_showOption) {
        _showOption = true;
        widget.timerAnimationController.forward(from: 0);
      }
      _hasCompleted = true;
    }

    setState(() {});
  }

  Widget _buildPlayAudioContainer() {
    if (_hasError) {
      return IconButton(
        onPressed: () {
          //retry
        },
        icon: Icon(
          Icons.error,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
    if (_isLoading || _isBuffering) {
      return IconButton(
        onPressed: null,
        icon: SizedBox(
          height: 20,
          width: 20,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    if (_hasCompleted) {
      return IconButton(
        onPressed: () {
          _audioPlayer.seek(Duration.zero);
        },
        icon: Icon(
          Icons.restart_alt,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
    if (_isPlaying) {
      return IconButton(
        onPressed: () {
          _audioPlayer.pause();
          _isPlaying = false;
          setState(() {});
        },
        icon: Icon(
          Icons.pause,
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          _audioPlayer.play();
          _isPlaying = true;
        });
      },
      icon: Icon(
        Icons.play_arrow,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _processingStateStreamSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get showOption => _showOption;

  void changeShowOption() {
    setState(() => _showOption = true);
  }

  Widget _buildCurrentQuestionIndex() {
    return Align(
      alignment: AlignmentDirectional.center,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.currentQuestionIndex + 1} / ',
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: '${widget.questions.length}',
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 17.5),
          _buildCurrentQuestionIndex(),
          const SizedBox(height: 5),
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Text(
              '${question.question}',
              style: TextStyle(
                height: 1.125,
                fontSize: questionTextSize,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
          SizedBox(height: widget.constraints.maxHeight * (0.04)),
          Container(
            width: widget.constraints.maxWidth * 1.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.constraints.maxWidth * (0.05),
              vertical: 10,
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child:
                          BufferedDurationContainer(audioPlayer: _audioPlayer),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CurrentDurationSliderContainer(
                          audioPlayer: _audioPlayer,
                          duration: _audioDuration,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.constraints.minHeight * .025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CurrentDurationContainer(audioPlayer: _audioPlayer),
                    const Spacer(),
                    _buildPlayAudioContainer(),
                    const Spacer(),
                    Container(
                      alignment: Alignment.centerRight,
                      //decoration: BoxDecoration(border: Border.all()),
                      width: MediaQuery.of(context).size.width * (0.1),
                      child: Text(
                        '${_audioDuration.inSeconds}s',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: widget.constraints.maxHeight * 0.04),
          if (_showOption)
            Column(
              children: question.answerOptions!.map((option) {
                return OptionContainer(
                  quizType: QuizTypes.audioQuestions,
                  submittedAnswerId: question.submittedAnswerId,
                  answerMode: widget.answerMode,
                  showAudiencePoll: false,
                  hasSubmittedAnswerForCurrentQuestion:
                      widget.hasSubmittedAnswerForCurrentQuestion,
                  constraints: widget.constraints,
                  answerOption: option,
                  correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                    rawKey:
                        context.read<UserDetailsCubit>().getUserFirebaseId(),
                    correctAnswer: question.correctAnswer!,
                  ),
                  submitAnswer: widget.submitAnswer,
                );
              }).toList(),
            )
          else
            Column(
              children: question.answerOptions!
                  .map(
                    (e) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      margin: EdgeInsets.only(
                        top: widget.constraints.maxHeight * (0.015),
                      ),
                      height: widget.constraints.maxHeight * (0.105),
                      width: widget.constraints.maxWidth,
                      child: Center(
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class CurrentDurationSliderContainer extends StatefulWidget {
  const CurrentDurationSliderContainer({
    required this.audioPlayer,
    required this.duration,
    super.key,
  });

  final AudioPlayer audioPlayer;
  final Duration duration;

  @override
  State<CurrentDurationSliderContainer> createState() =>
      _CurrentDurationSliderContainerState();
}

class _CurrentDurationSliderContainerState
    extends State<CurrentDurationSliderContainer> {
  double currentValue = 0;

  late StreamSubscription<Duration> streamSubscription;

  @override
  void initState() {
    streamSubscription =
        widget.audioPlayer.positionStream.listen(currentDurationListener);
    super.initState();
  }

  void currentDurationListener(Duration duration) {
    currentValue = duration.inSeconds.toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            trackHeight: 5,
            trackShape: CustomTrackShape(),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
          ),
      child: SizedBox(
        height: 5,
        width: MediaQuery.of(context).size.width,
        child: Slider(
          max: widget.duration.inSeconds.toDouble(),
          activeColor: Theme.of(context).primaryColor.withOpacity(0.6),
          inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
          value: currentValue,
          thumbColor: Theme.of(context).primaryColor,
          onChanged: (value) {
            setState(() {
              currentValue = value;
            });
            widget.audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
      ),
    );
  }
}

class BufferedDurationContainer extends StatefulWidget {
  const BufferedDurationContainer({required this.audioPlayer, super.key});

  final AudioPlayer audioPlayer;

  @override
  State<BufferedDurationContainer> createState() =>
      _BufferedDurationContainerState();
}

class _BufferedDurationContainerState extends State<BufferedDurationContainer> {
  late double bufferedPercentage = 0;

  late StreamSubscription<Duration> streamSubscription;

  @override
  void initState() {
    streamSubscription = widget.audioPlayer.bufferedPositionStream
        .listen(bufferedDurationListener);
    super.initState();
  }

  void bufferedDurationListener(Duration duration) {
    final audioDuration = widget.audioPlayer.duration ?? Duration.zero;
    bufferedPercentage = audioDuration.inSeconds == 0
        ? 0.0
        : (duration.inSeconds / audioDuration.inSeconds);
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        color: Theme.of(context).primaryColor.withOpacity(0.6),
      ),
      width: MediaQuery.of(context).size.width * bufferedPercentage,
      height: 5,
    );
  }
}

class CurrentDurationContainer extends StatefulWidget {
  const CurrentDurationContainer({required this.audioPlayer, super.key});

  final AudioPlayer audioPlayer;

  @override
  State<CurrentDurationContainer> createState() =>
      _CurrentDurationContainerState();
}

class _CurrentDurationContainerState extends State<CurrentDurationContainer> {
  late StreamSubscription<Duration> currentAudioDurationStreamSubscription;
  late Duration currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    currentAudioDurationStreamSubscription =
        widget.audioPlayer.positionStream.listen(currentDurationListener);
  }

  void currentDurationListener(Duration duration) {
    setState(() {
      currentDuration = duration;
    });
  }

  @override
  void dispose() {
    currentAudioDurationStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      //decoration: BoxDecoration(border: Border.all()),
      width: MediaQuery.of(context).size.width * (0.1),
      child: Text(
        '${currentDuration.inSeconds}',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 0,
  }) {
    return Offset(offset.dx, offset.dy) &
        Size(parentBox.size.width, sliderTheme.trackHeight!);
  } //
}
