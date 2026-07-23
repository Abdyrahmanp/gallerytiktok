// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Base palette
  static const Color background  = Color(0xFF050505);
  static const Color surface     = Color(0xFF0F0F0F);
  static const Color cardSurface = Color(0xFF181818);

  // Brand accent (default — overridden at runtime by accentColorIndexProvider)
  static const Color accent     = Color(0xFFFF3B5C);
  static const Color accentGold = Color(0xFFFFD60A);
  static const Color accentBlue = Color(0xFF4CC9F0);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted     = Color(0xFF555555);

  // Semantic
  static const Color liked  = Color(0xFFFF3B5C);
  static const Color hidden = Color(0xFF9CA3AF);

  // Gradients
  static const LinearGradient bottomOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 1.0],
    colors: [
      Colors.transparent,
      Colors.transparent,
      Color(0xDD000000),
    ],
  );

  static const LinearGradient topOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.35],
    colors: [
      Color(0xAA000000),
      Colors.transparent,
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentBlue,
        surface: surface,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge:  TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          titleLarge:     TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium:    TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          bodyLarge:      TextStyle(color: textPrimary),
          bodyMedium:     TextStyle(color: textSecondary),
          labelLarge:     TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D0D0D),
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardSurface,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white54;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.white12;
        }),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
