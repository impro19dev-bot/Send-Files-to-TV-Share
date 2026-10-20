/// Cross-network gate for IDFA / advertiser tracking.
///
/// The host app sets [idfaAuthorized] after App Tracking Transparency (and
/// after UMP). Networks must not enable IDFA-based tracking unless this is true.
abstract final class TrackingGate {
  /// `true` only when Apple ATT is [authorized] (or non-iOS).
  static bool idfaAuthorized = false;
}
