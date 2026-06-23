import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF08152E);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
    ),
  );
}