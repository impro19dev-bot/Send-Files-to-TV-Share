import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google UMP (User Messaging Platform) — AdMob's certified CMP for GDPR / EEA consent.
abstract final class AdConsent {
  /// Whether ads may be requested after the latest consent flow.
  static bool canRequestAds = false;

  /// Runs UMP on every cold start before [MobileAds] / ad loading.
  ///
  /// Configure messages in AdMob → Privacy & messaging. Set [debugEea] to true
  /// only while testing the consent form in non-EEA regions.
  static Future<bool> gather({bool debugEea = false}) async {
    final params = ConsentRequestParameters(
      consentDebugSettings: debugEea
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: const [
                '79738754EC81FA5F64972928128B2FFF',
              ],
            )
          : null,
    );

    final infoDone = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        if (!infoDone.isCompleted) infoDone.complete();
      },
      (_) {
        if (!infoDone.isCompleted) infoDone.complete();
      },
    );
    await infoDone.future;

    final formDone = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired((_) {
      if (!formDone.isCompleted) formDone.complete();
    });
    await formDone.future;

    canRequestAds = await ConsentInformation.instance.canRequestAds();
    return canRequestAds;
  }

  /// Whether AdMob requires a visible privacy / consent settings entry.
  static Future<bool> privacyOptionsRequired() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// Opens the UMP privacy options form (for Settings).
  static Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) {
      if (!done.isCompleted) done.complete();
    });
    await done.future;
    canRequestAds = await ConsentInformation.instance.canRequestAds();
  }
}
