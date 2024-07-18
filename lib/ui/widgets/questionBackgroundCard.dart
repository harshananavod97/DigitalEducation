import 'package:flutter/material.dart';

class QuestionBackgroundCard extends StatelessWidget {
  const QuestionBackgroundCard({
    required this.opacity,
    required this.heightPercentage,
    required this.topMarginPercentage,
    required this.widthPercentage,
    super.key,
  });
  final double opacity;
  final double widthPercentage;
  final double topMarginPercentage;
  final double heightPercentage;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * topMarginPercentage,
        ),
        width: MediaQuery.of(context).size.width * widthPercentage,
        height: MediaQuery.of(context).size.height * heightPercentage,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
