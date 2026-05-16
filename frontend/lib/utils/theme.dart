import 'package:flutter/material.dart';

class AppTheme {
  static const Color greenPrimary = Color(0xFF2ECC71);
  static const Color greenDark = Color(0xFF1aab57);
  static const Color greenLight = Color(0xFFd4f5e3);
  static const Color greenPale = Color(0xFFf0faf4);
  static const Color redAction = Color(0xFFe74c3c);
  static const Color redLight = Color(0xFFfdecea);
  static const Color textDark = Color(0xFF1a2e1a);
  static const Color textMid = Color(0xFF4a6a4a);
  static const Color textLight = Color(0xFF7a9a7a);
  static const Color bgWhite = Color(0xFFffffff);
  static const Color bgPale = Color(0xFFf8faf8);
  static const Color border = Color(0xFFe2e8e2);
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: greenPrimary,
    scaffoldBackgroundColor: bgPale,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
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
      color: Colors.white,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    primaryColor: greenPrimary,
    scaffoldBackgroundColor: const Color(0xFF121f12),
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1a2e1a),
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1e301e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2a4a2a)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2a4a2a)),
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
      color: Color(0xFF1e301e),
    ),
  );
}