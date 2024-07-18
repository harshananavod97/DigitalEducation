import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';

Future<void> showAlreadyLoggedInDialog(BuildContext context) {
  context.read<AuthCubit>().signOut();

  return showDialog<void>(
    context: context,
    builder: (_) => const PopScope(
      canPop: false,
      child: _AlreadyLoggedInDialog(),
    ),
  );
}

class _AlreadyLoggedInDialog extends StatelessWidget {
  const _AlreadyLoggedInDialog();

  @override
  Widget build(BuildContext context) {
    final isXSmall = context.isXSmall;
    final colorScheme = Theme.of(context).colorScheme;

    final alreadyLoginSvg = SvgPicture.asset(
      Assets.alreadyLogin,
    );

    return SizedBox(
      width: context.shortestSide,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return AlertDialog(
            alignment: Alignment.center,
            actionsAlignment: MainAxisAlignment.center,
            title: SizedBox(
              width: maxWidth * (isXSmall ? .4 : .2),
              height: maxWidth * (isXSmall ? .5 : .3),
              child: alreadyLoginSvg,
            ),
            content: Text(
              context.tr(alreadyLoggedInKey)!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            actions: [
              SizedBox(
                width: maxWidth * (isXSmall ? 1 : .5),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pushReplacementNamed(Routes.login);
                  },
                  child: Text(
                    context.tr(okayLbl)!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.surface,
                          fontWeight: FontWeights.semiBold,
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
