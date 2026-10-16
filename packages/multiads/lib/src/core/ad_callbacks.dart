/// App-level hooks fired when a full-screen ad finishes (or is skipped).
abstract final class AdCallbacks {
  static void Function()? onInterstitialDismissed;
  static void Function()? onAppOpenShown;
  static void Function()? onAppOpenDismissed;
}

/// Invokes a rewarded-ad completion callback with a single optional argument.
///
/// App code often passes `(_) { ... }`; calling `rewarded()` with zero args
/// throws and skips navigation. Always pass one argument here.
void completeRewardCallback(Function rewarded, [dynamic reward]) {
  rewarded(reward);
}
