import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:multiads/multiads.dart';

/// Apple App Tracking Transparency (ATT) — separate from Google UMP / GDPR.
///
/// - Requests only when status is [TrackingStatus.notDetermined]
/// - Skips if UMP's optional IDFA message already triggered ATT
/// - Never enables IDFA unless the user authorizes
abstract final class AttTracking {
  static bool _handledThisSession = false;

  static bool get allowsIdfaTracking => TrackingGate.idfaAuthorized;

  /// Presents the system ATT prompt when needed. Safe to call more than once.
  static Future<void> requestIfNeeded() async {
    if (!Platform.isIOS) {
      TrackingGate.idfaAuthorized = true;
      return;
    }
    if (_handledThisSession) return;
    _handledThisSession = true;

    try {
      // Avoid overlapping with UMP / other system dialogs.
      await _waitUntilResumed();
      await Future<void>.delayed(const Duration(milliseconds: 600));

      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (kDebugMode) {
        debugPrint('ATT >> status before request: $status');
      }

      // UMP may already have shown an IDFA/ATT flow — do not prompt again.
      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
        if (kDebugMode) {
          debugPrint('ATT >> status after request: $status');
        }
      }

      TrackingGate.idfaAuthorized = status == TrackingStatus.authorized;
    } catch (e, st) {
      TrackingGate.idfaAuthorized = false;
      if (kDebugMode) {
        debugPrint('ATT >> request failed: $e\n$st');
      }
    }
  }

  static Future<void> _waitUntilResumed({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final binding = WidgetsBinding.instance;
    if (binding.lifecycleState == null ||
        binding.lifecycleState == AppLifecycleState.resumed) {
      return;
    }

    final done = Completer<void>();
    late final WidgetsBindingObserver observer;

    observer = _LifecycleObserver((state) {
      if (state == AppLifecycleState.resumed && !done.isCompleted) {
        done.complete();
      }
    });

    binding.addObserver(observer);
    try {
      await done.future.timeout(timeout, onTimeout: () {});
    } finally {
      binding.removeObserver(observer);
    }
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this.onChange);

  final void Function(AppLifecycleState state) onChange;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChange(state);
}
