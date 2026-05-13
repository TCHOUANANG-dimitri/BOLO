import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFFFB772C);
  static const Color primaryDark = Color(0xFFE8651A);
  static const Color primaryLight = Color(0xFFFFEDE3);
  static const Color secondary = Color(0xFFFC6B5A);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFB772C), Color(0xFFFC6B5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFFFF8F4), Color(0xFFFFEDE3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Background
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundWarm = Color(0xFFFFF8F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Online indicator
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF9CA3AF);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Star rating
  static const Color starFilled = Color(0xFFFB772C);
  static const Color starEmpty = Color(0xFFE5E7EB);

  // Shadow
  static const Color shadow = Color(0x14000000);
  static const Color shadowMedium = Color(0x1F000000);
}
