import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brand/ink.dart';

class SampleLane extends StatefulWidget {
  const SampleLane({super.key});

  @override
  State<SampleLane> createState() => _SampleLaneState();
}

class _SampleLaneState extends State<SampleLane> {
  _Scene? _scene;
  double? _rate;
  int? _lag;
  bool _spinning = false;

  static const _scenes = <_Scene>[
    _Scene('Quiet house', 90, 160, 6, 14),
    _Scene('Busy evening', 18, 55, 20, 48),
    _Scene('Wired dock', 200, 420, 2, 8),
  ];

  Future<void> _draw(_Scene scene) async {
    setState(() {
      _spinning = true;
      _scene = scene;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final roll = math.Random();
    setState(() {
      _rate = scene.low + roll.nextDouble() * (scene.high - scene.low);
      _lag = scene.lagLow + roll.nextInt(scene.lagHigh - scene.lagLow + 1);
      _spinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network planner')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Pick a scene. The figures below are invented inside a range so you can '
            'feel how the transfer estimate behaves. They are not a reading of this Wi‑Fi.',
            style: TextStyle(color: Pigment.mute, height: 1.45),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final scene in _scenes)
                ChoiceChip(
                  label: Text(scene.label),
                  selected: _scene == scene,
                  onSelected: _spinning ? null : (_) => _draw(scene),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_spinning)
            const Center(child: CircularProgressIndicator(color: Pigment.olive))
          else if (_rate != null) ...[
            _Figure(
              label: 'Illustrated rate',
              value: '${_rate!.toStringAsFixed(0)} Mb/s',
            ),
            const SizedBox(height: 10),
            _Figure(label: 'Illustrated lag', value: '$_lag ms'),
            const SizedBox(height: 14),
            Text(
              'Carry ${_rate!.toStringAsFixed(0)} Mb/s into Transfer time if you want a matching estimate. For a real measurement, use your router or a dedicated speed test.',
              style: const TextStyle(color: Pigment.mute, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _Scene {
  const _Scene(this.label, this.low, this.high, this.lagLow, this.lagHigh);

  final String label;
  final double low;
  final double high;
  final int lagLow;
  final int lagHigh;
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Pigment.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pigment.mist),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              color: Pigment.olive,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
