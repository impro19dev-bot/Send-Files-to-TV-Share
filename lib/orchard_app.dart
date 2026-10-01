import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brand/look.dart';
import 'flow/deck.dart';
import 'flow/opening.dart';
import 'flow/primer.dart';

const primerDoneKey = 'orchard_primer_done';

void launchOrchard(SharedPreferences prefs) {
  runApp(OrchardApp(prefs: prefs));
}

class OrchardApp extends StatelessWidget {
  const OrchardApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send Files to TV: Share',
      debugShowCheckedModeBanner: false,
      theme: appLook(),
      home: Opening(
        onReady: (context) {
          final seen = prefs.getBool(primerDoneKey) ?? false;
          final Widget next = seen ? const Deck() : Primer(prefs: prefs);
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              transitionDuration: const Duration(milliseconds: 520),
              pageBuilder: (_, animation, _) =>
                  FadeTransition(opacity: animation, child: next),
            ),
          );
        },
      ),
    );
  }
}
