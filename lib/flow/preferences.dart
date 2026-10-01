import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../brand/ink.dart';
import '../orchard_app.dart';

class Preferences extends StatelessWidget {
  const Preferences({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _Label('This copy'),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final line = info == null
                  ? 'Reading…'
                  : '${info.version} · ${info.buildNumber}';
              return ListTile(
                title: const Text('Version'),
                subtitle: Text(line),
              );
            },
          ),
          const ListTile(
            title: Text('Send Files to TV: Share'),
            subtitle: Text(
              'Send files from this iPhone to a TV browser on the same Wi‑Fi.',
            ),
          ),
          const _Label('Primer'),
          ListTile(
            title: const Text('See the primer again'),
            subtitle: const Text(
              'Clears the intro flag. Fully quit the app, then open it once more.',
            ),
            onTap: () => _confirmPrimerReset(context),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmPrimerReset(BuildContext context) async {
  final yes = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Replay the primer?'),
      content: const Text(
        'The next cold start will show the three intro pages. You can still skip them.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Keep'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Replay'),
        ),
      ],
    ),
  );
  if (yes != true || !context.mounted) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(primerDoneKey);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Primer cleared. Quit the app fully, then reopen it.'),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Pigment.olive,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
