import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class ExitGameDialog extends StatelessWidget {
  const ExitGameDialog({super.key, this.onTapYes});

  final VoidCallback? onTapYes;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.nunito(
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.transparent,
      content: Text(
        context.tr('quizExitLbl')!,
        style: textStyle,
      ),
      actions: [
        CupertinoButton(
          child: Text(
            context.tr('yesBtn')!,
            style: textStyle,
          ),
          onPressed: () {
            if (onTapYes != null) {
              onTapYes!();
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
        ),
        CupertinoButton(
          onPressed: Navigator.of(context).pop,
          child: Text(
            context.tr('noBtn')!,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
