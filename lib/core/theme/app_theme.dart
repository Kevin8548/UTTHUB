import 'package:flutter/material.dart';

class AppColorScheme {
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color emerald;
  final Color emeraldDim;
  final Color amber;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.emerald,
    required this.emeraldDim,
    required this.amber,
  });

  static const dark = AppColorScheme(
    background: Color(0xFF0B0F0E),
    surface: Color(0xFF14181A),
    border: Color(0xFF262E2C),
    textPrimary: Color(0xFFF4F6F5),
    textMuted: Color(0xFF8A938F),
    emerald: Color(0xFF34D399),
    emeraldDim: Color(0xFF1F7A5C),
    amber: Color(0xFFF5B942),
  );

  static const light = AppColorScheme(
    background: Color(0xFFF7F8F7),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE3E7E5),
    textPrimary: Color(0xFF14181A),
    textMuted: Color(0xFF6B756F),
    emerald: Color(0xFF0E9E70),
    emeraldDim: Color(0xFFBFE9D9),
    amber: Color(0xFFC98A1B),
  );
}

extension AppColorsX on BuildContext {
  AppColorScheme get colors => Theme.of(this).brightness == Brightness.dark
      ? AppColorScheme.dark
      : AppColorScheme.light;
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _themeFor(AppColorScheme.dark, Brightness.dark);
  static ThemeData get light =>
      _themeFor(AppColorScheme.light, Brightness.light);

  static ThemeData _themeFor(AppColorScheme colors, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: colors.emerald,
        secondary: colors.amber,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        brightness: brightness,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 14,
          color: colors.textMuted,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: colors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.emerald,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
