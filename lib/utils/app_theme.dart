import 'package:flutter/material.dart';

// App colors and themes matching the Figma design
class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF5E4AE3);
  static const Color primaryLight = Color(0xFFECEBFF);
  static const Color primaryDark = Color(0xFF4534B8);

  // Backgrounds & Surfaces
  static const Color scaffoldBackground = Color(0xFFF7F8FC);
  static const Color cardBackground = Colors.white;
  static const Color borderColor = Color(0xFFE6E8F0);

  // Text colors
  static const Color textPrimary = Color(0xFF171A26);
  static const Color textSecondary = Color(0xFF757D8F);
  static const Color textMuted = Color(0xFFA0A6B5);

  // Status badge colors
  static const Color statusSubmittedBg = Color(0xFFFFF3DC);
  static const Color statusSubmittedText = Color(0xFFE28A00);

  static const Color statusInProgressBg = Color(0xFFEAE7FF);
  static const Color statusInProgressText = Color(0xFF5E4AE3);

  static const Color statusResolvedBg = Color(0xFFE3F8ED);
  static const Color statusResolvedText = Color(0xFF18A058);

  static const Color statusAlertBg = Color(0xFFFFEBEB);
  static const Color statusAlertText = Color(0xFFE53E3E);

  // App ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
