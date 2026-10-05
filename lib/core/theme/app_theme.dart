import 'package:flutter/material.dart';

abstract final class ShotKitColors {
  static const ink = Color(0xFF0E0F11);
  static const nav = Color(0xFF121418);
  static const surface = Color(0xFF16181C);
  static const raised = Color(0xFF1E2127);
  static const line = Color(0xFF2A2D34);
  static const grid = Color(0xFF2C3038);
  static const strong = Color(0xFF3A3E47);
  static const paper = Color(0xFFEDEBE6);
  static const subtle = Color(0xFFC9CCD2);
  static const dim = Color(0xFF9097A1);
  static const tape = Color(0xFFFFB020);
  static const tapeSoft = Color(0x1FFFB020);
  static const tapeInk = Color(0xFF161006);
  static const record = Color(0xFFFF4438);
  static const success = Color(0xFF3DDC84);
  static const cam = Color(0xFF8FB4FF);
}

/// Bundled typefaces (see pubspec.yaml). Static instances, so FontWeight
/// selects real cuts instead of synthesised bold.
abstract final class ShotKitFonts {
  static const sans = 'Archivo';
  static const semiCondensed = 'ArchivoSemiCondensed';
  static const condensed = 'ArchivoCondensed';
  static const mono = 'JetBrainsMono';
}

abstract final class ShotKitText {
  /// Uppercase condensed screen titles ("PREP & DETAILS").
  static TextStyle display(
          {double size = 34, Color color = ShotKitColors.paper}) =>
      TextStyle(
        fontFamily: ShotKitFonts.condensed,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.02,
        letterSpacing: .2,
        color: color,
      );

  /// Semi-condensed headline for the shot or project in focus.
  static TextStyle headline(
          {double size = 25, Color color = ShotKitColors.paper}) =>
      TextStyle(
        fontFamily: ShotKitFonts.semiCondensed,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: color,
      );

  /// Monospace for shot codes, specs and counters.
  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w500,
    Color color = ShotKitColors.dim,
    double spacing = 0,
    double? height,
  }) =>
      TextStyle(
        fontFamily: ShotKitFonts.mono,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height,
      );

  /// Tracked uppercase section label.
  static const label = TextStyle(
    fontFamily: ShotKitFonts.mono,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    height: 1.2,
    color: ShotKitColors.dim,
  );
}

/// On-set mode can switch to a high-contrast daylight palette for shooting
/// outdoors, so it reads its colors from here instead of the app theme.
@immutable
class OnSetPalette {
  const OnSetPalette({
    required this.daylight,
    required this.ground,
    required this.surface,
    required this.raised,
    required this.line,
    required this.text,
    required this.dim,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.record,
    required this.success,
    required this.onSuccess,
    required this.frame,
    required this.grid,
    required this.glyph,
    required this.glyphFill,
    required this.bracket,
    required this.stripe,
  });

  final bool daylight;
  final Color ground;
  final Color surface;
  final Color raised;
  final Color line;
  final Color text;
  final Color dim;
  final Color accent;
  final Color accentText;
  final Color onAccent;
  final Color record;
  final Color success;
  final Color onSuccess;
  final Color frame;
  final Color grid;
  final Color glyph;
  final Color glyphFill;
  final Color bracket;
  final Color stripe;

  static const dark = OnSetPalette(
    daylight: false,
    ground: ShotKitColors.ink,
    surface: ShotKitColors.surface,
    raised: ShotKitColors.raised,
    line: ShotKitColors.line,
    text: ShotKitColors.paper,
    dim: ShotKitColors.dim,
    accent: ShotKitColors.tape,
    accentText: ShotKitColors.tape,
    onAccent: ShotKitColors.tapeInk,
    record: ShotKitColors.record,
    success: ShotKitColors.success,
    onSuccess: ShotKitColors.ink,
    frame: ShotKitColors.raised,
    grid: ShotKitColors.grid,
    glyph: ShotKitColors.tape,
    glyphFill: Color(0x24FFB020),
    bracket: Color(0xB3EDEBE6),
    stripe: ShotKitColors.tape,
  );

  static const daylightPalette = OnSetPalette(
    daylight: true,
    ground: Color(0xFFF3F0E8),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFECE8DE),
    line: Color(0xFFD6D0C2),
    text: Color(0xFF121212),
    dim: Color(0xFF565B64),
    accent: ShotKitColors.tape,
    accentText: Color(0xFF8A5600),
    onAccent: ShotKitColors.tapeInk,
    record: Color(0xFFC42B1F),
    success: Color(0xFF0E7A3B),
    onSuccess: Color(0xFFFFFFFF),
    frame: Color(0xFFECE8DE),
    grid: Color(0xFFD9D3C5),
    glyph: Color(0xFF8A5600),
    glyphFill: Color(0x1A8A5600),
    bracket: Color(0x8C121212),
    stripe: Color(0xFF121212),
  );
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
    onSurfaceVariant: ShotKitColors.dim,
    outline: ShotKitColors.line,
    outlineVariant: ShotKitColors.line,
    surfaceContainerHighest: ShotKitColors.raised,
  );

  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: ShotKitColors.ink,
    fontFamily: ShotKitFonts.sans,
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
  );

  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  const buttonText = TextStyle(
    fontFamily: ShotKitFonts.sans,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: .2,
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(
          fontFamily: ShotKitFonts.sans,
          bodyColor: ShotKitColors.paper,
          displayColor: ShotKitColors.paper,
        )
        .copyWith(
          displaySmall: ShotKitText.display(),
          headlineSmall: ShotKitText.headline(size: 24),
          titleMedium: const TextStyle(
            fontFamily: ShotKitFonts.sans,
            color: ShotKitColors.paper,
            fontSize: 17,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: const TextStyle(
            fontFamily: ShotKitFonts.sans,
            color: ShotKitColors.paper,
            fontSize: 15,
            height: 1.45,
          ),
          bodyMedium: const TextStyle(
            fontFamily: ShotKitFonts.sans,
            color: ShotKitColors.paper,
            fontSize: 14,
            height: 1.4,
          ),
          labelLarge: buttonText,
          labelSmall: ShotKitText.label,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ShotKitColors.ink,
      foregroundColor: ShotKitColors.paper,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: ShotKitFonts.sans,
        color: ShotKitColors.paper,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: ShotKitColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: ShotKitColors.line),
      ),
    ),
    dividerColor: ShotKitColors.line,
    dividerTheme: const DividerThemeData(color: ShotKitColors.line),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: ShotKitColors.surface,
      labelStyle: TextStyle(color: ShotKitColors.dim),
      hintStyle: TextStyle(color: ShotKitColors.dim),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: ShotKitColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: ShotKitColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: ShotKitColors.tape, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ShotKitColors.tape,
        foregroundColor: ShotKitColors.tapeInk,
        disabledBackgroundColor: ShotKitColors.raised,
        disabledForegroundColor: ShotKitColors.dim,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: ShotKitColors.raised,
        foregroundColor: ShotKitColors.paper,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        side: const BorderSide(color: ShotKitColors.line),
        shape: buttonShape,
        textStyle: buttonText.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ShotKitColors.tape,
        minimumSize: const Size(44, 44),
        textStyle: buttonText.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ShotKitColors.tapeInk
            : ShotKitColors.dim,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ShotKitColors.tape
            : ShotKitColors.raised,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ShotKitColors.tape
            : ShotKitColors.strong,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ShotKitColors.tape,
      linearTrackColor: ShotKitColors.line,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ShotKitColors.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: ShotKitColors.line),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: ShotKitColors.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: ShotKitColors.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: ShotKitColors.line),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ShotKitColors.raised,
      actionTextColor: ShotKitColors.tape,
      contentTextStyle: TextStyle(
        fontFamily: ShotKitFonts.sans,
        color: ShotKitColors.paper,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
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
