import 'package:flutter/material.dart';

import '../util/ads_helper.dart';
import 'device_compatibility_screen.dart';
import 'format_checker_screen.dart';
import 'network_speed_screen.dart';
import 'transfer_calculator_screen.dart';
import 'wifi_send_screen.dart';

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String subtitle, IconData icon, Widget page})>[
      (
        title: 'Wi‑Fi send to TV',
        subtitle:
            'Pick files on this iPhone and download them on your TV’s browser over home Wi‑Fi.',
        icon: Icons.wifi_tethering,
        page: const WifiSendScreen(),
      ),
      (
        title: 'Network planner',
        subtitle:
            'Generate example Mb/s values for “what‑if” transfer math—not a live test.',
        icon: Icons.speed,
        page: const NetworkSpeedScreen(),
      ),
      (
        title: 'Device compatibility',
        subtitle:
            'High‑level notes for common TVs; models and firmware vary—verify on yours.',
        icon: Icons.devices_other,
        page: const DeviceCompatibilityScreen(),
      ),
      (
        title: 'Format compatibility',
        subtitle:
            'General rules of thumb for codecs and containers—confirm with a short test clip.',
        icon: Icons.video_settings,
        page: const FormatCheckerScreen(),
      ),
      (
        title: 'Transfer time calculator',
        subtitle:
            'Idealized time from size and link speed; real transfers usually take longer.',
        icon: Icons.calculate_outlined,
        page: const TransferCalculatorScreen(),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = items[i];
        return Card(
          child: ListTile(
            leading: Icon(e.icon),
            title: Text(e.title),
            subtitle: Text(
              e.subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openTool(context, e.title, e.page),
          ),
        );
      },
    );
  }

  void _openTool(BuildContext context, String title, Widget page) {
    final isRewarded = title == 'Wi‑Fi send to TV' || title == 'Network planner';
    if (isRewarded) {
      showRewardedThen(() {
        if (!context.mounted) return;
        pushWithInterstitialBack<void>(context, page);
      });
      return;
    }
    showInterstitialThen(() {
      if (!context.mounted) return;
      pushWithInterstitialBack<void>(context, page);
    });
  }
}
