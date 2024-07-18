import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/normalize_number.dart';

class RadialPercentageResultContainer extends StatefulWidget {
  //respect to width

  const RadialPercentageResultContainer({
    required this.percentage,
    required this.size,
    super.key,
    this.textFontSize,
    this.circleStrokeWidth = 8.0,
    this.arcStrokeWidth = 8.0,
    this.radiusPercentage = 0.27,
    this.timeTakenToCompleteQuizInSeconds,
    this.arcColor,
    this.circleColor,
  });

  final Size size;
  final double percentage;
  final double circleStrokeWidth;
  final double arcStrokeWidth;
  final Color? circleColor;
  final Color? arcColor;
  final double? textFontSize;
  final int? timeTakenToCompleteQuizInSeconds;
  final double radiusPercentage;

  @override
  State<RadialPercentageResultContainer> createState() =>
      _RadialPercentageResultContainerState();
}

class _RadialPercentageResultContainerState
    extends State<RadialPercentageResultContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation = Tween<double>(
      begin: 0,
      end: NormalizeNumber.inRange(
        currentValue: widget.percentage,
        minValue: 0,
        maxValue: 100,
        newMaxValue: 360,
        newMinValue: 0,
      ),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  String _getTimeInMinutesAndSeconds() {
    final totalTime = widget.timeTakenToCompleteQuizInSeconds ?? 0;
    if (totalTime == 0) {
      return '';
    }
    final seconds = totalTime % 60;
    final minutes = totalTime ~/ 60;
    return "${minutes < 10 ? 0 : ''}$minutes:${seconds < 10 ? 0 : ''}$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.size.height,
          width: widget.size.width,
          child: CustomPaint(
            painter: CircleCustomPainter(
              color: widget.circleColor ??
                  Theme.of(context).scaffoldBackgroundColor,
              radiusPercentage: widget.radiusPercentage,
              strokeWidth: widget.circleStrokeWidth,
            ),
          ),
        ),
        SizedBox(
          height: widget.size.height,
          width: widget.size.width,
          child: AnimatedBuilder(
            builder: (context, _) {
              return CustomPaint(
                painter: ArcCustomPainter(
                  sweepAngle: animation.value,
                  color: Theme.of(context).primaryColor,
                  radiusPercentage: widget.radiusPercentage,
                  strokeWidth: widget.arcStrokeWidth,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 2.5),
                      child: Text(
                        '${widget.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: widget.textFontSize ?? 17.0,
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontWeight: FontWeights.bold,
                        ),
                      ),
                    ),
                    if (_getTimeInMinutesAndSeconds().isNotEmpty)
                      Text(
                        _getTimeInMinutesAndSeconds(),
                        style: TextStyle(
                          fontSize: widget.textFontSize != null
                              ? (widget.textFontSize! - 5)
                              : 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.3),
                          fontWeight: FontWeights.regular,
                        ),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
              );
            },
            animation: animationController,
          ),
        ),
      ],
    );
  }
}

class CircleCustomPainter extends CustomPainter {
  CircleCustomPainter({this.color, this.radiusPercentage, this.strokeWidth});

  final Color? color;
  final double? strokeWidth;
  final double? radiusPercentage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * (0.5), size.height * (0.5));
    final paint = Paint()
      ..strokeWidth = strokeWidth!
      ..color = color!
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * radiusPercentage!, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //generally it return false but when parent widget is changing
    //or animating it should return true
    return false;
  }
}

class ArcCustomPainter extends CustomPainter {
  ArcCustomPainter({
    required this.sweepAngle,
    required this.color,
    required this.radiusPercentage,
    required this.strokeWidth,
  });

  final double sweepAngle;
  final Color color;
  final double radiusPercentage;
  final double strokeWidth;

  double _degreeToRadian() => -((sweepAngle * pi) / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(
          size.width * (0.5),
          size.height * (0.5),
        ),
        radius: size.width * radiusPercentage,
      ),
      3 * (pi / 2),
      _degreeToRadian(),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
