import 'package:flutter/material.dart';

import '../util/ads_helper.dart';
import '../theme/app_colors.dart';
import 'device_compatibility_screen.dart';
import 'format_checker_screen.dart';
import 'network_speed_screen.dart';
import 'transfer_calculator_screen.dart';
import 'wifi_send_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  static const _welcomeTitle = 'Welcome to Send files to TV';
  static const _welcomeSubtitle =
      'Your companion for streaming and local file transfer to the TV.';
  static const _welcomeBody =
      'Send files to your TV over Wi‑Fi from this screen, explore network planning, '
      'compatibility notes, format guidance, and step-by-step casting guides—all in '
      'one place. Always follow your device and app vendor instructions for playback.';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const _WelcomeCard(
          title: _welcomeTitle,
          subtitle: _welcomeSubtitle,
          body: _welcomeBody,
        ),
        const SizedBox(height: 24),
        Text(
          'Plan transfers, send files over Wi‑Fi to your TV’s browser, check device and '
          'format notes, and follow step‑by‑step guides for AirPlay, Chromecast, and '
          'other common setups. This app is educational—always follow your hardware '
          'and app vendor docs.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            height: 1.45,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Key features',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.98,
          children: [
            _FeatureCard(
              icon: Icons.wifi_tethering,
              label: 'Wi‑Fi send to TV',
              onTap: () => _openRewarded(context, const WifiSendScreen()),
            ),
            _FeatureCard(
              icon: Icons.speed,
              label: 'Network planner',
              onTap: () => _openRewarded(context, const NetworkSpeedScreen()),
            ),
            _FeatureCard(
              icon: Icons.devices_other,
              label: 'Device compatibility',
              onTap: () => _openInterstitial(
                context,
                const DeviceCompatibilityScreen(),
              ),
            ),
            _FeatureCard(
              icon: Icons.video_file_outlined,
              label: 'Format checker',
              onTap: () =>
                  _openInterstitial(context, const FormatCheckerScreen()),
            ),
            _FeatureCard(
              icon: Icons.calculate_outlined,
              label: 'Transfer calculator',
              onTap: () => _openInterstitial(
                context,
                const TransferCalculatorScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openRewarded(BuildContext context, Widget page) {
    showRewardedThen(() {
      if (!context.mounted) return;
      pushWithInterstitialBack<void>(context, page);
    });
  }

  Future<void> _openInterstitial(BuildContext context, Widget page) async {
    await showInterstitialThen(() {
      if (!context.mounted) return;
      pushWithInterstitialBack<void>(context, page);
    });
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final String title;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF29B6F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.tv_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF252842),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accentCyan, size: 30),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
