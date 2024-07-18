import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppContainer extends StatelessWidget {
  const UpdateAppContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: UiUtils.dialogBlurSigma,
        sigmaY: UiUtils.dialogBlurSigma,
      ),
      child: Container(
        color: Colors.black45,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: CupertinoAlertDialog(
          title: Text(
            context.tr(warningKey)!,
            style: const TextStyle(fontSize: 18),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              context.tr(updateApplicationKey)!,
              style: const TextStyle(fontSize: 14.5),
            ),
          ),
          actions: [
            //CustomRoundedButton(widthPercentage: 0.5, backgroundColor: Theme., buttonTitle: buttonTitle, radius: radius, showBorder: showBorder, height: height,),
            CupertinoButton(
              onPressed: () async {
                try {
                  final url = context.read<SystemConfigCubit>().appUrl;
                  if (url.isEmpty) {
                    UiUtils.showSnackBar(
                      context.tr(failedToGetAppUrlKey)!,
                      context,
                    );

                    return;
                  }
                  final canLaunch = await canLaunchUrl(Uri.parse(url));
                  if (canLaunch) {
                    await launchUrl(Uri.parse(url));
                  }
                } catch (e) {
                  UiUtils.showSnackBar(
                    context.tr(failedToGetAppUrlKey)!,
                    context,
                  );
                }
              },
              child: Text(
                context.tr(updateKey)!,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
