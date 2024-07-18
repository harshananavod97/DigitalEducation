import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/screens/auth/otp_screen.dart';
import 'package:flutterquiz/utils/extensions.dart';

class ResendOtpTimerContainer extends StatefulWidget {
  const ResendOtpTimerContainer({
    required this.enableResendOtpButton,
    super.key,
  });

  final VoidCallback enableResendOtpButton;

  @override
  ResendOtpTimerContainerState createState() => ResendOtpTimerContainerState();
}

class ResendOtpTimerContainerState extends State<ResendOtpTimerContainer> {
  Timer? resendOtpTimer;
  int resendOtpTimeInSeconds = otpTimeOutSeconds - 1;

  //
  void setResendOtpTimer() {
    setState(() {
      resendOtpTimeInSeconds = otpTimeOutSeconds - 1;
    });
    resendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendOtpTimeInSeconds == 0) {
        timer.cancel();
        widget.enableResendOtpButton();
      } else {
        resendOtpTimeInSeconds--;
        setState(() {});
      }
    });
  }

  void cancelOtpTimer() {
    resendOtpTimer?.cancel();
  }

  @override
  void dispose() {
    cancelOtpTimer();
    super.dispose();
  }

//to get time to display in text widget
  String getTime() {
    final secondsAsString = resendOtpTimeInSeconds < 10
        ? ' 0$resendOtpTimeInSeconds'
        : resendOtpTimeInSeconds.toString();
    return ' $secondsAsString';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr('resetLbl')! + getTime(),
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
