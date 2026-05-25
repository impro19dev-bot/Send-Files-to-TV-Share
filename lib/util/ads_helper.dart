import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multiads/multiads.dart';

import 'global.dart';

/// Seconds the app must stay in the background before an app-open ad on resume.
const int kOpenAdBackgroundSeconds = 30;

/// Minimum seconds between any two app-open impressions (prevents back-to-back).
const int kOpenAdMinIntervalSeconds = 30;

// ─── App open timing ─────────────────────────────────────────────────────────

/// Controls when app-open ads may show (cold start → home, or return from background).
class OpenAdGate {
  OpenAdGate._();

  static bool _beforeHomePending = false;
  static bool _beforeHomeShown = false;
  static DateTime? _appStartedAt;
  static DateTime? _backgroundedAt;
  static bool _wentToBackground = false;
  static DateTime? _lastOpenAdShownAt;
  static bool _openAdOnScreen = false;

  static void markAppStarted() {
    _appStartedAt = DateTime.now();
  }

  /// Call when navigating to [MainShell] (after splash / onboarding).
  static void scheduleBeforeHome() {
    _beforeHomePending = true;
  }

  /// At most one app-open ad when home first appears (cold start / post-onboarding).
  static void showBeforeHomeOnce() {
    if (!_beforeHomePending || _beforeHomeShown) return;
    if (!_mayShowAnotherOpenAd()) return;
    _beforeHomePending = false;
    _beforeHomeShown = true;
    _showOpenAd();
  }

  /// User sent the app to background (not an in-app full-screen ad).
  static void onPaused() {
    if (_openAdOnScreen || isInterShowed) return;
    _backgroundedAt = DateTime.now();
    _wentToBackground = true;
  }

  /// User returned to the app; show open ad only after real background time.
  static void onResumed() {
    if (_openAdOnScreen) {
      _openAdOnScreen = false;
      _wentToBackground = false;
      _backgroundedAt = null;
      return;
    }
    if (isInterShowed) {
      _wentToBackground = false;
      _backgroundedAt = null;
      return;
    }
    if (!_wentToBackground || _backgroundedAt == null) return;
    if (_inLaunchGracePeriod()) {
      _wentToBackground = false;
      _backgroundedAt = null;
      return;
    }

    final elapsed = DateTime.now().difference(_backgroundedAt!);
    _wentToBackground = false;
    _backgroundedAt = null;

    if (elapsed.inSeconds < kOpenAdBackgroundSeconds) return;
    if (!_mayShowAnotherOpenAd()) return;
    _showOpenAd();
  }

  static bool _inLaunchGracePeriod() {
    final started = _appStartedAt;
    if (started == null) return false;
    return DateTime.now().difference(started).inSeconds < 15;
  }

  static bool _mayShowAnotherOpenAd() {
    final last = _lastOpenAdShownAt;
    if (last == null) return true;
    return DateTime.now().difference(last).inSeconds >=
        kOpenAdMinIntervalSeconds;
  }

  static void _showOpenAd() {
    if (!gAdsReady || !gAds.hasAppOpen) return;
    _lastOpenAdShownAt = DateTime.now();
    _openAdOnScreen = true;
    gAds.openAdsInstance.showAdIfAvailableOpenAds();
    // If nothing was loaded, AdMob returns immediately — clear overlay flag.
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (_openAdOnScreen && !isInterShowed) {
        _openAdOnScreen = false;
      }
    });
  }
}

// ─── Rewarded / interstitial ─────────────────────────────────────────────────

/// Shows a rewarded ad, then runs [action] when the ad closes (or immediately if ads are off).
void showRewardedThen(VoidCallback action) {
  if (!gAdsReady || !gAds.hasRewarded) {
    action();
    return;
  }
  gAds.rewardInstance.showRewardAd(action);
}

/// Shows an interstitial, then runs [action] when the ad closes (or immediately if ads are off).
Future<void> showInterstitialThen(VoidCallback action) async {
  if (!gAdsReady || !gAds.hasInterstitials) {
    action();
    return;
  }
  final done = Completer<void>();
  AdCallbacks.onInterstitialDismissed = () {
    if (!done.isCompleted) done.complete();
    action();
  };
  gAds.interInstance.showInterstitialAd();
  await done.future;
}

/// Pushes [page] and shows an interstitial when the user goes back.
Future<T?> pushWithInterstitialBack<T>(
  BuildContext context,
  Widget page,
) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      builder: (_) => InterstitialPopScope(child: page),
    ),
  );
}

/// Wraps [child] so system back / AppBar back runs an interstitial first.
class InterstitialPopScope extends StatelessWidget {
  const InterstitialPopScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await showInterstitialThen(() {
          if (context.mounted) Navigator.of(context).pop(result);
        });
      },
      child: child,
    );
  }
}

/// Closes a route or dialog after an interstitial (back / close actions).
Future<void> popWithInterstitial(BuildContext context, [Object? result]) async {
  await showInterstitialThen(() {
    if (context.mounted) Navigator.of(context).pop(result);
  });
}

/// Observes foreground/background for timed app-open ads only (not every resume).
class AppOpenLifecycleObserver extends StatefulWidget {
  const AppOpenLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  State<AppOpenLifecycleObserver> createState() =>
      _AppOpenLifecycleObserverState();
}

class _AppOpenLifecycleObserverState extends State<AppOpenLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    OpenAdGate.markAppStarted();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        OpenAdGate.onPaused();
      case AppLifecycleState.resumed:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OpenAdGate.onResumed();
        });
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
