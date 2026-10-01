import 'package:flutter/material.dart';

import '../brand/ink.dart';

class EtaBoard extends StatefulWidget {
  const EtaBoard({super.key});

  @override
  State<EtaBoard> createState() => _EtaBoardState();
}

class _EtaBoardState extends State<EtaBoard> {
  double _megabytes = 800;
  double _megabits = 40;

  @override
  Widget build(BuildContext context) {
    final seconds = (_megabytes * 8) / _megabits;
    final span = Duration(seconds: seconds.round().clamp(1, 864000));

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer time')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'A steady-link sketch. Megabytes here are decimal (1 MB = 1,000,000 bytes) '
            'and the rate is megabits per second. Overhead, disk speed, and a busy '
            'channel usually make the real copy slower.',
            style: TextStyle(color: Pigment.mute, height: 1.45),
          ),
          const SizedBox(height: 20),
          Text(
            '${_megabytes.round()} MB',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _megabytes,
            min: 50,
            max: 8000,
            divisions: 159,
            activeColor: Pigment.olive,
            label: '${_megabytes.round()} MB',
            onChanged: (value) => setState(() => _megabytes = value),
          ),
          Text(
            '${_megabits.round()} Mb/s',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _megabits,
            min: 5,
            max: 400,
            divisions: 79,
            activeColor: Pigment.clay,
            label: '${_megabits.round()} Mb/s',
            onChanged: (value) => setState(() => _megabits = value),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Pigment.moss,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About', style: TextStyle(color: Color(0xFFE7E2D8))),
                const SizedBox(height: 6),
                Text(
                  _speak(span),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _speak(Duration span) {
    final hours = span.inHours;
    final minutes = span.inMinutes.remainder(60);
    final seconds = span.inSeconds.remainder(60);
    if (hours >= 48) {
      return '${span.inDays} days';
    }
    if (hours >= 1) {
      return '$hours h $minutes min';
    }
    if (minutes >= 1) {
      return '$minutes min $seconds s';
    }
    return '$seconds s';
  }
}
