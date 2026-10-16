import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/log.dart';

/// Google UMP (User Messaging Platform) GDPR / privacy consent.
///
/// This is intentionally separate from Apple ATT
/// ([ATTrackingManager] / IDFA). Do not request tracking authorization here.
abstract final class UmpConsent {
  static bool _gathered = false;

  /// Updates consent info and shows the Google-rendered form when required.
  ///
  /// Never throws. Times out so launch is not blocked if the form stalls.
  static Future<void> gather({
    List<String> testDeviceIds = const [],
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (_gathered) return;
    _gathered = true;

    try {
      final params = ConsentRequestParameters(
        tagForUnderAgeOfConsent: false,
        // Debug geography only in debug builds so EU CMP can be verified.
        consentDebugSettings: kDebugMode && testDeviceIds.isNotEmpty
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
                testIdentifiers: testDeviceIds,
              )
            : null,
      );

      final updateDone = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () {
          if (!updateDone.isCompleted) updateDone.complete();
        },
        (FormError error) {
          Log.log('UMP >> consent info update failed: ${error.message}');
          if (!updateDone.isCompleted) updateDone.complete();
        },
      );

      await updateDone.future.timeout(timeout, onTimeout: () {
        Log.log('UMP >> consent info update timed out');
      });

      final formDone = Completer<void>();
      await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) {
          Log.log('UMP >> consent form error: ${error.message}');
        } else {
          Log.log('UMP >> consent form finished (or not required)');
        }
        if (!formDone.isCompleted) formDone.complete();
      });
      await formDone.future.timeout(timeout, onTimeout: () {
        Log.log('UMP >> consent form timed out');
      });

      final status = await ConsentInformation.instance.getConsentStatus();
      final canRequest = await ConsentInformation.instance.canRequestAds();
      Log.log('UMP >> status=$status canRequestAds=$canRequest');
    } catch (e, st) {
      Log.log('UMP >> gather error: $e\n$st');
    }
  }

  /// Whether the Mobile Ads SDK may request ads after consent gathering.
  static Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return true;
    }
  }
}
