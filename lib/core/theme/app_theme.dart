import 'package:flutter/material.dart';

/// Material Design 3 theme for AquaGuard
/// Neutral base: blue / grey with status colors
class AppTheme {
  AppTheme._();

  // Status colors
  static const Color statusNormal = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFF57C00);
  static const Color statusCritical = Color(0xFFC62828);
  static const Color statusOffline = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
        primary: const Color(0xFF1565C0),
        secondary: const Color(0xFF455A64),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF42A5F5),
        brightness: Brightness.dark,
        primary: const Color(0xFF42A5F5),
        secondary: const Color(0xFF78909C),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
