import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color greenPrimary = Color(0xFF2ECC71);
  static const Color greenDark = Color(0xFF27AE60);
  static const Color greenLight = Color(0xFFD4F5E3);
  static const Color greenPale = Color(0xFFF0FAF4);
  
  // Alert colors
  static const Color redAction = Color(0xFFE74C3C);
  static const Color redLight = Color(0xFFFDEAEA);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  // Mode clair
  static const Color textDark = Color(0xFF1A2E1A);
  static const Color textMid = Color(0xFF4A6A4A);
  static const Color textLight = Color(0xFF7A9A7A);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgPale = Color(0xFFF8FAF8);
  static const Color border = Color(0xFFE2E8E2);
  
  // Mode sombre
  static const Color darkBg = Color(0xFF121F12);
  static const Color darkSurface = Color(0xFF1A2E1A);
  static const Color darkCard = Color(0xFF1E301E);
  static const Color darkBorder = Color(0xFF2A4A2A);
  static const Color darkText = Color(0xFFE4E4E4);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: greenPrimary,
    scaffoldBackgroundColor: bgPale,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: greenPrimary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: greenPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      color: bgWhite,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: greenPrimary,
    scaffoldBackgroundColor: darkBg,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: greenPrimary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: greenPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      color: darkCard,
    ),
  );
}