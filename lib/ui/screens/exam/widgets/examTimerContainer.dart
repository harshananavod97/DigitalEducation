import 'dart:async';

import 'package:flutter/material.dart';

class ExamTimerContainer extends StatefulWidget {
  const ExamTimerContainer({
    required this.examDurationInMinutes,
    required this.navigateToResultScreen,
    super.key,
  });

  final int examDurationInMinutes;
  final VoidCallback navigateToResultScreen;

  @override
  State<ExamTimerContainer> createState() => ExamTimerContainerState();
}

class ExamTimerContainerState extends State<ExamTimerContainer> {
  late int minutesLeft = widget.examDurationInMinutes - 1;
  late int secondsLeft = 59;

  void startTimer() {
    examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (minutesLeft == 0 && secondsLeft == 0) {
        timer.cancel();
        widget.navigateToResultScreen();
      } else {
        if (secondsLeft == 0) {
          secondsLeft = 59;
          minutesLeft--;
        } else {
          secondsLeft--;
        }
        setState(() {});
      }
    });
  }

  Timer? examTimer;

  int getCompletedExamDuration() {
    return widget.examDurationInMinutes - minutesLeft;
  }

  void cancelTimer() {
    examTimer?.cancel();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var hours = (minutesLeft ~/ 60).toString().length == 1
        ? '0${minutesLeft ~/ 60}'
        : (minutesLeft ~/ 60).toString();

    final minutes = (minutesLeft % 60).toString().length == 1
        ? '0${minutesLeft % 60}'
        : (minutesLeft % 60).toString();
    hours = hours == '00' ? '' : hours;

    final seconds = secondsLeft < 10 ? '0$secondsLeft' : '$secondsLeft';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
          width: 4,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        hours.isEmpty ? '$minutes:$seconds' : '$hours:$minutes:$seconds',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
