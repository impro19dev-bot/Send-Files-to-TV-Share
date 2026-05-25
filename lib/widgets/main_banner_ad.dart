import 'package:flutter/material.dart';
import 'package:multiads/multiads.dart';

import '../util/global.dart';

/// Adaptive banner above the bottom navigation bar on the main shell.
class MainBannerAd extends StatefulWidget {
  const MainBannerAd({super.key});

  static final Key bannerKey = GlobalKey(debugLabel: 'main_shell_banner');

  @override
  State<MainBannerAd> createState() => _MainBannerAdState();
}

class _MainBannerAdState extends State<MainBannerAd> {
  Ads? _bannerAds;
  bool _loaded = false;
  bool _loadStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
  }

  Future<void> _loadBanner() async {
    if (_loadStarted || !gAdsReady || !gAds.hasBanners) return;
    _loadStarted = true;
    _bannerAds = gAds.bannerInstance;
    await _bannerAds!.loadBannerAd(() {
      if (mounted) setState(() => _loaded = true);
    }, MainBannerAd.bannerKey);
  }

  @override
  void dispose() {
    if (_bannerAds != null) {
      _bannerAds!.disposeBanner(MainBannerAd.bannerKey);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!gAdsReady || !gAds.hasBanners || !_loaded || _bannerAds == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Center(
        child: _bannerAds!.getBannerAdWidget(MainBannerAd.bannerKey),
      ),
    );
  }
}
