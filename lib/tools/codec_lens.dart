import 'package:flutter/material.dart';

import '../brand/ink.dart';

enum _Wrap { mp4H264, mp4Hevc, movProRes, mkv, avi }

enum _Where { apple, cast, samsung, lg, roku }

class CodecLens extends StatefulWidget {
  const CodecLens({super.key});

  @override
  State<CodecLens> createState() => _CodecLensState();
}

class _CodecLensState extends State<CodecLens> {
  _Wrap _wrap = _Wrap.mp4H264;
  _Where _where = _Where.apple;

  @override
  Widget build(BuildContext context) {
    final note = _read(_wrap, _where);
    return Scaffold(
      appBar: AppBar(title: const Text('Format checker')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'A starting opinion, not a spec sheet. Profiles, HDR, and the app doing '
            'the playback can change the outcome. Try a short clip before a long copy.',
            style: TextStyle(color: Pigment.mute, height: 1.45),
          ),
          const SizedBox(height: 18),
          const Text(
            'Container',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final wrap in _Wrap.values)
                ChoiceChip(
                  label: Text(_wrapLabel(wrap)),
                  selected: _wrap == wrap,
                  onSelected: (_) => setState(() => _wrap = wrap),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Destination',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final where in _Where.values)
                ChoiceChip(
                  label: Text(_whereLabel(where)),
                  selected: _where == where,
                  onSelected: (_) => setState(() => _where = where),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Pigment.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Pigment.mist),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                    color: Pigment.olive,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(note.body, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _wrapLabel(_Wrap wrap) => switch (wrap) {
  _Wrap.mp4H264 => 'MP4 · H.264',
  _Wrap.mp4Hevc => 'MP4 · HEVC',
  _Wrap.movProRes => 'MOV · ProRes',
  _Wrap.mkv => 'MKV',
  _Wrap.avi => 'AVI',
};

String _whereLabel(_Where where) => switch (where) {
  _Where.apple => 'Apple TV',
  _Where.cast => 'Chromecast',
  _Where.samsung => 'Samsung',
  _Where.lg => 'LG webOS',
  _Where.roku => 'Roku',
};

({String title, String body}) _read(_Wrap wrap, _Where where) {
  if (wrap == _Wrap.avi) {
    return (
      title: 'Plan a conversion',
      body:
          'AVI usually carries older codecs. Most current televisions and AirPlay paths expect MP4 or MOV. Transcode, or remux only if you already know the inner streams are modern.',
    );
  }
  if (wrap == _Wrap.mkv) {
    return (
      title: 'Fine in a library, awkward over AirPlay',
      body:
          'MKV is common on a computer or NAS. Sending it through AirPlay from iOS is less predictable. If the video is already H.264 or HEVC with AAC, remuxing into MP4 often avoids a full re-encode.',
    );
  }
  if (wrap == _Wrap.movProRes && where == _Where.apple) {
    return (
      title: 'At home on Apple hardware, heavy on the link',
      body:
          'ProRes is an Apple-friendly master, and the bitrate can be large. Ethernet on the Apple TV helps. Other living-room boxes often want a lighter H.264 or HEVC export.',
    );
  }
  if (wrap == _Wrap.mp4Hevc && (where == _Where.cast || where == _Where.roku)) {
    return (
      title: 'Depends on the exact box',
      body:
          'Some Chromecast and Roku models decode HEVC, and some do not. When the model year is unclear, H.264 with AAC in MP4 is the safer export.',
    );
  }
  return (
    title: 'A widely readable default',
    body:
        'H.264 and AAC inside MP4 still travels the furthest. High frame rate, HDR, or many audio channels can still need a setting the receiver understands.',
  );
}
