import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF0A0E2A);
  static const Color navyMid = Color(0xFF1A237E);
  static const Color purple = Color(0xFF6C3DE8);
  static const Color primary = purple;
  static const Color purpleLight = Color(0xFF9C6FFF);
  static const Color blue = Color(0xFF2979FF);
  static const Color blueLight = Color(0xFF82B1FF);
  static const Color gold = Color(0xFFFFB300);
  static const Color goldLight = Color(0xFFFFE57F);

  // Backgrounds
  static const Color bgLight = Color(0xFFF0F2FF);
  static const Color bgDark = Color(0xFF080C1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1C2541);

  // Text
  static const Color textLight = Color(0xFF1A237E);
  static const Color textDark = Color(0xFFE8EAFF);
  static const Color textMutedDark = Color(0xFF8B9DC3);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyMid, purple, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lockedGradient = LinearGradient(
    colors: [Color(0xFF1C2541), Color(0xFF0D1B3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient unlockedGradient = LinearGradient(
    colors: [Color(0xFFB8860B), Color(0xFFFFB300), Color(0xFFFFE57F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Text Theme Helper ─────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color color) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: color),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: color),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: navyMid,
      secondary: purple,
      tertiary: blue,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSurface: textLight,
    ),
    scaffoldBackgroundColor: bgLight,
    textTheme: _buildTextTheme(textLight),
    appBarTheme: AppBarTheme(
      backgroundColor: bgLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: navyMid),
      titleTextStyle: GoogleFonts.inter(
        color: navyMid, fontSize: 20, fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.indigo.withValues(alpha: 0.1)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: navyMid,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.indigo.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: purple, width: 2),
      ),
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: purpleLight,
      secondary: blueLight,
      tertiary: gold,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: bgDark,
    textTheme: _buildTextTheme(textDark),
    appBarTheme: AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textDark),
      titleTextStyle: GoogleFonts.inter(
        color: textDark, fontSize: 20, fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: purpleLight, width: 2),
      ),
      hintStyle: const TextStyle(color: textMutedDark),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: purple.withValues(alpha: 0.3),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
