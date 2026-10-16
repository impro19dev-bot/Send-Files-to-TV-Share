import 'package:flutter/foundation.dart';

import '../util/global.dart';
import 'ads_actions.dart';

/// One-shot ads startup after the UI is on screen (so UMP can present).
abstract final class AdsBootstrap {
  static bool _started = false;

  /// Runs UMP (inside AdMob init) → SDK init → preload. Safe to call twice.
  static Future<void> ensureReady() async {
    if (_started) return;
    _started = true;

    final ads = gAds;
    if (!gAdsReady || ads == null) return;

    try {
      await ads.init();
      await ads.loadAds();
      AdsActions.registerCallbacks();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AdsBootstrap failed: $e\n$st');
      }
    }
  }
}
