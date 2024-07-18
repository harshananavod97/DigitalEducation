import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';

Future<void> showLoginDialog(
  BuildContext context, {
  required VoidCallback onTapYes,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _LoginDialogWidget(onTapYesButton: onTapYes),
  );
}

class _LoginDialogWidget extends StatelessWidget {
  const _LoginDialogWidget({required this.onTapYesButton});

  final VoidCallback onTapYesButton;

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = TextStyle(
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeights.medium,
      fontSize: 16,
    );
    final contentTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onTertiary,
      fontSize: 18,
      fontWeight: FontWeights.regular,
    );

    return AlertDialog(
      content: Text(context.tr('guestMode')!, style: contentTextStyle),
      actions: [
        CupertinoButton(
          onPressed: Navigator.of(context).pop,
          child: Text(context.tr('cancel')!, style: buttonTextStyle),
        ),
        CupertinoButton(
          onPressed: onTapYesButton,
          child: Text(context.tr('loginLbl')!, style: buttonTextStyle),
        ),
      ],
    );
  }
}
