import 'package:flutter/material.dart';

class NinepmTheme {
  static ThemeData themeData = ThemeData(
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFFFFFFFF),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        fixedSize: const Size.fromHeight(48),
        backgroundColor: const Color(0xFF7E4DE7),
        disabledBackgroundColor: const Color(0xFFCCCCCF),
        disabledForegroundColor: const Color(0x66FFFFFF),
        textStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );
}