import 'dart:async';
import 'dart:math';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as tmp;

import '../../core/ad_callbacks.dart';
import '../../core/ads_base.dart';
import '../../core/log.dart';
import '../../models/ads_settings.dart';
import 'applovin_data.dart';

class ApplovinAD extends Ads {
  final ApplovinData _applovinData;

  ApplovinAD(this._applovinData, AdsSettings settings);

  Function? onRewarded;
  bool isRewardedVideoAvailable = false;
  bool isInterstitialVideoAvailable = false;
  var _interstitialRetryAttempt = 0;
  var _rewardedAdRetryAttempt = 0;

  @override
  Future<void> init() async {
    bool? isInitialized = await AppLovinMAX.isInitialized();
    if (isInitialized == null || !isInitialized) {
      await AppLovinMAX.initialize(_applovinData.sdkKey);
      Log.log('>> Applovin > init' + _applovinData.sdkKey);
    }
  }

  @override
  Future<void> loadAppOpenAd() async {
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (ad) {},
        onAdLoadFailedCallback: (adUnitId, error) {},
        onAdDisplayedCallback: (ad) {
          AdCallbacks.onAppOpenShown?.call();
        },
        onAdDisplayFailedCallback: (ad, error) {
          AppLovinMAX.loadAppOpenAd(_applovinData.openAdsId);
          _finishAppOpenPresentation();
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          AppLovinMAX.loadAppOpenAd(_applovinData.openAdsId);
          _finishAppOpenPresentation();
        },
        onAdRevenuePaidCallback: (ad) {},
      ),
    );
    AppLovinMAX.loadAppOpenAd(_applovinData.openAdsId);
  }

  @override
  bool showAdIfAvailableOpenAds() {
    unawaited(_showAppOpenIfReady());
    // AppLovin readiness is async; launch flow relies on [AdCallbacks].
    return false;
  }

  Future<void> _showAppOpenIfReady() async {
    final isReady = await AppLovinMAX.isAppOpenAdReady(
      _applovinData.openAdsId,
    );
    if (isReady == true) {
      AppLovinMAX.showAppOpenAd(_applovinData.openAdsId);
    } else {
      AppLovinMAX.loadAppOpenAd(_applovinData.openAdsId);
    }
  }

  void _finishAppOpenPresentation() {
    final done = AdCallbacks.onAppOpenDismissed;
    AdCallbacks.onAppOpenDismissed = null;
    done?.call();
  }

  // banner
  @override
  Future<void> loadBannerAd(Function? onLoaded, Key key) async {
    // AppLovinMAX.createBanner(
    //     _applovinData.bannerId, AdViewPosition.bottomCenter);
  }

  @override
  Widget getBannerAdWidget(Key key) {
    // AppLovinMAX.showBanner(_applovinData.bannerId);
    return MaxAdView(
      adUnitId: _applovinData.bannerId,
      adFormat: AdFormat.banner,
      listener: AdViewAdListener(
        onAdLoadedCallback: (ad) {
          Log.log('Banner widget ad loaded from ' + ad.networkName);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          Log.log(
            'Banner widget ad failed to load with error code ' +
                error.code.toString() +
                ' and message: ' +
                error.message,
          );
        },
        onAdClickedCallback: (ad) {
          Log.log('Banner widget ad clicked');
        },
        onAdExpandedCallback: (ad) {
          Log.log('Banner widget ad expanded');
        },
        onAdCollapsedCallback: (ad) {
          Log.log('Banner widget ad collapsed');
        },
      ),
    );
  }

  @override
  Future<void> disposeBanner(Key key) async {
    // AppLovinMAX.destroyBanner(_applovinData.bannerId);
    // AppLovinMAX.hideBanner(_applovinData.bannerId);
  }

  @override
  Future<void> loadNativeAd(
    Function? onLoaded,
    Key key,
    dynamic templateType,
  ) async {}

  @override
  Widget getNativeAdWidget(Key key, double height) {
    return Container();
  }

  Future<void> disposeNative(Key key) async {}

  // inter
  @override
  Future<void> loadInterstitialAd() async {
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) {
          Log.log('Interstitial ad loaded from ' + ad.networkName);
          _interstitialRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _interstitialRetryAttempt = _interstitialRetryAttempt + 1;
          int retryDelay = pow(2, min(6, _interstitialRetryAttempt)).toInt();
          Log.log(
            'Interstitial ad failed to load with code ' +
                error.code.toString() +
                ' - retrying in ' +
                retryDelay.toString() +
                's',
          );
          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadInterstitial(_applovinData.interId);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          loadInterstitialAd();
          isInterShowed = false;
          final done = AdCallbacks.onInterstitialDismissed;
          AdCallbacks.onInterstitialDismissed = null;
          done?.call();
        },
      ),
    );
    AppLovinMAX.loadInterstitial(_applovinData.interId);
  }

  @override
  Future<void> showInterstitialAd() async {
    Log.log(">> Applovin > loading inter");
    isInterstitialVideoAvailable =
        (await AppLovinMAX.isInterstitialReady(_applovinData.interId)) ?? false;
    if (isInterstitialVideoAvailable) {
      Log.log(">> Applovin > inter loaded");
      isInterShowed = true;
      AppLovinMAX.showInterstitial(_applovinData.interId);
      loadInterstitialAd();
    } else {
      loadInterstitialAd();
      isInterShowed = false;
      final done = AdCallbacks.onInterstitialDismissed;
      AdCallbacks.onInterstitialDismissed = null;
      done?.call();
    }
  }

  // reward
  @override
  Future<void> loadRewardAd() async {
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (ad) {
          Log.log('Rewarded ad loaded from ' + ad.networkName);
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;
          int retryDelay = pow(2, min(6, _rewardedAdRetryAttempt)).toInt();
          Log.log(
            'Rewarded ad failed to load with code ' +
                error.code.toString() +
                ' - retrying in ' +
                retryDelay.toString() +
                's',
          );
          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(_applovinData.rewardId);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {
          isInterShowed = false;
          final callback = onRewarded;
          onRewarded = null;
          if (callback != null) completeRewardCallback(callback);
          loadRewardAd();
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          isInterShowed = false;
          final callback = onRewarded;
          onRewarded = null;
          if (callback != null) completeRewardCallback(callback);
          loadRewardAd();
        },
        onAdReceivedRewardCallback: (ad, reward) {},
      ),
    );
    AppLovinMAX.loadRewardedAd(_applovinData.rewardId);
  }

  @override
  void showRewardAd(Function rewarded) async {
    isRewardedVideoAvailable =
        (await AppLovinMAX.isRewardedAdReady(_applovinData.rewardId)) ?? false;
    Log.log(">> Applovin > loading reward: $isRewardedVideoAvailable");
    if (isRewardedVideoAvailable) {
      // Assign before show so onAdHidden always has the navigation callback.
      onRewarded = rewarded;
      isInterShowed = true;
      AppLovinMAX.showRewardedAd(_applovinData.rewardId);
    } else {
      loadRewardAd();
      completeRewardCallback(rewarded);
    }
  }
}
