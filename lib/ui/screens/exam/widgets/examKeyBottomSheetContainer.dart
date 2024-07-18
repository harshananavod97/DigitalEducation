import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ExamKeyBottomSheetContainer extends StatefulWidget {
  const ExamKeyBottomSheetContainer({
    required this.exam,
    required this.navigateToExamScreen,
    super.key,
  });

  final Exam exam;
  final VoidCallback navigateToExamScreen;

  @override
  State<ExamKeyBottomSheetContainer> createState() =>
      _ExamKeyBottomSheetContainerState();
}

class _ExamKeyBottomSheetContainerState
    extends State<ExamKeyBottomSheetContainer> {
  late final examKeyController = TextEditingController(text: '1234');

  late String errorMessage = '';

  bool showAllExamRules = false;

  late bool showViewAllRulesButton = examRules.length > 2;

  late bool rulesAccepted = false;

  final double horizontalPaddingPercentage = 0.125;

  Widget _buildAcceptRulesContainer() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * horizontalPaddingPercentage,
        vertical: 10,
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(width: 2),
          InkWell(
            onTap: () {
              setState(() {
                rulesAccepted = !rulesAccepted;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rulesAccepted
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1.5,
                  color: rulesAccepted
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              child: Icon(
                Icons.check,
                color: rulesAccepted
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onTertiary,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            context.tr(iAgreeWithExamRulesKey)!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleLine(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              rule,
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamRules() {
    var allExamRules = <String>[];
    if (showAllExamRules) {
      allExamRules = examRules;
    } else {
      allExamRules =
          examRules.length >= 2 ? examRules.sublist(0, 2) : examRules;
    }

    return Column(
      children: allExamRules.map(_buildRuleLine).toList(),
    );
  }

  late Color _onTertiary;
  late String _showLessLbl;
  late String _viewAllRulesLbl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onTertiary = Theme.of(context).colorScheme.onTertiary;
    _showLessLbl = context.tr('showLess')!;
    _viewAllRulesLbl = context.tr(viewAllRulesKey)!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.read<ExamCubit>().state is! ExamFetchInProgress,
      child: BlocListener<ExamCubit, ExamState>(
        bloc: context.read<ExamCubit>(),
        listener: (context, state) {
          if (state is ExamFetchFailure) {
            setState(() {
              errorMessage = context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!;
            });
          } else if (state is ExamFetchSuccess) {
            widget.navigateToExamScreen();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Align(
                  child: Text(
                    context.tr('enterExamLbl')!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _onTertiary,
                    ),
                  ),
                ),
                Divider(
                  color: _onTertiary.withOpacity(0.6),
                  thickness: 1.5,
                ),
                const SizedBox(height: 20),
                Align(
                  child: Text(
                    context.tr('enterExamKeyLbl')!,
                    style: TextStyle(
                      fontSize: 16,
                      color: _onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// Enter Exam Key
                Align(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: PinCodeTextField(
                      controller: examKeyController,
                      appContext: context,
                      length: 4,
                      keyboardType: TextInputType.number,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      textStyle: TextStyle(color: _onTertiary),
                      pinTheme: PinTheme(
                        selectedFillColor: _onTertiary.withOpacity(0.1),
                        inactiveColor: _onTertiary.withOpacity(0.1),
                        activeColor: _onTertiary.withOpacity(0.1),
                        inactiveFillColor: _onTertiary.withOpacity(0.1),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 45,
                        fieldWidth: 45,
                        activeFillColor: _onTertiary.withOpacity(0.2),
                      ),
                      cursorColor: _onTertiary,
                      animationDuration: const Duration(milliseconds: 200),
                      enableActiveFill: true,
                      onChanged: (v) {},
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .0125),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _onTertiary.withOpacity(0.1),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(examRulesKey)!,
                        style: TextStyle(
                          color: _onTertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildExamRules(),

                      /// View All/Show less
                      GestureDetector(
                        onTap: () => setState(() {
                          showAllExamRules = !showAllExamRules;
                        }),
                        child: Text(
                          showAllExamRules ? _showLessLbl : _viewAllRulesLbl,
                          style: TextStyle(
                            fontSize: 12,
                            color: _onTertiary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildAcceptRulesContainer(),

                //show any error message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(height: 20)
                      : SizedBox(
                          height: 20,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: _onTertiary,
                            ),
                          ),
                        ),
                ),

                //show submit button
                BlocBuilder<ExamCubit, ExamState>(
                  bloc: context.read<ExamCubit>(),
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width *
                            UiUtils.hzMarginPct,
                      ),
                      child: CustomRoundedButton(
                        widthPercentage: MediaQuery.of(context).size.width,
                        backgroundColor: rulesAccepted
                            ? Theme.of(context).primaryColor
                            : _onTertiary,
                        buttonTitle: state is ExamFetchInProgress
                            ? context.tr(submittingButton)!
                            : context.tr(submitBtn)!,
                        radius: 8,
                        showBorder: false,
                        onTap: state is ExamFetchInProgress
                            ? () {}
                            : () {
                                if (!rulesAccepted) {
                                  setState(() {
                                    errorMessage = context.tr(
                                      pleaseAcceptExamRulesKey,
                                    )!;
                                  });
                                } else if (examKeyController.text.trim() ==
                                    widget.exam.examKey) {
                                  context
                                      .read<ExamCubit>()
                                      .startExam(exam: widget.exam);
                                } else {
                                  setState(() {
                                    errorMessage = context.tr(
                                      enterValidExamKey,
                                    )!;
                                  });
                                }
                              },
                        fontWeight: FontWeight.bold,
                        titleColor: Theme.of(context).colorScheme.surface,
                        height: 45,
                      ),
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
