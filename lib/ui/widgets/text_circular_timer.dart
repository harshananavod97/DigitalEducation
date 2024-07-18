import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class TextCircularTimer extends StatelessWidget {
  const TextCircularTimer({
    required this.animationController,
    required this.arcColor,
    required this.color,
    super.key,
    this.size = 40,
    this.strokeWidth = 4,
  });

  final AnimationController animationController;
  final Color arcColor;
  final Color color;
  final double size;
  final double strokeWidth;

  /// calculate remaining time when isAnimating,
  /// otherwise gets null check error on elapsedDuration and duration.
  String get remaining {
    final remainingSeconds = (animationController.isAnimating)
        ? (animationController.duration! -
                animationController.duration! * animationController.value)
            .inSeconds
        : animationController.duration!.inSeconds;

    return remainingSeconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            /// Circle
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _CircleCustomPainter(
                  color: color,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),

            /// Arc
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _ArcCustomPainter(
                  color: arcColor,
                  strokeWidth: strokeWidth,
                  sweepDegree: 360 * animationController.value,
                ),
              ),
            ),

            /// Timer Text
            Text(
              remaining,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  color: arcColor,
                  fontWeight: FontWeights.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircleCustomPainter extends CustomPainter {
  const _CircleCustomPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * 0.5, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArcCustomPainter extends CustomPainter {
  const _ArcCustomPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepDegree,
  });
  final Color color;
  final double strokeWidth;
  final double sweepDegree;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final p = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    /// The PI constant.
    const pi = 3.1415926535897932;

    const startAngle = 3 * (pi / 2);
    final sweepAngle = -((360 - sweepDegree) * pi / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.5),
      startAngle,
      sweepAngle,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
