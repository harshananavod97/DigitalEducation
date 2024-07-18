import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';

class BadgesIconContainer extends StatelessWidget {
  const BadgesIconContainer({
    required this.badge,
    required this.constraints,
    required this.addTopPadding,
    super.key,
  });

  final Badges badge;
  final BoxConstraints constraints;
  final bool addTopPadding;

  static const _greyscale = ColorFilter.matrix([
    .3,
    .59,
    .11,
    .0,
    .0,
    .3,
    .59,
    .11,
    .0,
    .0,
    .3,
    .59,
    .11,
    .0,
    .0,
    .0,
    .0,
    .0,
    1.0,
    .0,
  ]);

  @override
  Widget build(BuildContext context) {
    final hexagon = SvgPicture.asset(Assets.hexagon);

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.095 : 0),
            ),
            child: SizedBox(
              width: constraints.maxWidth * (0.775),
              height: constraints.maxHeight * (0.5),
              child: badge.status == '0'
                  ? ColorFiltered(colorFilter: _greyscale, child: hexagon)
                  : hexagon,
            ),
          ),
        ),
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight *
                  (addTopPadding
                      ? 0.100
                      : 0), //outer hexagon top padding + difference of inner and outer height
            ),
            child: SizedBox(
              width: constraints.maxWidth * (0.725),
              height: constraints.maxHeight * (0.5),
              child: Padding(
                padding: const EdgeInsets.all(12.5),
                child: CachedNetworkImage(imageUrl: badge.badgeIcon),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
