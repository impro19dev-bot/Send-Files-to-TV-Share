import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ads/ads_actions.dart';
import '../ads/ads_bootstrap.dart';
import '../brand/crest.dart';
import '../brand/ink.dart';
import '../util/global.dart';

typedef OpeningDone = void Function(BuildContext context);

class Opening extends StatefulWidget {
  const Opening({super.key, required this.onReady});

  final OpeningDone onReady;

  @override
  State<Opening> createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _startLaunchFlow();
  }

  Future<void> _startLaunchFlow() async {
    // Let the first frame paint so UMP can present above the splash.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await AdsBootstrap.ensureReady();
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // App Open (if ready) then continue; never blocks when ads are missing.
    await AdsActions.showAppOpenOnLaunch(onFinished: _continueAfterAds);
  }

  void _continueAfterAds() {
    if (!mounted) return;
    pastSplash = true;
    widget.onReady(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Pigment.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Crest(size: 120),
            SizedBox(height: 22),
            Text(
              'Send Files to TV: Share',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Pigment.ink,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'From your iPhone to the TV',
              style: TextStyle(color: Pigment.mute, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
