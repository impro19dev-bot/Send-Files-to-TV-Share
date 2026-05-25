import 'package:flutter/material.dart';

import '../util/ads_helper.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  static const _guides = <_Guide>[
    _Guide(
      title: 'AirPlay from iPhone or iPad',
      steps: [
        'Connect your iPhone or iPad to the same Wi‑Fi (or Ethernet, for Apple TV) as the playback device.',
        'For screen mirroring: open Control Center—on Face ID models, swipe down from the top‑right edge—tap Screen Mirroring, then choose your Apple TV or AirPlay‑capable TV.',
        'For video or music inside an app, prefer the AirPlay or “output” icon in that app’s player. That path usually keeps quality higher than full‑screen mirroring.',
        'If video stutters, move closer to the router, reduce mirroring resolution where possible, or use wired Ethernet on Apple TV for large 4K files.',
      ],
    ),
    _Guide(
      title: 'Chromecast & Google TV',
      steps: [
        'Put your phone and Chromecast on the same Wi‑Fi network (same SSID and band when possible).',
        'In a Cast‑enabled app (for example YouTube, Netflix, or Spotify), tap the Cast icon and select your Chromecast or TV with Chromecast built‑in.',
        'The stream typically plays on the TV while your phone acts as a remote; you can lock the phone for many services once playback starts.',
        'The Google Home app is useful for setup and firmware updates but is not required for every Cast session. Local files need an app that explicitly supports casting to Chromecast.',
      ],
    ),
    _Guide(
      title: 'DLNA / media servers on smart TVs',
      steps: [
        'On the TV, enable media sharing, DLNA, or “play from PC” style features if your manufacturer exposes them (names vary).',
        'On a Mac or PC on the same network, run a DLNA/UPnP server (for example Plex, Jellyfin, or the NAS vendor’s app) and add your media folders.',
        'From the TV’s media browser, open the server and play files. The TV must support the file’s codecs—transcode to H.264/AAC when unsure.',
        'This path is separate from AirPlay; it is best for libraries stored on a computer or NAS, not for every iOS app.',
      ],
    ),
    _Guide(
      title: 'HDMI adapters (wired fallback)',
      steps: [
        'For a direct HDMI connection from iPhone or iPad, use an Apple‑compatible Digital AV adapter (Lightning or USB‑C, matching your device) or a reputable USB‑C dock with HDMI that lists iPad/iPhone support.',
        'Connect HDMI to the correct TV input, switch the TV to that input, and keep the device charged—some adapters need external power for long sessions.',
        'Wired HDMI avoids Wi‑Fi congestion and is useful for presentations or when wireless casting is unreliable.',
      ],
    ),
  ];

  final Set<int> _expanded = {};

  Future<void> _onGuideTap(int index) async {
    if (_expanded.contains(index)) {
      setState(() => _expanded.remove(index));
      return;
    }
    await showInterstitialThen(() {
      if (!mounted) return;
      setState(() => _expanded.add(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _guides.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final g = _guides[i];
        final isOpen = _expanded.contains(i);
        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  g.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
                onTap: () => _onGuideTap(i),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      for (var s = 0; s < g.steps.length; s++) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s + 1}.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                g.steps[s],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (s != g.steps.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Guide {
  const _Guide({required this.title, required this.steps});

  final String title;
  final List<String> steps;
}
