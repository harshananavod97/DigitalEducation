import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/rectangleTimerProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';

class RectangleUserProfileContainer extends StatelessWidget {
  const RectangleUserProfileContainer({
    required this.animationController,
    required this.progressColor,
    required this.userBattleRoomDetails,
    required this.isLeft,
    super.key,
  });

  final UserBattleRoomDetails userBattleRoomDetails;

  final AnimationController animationController;
  final Color progressColor;
  final bool isLeft;

  static const userDetailsHeightPercentage = 0.039;
  static const userDetailsWidthPercentage = 0.12;

  Widget _buildProfileContainer(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: RectanglePainter(
            color: Theme.of(context).primaryColor,
            paintingStyle: PaintingStyle.stroke,
            points: [],
            animationControllerValue: 1,
            curveRadius: 10,
          ),
          child: SizedBox(
            width:
                MediaQuery.of(context).size.width * userDetailsWidthPercentage,
            height: MediaQuery.of(context).size.height *
                userDetailsHeightPercentage,
          ),
        ),
        RectangleTimerProgressContainer(
          animationController: animationController,
          color: progressColor,
        ),
        CustomPaint(
          painter: RectanglePainter(
            color: Theme.of(context).primaryColor,
            paintingStyle: PaintingStyle.fill,
            points: [],
            animationControllerValue: 1,
            curveRadius: 10,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            width:
                MediaQuery.of(context).size.width * userDetailsWidthPercentage,
            height: MediaQuery.of(context).size.height *
                userDetailsHeightPercentage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: QImage(
                imageUrl: userBattleRoomDetails.profileUrl,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserName(BuildContext context) {
    return Flexible(
      child: Text(
        userBattleRoomDetails.name,
        style: TextStyle(
          height: 1.1,
          fontSize: 13,
          color: Theme.of(context).colorScheme.surface,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * (0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isLeft)
            _buildProfileContainer(context)
          else
            _buildUserName(context),
          const SizedBox(width: 12.50),
          if (isLeft)
            _buildUserName(context)
          else
            _buildProfileContainer(context),
        ],
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  RectanglePainter({
    required this.color,
    required this.points,
    required this.animationControllerValue,
    required this.curveRadius,
    required this.paintingStyle,
  });

  final PaintingStyle paintingStyle;
  final Color color;
  final List<double> points;
  final double animationControllerValue;
  final double curveRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = paintingStyle
      ..strokeWidth = 6.0;

    final path = Path()..moveTo(curveRadius, 0);

    if (paintingStyle == PaintingStyle.stroke) {
      if (points.isEmpty) {
        path
          ..lineTo(size.width - curveRadius, 0)
          ..addArc(
            Rect.fromCircle(
              center: Offset(size.width - curveRadius, curveRadius),
              radius: curveRadius,
            ),
            3 * pi / 2,
            pi / 2,
          )
          ..lineTo(size.width, size.height - curveRadius)
          ..addArc(
            Rect.fromCircle(
              center:
                  Offset(size.width - curveRadius, size.height - curveRadius),
              radius: curveRadius,
            ),
            0,
            pi / 2,
          )
          ..lineTo(curveRadius, size.height)
          ..addArc(
            Rect.fromCircle(
              center: Offset(curveRadius, size.height - curveRadius),
              radius: curveRadius,
            ),
            pi / 2,
            pi / 2,
          )
          ..lineTo(0, curveRadius)
          ..addArc(
            Rect.fromCircle(
              center: Offset(curveRadius, curveRadius),
              radius: curveRadius,
            ),
            pi,
            pi / 2,
          );
      } else {
        if (animationControllerValue <= 0.2) {
          path.lineTo(
            curveRadius +
                size.width * points.first -
                (2 * curveRadius * points.first),
            0,
          );
        } else if (animationControllerValue > 0.2 &&
            animationControllerValue <= 0.25) {
          path
            ..lineTo(size.width - curveRadius, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              (pi / 180) * points[1],
            );
          //
        } else if (animationControllerValue > 0.25 &&
            animationControllerValue <= 0.45) {
          //add animation here
          path
            ..lineTo((size.width - curveRadius) * points.first, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              pi / 2,
            )
            //second line
            ..lineTo(
              size.width,
              curveRadius +
                  (size.height * points[2]) -
                  (2 * curveRadius * points[2]),
            );
        } else if (animationControllerValue > 0.45 &&
            animationControllerValue <= 0.5) {
          path
            ..lineTo((size.width - curveRadius) * points.first, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              (pi / 180) * points[1],
            )
            ..lineTo(size.width, (size.height - curveRadius) * points[2])
            //second curve
            ..addArc(
              Rect.fromCircle(
                center: Offset(
                  size.width - curveRadius,
                  size.height - curveRadius,
                ),
                radius: curveRadius,
              ),
              0,
              (pi / 180) * points[3],
            );
        } else if (animationControllerValue > 0.5 &&
            animationControllerValue <= 0.7) {
          path
            ..lineTo((size.width - curveRadius) * points.first, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              (pi / 180) * points[1],
            )
            ..lineTo(size.width, (size.height - curveRadius) * points[2])
            ..addArc(
              Rect.fromCircle(
                center: Offset(
                  size.width - curveRadius,
                  size.height - curveRadius,
                ),
                radius: curveRadius,
              ),
              0,
              (pi / 180) * points[3],
            )
            //third line
            ..lineTo(
              size.width -
                  curveRadius -
                  (size.width) * points[4] +
                  2 * curveRadius * points[4],
              size.height,
            );
        } else if (animationControllerValue > 0.7 &&
            animationControllerValue <= 0.75) {
          path
            ..lineTo((size.width - curveRadius) * points.first, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              (pi / 180) * points[1],
            )
            ..lineTo(size.width, (size.height - curveRadius) * points[2])
            ..addArc(
              Rect.fromCircle(
                center: Offset(
                  size.width - curveRadius,
                  size.height - curveRadius,
                ),
                radius: curveRadius,
              ),
              0,
              pi / 2,
            )
            ..lineTo(curveRadius, size.height)

            //third curve
            ..addArc(
              Rect.fromCircle(
                center: Offset(curveRadius, size.height - curveRadius),
                radius: curveRadius,
              ),
              pi / 2,
              (pi / 180) * points[5],
            );
        } else if (animationControllerValue > 0.75 &&
            animationControllerValue <= 0.95) {
          path
            ..lineTo((size.width - curveRadius) * points.first, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              (pi / 180) * points[1],
            )
            ..lineTo(size.width, (size.height - curveRadius) * points[2])
            ..addArc(
              Rect.fromCircle(
                center: Offset(
                  size.width - curveRadius,
                  size.height - curveRadius,
                ),
                radius: curveRadius,
              ),
              0,
              pi / 2,
            )
            ..lineTo(curveRadius, size.height)
            ..addArc(
              Rect.fromCircle(
                center: Offset(curveRadius, size.height - curveRadius),
                radius: curveRadius,
              ),
              pi / 2,
              pi / 2,
            )
            //fourth line
            ..lineTo(
              0,
              size.height -
                  curveRadius +
                  (2 * curveRadius * points[6]) -
                  (size.height * points[6]),
            ); //points[6]
        } else if (animationControllerValue > 0.95 &&
            animationControllerValue <= 1.0) {
          path
            ..lineTo((size.width - curveRadius) * points.first, 0)
            ..addArc(
              Rect.fromCircle(
                center: Offset(size.width - curveRadius, curveRadius),
                radius: curveRadius,
              ),
              3 * pi / 2,
              (pi / 180) * points[1],
            )
            ..lineTo(size.width, (size.height - curveRadius) * points[2])
            ..addArc(
              Rect.fromCircle(
                center: Offset(
                  size.width - curveRadius,
                  size.height - curveRadius,
                ),
                radius: curveRadius,
              ),
              0,
              pi / 2,
            )
            ..lineTo(curveRadius, size.height)
            ..addArc(
              Rect.fromCircle(
                center: Offset(curveRadius, size.height - curveRadius),
                radius: curveRadius,
              ),
              pi / 2,
              pi / 2,
            )
            ..lineTo(0, curveRadius)
            ..addArc(
              Rect.fromCircle(
                center: Offset(curveRadius, curveRadius),
                radius: curveRadius,
              ),
              pi,
              (pi / 180) * points[7],
            );
        }
      }

      canvas.drawPath(path, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(curveRadius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
