import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';

/// Renders a premium category access badge icon.
///
/// Parameters:
/// - [isPremium] - Bool indicating if category is premium.
/// - [hasUnlocked] - Bool indicating if premium category is unlocked.
///
class PremiumCategoryAccessBadge extends StatelessWidget {
  const PremiumCategoryAccessBadge({
    required this.hasUnlocked,
    required this.isPremium,
    super.key,
  });

  final bool isPremium;
  final bool hasUnlocked;

  static const _premiumIconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return isPremium && !hasUnlocked
        ? const QImage(
            imageUrl: Assets.premiumIcon,
            width: _premiumIconSize,
            height: _premiumIconSize,
          )
        : const SizedBox.shrink();
  }
}
