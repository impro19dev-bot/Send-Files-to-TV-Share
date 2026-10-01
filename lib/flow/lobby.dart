import 'package:flutter/material.dart';

import '../brand/crest.dart';
import '../brand/ink.dart';
import '../tools/codec_lens.dart';
import '../tools/eta_board.dart';
import '../tools/handoff_desk.dart';
import '../tools/receiver_atlas.dart';
import '../tools/sample_lane.dart';

class Lobby extends StatelessWidget {
  const Lobby({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pigment.moss,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Crest(size: 64),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send files to your TV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Same Wi‑Fi. Pick files here, then open the link in your TV’s browser.',
                      style: TextStyle(color: Color(0xFFE7F8FF), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _open(context, const HandoffDesk()),
          icon: const Icon(Icons.send_rounded),
          label: const Text('Send files'),
        ),
        const SizedBox(height: 26),
        const Text(
          'Tools',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _Link(
          icon: Icons.speed_rounded,
          title: 'Network planner',
          detail: 'Sample speeds for transfer estimates.',
          onTap: () => _open(context, const SampleLane()),
        ),
        _Link(
          icon: Icons.tv_rounded,
          title: 'TV compatibility',
          detail: 'What to expect from common receivers.',
          onTap: () => _open(context, const ReceiverAtlas()),
        ),
        _Link(
          icon: Icons.video_file_outlined,
          title: 'Format checker',
          detail: 'See which files usually play on a TV.',
          onTap: () => _open(context, const CodecLens()),
        ),
        _Link(
          icon: Icons.timer_outlined,
          title: 'Transfer time',
          detail: 'Estimate how long a file will take.',
          onTap: () => _open(context, const EtaBoard()),
        ),
      ],
    );
  }
}

void _open(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _Link extends StatelessWidget {
  const _Link({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Pigment.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Pigment.olive.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Pigment.olive, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: const TextStyle(
                          color: Pigment.mute,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Pigment.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
