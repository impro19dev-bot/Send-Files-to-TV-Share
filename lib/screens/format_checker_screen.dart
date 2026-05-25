import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FormatCheckerScreen extends StatefulWidget {
  const FormatCheckerScreen({super.key});

  @override
  State<FormatCheckerScreen> createState() => _FormatCheckerScreenState();
}

class _FormatCheckerScreenState extends State<FormatCheckerScreen> {
  String _format = 'MP4 (H.264 + AAC)';
  String _target = 'Apple TV / AirPlay';

  static const _formats = <String>[
    'MP4 (H.264 + AAC)',
    'MP4 (H.265/HEVC + AAC)',
    'MOV (ProRes)',
    'MKV (H.264)',
    'MKV (H.265)',
    'AVI (legacy codecs)',
  ];

  static const _targets = <String>[
    'Apple TV / AirPlay',
    'Chromecast',
    'Samsung TV',
    'LG webOS',
    'Roku',
  ];

  @override
  Widget build(BuildContext context) {
    final verdict = _verdict(_format, _target);
    return Scaffold(
      appBar: AppBar(title: const Text('Format checker')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a typical container/codec pair and where playback happens. '
            'This is general guidance only: real support depends on exact codecs, '
            'profiles, HDR flags, and app versions—always test a short clip first.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          _LabeledDropdown(
            label: 'Format',
            value: _format,
            items: _formats,
            onChanged: (v) => setState(() => _format = v ?? _format),
          ),
          const SizedBox(height: 16),
          _LabeledDropdown(
            label: 'Target',
            value: _target,
            items: _targets,
            onChanged: (v) => setState(() => _target = v ?? _target),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF252842),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdict.title,
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  verdict.detail,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _Verdict _verdict(String format, String target) {
    final hevc = format.contains('HEVC') || format.contains('H.265');
    final isAvi = format.contains('AVI');
    final isMkv = format.contains('MKV');

    if (target == 'Chromecast' && hevc) {
      return const _Verdict(
        title: 'Often works, but verify',
        detail:
            'Many Chromecast devices decode HEVC, but support varies by model, '
            'firmware, and whether the sender app remuxes or transcodes. H.264/AAC '
            'in MP4 remains the most predictable choice for casting.',
      );
    }
    if (target.contains('AirPlay') && format.contains('ProRes')) {
      return const _Verdict(
        title: 'Good on Apple receivers, heavy on Wi‑Fi',
        detail:
            'ProRes is commonly used in the Apple ecosystem, but bitrates can be '
            'very high. Prefer wired Ethernet to Apple TV for long or HDR clips, '
            'and confirm your editing/export settings match what the receiver supports.',
      );
    }
    if (isAvi) {
      return const _Verdict(
        title: 'Likely needs conversion',
        detail:
            'AVI often holds older codecs. iOS, AirPlay, and many smart TVs expect '
            'modern MP4/MOV pipelines—plan to transcode or remux to H.264/AAC (or '
            'HEVC where supported) before casting.',
      );
    }
    if (isMkv) {
      return const _Verdict(
        title: 'MKV: playback vs casting',
        detail:
            'MKV is common for local libraries, but AirPlay from iOS usually expects '
            'MP4/MOV. If the inner video/audio are already compatible (for example '
            'H.264 + AAC), remuxing to MP4 without re‑encoding is often enough.',
      );
    }
    if (target == 'Roku' && hevc) {
      return const _Verdict(
        title: 'Check Roku model specs',
        detail:
            'HEVC support depends on the specific Roku device and app. When unsure, '
            'export to H.264/AAC MP4 for the widest compatibility.',
      );
    }
    return const _Verdict(
      title: 'Usually a safe default',
      detail:
          'H.264 with AAC in an MP4 container is widely supported for streaming and '
          'casting. HDR, high frame rates, or multichannel audio can still require '
          'specific settings—confirm with a short test before long transfers.',
    );
  }
}

class _Verdict {
  const _Verdict({required this.title, required this.detail});

  final String title;
  final String detail;
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF252842),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: const Color(0xFF252842),
              style: const TextStyle(color: Colors.white),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
