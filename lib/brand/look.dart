import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ink.dart';

ThemeData appLook() {
  const scheme = ColorScheme.dark(
    surface: Pigment.paper,
    primary: Pigment.olive,
    onPrimary: Pigment.navy,
    secondary: Pigment.clay,
    onSecondary: Pigment.navy,
    onSurface: Pigment.ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Pigment.paper,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Pigment.paper,
      foregroundColor: Pigment.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: Pigment.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Pigment.mist),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pigment.olive,
        foregroundColor: Pigment.navy,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Pigment.navy,
      indicatorColor: Pigment.olive.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Pigment.olive : Pigment.mute,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Pigment.olive);
        }
        return const IconThemeData(color: Pigment.mute);
      }),
    ),
    dividerColor: Pigment.mist,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Pigment.card,
      contentTextStyle: TextStyle(color: Pigment.ink),
    ),
    textTheme: Typography.whiteCupertino.apply(
      bodyColor: Pigment.ink,
      displayColor: Pigment.ink,
    ),
  );
}
