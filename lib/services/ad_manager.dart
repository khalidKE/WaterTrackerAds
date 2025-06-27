import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdManager {
  // Banner Ad
  BannerAd? bannerAd;
  bool isBannerLoaded = false;

  // Rewarded Interstitial Ad
  RewardedInterstitialAd? rewardedInterstitialAd;
  bool isRewardedInterstitialLoaded = false;

  // Native/Content Ad (using NativeAd)
  NativeAd? nativeAd;
  bool isNativeLoaded = false;

  // Singleton
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Banner Ad Unit ID
  final String bannerAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-8639311525630636/3338897592'
          : 'ca-app-pub-8639311525630636/3338897592';

  // Rewarded Interstitial Ad Unit ID
  final String rewardedInterstitialAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-8639311525630636/4786651148'
          : 'ca-app-pub-8639311525630636/4786651148';

  // Native/Content Ad Unit ID
  final String nativeAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-8639311525630636/4728014197'
          : 'ca-app-pub-8639311525630636/4728014197';

  void loadBannerAd(VoidCallback onLoaded) {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
        },
      ),
    )..load();
  }

  void loadRewardedInterstitialAd(VoidCallback onLoaded) {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedInterstitialAd = ad;
          isRewardedInterstitialLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (error) {
          isRewardedInterstitialLoaded = false;
        },
      ),
    );
  }

  void showRewardedInterstitialAd(BuildContext context, {required VoidCallback onRewarded}) {
    if (rewardedInterstitialAd != null) {
      rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          isRewardedInterstitialLoaded = false;
          loadRewardedInterstitialAd(() {});
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          isRewardedInterstitialLoaded = false;
          loadRewardedInterstitialAd(() {});
        },
      );
      rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );
      rewardedInterstitialAd = null;
    }
  }

  void loadNativeAd(VoidCallback onLoaded) {
    nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'listTile', // You need to register this factory in main.dart
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          isNativeLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isNativeLoaded = false;
        },
      ),
    )..load();
  }

  void disposeAds() {
    bannerAd?.dispose();
    rewardedInterstitialAd?.dispose();
    nativeAd?.dispose();
  }
} 