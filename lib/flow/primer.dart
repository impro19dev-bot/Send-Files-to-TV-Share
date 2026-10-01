import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../art/room_sketch.dart';
import '../brand/ink.dart';
import '../orchard_app.dart';
import 'deck.dart';

class Primer extends StatefulWidget {
  const Primer({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<Primer> createState() => _PrimerState();
}

class _PrimerState extends State<Primer> {
  final _pager = PageController();
  int _page = 0;

  static const _slides = <_Slide>[
    _Slide(
      kicker: 'Send',
      title: 'Files to the TV browser',
      body:
          'Send Files to TV: Share keeps the files you pick on this iPhone and '
          'offers them to a browser on the same Wi‑Fi. Your television opens a '
          'web page. It does not need a matching app.',
      sketch: true,
    ),
    _Slide(
      kicker: 'Plan',
      title: 'Check the transfer first',
      body:
          'Use the network planner, TV compatibility notes, format checker, and '
          'transfer-time estimate before you move a large file. Those screens '
          'illustrate typical cases. They do not measure your router.',
    ),
    _Slide(
      kicker: 'Watch',
      title: 'AirPlay, Cast, and cables',
      body:
          'Guides cover screen mirroring, in-app playback, media servers, and a '
          'wired HDMI fallback. Follow the path that matches your television.',
    ),
  ];

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await widget.prefs.setBool(primerDoneKey, true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const Deck()));
  }

  void _advance() {
    if (_page >= _slides.length - 1) {
      _finish();
      return;
    }
    _pager.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide.kicker.toUpperCase(),
                style: const TextStyle(
                  color: Pigment.clay,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                slide.title,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: Pigment.ink,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView.builder(
                  controller: _pager,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final item = _slides[i];
                    return ListView(
                      children: [
                        if (item.sketch) const RoomSketch(height: 210),
                        if (item.sketch) const SizedBox(height: 18),
                        Text(
                          item.body,
                          style: const TextStyle(
                            color: Pigment.mute,
                            fontSize: 17,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  TextButton(onPressed: _finish, child: const Text('Later')),
                  const Spacer(),
                  ...List.generate(_slides.length, (i) {
                    final on = i == _page;
                    return Container(
                      width: on ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        color: on ? Pigment.olive : Pigment.mist,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                  const Spacer(),
                  FilledButton(
                    onPressed: _advance,
                    child: Text(_page == _slides.length - 1 ? 'Enter' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.kicker,
    required this.title,
    required this.body,
    this.sketch = false,
  });

  final String kicker;
  final String title;
  final String body;
  final bool sketch;
}
