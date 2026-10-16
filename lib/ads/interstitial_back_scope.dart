import 'package:flutter/material.dart';

import 'ads_actions.dart';

/// Shows an interstitial (when available) before popping via system/AppBar back.
class InterstitialBackScope extends StatefulWidget {
  const InterstitialBackScope({super.key, required this.child});

  final Widget child;

  @override
  State<InterstitialBackScope> createState() => _InterstitialBackScopeState();
}

class _InterstitialBackScopeState extends State<InterstitialBackScope> {
  bool _allowPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        AdsActions.showInterstitialThen(() {
          if (!mounted) return;
          setState(() => _allowPop = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pop(result);
          });
        });
      },
      child: widget.child,
    );
  }
}
