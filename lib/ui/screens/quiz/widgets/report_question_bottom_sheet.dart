import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionCubit.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

void showReportQuestionBottomSheet({
  required BuildContext context,
  required String questionId,
  required ReportQuestionCubit reportQuestionCubit,
}) {
  showModalBottomSheet<_ReportQuestionBottomSheet>(
    shape: const RoundedRectangleBorder(
      borderRadius: UiUtils.bottomSheetTopRadius,
    ),
    isDismissible: false,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    enableDrag: false,
    isScrollControlled: true,
    context: context,
    builder: (_) => _ReportQuestionBottomSheet(
      questionId: questionId,
      reportQuestionCubit: reportQuestionCubit,
    ),
  );
}

class _ReportQuestionBottomSheet extends StatefulWidget {
  const _ReportQuestionBottomSheet({
    required this.questionId,
    required this.reportQuestionCubit,
  });

  final String questionId;
  final ReportQuestionCubit reportQuestionCubit;

  @override
  State<_ReportQuestionBottomSheet> createState() =>
      _ReportQuestionBottomSheetState();
}

class _ReportQuestionBottomSheetState
    extends State<_ReportQuestionBottomSheet> {
  final reason = TextEditingController();
  String errorMessage = '';

  void _reportQuestionListener(
    BuildContext context,
    ReportQuestionState state,
  ) {
    if (state is ReportQuestionSuccess) {
      Navigator.pop(context);
    }

    if (state is ReportQuestionFailure) {
      if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
        showAlreadyLoggedInDialog(context);
        return;
      }

      ///
      setState(() {
        errorMessage = context.tr(
          convertErrorCodeToLanguageKey(state.errorMessageCode),
        )!;
      });
    }
  }

  void _onTapClose() {
    if (widget.reportQuestionCubit.state is! ReportQuestionInProgress) {
      Navigator.of(context).pop();
    }
  }

  void _onTapReportQuestion() {
    if (widget.reportQuestionCubit.state is! ReportQuestionInProgress) {
      widget.reportQuestionCubit.reportQuestion(
        message: reason.text.trim(),
        questionId: widget.questionId,
      );
    }
  }

  ///
  /// --- UI ---
  ///

  String get _buttonTitle {
    late final String title;

    if (widget.reportQuestionCubit.state is ReportQuestionInProgress) {
      title = submittingButton;
    } else if (widget.reportQuestionCubit.state is ReportQuestionFailure) {
      title = retryLbl;
    } else {
      title = submitBtn;
    }

    return context.tr(title)!;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return BlocListener<ReportQuestionCubit, ReportQuestionState>(
      bloc: widget.reportQuestionCubit,
      listener: _reportQuestionListener,
      child: PopScope(
        canPop: widget.reportQuestionCubit.state is! ReportQuestionInProgress,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: IconButton(
                        onPressed: _onTapClose,
                        icon: Icon(
                          Icons.close,
                          size: 28,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  child: Text(
                    context.tr(reportQuestionKey)!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                /// Reason Text Field
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: size.width * .125),
                  padding: const EdgeInsets.only(left: 20),
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colorScheme.surface,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onTertiary),
                    controller: reason,
                    decoration: InputDecoration(
                      hintText: context.tr(enterReasonKey),
                      hintStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: size.height * .02),

                /// Error Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(height: 20)
                      : SizedBox(
                          height: 20,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: size.height * .02),

                /// Report Button
                BlocBuilder<ReportQuestionCubit, ReportQuestionState>(
                  bloc: widget.reportQuestionCubit,
                  builder: (context, state) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * .3),
                      child: CustomRoundedButton(
                        widthPercentage: size.width,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: _buttonTitle,
                        radius: 10,
                        showBorder: false,
                        onTap: _onTapReportQuestion,
                        fontWeight: FontWeight.bold,
                        titleColor: colorScheme.surface,
                        height: 40,
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * .05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
