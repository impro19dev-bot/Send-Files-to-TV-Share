import 'package:flutter/material.dart';

/// Launcher artwork used inside the app as well.
class Crest extends StatelessWidget {
  const Crest({super.key, this.size = 88});

  static const asset = 'assets/icons/app_icon.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
