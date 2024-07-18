import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const QImage(
      imageUrl: Assets.appLogo,
      height: 80,
      width: 168,
    );
  }
}
