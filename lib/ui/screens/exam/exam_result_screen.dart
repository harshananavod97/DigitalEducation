import 'package:flutter/material.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({required this.examResult, super.key});

  final ExamResult examResult;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(examResult.date),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: QAppBar(
        elevation: 0,
        title: Text(
          context.tr(examResultKey)!,
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: size.height * .315,
            width: size.width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeights.regular,
                    height: 1.2,
                    color: colorScheme.onTertiary.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  examResult.title,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeights.medium,
                    color: colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.onTertiary.withOpacity(0.4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 10,
                  ),
                  child: Text(
                    '${context.tr(obtainedMarksLblKey)!} : ${examResult.obtainedMarks()}/${examResult.totalMarks}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeights.semiBold,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('totalQuestions')!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeights.medium,
                        color: colorScheme.onTertiary,
                      ),
                    ),
                    Text(
                      "[ ${examResult.totalQuestions()} ${context.tr("quesLbl")!}]",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeights.medium,
                        color: colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Theme.of(context).primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeights.semiBold,
                            color: colorScheme.surface,
                          ),
                          children: [
                            TextSpan(
                              text: '${examResult.totalCorrectAnswers()}\n',
                            ),
                            TextSpan(
                              text: context.tr('correctAnswersLbl'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeights.semiBold,
                            color: colorScheme.surface,
                          ),
                          children: [
                            TextSpan(
                              text: '${examResult.totalInCorrectAnswers()}\n',
                            ),
                            TextSpan(
                              text: context.tr('incorrectAnswersLbl'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeights.regular,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...examResult.getUniqueMarksOfQuestion().map(
                (marks) => _StatCard(
                  marks: marks,
                  totalQues: examResult.totalQuestionsByMark(marks).toString(),
                  correctAns:
                      examResult.totalCorrectAnswersByMark(marks).toString(),
                  incorrectAns:
                      examResult.totalInCorrectAnswersByMark(marks).toString(),
                ),
              ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.marks,
    required this.totalQues,
    required this.correctAns,
    required this.incorrectAns,
  });

  final String marks;
  final String totalQues;
  final String correctAns;
  final String incorrectAns;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onTertiary;
    final subtextColor = textColor.withOpacity(0.6);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$marks ${context.tr("markQuestionsLbl")!}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeights.medium,
                  color: textColor,
                ),
              ),
              Text(
                "[ $totalQues ${context.tr("quesLbl")!} ]",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeights.medium,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      correctAns,
                      style: TextStyle(
                        fontWeight: FontWeights.semiBold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    Text(
                      context.tr('correctAnswersLbl')!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeights.regular,
                        color: subtextColor,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 6,
                      width: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          color: kCorrectAnswerColor,
                        ),
                      ),
                    ),
                  ],
                ),
                VerticalDivider(
                  indent: 10,
                  endIndent: 20,
                  color: subtextColor,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      incorrectAns,
                      style: TextStyle(
                        fontWeight: FontWeights.semiBold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    Text(
                      context.tr('incorrectAnswersLbl')!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeights.regular,
                        color: subtextColor,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      height: 6,
                      width: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
