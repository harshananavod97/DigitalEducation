import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/extensions.dart';

class WatchRewardAdDialog extends StatelessWidget {
  const WatchRewardAdDialog({
    required this.onTapYesButton,
    super.key,
    this.onTapNoButton,
  });

  final VoidCallback onTapYesButton;
  final VoidCallback? onTapNoButton;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shadowColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: Text(
        context.tr('showAdsLbl')!,
      ),
      actions: [
        CupertinoButton(
          onPressed: () {
            onTapYesButton();
            Navigator.pop(context);
          },
          child: Text(
            context.tr('yesBtn')!,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        CupertinoButton(
          onPressed: () {
            if (onTapNoButton != null) {
              onTapNoButton!();
              return;
            }
            Navigator.pop(context);
          },
          child: Text(
            context.tr('noBtn')!,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
