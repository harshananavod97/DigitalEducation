import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/features/profileManagement/cubits/deleteAccountCubit.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

void showDeleteAccountDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) {
      final size = MediaQuery.of(context).size;
      final colorScheme = Theme.of(context).colorScheme;

      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width * UiUtils.hzMarginPct,
        ),
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.symmetric(
          vertical: size.height * UiUtils.vtMarginPct,
          horizontal: size.width * UiUtils.hzMarginPct,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(Assets.deleteAccount),
            const SizedBox(height: 32),
            Text(
              context.tr('deleteAccountLbl')!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeights.bold,
                color: colorScheme.onTertiary,
              ),
            ),
            const SizedBox(height: 19),
            Text(
              context.tr('deleteAccConfirmation')!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onTertiary,
              ),
            ),

            ///
            const SizedBox(height: 33),
            TextButton(
              onPressed: () {
                context.read<DeleteAccountCubit>().deleteUserAccount();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(Theme.of(context).primaryColor),
              ),
              child: Text(
                context.tr('yesDeleteAcc')!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeights.semiBold,
                  color: colorScheme.surface,
                ),
              ),
            ),

            ///
            const SizedBox(height: 19),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                context.tr('keepAccount')!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeights.semiBold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
