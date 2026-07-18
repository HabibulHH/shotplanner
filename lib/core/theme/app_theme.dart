import 'package:flutter/material.dart';

abstract final class ShotKitColors {
  static const ink = Color(0xFF0E0F11);
  static const surface = Color(0xFF17191D);
  static const raised = Color(0xFF1F2228);
  static const line = Color(0xFF2A2D34);
  static const paper = Color(0xFFEDEBE6);
  static const dim = Color(0xFF8B8F98);
  static const tape = Color(0xFFFFB020);
  static const tapeInk = Color(0xFF161006);
  static const record = Color(0xFFFF4438);
  static const success = Color(0xFF3DDC84);
}

ThemeData buildShotKitTheme() {
  const scheme = ColorScheme.dark(
    primary: ShotKitColors.tape,
    onPrimary: ShotKitColors.tapeInk,
    secondary: ShotKitColors.success,
    onSecondary: ShotKitColors.ink,
    error: ShotKitColors.record,
    surface: ShotKitColors.surface,
    onSurface: ShotKitColors.paper,
    outline: ShotKitColors.line,
  );

  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: ShotKitColors.ink,
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: const TextStyle(
        color: ShotKitColors.paper,
        fontSize: 27,
        height: 1.02,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      headlineSmall: const TextStyle(
        color: ShotKitColors.paper,
        fontSize: 20,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: const TextStyle(
        color: ShotKitColors.paper,
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: const TextStyle(
        color: ShotKitColors.paper,
        fontSize: 15,
        height: 1.45,
      ),
      bodyMedium: const TextStyle(
        color: ShotKitColors.paper,
        fontSize: 13.5,
        height: 1.4,
      ),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      labelSmall: const TextStyle(
        color: ShotKitColors.dim,
        fontSize: 10.5,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ShotKitColors.ink,
      foregroundColor: ShotKitColors.paper,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: ShotKitColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: ShotKitColors.line),
      ),
    ),
    dividerColor: ShotKitColors.line,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: ShotKitColors.surface,
      labelStyle: TextStyle(color: ShotKitColors.dim),
      hintStyle: TextStyle(color: ShotKitColors.dim),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(11)),
        borderSide: BorderSide(color: ShotKitColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(11)),
        borderSide: BorderSide(color: ShotKitColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(11)),
        borderSide: BorderSide(color: ShotKitColors.tape, width: 1.5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ShotKitColors.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: ShotKitColors.line),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ShotKitColors.tape,
      foregroundColor: ShotKitColors.tapeInk,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
