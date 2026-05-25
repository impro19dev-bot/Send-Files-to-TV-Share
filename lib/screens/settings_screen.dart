import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../util/ad_consent.dart';
import '../util/ads_helper.dart';

Future<void> confirmResetOnboarding(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Show intro again?'),
      content: const Text(
        'The next time you launch the app from a cold start, the intro screens will appear. '
        'You can still skip them.',
      ),
      actions: [
        TextButton(
          onPressed: () => popWithInterstitial(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(kOnboardingCompleteKey);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Intro reset. Quit the app completely, then reopen.'),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader(label: 'About'),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App version'),
                subtitle: Text(
                  info == null
                      ? 'Loading…'
                      : '${info.version} (build ${info.buildNumber})',
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.smartphone_outlined),
            title: Text('Send files to TV'),
            subtitle: Text(
              'Wi‑Fi send, guides, and planning tools. File transfer uses your home network.',
            ),
          ),
          const _SectionHeader(label: 'Privacy'),
          FutureBuilder<bool>(
            future: AdConsent.privacyOptionsRequired(),
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Ad privacy choices'),
                subtitle: const Text(
                  'Manage consent for personalized ads (required in some regions).',
                ),
                onTap: () => AdConsent.showPrivacyOptions(),
              );
            },
          ),
          const _SectionHeader(label: 'Onboarding'),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Show intro again'),
            subtitle: const Text(
              'Clears the intro completion flag. Fully quit and reopen the app to see onboarding.',
            ),
            onTap: () async {
              await showInterstitialThen(() {
                if (!context.mounted) return;
                confirmResetOnboarding(context);
              });
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
