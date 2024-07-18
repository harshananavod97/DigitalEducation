import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

abstract class InterstitialAdState {}

class InterstitialAdInitial extends InterstitialAdState {}

class InterstitialAdLoaded extends InterstitialAdState {}

class InterstitialAdLoadInProgress extends InterstitialAdState {}

class InterstitialAdFailToLoad extends InterstitialAdState {}

class InterstitialAdCubit extends Cubit<InterstitialAdState> {
  InterstitialAdCubit() : super(InterstitialAdInitial());

  InterstitialAd? _interstitialAd;

  InterstitialAd? get interstitialAd => _interstitialAd;

  void _createGoogleInterstitialAd(BuildContext context) {
    InterstitialAd.load(
      adUnitId: context.read<SystemConfigCubit>().googleInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          emit(InterstitialAdLoaded());
        },
        onAdFailedToLoad: (err) {
          emit(InterstitialAdFailToLoad());
        },
      ),
    );
  }

  void _createUnityAds() {
    UnityAds.load(
      placementId: unityInterstitialPlacement(),
      onComplete: (placementId) => emit(InterstitialAdLoaded()),
      onFailed: (placementId, err, msg) => emit(InterstitialAdFailToLoad()),
    );
  }

  void createInterstitialAd(BuildContext context) {
    final systemConfigCubit = context.read<SystemConfigCubit>();
    if (systemConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      emit(InterstitialAdLoadInProgress());
      final adsType = systemConfigCubit.adsType;
      if (adsType == 1) {
        _createGoogleInterstitialAd(context);
      } else {
        _createUnityAds();
      }
    }
  }

  void showAd(BuildContext context) {
    //if ad is enable
    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      //if ad loaded succesfully
      if (state is InterstitialAdLoaded) {
        //show google interstitial ad
        if (sysConfigCubit.adsType == 1) {
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {},
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              createInterstitialAd(context);
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              createInterstitialAd(context);
            },
          );
          interstitialAd?.show();
        } else {
          //show Unity interstitial ad
          UnityAds.showVideoAd(
            placementId: unityInterstitialPlacement(),
            onComplete: (placementId) => createInterstitialAd(context),
            onFailed: (placementId, error, message) =>
                log('Video Ad $placementId failed: $error $message'),
            onStart: (placementId) => log('Video Ad $placementId started'),
            onClick: (placementId) => log('Video Ad $placementId click'),
            onSkipped: (placementId) => createInterstitialAd(context),
          );
        }
      } else if (state is InterstitialAdFailToLoad) {
        createInterstitialAd(context);
      }
    }
  }

  String unityInterstitialPlacement() {
    if (Platform.isAndroid) {
      return 'Interstitial_Android';
    }
    if (Platform.isIOS) {
      return 'Interstitial_iOS';
    }

    return '';
  }

  @override
  Future<void> close() async {
    await _interstitialAd?.dispose();

    return super.close();
  }
}
