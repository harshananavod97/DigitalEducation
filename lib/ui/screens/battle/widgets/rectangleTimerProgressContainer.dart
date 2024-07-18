import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/rectangleUserProfileContainer.dart';

class RectangleTimerProgressContainer extends StatefulWidget {
  const RectangleTimerProgressContainer({
    required this.animationController,
    required this.color,
    super.key,
  });

  final AnimationController animationController;
  final Color color;

  @override
  State<RectangleTimerProgressContainer> createState() =>
      _RectangleTimerProgressContainerState();
}

class _RectangleTimerProgressContainerState
    extends State<RectangleTimerProgressContainer> {
  late final Animation<double> _animation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0, 0.2),
    ),
  );

  late final Animation<double> _firstCurveAnimation =
      Tween<double>(begin: 0, end: 90).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.2, 0.25),
    ),
  );

  late final Animation<double> _secondPointAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.25, 0.45),
    ),
  );
  late final Animation<double> _secondCurveAnimation =
      Tween<double>(begin: 0, end: 90).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.45, 0.5),
    ),
  );
  late final Animation<double> _thirdAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.5, 0.7),
    ),
  );
  late final Animation<double> _thirdCurveAnimation =
      Tween<double>(begin: 0, end: 90).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.7, 0.75),
    ),
  );
  late final Animation<double> _fourthPointAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.75, 0.95),
    ),
  );
  late final _fourthCurveAnimation = Tween<double>(begin: 0, end: 90).animate(
    CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.95, 1),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: RectanglePainter(
            color: widget.color,
            paintingStyle: PaintingStyle.stroke,
            points: [
              _animation.value,
              _firstCurveAnimation.value,
              _secondPointAnimation.value,
              _secondCurveAnimation.value,
              _thirdAnimation.value,
              _thirdCurveAnimation.value,
              _fourthPointAnimation.value,
              _fourthCurveAnimation.value,
            ],
            animationControllerValue: widget.animationController.value,
            curveRadius: 10,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width *
                RectangleUserProfileContainer.userDetailsWidthPercentage,
            height: MediaQuery.of(context).size.height *
                RectangleUserProfileContainer.userDetailsHeightPercentage,
          ),
        );
      },
    );
  }
}
