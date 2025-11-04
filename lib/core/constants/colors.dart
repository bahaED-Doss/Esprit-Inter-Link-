import 'package:flutter/material.dart';

/// Central color definitions for the app.
/// This is like your Angular theme or SCSS variables.
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFFBB86FC);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFB00020);
  static const Color divider = Color(0xFFE0E0E0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
