import 'package:flutter/foundation.dart';
import 'package:multiads/multiads.dart';

import '../util/global.dart';
import 'ads_actions.dart';
import 'att_tracking.dart';

/// One-shot ads startup after the UI is on screen.
///
/// Order (required for App Review 5.1.2(i)):
/// 1. Google UMP / GDPR consent form (if required)
/// 2. Apple ATT prompt (only if still notDetermined — skips if UMP IDFA already ran)
/// 3. Ad SDK init + preload (IDFA tracking only if ATT authorized)
abstract final class AdsBootstrap {
  static bool _started = false;

  static const _testDeviceIds = ['79738754EC81FA5F64972928128B2FFF'];

  /// Safe to call twice; runs once per process.
  static Future<void> ensureReady() async {
    if (_started) return;
    _started = true;

    final ads = gAds;
    if (!gAdsReady || ads == null) return;

    try {
      // 1) GDPR / UMP only — does not request Apple ATT.
      await UmpConsent.gather(testDeviceIds: _testDeviceIds);

      // 2) ATT after UMP so dialogs do not overlap.
      await AttTracking.requestIfNeeded();

      // 3) Initialize networks. Mobile Ads starts after consent + ATT checks.
      //    Facebook advertiser tracking uses [TrackingGate.idfaAuthorized].
      await ads.init();
      await ads.loadAds();
      AdsActions.registerCallbacks();

      if (kDebugMode) {
        debugPrint(
          'AdsBootstrap ready (idfaAuthorized=${AttTracking.allowsIdfaTracking})',
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AdsBootstrap failed: $e\n$st');
      }
    }
  }
}
