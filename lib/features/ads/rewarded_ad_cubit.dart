import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// TODO(J): watching Unity Video Ad crashes the app. check after updating unity dependency to latest.
abstract class RewardedAdState {}

class RewardedAdInitial extends RewardedAdState {}

class RewardedAdLoaded extends RewardedAdState {}

class RewardedAdLoadInProgress extends RewardedAdState {}

class RewardedAdFailure extends RewardedAdState {}

class RewardedAdCubit extends Cubit<RewardedAdState> {
  RewardedAdCubit() : super(RewardedAdInitial());

  RewardedAd? _rewardedAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  void _createGoogleRewardedAd(BuildContext context) {
    //dispose ad and then load
    _rewardedAd?.dispose();
    RewardedAd.load(
      adUnitId: context.read<SystemConfigCubit>().googleRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdFailedToLoad: (error) {
          log(error.message, name: 'Create Google Ads');
          emit(RewardedAdFailure());
        },
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          emit(RewardedAdLoaded());
        },
      ),
    );
  }

  void createUnityRewardsAd() {
    UnityAds.load(
      placementId: unityRewardsPlacement(),
      onComplete: (placementId) => emit(RewardedAdLoaded()),
      onFailed: (p, e, m) => emit(RewardedAdFailure()),
    );
  }

  void createRewardedAd(BuildContext context) {
    emit(RewardedAdLoadInProgress());

    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (sysConfigCubit.adsType == 1) {
        _createGoogleRewardedAd(context);
      } else {
        createUnityRewardsAd();
      }
    }
  }

  Future<void> createDailyRewardAd(BuildContext context) async {
    emit(RewardedAdLoadInProgress());

    final sysConfig = context.read<SystemConfigCubit>();
    if (sysConfig.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (sysConfig.adsType == 1) {
        _createGoogleRewardedAd(context);
      } else {
        createUnityRewardsAd();
      }
    }
  }

  Future<void> showDailyAd({required BuildContext context}) async {
    final sysConfigCubit = context.read<SystemConfigCubit>();
    final userDetails = context.read<UserDetailsCubit>();

    if (sysConfigCubit.isAdsEnable && state is RewardedAdLoaded) {
      ///
      if (sysConfigCubit.adsType == 1) {
        _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) async {
            // await ad.dispose();
            await createDailyRewardAd(context);
          },
          onAdFailedToShowFullScreenContent: (ad, error) async {
            await ad.dispose();
            emit(RewardedAdFailure());
          },
        );
        await rewardedAd?.show(
          onUserEarnedReward: (_, __) {
            userDetails.watchedDailyAd().then((_) async {
              await context.read<UserDetailsCubit>().fetchUserDetails();

              if (!context.mounted) return;

              UiUtils.showSnackBar(
                "${context.tr("earnedLbl")!} "
                '${sysConfigCubit.coinsPerDailyAdView} '
                "${context.tr("coinsLbl")!}",
                context,
                duration: const Duration(seconds: 2),
              );
            }).catchError((dynamic e) {
              if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
                UiUtils.showSnackBar(
                  context.tr('dailyAdsLimitExceeded')!,
                  context,
                );
              }
            });
          },
        );
      } else {
        await UnityAds.showVideoAd(
          placementId: unityRewardsPlacement(),
          onComplete: (_) async {
            await userDetails.watchedDailyAd().then((_) async {
              await context.read<UserDetailsCubit>().fetchUserDetails();

              if (!context.mounted) return;

              UiUtils.showSnackBar(
                "${context.tr("earnedLbl")!} "
                '${sysConfigCubit.coinsPerDailyAdView} '
                "${context.tr("coinsLbl")!}",
                context,
                duration: const Duration(seconds: 2),
              );
            }).catchError((dynamic e) {
              if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
                UiUtils.showSnackBar(
                  context.tr('dailyAdsLimitExceeded')!,
                  context,
                );
              }
            });
            log('Watched Daily Ad', name: 'Admob Ads');

            return createDailyRewardAd(context);
          },
        );
      }
    } else if (state is RewardedAdFailure) {
      await createDailyRewardAd(context);
    }
  }

  void showAd({
    required VoidCallback onAdDismissedCallback,
    required BuildContext context,
  }) {
    //if ads is enable
    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (state is RewardedAdLoaded) {
        //if google ad is enable
        if (sysConfigCubit.adsType == 1) {
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissedCallback();
              createRewardedAd(context);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              //need to show this reason to user
              emit(RewardedAdFailure());
              createRewardedAd(context);
            },
          );
          rewardedAd?.show(onUserEarnedReward: (_, __) => {});
        } else {
          UnityAds.showVideoAd(
            placementId: unityRewardsPlacement(),
            onComplete: (placementId) {
              onAdDismissedCallback();
              createRewardedAd(context);
            },
            onFailed: (placementId, error, message) =>
                log('Video Ad $placementId failed: $error $message'),
            onStart: (placementId) => log('Video Ad $placementId started'),
            onClick: (placementId) => log('Video Ad $placementId click'),
          );
        }
      } else if (state is RewardedAdFailure) {
        //create reward ad if ad is not loaded successfully
        createRewardedAd(context);
      }
    }
  }

  String unityRewardsPlacement() {
    if (Platform.isAndroid) {
      return 'Rewarded_Android';
    }
    if (Platform.isIOS) {
      return 'Rewarded_iOS';
    }

    return '';
  }

  @override
  Future<void> close() async {
    await _rewardedAd?.dispose();
    return super.close();
  }
}
