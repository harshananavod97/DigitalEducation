import 'dart:math';

import 'package:flutter/material.dart';

class CircularTimerContainer extends StatelessWidget {
  const CircularTimerContainer({
    required this.timerAnimationController,
    required this.heightAndWidth,
    super.key,
  });
  final double heightAndWidth;

  final AnimationController timerAnimationController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: heightAndWidth,
          width: heightAndWidth,
          child: CustomPaint(
            painter: CircleCustomPainter(
              color: Theme.of(context).colorScheme.surface,
              radiusPercentage: 0.5,
              strokeWidth: 3,
            ),
          ),
        ),
        SizedBox(
          height: heightAndWidth,
          width: heightAndWidth,
          child: AnimatedBuilder(
            builder: (context, _) {
              return CustomPaint(
                painter: ArcCustomPainter(
                  sweepAngle: 360 * timerAnimationController.value,
                  color: Theme.of(context).primaryColor,
                  radiusPercentage: 0.5,
                  strokeWidth: 3,
                ),
              );
            },
            animation: timerAnimationController,
          ),
        ),
      ],
    );
  }
}

class CircleCustomPainter extends CustomPainter {
  CircleCustomPainter({
    required this.color,
    required this.radiusPercentage,
    required this.strokeWidth,
  });
  final Color color;
  final double strokeWidth;
  final double radiusPercentage;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * (0.5), size.height * (0.5));
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * radiusPercentage, paint);
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

  double _degreeToRadian() {
    return (sweepAngle * pi) / 180.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * (0.5), size.height * (0.5)),
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
