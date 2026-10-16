import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multiads/multiads.dart';

import '../util/global.dart';
import 'interstitial_back_scope.dart';

/// Thin helpers around [gAds]. Ads never block core navigation when missing.
abstract final class AdsActions {
  static void registerCallbacks() {
    AdCallbacks.onInterstitialDismissed = () {
      isInterShowed = false;
    };
  }

  /// Shows an app-open ad during the opening splash, then calls [onFinished].
  static Future<void> showAppOpenOnLaunch({
    required VoidCallback onFinished,
    Duration maxWaitToShow = const Duration(seconds: 3),
  }) async {
    final ads = gAds;
    if (!gAdsReady ||
        ads == null ||
        !ads.hasAppOpen ||
        appOpenShownThisSession) {
      onFinished();
      return;
    }

    appOpenShownThisSession = true;
    var finished = false;
    var adShown = false;

    void finish() {
      if (finished) return;
      finished = true;
      AdCallbacks.onAppOpenShown = null;
      AdCallbacks.onAppOpenDismissed = null;
      onFinished();
    }

    AdCallbacks.onAppOpenShown = () => adShown = true;
    AdCallbacks.onAppOpenDismissed = finish;

    try {
      final deadline = DateTime.now().add(maxWaitToShow);
      while (!adShown && DateTime.now().isBefore(deadline)) {
        ads.openAdsInstance.showAdIfAvailableOpenAds();
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }

      if (!adShown) {
        finish();
        return;
      }

      Timer(const Duration(seconds: 45), finish);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('App Open skipped: $e\n$st');
      }
      finish();
    }
  }

  /// Runs [onContinue] after a rewarded ad, or immediately if unavailable.
  static void showRewardedThen(VoidCallback onContinue) {
    final ads = gAds;
    if (!pastSplash ||
        !gAdsReady ||
        ads == null ||
        !ads.hasRewarded ||
        isInterShowed) {
      onContinue();
      return;
    }

    var finished = false;
    void finish() {
      if (finished) return;
      finished = true;
      isInterShowed = false;
      // Defer navigation until after the ad UI has fully torn down.
      WidgetsBinding.instance.addPostFrameCallback((_) => onContinue());
    }

    try {
      ads.rewardInstance.showRewardAd((_) => finish());
      // Safety net if the SDK never invokes the completion callback.
      Timer(const Duration(seconds: 90), finish);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Rewarded skipped: $e\n$st');
      }
      finish();
    }
  }

  /// Runs [onContinue] after an interstitial, or immediately if unavailable.
  static void showInterstitialThen(VoidCallback onContinue) {
    final ads = gAds;
    if (!pastSplash ||
        !gAdsReady ||
        ads == null ||
        !ads.hasInterstitials ||
        isInterShowed) {
      onContinue();
      return;
    }

    showInterstitial(onDismissed: onContinue);
  }

  static void showInterstitial({VoidCallback? onDismissed}) {
    final ads = gAds;
    if (!gAdsReady || ads == null || !ads.hasInterstitials || isInterShowed) {
      onDismissed?.call();
      return;
    }

    try {
      isInterShowed = true;
      AdCallbacks.onInterstitialDismissed = () {
        isInterShowed = false;
        onDismissed?.call();
      };
      ads.interInstance.showInterstitialAd();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Interstitial skipped: $e\n$st');
      }
      isInterShowed = false;
      onDismissed?.call();
    }
  }

  static Widget bannerOrEmpty(Key key) {
    final ads = gAds;
    if (!pastSplash || !gAdsReady || ads == null || !ads.hasBanners) {
      return const SizedBox.shrink();
    }
    return ads.bannerInstance.getBannerAdWidget(key);
  }

  static Future<void> loadBanner(Key key, {VoidCallback? onLoaded}) async {
    final ads = gAds;
    if (!pastSplash || !gAdsReady || ads == null || !ads.hasBanners) return;
    try {
      await ads.bannerInstance.loadBannerAd(onLoaded, key);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Banner load skipped: $e\n$st');
      }
    }
  }

  static Future<void> disposeBanner(Key key) async {
    final ads = gAds;
    if (!gAdsReady || ads == null || !ads.hasBanners) return;
    try {
      await ads.bannerInstance.disposeBanner(key);
    } catch (_) {}
  }

  static void pushRewarded(BuildContext context, Widget screen) {
    showRewardedThen(() {
      if (!context.mounted) return;
      Navigator.of(context).push(_route(screen));
    });
  }

  static void pushInterstitial(BuildContext context, Widget screen) {
    showInterstitialThen(() {
      if (!context.mounted) return;
      Navigator.of(context).push(_route(screen));
    });
  }

  static void popWithInterstitial(BuildContext context, [Object? result]) {
    showInterstitialThen(() {
      if (!context.mounted) return;
      Navigator.of(context).pop(result);
    });
  }

  static MaterialPageRoute<void> _route(Widget screen) {
    return MaterialPageRoute<void>(
      builder: (_) => InterstitialBackScope(child: screen),
    );
  }
}
