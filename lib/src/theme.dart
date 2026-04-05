import 'package:flutter/material.dart';

class AppPalette {
  static const Color canvas = Color(0xFFFFF7F0);
  static const Color paper = Color(0xFFFFFCF8);
  static const Color ink = Color(0xFF161B2C);
  static const Color mutedInk = Color(0xFF586076);
  static const Color coral = Color(0xFFFF6B4A);
  static const Color sky = Color(0xFF267BFF);
  static const Color cyan = Color(0xFF08B5D6);
  static const Color lime = Color(0xFF9BD722);
  static const Color gold = Color(0xFFF3B31C);
  static const Color blush = Color(0xFFFFE2D3);
  static const Color line = Color(0xFFE4D6C8);
}

ThemeData buildPoliscopeTheme() {
  final base = ThemeData(useMaterial3: true);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppPalette.coral,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppPalette.coral,
        secondary: AppPalette.sky,
        tertiary: AppPalette.lime,
        surface: AppPalette.paper,
        onSurface: AppPalette.ink,
        outline: AppPalette.line,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.canvas,
    fontFamily: 'UbuntuSans',
    textTheme: base.textTheme.copyWith(
      displayMedium: base.textTheme.displayMedium?.copyWith(
        color: AppPalette.ink,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -1.3,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        color: AppPalette.ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: AppPalette.ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: AppPalette.ink,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: AppPalette.ink,
        height: 1.35,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: AppPalette.mutedInk,
        height: 1.35,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        color: AppPalette.ink,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppPalette.ink,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        foregroundColor: AppPalette.ink,
        side: const BorderSide(color: AppPalette.line, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.ink,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Color axisColor(String axisCode) => switch (axisCode) {
  'eco' => AppPalette.coral,
  'auth' => AppPalette.cyan,
  'cult' => AppPalette.gold,
  'eu' => AppPalette.sky,
  'ecolo' => AppPalette.lime,
  _ => AppPalette.ink,
};

IconData axisIcon(String axisCode) => switch (axisCode) {
  'eco' => Icons.payments_rounded,
  'auth' => Icons.balance_rounded,
  'cult' => Icons.groups_rounded,
  'eu' => Icons.public_rounded,
  'ecolo' => Icons.eco_rounded,
  _ => Icons.auto_awesome_rounded,
};

String axisPillLabel(String axisCode) => switch (axisCode) {
  'eco' => 'Économie',
  'auth' => 'Libertés & autorité',
  'cult' => 'Société',
  'eu' => 'Europe',
  'ecolo' => 'Écologie',
  _ => 'Axe',
};
