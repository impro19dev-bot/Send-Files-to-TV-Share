import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../../core/ad_callbacks.dart';
import '../../core/ads_base.dart';
import '../../core/log.dart';
import '../../models/multiads_config.dart';
import 'ironsource_data.dart';

class IronsourceAD extends Ads {
  final IronsourceData _data;
  final MultiAdsConfig _config;

  IronsourceAD(this._data, this._config);

  LevelPlayInterstitialAd? _interstitialAd;
  LevelPlayRewardedAd? _rewardedAd;
  Function? _onRewarded;

  final _bannerReady = <Key, bool>{};
  final _bannerWidgets = <Key, Widget>{};
  final _bannerViewKeys = <Key, GlobalKey<LevelPlayBannerAdViewState>>{};

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized || _data.appKey.isEmpty) {
      Log.log('IronSource >> skip init (already done or missing app_key)');
      return;
    }

    try {
      if (_config.enableLogs) {
        await LevelPlay.setAdaptersDebug(true);
      }
      // LevelPlay 9.2 API (9.3+ renames this to setGDPRConsent).
      await LevelPlayPrivacySettings.setGDPRConsents({
        'ironSource': true,
      });

      final completer = Completer<void>();
      final request = LevelPlayInitRequest.builder(_data.appKey).build();
      await LevelPlay.init(
        initRequest: request,
        initListener: _InitListener(
          onSuccess: () {
            Log.log('IronSource >> initialized');
            if (!completer.isCompleted) completer.complete();
          },
          onFailed: (error) {
            Log.log('IronSource >> init failed: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await completer.future;
      _initialized = true;
    } catch (e) {
      Log.log('IronSource >> init error: $e');
    }
  }

  @override
  Future<void> loadAppOpenAd() async {
    Log.log('IronSource >> App Open Ads not supported');
  }

  @override
  bool showAdIfAvailableOpenAds() {
    Log.log('IronSource >> App Open Ads not supported');
    return false;
  }

  @override
  Future<void> loadBannerAd(Function? onLoaded, Key key) async {
    if (_data.bannerId.isEmpty) {
      Log.log('IronSource >> No banner ID');
      return;
    }
    _bannerReady[key] = true;
    onLoaded?.call();
  }

  @override
  Widget getBannerAdWidget(Key key) {
    if (_bannerReady[key] != true) return const SizedBox.shrink();
    return _bannerWidgets.putIfAbsent(key, () {
      final bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
      _bannerViewKeys[key] = bannerKey;
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: LevelPlayBannerAdView(
          key: bannerKey,
          adUnitId: _data.bannerId,
          adSize: LevelPlayAdSize.BANNER,
          listener: _BannerListener(),
          onPlatformViewCreated: () {
            bannerKey.currentState?.loadAd();
          },
        ),
      );
    });
  }

  @override
  Future<void> disposeBanner(Key key) async {
    _bannerViewKeys[key]?.currentState?.destroy();
    _bannerViewKeys.remove(key);
    _bannerWidgets.remove(key);
    _bannerReady.remove(key);
    Log.log('IronSource >> Banner disposed');
  }

  @override
  Future<void> loadInterstitialAd() async {
    if (_data.interId.isEmpty) {
      Log.log('IronSource >> No interstitial ID');
      return;
    }

    _interstitialAd = LevelPlayInterstitialAd(adUnitId: _data.interId);
    _interstitialAd!.setListener(
      _InterstitialListener(
        onClosed: _finishInterstitialAndReload,
        onFailedToShow: _finishInterstitialAndReload,
      ),
    );
    _interstitialAd!.loadAd();
    Log.log('IronSource >> Loading interstitial: ${_data.interId}');
  }

  @override
  void showInterstitialAd() {
    unawaited(_showInterstitialAd());
  }

  Future<void> _showInterstitialAd() async {
    final ad = _interstitialAd;
    final ready = ad != null && await ad.isAdReady();
    if (!ready) {
      Log.log('IronSource >> Interstitial not ready');
      loadInterstitialAd();
      _finishInterstitial();
      return;
    }

    isInterShowed = true;
    ad.showAd();
  }

  void _finishInterstitial() {
    isInterShowed = false;
    final done = AdCallbacks.onInterstitialDismissed;
    AdCallbacks.onInterstitialDismissed = null;
    done?.call();
  }

  void _finishInterstitialAndReload() {
    _finishInterstitial();
    loadInterstitialAd();
  }

  @override
  Future<void> loadRewardAd() async {
    if (_data.rewardId.isEmpty) {
      Log.log('IronSource >> No rewarded ID');
      return;
    }

    _rewardedAd = LevelPlayRewardedAd(adUnitId: _data.rewardId);
    _rewardedAd!.setListener(
      _RewardedListener(
        onClosed: () {
          final rewarded = _onRewarded;
          _onRewarded = null;
          isInterShowed = false;
          if (rewarded != null) completeRewardCallback(rewarded);
          loadRewardAd();
        },
        onFailedToShow: () {
          final rewarded = _onRewarded;
          _onRewarded = null;
          isInterShowed = false;
          if (rewarded != null) completeRewardCallback(rewarded);
          loadRewardAd();
        },
      ),
    );
    _rewardedAd!.loadAd();
    Log.log('IronSource >> Loading rewarded: ${_data.rewardId}');
  }

  @override
  void showRewardAd(Function rewarded) {
    unawaited(_showRewardAd(rewarded));
  }

  Future<void> _showRewardAd(Function rewarded) async {
    final ad = _rewardedAd;
    final ready = ad != null && await ad.isAdReady();
    if (!ready) {
      Log.log('IronSource >> Rewarded not ready');
      loadRewardAd();
      completeRewardCallback(rewarded);
      return;
    }

    _onRewarded = rewarded;
    isInterShowed = true;
    ad.showAd();
  }

  @override
  Future<void> loadNativeAd(
    Function? onLoaded,
    Key key,
    dynamic templateType,
  ) async {}

  @override
  Widget getNativeAdWidget(Key key, double height) => const SizedBox.shrink();

  @override
  Future<void> disposeNative(Key key) async {}
}

class _InitListener implements LevelPlayInitListener {
  final VoidCallback onSuccess;
  final void Function(Object error) onFailed;

  _InitListener({required this.onSuccess, required this.onFailed});

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) => onSuccess();

  @override
  void onInitFailed(LevelPlayInitError error) => onFailed(error);
}

class _InterstitialListener implements LevelPlayInterstitialAdListener {
  final VoidCallback onClosed;
  final VoidCallback onFailedToShow;

  _InterstitialListener({
    required this.onClosed,
    required this.onFailedToShow,
  });

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    Log.log('IronSource >> Interstitial loaded');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    Log.log('IronSource >> Interstitial load failed: $error');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    Log.log('IronSource >> Interstitial show failed: $error');
    onFailedToShow();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) => onClosed();

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

class _RewardedListener implements LevelPlayRewardedAdListener {
  final VoidCallback onClosed;
  final VoidCallback onFailedToShow;

  _RewardedListener({
    required this.onClosed,
    required this.onFailedToShow,
  });

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    Log.log('IronSource >> Rewarded loaded');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    Log.log('IronSource >> Rewarded load failed: $error');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    Log.log('IronSource >> Rewarded show failed: $error');
    onFailedToShow();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) => onClosed();

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {}
}

class _BannerListener implements LevelPlayBannerAdViewListener {
  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    Log.log('IronSource >> Banner loaded');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    Log.log('IronSource >> Banner load failed: $error');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}
}
