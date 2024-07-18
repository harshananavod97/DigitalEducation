import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSliderScreen>
    with TickerProviderStateMixin {
  int sliderIndex = 0;

  late AnimationController buttonController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late Animation<double> buttonSqueezeAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: buttonController,
      curve: Curves.easeInOut,
    ),
  );

  late AnimationController imageSlideAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);
  late Animation<Offset> imageSlideAnimation =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.025)).animate(
    CurvedAnimation(
      parent: imageSlideAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  late final List<({String image, String title, String desc})> slideList = [
    (
      image: Assets.onboardingA,
      title: context.tr('title1')!,
      desc: context.tr('description1')!,
    ),
    (
      image: Assets.onboardingB,
      title: context.tr('title2')!,
      desc: context.tr('description2')!,
    ),
    (
      image: Assets.onboardingC,
      title: context.tr('title3')!,
      desc: context.tr('description3')!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    buttonController.forward();
  }

  @override
  void dispose() {
    buttonController.dispose();
    imageSlideAnimationController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) => setState(() {
        sliderIndex = index;
      });

  Widget _buildPageIndicatorNew() {
    const indicatorWidth = 8.0;
    const indicatorHeight = 8.0;
    const selectedIndicatorWidth = 8.0 * 3;
    final borderRadius = BorderRadius.circular(4);
    final secondaryColor = Theme.of(context).primaryColor;
    const duration = Duration(milliseconds: 150);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: duration,
          height: indicatorHeight,
          width: sliderIndex == 0 ? selectedIndicatorWidth : indicatorWidth,
          decoration: BoxDecoration(
            color: sliderIndex == 0
                ? secondaryColor
                : secondaryColor.withOpacity(0.5),
            borderRadius: borderRadius,
          ),
        ),
        const SizedBox(width: 3),
        AnimatedContainer(
          duration: duration,
          height: indicatorHeight,
          width: sliderIndex == 1 ? selectedIndicatorWidth : indicatorWidth,
          decoration: BoxDecoration(
            color: sliderIndex == 1
                ? secondaryColor
                : secondaryColor.withOpacity(0.5),
            borderRadius: borderRadius,
          ),
        ),
        const SizedBox(width: 3),
        AnimatedContainer(
          duration: duration,
          height: indicatorHeight,
          width: sliderIndex == 2 ? selectedIndicatorWidth : indicatorWidth,
          decoration: BoxDecoration(
            color: sliderIndex == 2
                ? secondaryColor
                : secondaryColor.withOpacity(0.5),
            borderRadius: borderRadius,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroSlider() {
    return PageView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: imageSlideAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * (0.4),
                alignment: Alignment.center,
                child: QImage(imageUrl: slideList[index].image),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .01),
            Text(
              slideList[index].title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 22,
                fontWeight: FontWeights.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .0175),
            SizedBox(
              height: 58,
              width: MediaQuery.of(context).size.width * .8,
              child: Text(
                slideList[index].desc,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeights.medium,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
      itemCount: slideList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            color: Theme.of(context).primaryColor,
          ),
          Container(
            height: size.height * 0.75,
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: _buildIntroSlider(),
          ),
          Container(
            width: size.width,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.shortestSide * 0.12,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPageIndicatorNew(),
                AnimatedBuilder(
                  builder: (context, child) => Transform.scale(
                    scale: buttonSqueezeAnimation.value,
                    child: child,
                  ),
                  animation: buttonController,
                  child: InkWell(
                    onTap: () {
                      context.read<SettingsCubit>().changeShowIntroSlider();
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.home, arguments: true);
                    },
                    child: Text(
                      context.tr('skip')!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeights.regular,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                context.read<SettingsCubit>().changeShowIntroSlider();
                Navigator.of(context)
                    .pushReplacementNamed(Routes.home, arguments: true);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: size.height * 0.10),
                height: 50,
                width: size.width * 0.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    context.tr('getStarted')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 22,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
