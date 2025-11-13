import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color.fromRGBO(130, 30, 35, 1); // adapte selon Figma
  static const accent = Color.fromRGBO(217, 160, 162, 1);
  static const bg = Color(0xFFF8F8F8);
  static const success = Color(0xFF2EC76F);
}

final appTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.bg,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ));
