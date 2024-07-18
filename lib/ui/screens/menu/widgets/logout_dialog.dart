import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

void showLogoutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) {
      final size = MediaQuery.of(context).size;

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
            SvgPicture.asset(Assets.logoutAccount),

            ///
            const SizedBox(height: 32),
            Text(
              context.tr(logoutLbl)!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),

            ///
            const SizedBox(height: 19),
            Text(
              context.tr(logoutDialogLbl)!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),

            ///
            const SizedBox(height: 33),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                context.read<BadgesCubit>().updateState(BadgesInitial());

                context.read<BookmarkCubit>().updateState(BookmarkInitial());

                context
                    .read<GuessTheWordBookmarkCubit>()
                    .updateState(GuessTheWordBookmarkInitial());

                context
                    .read<AudioQuestionBookmarkCubit>()
                    .updateState(AudioQuestionBookmarkInitial());

                context.read<AuthCubit>().signOut();
                Navigator.of(context).pushReplacementNamed(Routes.login);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              child: Text(
                context.tr('yesLogoutLbl')!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),

            ///
            const SizedBox(height: 19),
            TextButton(
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: Navigator.of(context).pop,
              child: Text(
                context.tr('stayLoggedLbl')!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
