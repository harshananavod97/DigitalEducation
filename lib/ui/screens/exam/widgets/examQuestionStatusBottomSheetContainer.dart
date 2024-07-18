import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ExamQuestionStatusBottomSheetContainer extends StatelessWidget {
  const ExamQuestionStatusBottomSheetContainer({
    required this.pageController,
    required this.navigateToResultScreen,
    super.key,
  });

  final PageController pageController;
  final Function navigateToResultScreen;

  Widget _buildQuestionAttemptedByMarksContainer({
    required BuildContext context,
    required String questionMark,
    required List<Question> questions,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * .1,
      ),
      child: Column(
        children: [
          Text(
            '$questionMark ${context.tr(markKey)!} (${questions.length})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontSize: 16,
            ),
          ),
          Wrap(
            children: List.generate(questions.length, (index) => index)
                .map(
                  (index) => hasQuestionAttemptedContainer(
                    attempted: questions[index].attempted,
                    context: context,
                    questionIndex: context
                        .read<ExamCubit>()
                        .getQuestionIndexById(questions[index].id!),
                  ),
                )
                .toList(),
          ),
          Divider(color: Theme.of(context).colorScheme.onTertiary),
          SizedBox(height: MediaQuery.of(context).size.height * .02),
        ],
      ),
    );
  }

  Widget hasQuestionAttemptedContainer({
    required int questionIndex,
    required bool attempted,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(
          questionIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
          ),
          color: attempted
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.surface,
        ),
        margin: const EdgeInsets.all(5),
        height: 40,
        width: 40,
        child: Text(
          '${questionIndex + 1}',
          style: TextStyle(
            color: attempted
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onTertiary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (0.95),
      ),
      decoration: BoxDecoration(
        borderRadius: UiUtils.bottomSheetTopRadius,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Text(
                  '${context.tr(totalQuestionsKey)!} : ${context.read<ExamCubit>().getQuestions().length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...context
                .read<ExamCubit>()
                .getUniqueQuestionMark()
                .map((questionMark) {
              return _buildQuestionAttemptedByMarksContainer(
                context: context,
                questionMark: questionMark,
                questions:
                    context.read<ExamCubit>().getQuestionsByMark(questionMark),
              );
            }),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
              ),
              child: CustomRoundedButton(
                onTap: navigateToResultScreen as VoidCallback,
                widthPercentage: MediaQuery.of(context).size.width,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('submitBtn'),
                radius: 8,
                showBorder: false,
                titleColor: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.w600,
                height: 50,
                textSize: 18,
              ),
            ),

            ///
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('attemptedLbl')!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.onTertiary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('unAttemptedLbl')!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .025),
          ],
        ),
      ),
    );
  }
}
