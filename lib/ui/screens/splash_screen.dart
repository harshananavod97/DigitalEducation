import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/gdpr_helper.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleUpAnimation;
  late Animation<double> _logoScaleDownAnimation;

  bool _systemConfigLoaded = false;

  final _appLogoPath = Assets.splashLogo;
  final _orgLogoPath = Assets.orgLogo;
  final showCompanyLogo = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchSystemConfig();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() {
        if (_logoAnimationController.isCompleted) {
          _navigateToNextScreen();
          // setState(() {});
        }
      });
    _logoScaleUpAnimation = Tween<double>(begin: 0, end: 1.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0, 0.4, curve: Curves.ease),
      ),
    );
    _logoScaleDownAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.4, 1, curve: Curves.easeInOut),
      ),
    );

    _logoAnimationController.forward();
  }

  Future<void> _initUnityAds() async {
    await UnityAds.init(
      gameId: context.read<SystemConfigCubit>().unityGameId,
      testMode: true,
      onComplete: () => log('Initialized', name: 'Unity Ads'),
      onFailed: (err, msg) =>
          log('Initialization Failed: $err $msg', name: 'Unity Ads'),
    );
  }

  Future<void> _fetchSystemConfig() async {
    await context.read<SystemConfigCubit>().getSystemConfig();
    await GdprHelper.initialize();
  }

  Future<void> _navigateToNextScreen() async {
    if (!_systemConfigLoaded) return;

    await _initUnityAds();

    final showIntroSlider =
        context.read<SettingsCubit>().state.settingsModel!.showIntroSlider;
    final currAuthState = context.read<AuthCubit>().state;

    if (showIntroSlider) {
      // if (context.read<SystemConfigCubit>().isLanguageModeEnabled) {
      //   await Navigator.of(context).pushReplacementNamed(Routes.languageSelect);
      // } else {
      await Navigator.of(context).pushReplacementNamed(Routes.introSlider);
      // }
      return;
    }

    if (currAuthState is Authenticated) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.home,
        arguments: false,
      );
    } else {
      await Navigator.of(context).pushReplacementNamed(
        Routes.home,
        arguments: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SystemConfigCubit, SystemConfigState>(
      bloc: context.read<SystemConfigCubit>(),
      listener: (context, state) {
        if (state is SystemConfigFetchSuccess) {
          if (!_systemConfigLoaded) {
            _systemConfigLoaded = true;
          }

          if (_logoAnimationController.isCompleted) {
            _navigateToNextScreen();
          }
        }
      },
      builder: (context, state) {
        if (state is SystemConfigFetchFailure) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              key: const Key('errorContainer'),
              child: ErrorContainer(
                showBackButton: true,
                errorMessageColor: Theme.of(context).colorScheme.onTertiary,
                errorMessage: convertErrorCodeToLanguageKey(state.errorCode),
                onTapRetry: () {
                  setState(_initAnimations);
                  _fetchSystemConfig();
                },
                showErrorImage: true,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
            child: Stack(
              children: [
                /// App Logo
                Align(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (_, __) => Transform.scale(
                        scale: _logoScaleUpAnimation.value -
                            _logoScaleDownAnimation.value,
                        child: QImage(
                          imageUrl: _appLogoPath,
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Organization Logo
                // if (showCompanyLogo) ...[
                //   Align(
                //     alignment: Alignment.bottomCenter,
                //     child: Padding(
                //       padding: const EdgeInsets.only(bottom: 22),
                //       child: QImage(imageUrl: _orgLogoPath),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        );
      },
    );
  }
}
