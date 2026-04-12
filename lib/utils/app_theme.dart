import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF5B67F1);
  static const Color secondary = Color(0xFF8C93FF);
  static const Color accent = Color(0xFF1FC8A5);
  static const Color textDark = Color(0xFF1E2235);
  static const Color textMuted = Color(0xFF6C728A);
  static const Color border = Color(0xFFE7E9F2);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textDark,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMuted,
          height: 1.4,
        ),
      ),
    );
  }
}
