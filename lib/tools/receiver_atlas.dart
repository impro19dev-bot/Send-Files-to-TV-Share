import 'package:flutter/material.dart';

import '../brand/ink.dart';

enum _Family { apple, cast, other }

class ReceiverAtlas extends StatefulWidget {
  const ReceiverAtlas({super.key});

  @override
  State<ReceiverAtlas> createState() => _ReceiverAtlasState();
}

class _ReceiverAtlasState extends State<ReceiverAtlas> {
  _Family _family = _Family.apple;

  static const _cards = <_CardData>[
    _CardData(
      _Family.apple,
      'Apple TV',
      'The usual AirPlay target. Prefer the control inside a video app over mirroring the whole display. Ethernet on the box helps large files.',
    ),
    _CardData(
      _Family.apple,
      'AirPlay televisions',
      'Many recent Samsung, LG, and Roku sets can appear in Screen Mirroring after you enable Apple AirPlay in the television’s own settings. The menu name differs by year.',
    ),
    _CardData(
      _Family.cast,
      'Chromecast and Google TV',
      'Use the Cast control inside an app that offers it. Arbitrary files from the Files app are not automatically castable; the sending app has to support that device.',
    ),
    _CardData(
      _Family.cast,
      'Sony and other Google TV sets',
      'Built-in Cast is common. Confirm AirPlay separately in the model’s spec if you expected the iPhone mirroring list to include it.',
    ),
    _CardData(
      _Family.other,
      'Amazon Fire TV',
      'There is no first-party AirPlay receiver. Plan on an app both devices support, or a wired HDMI adapter from the iPhone.',
    ),
    _CardData(
      _Family.other,
      'A plain browser',
      'If the television can open a web page, the handoff desk is the path that does not depend on AirPlay or Cast. Both devices still have to share a network.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _cards.where((card) => card.family == _family);
    return Scaffold(
      appBar: AppBar(title: const Text('TV compatibility')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Model year, region, and firmware change what a set can do. Treat these cards as a map, then confirm on the television in front of you.',
            style: TextStyle(color: Pigment.mute, height: 1.45),
          ),
          const SizedBox(height: 14),
          SegmentedButton<_Family>(
            segments: const [
              ButtonSegment(value: _Family.apple, label: Text('Apple')),
              ButtonSegment(value: _Family.cast, label: Text('Cast')),
              ButtonSegment(value: _Family.other, label: Text('Other')),
            ],
            selected: {_family},
            onSelectionChanged: (next) => setState(() => _family = next.first),
          ),
          const SizedBox(height: 16),
          for (final card in visible) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Pigment.card,
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  left: BorderSide(color: Pigment.clay, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(card.body, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardData {
  const _CardData(this.family, this.title, this.body);

  final _Family family;
  final String title;
  final String body;
}
