import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // Colors
  // ============================================================

  static const Color primaryNavy = Color(0xFF1A237E);
  static const Color primaryPurple = Color(0xFF651FFF);
  static const Color primaryBlue = Color(0xFF2979FF);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0B0B1E);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF15152B);

  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF2A2A45);

  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);

  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0C0);

  // ============================================================
  // Border Radius
  // ============================================================

  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 18;
  static const double radiusXLarge = 22;

  // ============================================================
  // Light Theme
  // ============================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: primaryNavy,
      secondary: primaryPurple,
      tertiary: primaryBlue,
      surface: surfaceLight,
    ),

    scaffoldBackgroundColor: backgroundLight,

    // ------------------------------------------------------------
    // AppBar
    // ------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryNavy),
      titleTextStyle: TextStyle(
        color: primaryNavy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // ------------------------------------------------------------
    // Card
    // ------------------------------------------------------------
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: const BorderSide(color: borderLight, width: 0.6),
      ),
    ),

    // ------------------------------------------------------------
    // Elevated Button
    // ------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),

    // ------------------------------------------------------------
    // Outlined Button
    // ------------------------------------------------------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryNavy,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: const BorderSide(color: primaryNavy, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // ------------------------------------------------------------
    // Input Fields
    // ------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryNavy, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondaryLight),
      hintStyle: const TextStyle(color: textSecondaryLight),
    ),

    // ------------------------------------------------------------
    // Divider
    // ------------------------------------------------------------
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 0.8,
      space: 1,
    ),

    // ------------------------------------------------------------
    // TabBar
    // ------------------------------------------------------------
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryNavy,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryNavy,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // ------------------------------------------------------------
    // Floating Action Button
    // ------------------------------------------------------------
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    // ------------------------------------------------------------
    // SnackBar
    // ------------------------------------------------------------
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
  );

  // ============================================================
  // Dark Theme
  // ============================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryBlue,
      tertiary: primaryNavy,
      surface: surfaceDark,
    ),

    scaffoldBackgroundColor: backgroundDark,

    // ------------------------------------------------------------
    // AppBar
    // ------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // ------------------------------------------------------------
    // Card
    // ------------------------------------------------------------
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: const BorderSide(color: borderDark, width: 0.6),
      ),
    ),

    // ------------------------------------------------------------
    // Elevated Button
    // ------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),

    // ------------------------------------------------------------
    // Outlined Button
    // ------------------------------------------------------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: const BorderSide(color: primaryPurple, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // ------------------------------------------------------------
    // Input Fields
    // ------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondaryDark),
      hintStyle: const TextStyle(color: textSecondaryDark),
    ),

    // ------------------------------------------------------------
    // Divider
    // ------------------------------------------------------------
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 0.8,
      space: 1,
    ),

    // ------------------------------------------------------------
    // TabBar
    // ------------------------------------------------------------
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: primaryPurple,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // ------------------------------------------------------------
    // Floating Action Button
    // ------------------------------------------------------------
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    // ------------------------------------------------------------
    // SnackBar
    // ------------------------------------------------------------
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
  );
}
