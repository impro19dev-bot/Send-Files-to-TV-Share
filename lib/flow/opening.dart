import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brand/crest.dart';
import '../brand/ink.dart';

typedef OpeningDone = void Function(BuildContext context);

class Opening extends StatefulWidget {
  const Opening({super.key, required this.onReady});

  final OpeningDone onReady;

  @override
  State<Opening> createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      widget.onReady(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Pigment.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Crest(size: 120),
            SizedBox(height: 22),
            Text(
              'Send Files to TV: Share',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Pigment.ink,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'From your iPhone to the TV',
              style: TextStyle(color: Pigment.mute, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
