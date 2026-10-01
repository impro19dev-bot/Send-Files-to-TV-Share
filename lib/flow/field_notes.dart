import 'package:flutter/material.dart';

import '../brand/ink.dart';

class FieldNotes extends StatefulWidget {
  const FieldNotes({super.key});

  @override
  State<FieldNotes> createState() => _FieldNotesState();
}

class _FieldNotesState extends State<FieldNotes> {
  final _pager = PageController();
  int _index = 0;

  static const _notes = <_Note>[
    _Note(
      title: 'TV browser',
      lines: [
        'Join the iPhone and the television to one Wi‑Fi network. Pause any VPN on the phone.',
        'On Send to TV, choose files and start sharing. Leave Send Files to TV: Share in the foreground.',
        'On the television, launch its web browser — not a code-scanner app — and type the address shown on the phone.',
        'The square code is only a copy of that address. Scan it with another phone if typing on the TV remote is awkward, then enter the same address on the television.',
      ],
    ),
    _Note(
      title: 'AirPlay',
      lines: [
        'Keep the iPhone and the Apple TV, or an AirPlay television, on the same network.',
        'For the whole display, open Control Center and choose Screen Mirroring, then the receiver.',
        'Inside a video or music app, use that app’s AirPlay control when it is offered. That path is usually lighter than mirroring the entire screen.',
        'If motion stutters, move closer to the router or put the Apple TV on Ethernet.',
      ],
    ),
    _Note(
      title: 'Cast',
      lines: [
        'Place the phone and the Cast device on the same network name, and the same band when you can.',
        'In an app that shows a Cast mark, tap it and pick the television or dongle.',
        'Playback often continues on the television after the phone locks. Local files need an app that states it can cast them.',
        'The Home app helps with setup and updates. It is not required for every session.',
      ],
    ),
    _Note(
      title: 'Library servers',
      lines: [
        'On the television, turn on media sharing or “play from another device” if the maker exposes it. The label differs by brand.',
        'On a computer on the same network, run a DLNA or UPnP library and point it at your folders.',
        'Browse that library from the television. If a clip will not start, a widely readable H.264 and AAC export is the usual next try.',
        'This route is separate from AirPlay and suits files that already live on a computer or NAS.',
      ],
    ),
    _Note(
      title: 'HDMI cable',
      lines: [
        'Use a Digital AV adapter that matches Lightning or USB‑C, or a dock whose maker lists iPhone or iPad HDMI output.',
        'Plug into the television input you selected, and keep the phone charging for a long session.',
        'A cable sidesteps a crowded Wi‑Fi channel when wireless output keeps dropping frames.',
      ],
    ),
  ];

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _go(int next) {
    if (next == _index) return;
    _pager.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _notes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final on = i == _index;
              return ChoiceChip(
                label: Text(_notes[i].title),
                selected: on,
                onSelected: (_) => _go(i),
                selectedColor: Pigment.olive,
                labelStyle: TextStyle(
                  color: on ? Pigment.navy : Pigment.ink,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Pigment.card,
                side: const BorderSide(color: Pigment.mist),
              );
            },
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pager,
            itemCount: _notes.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final note = _notes[i];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var s = 0; s < note.lines.length; s++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Pigment.clay,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${s + 1}',
                              style: const TextStyle(
                                color: Pigment.navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              note.lines[s],
                              style: const TextStyle(height: 1.4, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Note {
  const _Note({required this.title, required this.lines});

  final String title;
  final List<String> lines;
}
