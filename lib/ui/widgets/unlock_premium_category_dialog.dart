import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlock_premium_category_cubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// [_UnlockPremiumAlertDialog] handles showing the unlock confirmation dialog.
///
/// It takes in the category details needed to show the unlock dialog.
///
/// On press unlock:
/// - Calls UnlockPremiumCategoryCubit to unlock the category/subcategory
/// - Updates user coins via UpdateScoreAndCoinsCubit if unlock succeeds
/// - Shows success/error message
/// - Closes dialog on completion
///
/// It disables back button while dialog is open.
///
/// Parameters:
/// - categoryId: id of category/subcategory to unlock
/// - subcategoryId: optional subcategory id
/// - categoryName: name to show in dialog text
/// - requiredCoins: coins needed to unlock
/// - isQuizZone (bool): Whether this is a quizzone category
///
/// State handling:
/// - Shows initial unlock confirmation dialog
/// - Shows circular progress indicator when unlock in progress
/// - Shows success/error message based on unlock result
/// - Closes dialog and resets state when finished
///
void showUnlockPremiumCategoryDialog(
  BuildContext context, {
  required String categoryId,
  required String categoryName,
  required int requiredCoins,
  String? subcategoryId,
  bool isQuizZone = false,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UnlockPremiumAlertDialog(
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      categoryName: categoryName,
      requiredCoins: requiredCoins,
      isQuizZone: isQuizZone,
    ),
  );
}

class _UnlockPremiumAlertDialog extends StatelessWidget {
  const _UnlockPremiumAlertDialog({
    required this.categoryId,
    required this.categoryName,
    required this.requiredCoins,
    required this.isQuizZone,
    this.subcategoryId,
  });

  final String categoryId;
  final String? subcategoryId;
  final String categoryName;
  final int requiredCoins;
  final bool isQuizZone;

  ///--- Logic
  void _onPressedUnlock(BuildContext context) {
    final coins = int.parse(context.read<UserDetailsCubit>().getCoins() ?? '0');
    if (coins >= requiredCoins) {
      context.read<UnlockPremiumCategoryCubit>().unlockPremiumCategory(
            categoryId: categoryId,
            subCategoryId: subcategoryId,
          );
    } else {
      _closeDialog(context);
      _showNotEnoughCoinsDialog(context);
      return;
    }
  }

  void _closeDialog(BuildContext context) {
    Navigator.pop(context);
    context.read<UnlockPremiumCategoryCubit>().reset();
  }

  ///--- UI

  Text _titleText(String textLbl, BuildContext context) {
    return Text(
      context.tr(textLbl) ?? textLbl,
      style: TextStyle(
        fontWeight: FontWeights.semiBold,
        fontSize: 16,
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
  }

  TextButton _textBtn(
    String textLbl,
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        context.tr(textLbl) ?? textLbl,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  void _showNotEnoughCoinsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: _titleText(notEnoughCoinsKey, context),
          actions: [
            _textBtn('close', context, onPressed: Navigator.of(context).pop),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final useLbl = context.tr('useLbl');
    final coinsLbl = context.tr('coinsLbl');
    final unlockLbl = context.tr('unlockLbl');
    final unlockedLbl = context.tr('unlockedLbl');
    final unlockPremiumDescription = context.tr('unlockPremiumDescription')!;

    return BlocProvider<UpdateScoreAndCoinsCubit>(
      create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
      child:
          BlocConsumer<UnlockPremiumCategoryCubit, UnlockPremiumCategoryState>(
        builder: (context, state) {
          if (state is UnlockPremiumCategoryInitial) {
            return AlertDialog(
              shadowColor: Colors.transparent,
              title: _titleText('$unlockLbl $categoryName', context),
              content: Text(
                unlockPremiumDescription,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
                ),
              ),
              actions: [
                PopScope(
                  canPop: state is! UnlockPremiumCategoryInProgress,
                  child: _textBtn(
                    'close',
                    context,
                    onPressed: () => _closeDialog(context),
                  ),
                ),
                _textBtn(
                  '$useLbl $requiredCoins $coinsLbl',
                  context,
                  onPressed: () => _onPressedUnlock(context),
                ),
              ],
            );
          }

          if (state is UnlockPremiumCategoryInProgress) {
            return const AlertDialog(
              content: CircularProgressContainer(),
            );
          }

          if (state is UnlockPremiumCategoryFailure) {
            return AlertDialog(
              content: _titleText('defaultErrorMessage', context),
              actions: [
                _textBtn(
                  'close',
                  context,
                  onPressed: () => _closeDialog(context),
                ),
              ],
            );
          }

          return const SizedBox();
        },
        listener: (context, state) {
          if (state is UnlockPremiumCategorySuccess) {
            /// Update Cached List.
            if (subcategoryId == null || subcategoryId!.isEmpty) {
              if (isQuizZone) {
                context
                    .read<QuizoneCategoryCubit>()
                    .unlockPremiumCategory(id: categoryId);
              } else {
                context
                    .read<QuizCategoryCubit>()
                    .unlockPremiumCategory(id: categoryId);
              }
            } else {
              context.read<SubCategoryCubit>().unlockPremiumSubCategory(
                    categoryId: categoryId,
                    id: subcategoryId!,
                  );
            }

            // update user coins to remote DS
            context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                  coins: requiredCoins,
                  addCoin: false,
                  title: '$unlockedLbl $categoryName',
                );
            // update user coins to local DS
            context.read<UserDetailsCubit>().updateCoins(
                  addCoin: false,
                  coins: requiredCoins,
                );

            UiUtils.showSnackBar('$unlockedLbl $categoryName', context);
            Navigator.pop(context);
            Future.delayed(
              const Duration(milliseconds: 20),
              context.read<UnlockPremiumCategoryCubit>().reset,
            );
          }
        },
      ),
    );
  }
}
