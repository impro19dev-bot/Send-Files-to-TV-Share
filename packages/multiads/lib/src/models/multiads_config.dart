import 'package:flutter/material.dart';

class MultiAdsConfig {
  // AdMob
  final List<String> admobTestDeviceIds;
  final Color admobNativeBackgroundColor;
  final Color admobNativePrimaryColor;
  final Color admobNativeSecondaryColor;
  final Color admobNativeActionColor;

  final String facebookTestingId;
  final bool facebookiOSTrackingEnabled;

  // General
  final bool enableLogs;

  const MultiAdsConfig({
    // AdMob defaults
    this.admobTestDeviceIds = const [],
    this.admobNativeBackgroundColor = Colors.black,
    this.admobNativePrimaryColor = Colors.blue,
    this.admobNativeSecondaryColor = const Color(0xFF4CB050),
    this.admobNativeActionColor = Colors.blue,
    // Facebook defaults — IDFA still gated by [TrackingGate.idfaAuthorized].
    this.facebookTestingId = "",
    this.facebookiOSTrackingEnabled = false,
    // General
    this.enableLogs = true,
  });
}
