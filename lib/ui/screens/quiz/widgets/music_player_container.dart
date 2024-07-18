import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/musicPlayer/musicPlayerCubit.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerContainer extends StatefulWidget {
  const MusicPlayerContainer({
    required this.currentIndex,
    required this.index,
    required this.url,
    super.key,
  });

  final String url;
  final int index;
  final int currentIndex;

  @override
  State<MusicPlayerContainer> createState() => MusicPlayerContainerState();
}

class MusicPlayerContainerState extends State<MusicPlayerContainer> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      context.read<MusicPlayerCubit>().initPlayer(widget.url);
    });
  }

  void playAudio() {
    context.read<MusicPlayerCubit>().audioPlayer.play();
  }

  void stopAudio() {
    context.read<MusicPlayerCubit>().audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CurrentDurationContainer(),
              const Spacer(),
              PlayerControlContainer(
                currentIndex: widget.currentIndex,
                index: widget.index,
              ),
              const Spacer(),
              BlocBuilder<MusicPlayerCubit, MusicPlayerState>(
                bloc: context.read<MusicPlayerCubit>(),
                builder: (context, state) {
                  if (state is MusicPlayerLoaded) {
                    var time = '';

                    final audioDuration = state.audioDuration;
                    if (audioDuration.inHours != 0) {
                      time = '${audioDuration.inHours}:';
                    }
                    if (audioDuration.inMinutes != 0) {
                      time =
                          '$time${audioDuration.inMinutes - (24 * audioDuration.inHours)}:';
                    }
                    if (audioDuration.inSeconds != 0) {
                      time =
                          '$time${audioDuration.inSeconds - (60 * audioDuration.inMinutes)}';
                    }
                    return Text(
                      time,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }
                  return Text(
                    '0:0',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BufferedDurationContainer(),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CurrentDurationSliderContainer(),
              ),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

class PlayerControlContainer extends StatefulWidget {
  const PlayerControlContainer({
    required this.currentIndex,
    required this.index,
    super.key,
  });

  final int index;
  final int currentIndex;

  @override
  State<PlayerControlContainer> createState() => _PlayerControlContainerState();
}

class _PlayerControlContainerState extends State<PlayerControlContainer> {
  StreamSubscription<ProcessingState>? _processingStateStreamSubscription;

  late bool _isPlaying = false;
  late bool _isBuffering = false;
  late bool _hasCompleted = false;
  late bool _isLoading = false;

  @override
  void dispose() {
    _processingStateStreamSubscription?.cancel();
    super.dispose();
  }

  void processingStateListener(ProcessingState event) {
    if (event == ProcessingState.ready) {
      //set loading to false once audio loaded
      if (_isLoading) {
        _isLoading = false;
      }

      if (widget.index == widget.currentIndex) {
        _isPlaying = true;
        context.read<MusicPlayerCubit>().audioPlayer.play();
      }

      //
      _isBuffering = false;
      _hasCompleted = false;
    } else if (event == ProcessingState.buffering) {
      _isBuffering = true;
    } else if (event == ProcessingState.completed) {
      _hasCompleted = true;
    }

    setState(() {});
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return IconButton(
      color: Theme.of(context).primaryColor,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicPlayerCubit = context.read<MusicPlayerCubit>();
    return BlocConsumer<MusicPlayerCubit, MusicPlayerState>(
      bloc: musicPlayerCubit,
      builder: (context, state) {
        if (state is MusicPlayerInitial || state is MusicPlayerLoading) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }
        if (state is MusicPlayerFailure) {
          return _buildButton(onPressed: () {}, icon: Icons.error);
        }

        if (_isLoading || _isBuffering) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }
        if (_hasCompleted) {
          return _buildButton(
            onPressed: () {
              context.read<MusicPlayerCubit>().audioPlayer.seek(Duration.zero);
            },
            icon: Icons.restart_alt,
          );
        }

        if (_isPlaying) {
          return _buildButton(
            onPressed: () {
              musicPlayerCubit.audioPlayer.pause();
              setState(() {
                _isPlaying = false;
              });
            },
            icon: Icons.pause,
          );
        }

        return _buildButton(
          onPressed: () {
            musicPlayerCubit.audioPlayer.play();
            setState(() {
              _isPlaying = true;
            });
          },
          icon: Icons.play_arrow,
        );
      },
      listener: (context, state) {
        if (state is MusicPlayerLoaded) {
          if (!_isLoading) {
            _isLoading = true;
            setState(() {});
          }
          _processingStateStreamSubscription?.cancel();
          _processingStateStreamSubscription = musicPlayerCubit
              .audioPlayer.processingStateStream
              .listen(processingStateListener);
        }
      },
    );
  }
}

class CurrentDurationSliderContainer extends StatefulWidget {
  const CurrentDurationSliderContainer({super.key});

  @override
  State<CurrentDurationSliderContainer> createState() =>
      _CurrentDurationSliderContainerState();
}

class _CurrentDurationSliderContainerState
    extends State<CurrentDurationSliderContainer> {
  double currentValue = 0;
  double max = 0;

  StreamSubscription<Duration>? streamSubscription;

  void currentDurationListener(Duration duration) {
    currentValue = duration.inSeconds.toDouble();
    setState(() {});
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerCubit, MusicPlayerState>(
      bloc: context.read<MusicPlayerCubit>(),
      listener: (context, state) {
        if (state is MusicPlayerLoaded) {
          currentValue = 0.0;
          max = state.audioDuration.inSeconds.toDouble();
          streamSubscription?.cancel();
          streamSubscription = context
              .read<MusicPlayerCubit>()
              .audioPlayer
              .positionStream
              .listen(currentDurationListener);
          setState(() {});
        }
      },
      child: SliderTheme(
        data: Theme.of(context).sliderTheme.copyWith(
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              trackHeight: 5,
              trackShape: CustomTrackShape(),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6.5,
              ),
            ),
        child: SizedBox(
          height: 5,
          width: MediaQuery.of(context).size.width,
          child: Slider(
            max: max,
            activeColor: Theme.of(context).primaryColor.withOpacity(0.6),
            inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
            value: currentValue,
            thumbColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              if (context.read<MusicPlayerCubit>().state is MusicPlayerLoaded) {
                setState(() {
                  currentValue = value;
                });
                context
                    .read<MusicPlayerCubit>()
                    .audioPlayer
                    .seek(Duration(seconds: value.toInt()));
              }
            },
          ),
        ),
      ),
    );
  }
}

class BufferedDurationContainer extends StatefulWidget {
  const BufferedDurationContainer({super.key});

  @override
  State<BufferedDurationContainer> createState() =>
      _BufferedDurationContainerState();
}

class _BufferedDurationContainerState extends State<BufferedDurationContainer> {
  late double bufferedPercentage = 0;

  StreamSubscription<Duration>? streamSubscription;

  void bufferedDurationListener(Duration duration) {
    if (context.read<MusicPlayerCubit>().state is MusicPlayerLoaded) {
      bufferedPercentage = duration.inSeconds /
          ((context.read<MusicPlayerCubit>().state as MusicPlayerLoaded)
              .audioDuration
              .inSeconds);
      setState(() {});
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerCubit, MusicPlayerState>(
      bloc: context.read<MusicPlayerCubit>(),
      listener: (context, state) {
        if (state is MusicPlayerLoaded) {
          if (bufferedPercentage != 0) {
            bufferedPercentage = 0.0;
            setState(() {});
          }
          streamSubscription?.cancel();

          streamSubscription = context
              .read<MusicPlayerCubit>()
              .audioPlayer
              .bufferedPositionStream
              .listen(bufferedDurationListener);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * bufferedPercentage,
        height: 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.5),
          color: Theme.of(context).primaryColor.withOpacity(0.6),
        ),
      ),
    );
  }
}

class CurrentDurationContainer extends StatefulWidget {
  const CurrentDurationContainer({super.key});

  @override
  State<CurrentDurationContainer> createState() =>
      _CurrentDurationContainerState();
}

class _CurrentDurationContainerState extends State<CurrentDurationContainer> {
  StreamSubscription<Duration>? currentAudioDurationStreamSubscription;
  late Duration currentDuration = Duration.zero;

  void currentDurationListener(Duration duration) {
    setState(() {
      currentDuration = duration;
    });
  }

  @override
  void dispose() {
    currentAudioDurationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerCubit, MusicPlayerState>(
      bloc: context.read<MusicPlayerCubit>(),
      listener: (context, state) {
        if (state is MusicPlayerLoaded) {
          if (currentDuration.inSeconds != 0) {
            currentDuration = Duration.zero;
            setState(() {});
          }
          currentAudioDurationStreamSubscription?.cancel();
          currentAudioDurationStreamSubscription = context
              .read<MusicPlayerCubit>()
              .audioPlayer
              .positionStream
              .listen(currentDurationListener);
        }
      },
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
