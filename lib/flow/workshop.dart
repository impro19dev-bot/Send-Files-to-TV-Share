import 'package:flutter/material.dart';

import '../brand/ink.dart';
import '../tools/codec_lens.dart';
import '../tools/eta_board.dart';
import '../tools/handoff_desk.dart';
import '../tools/receiver_atlas.dart';
import '../tools/sample_lane.dart';

class Workshop extends StatelessWidget {
  const Workshop({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        const _Heading('Send'),
        _BenchTile(
          title: 'Wi‑Fi send',
          line: 'Share chosen files with a browser on the same network.',
          page: const HandoffDesk(),
        ),
        const SizedBox(height: 18),
        const _Heading('Plan'),
        _BenchTile(
          title: 'Network planner',
          line: 'Sample figures you can use in the transfer estimate.',
          page: const SampleLane(),
        ),
        _BenchTile(
          title: 'TV compatibility',
          line: 'Notes for Apple TV, Cast, and other living-room devices.',
          page: const ReceiverAtlas(),
        ),
        _BenchTile(
          title: 'Format checker',
          line: 'Pair a file type with the TV you are sending to.',
          page: const CodecLens(),
        ),
        _BenchTile(
          title: 'Transfer time',
          line: 'Turn file size and link speed into an estimate.',
          page: const EtaBoard(),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Pigment.clayDeep,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BenchTile extends StatelessWidget {
  const _BenchTile({
    required this.title,
    required this.line,
    required this.page,
  });

  final String title;
  final String line;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(line, style: const TextStyle(color: Pigment.mute)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => page));
        },
      ),
    );
  }
}
