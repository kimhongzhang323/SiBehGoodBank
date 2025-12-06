import 'package:flutter/material.dart';

/// App color palette following a green and cream theme
class AppColors {
  // Primary green colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color softGreen = Color(0xFFE8F5E9);
  static const Color mintGreen = Color(0xFFC8E6C9);

  // Cream colors
  static const Color cream = Color(0xFFFFFBF5);
  static const Color lightCream = Color(0xFFFFF8E7);
  static const Color warmCream = Color(0xFFFAF3E0);

  // Legacy colors (keeping for compatibility)
  static const Color lavender = Color(0xFFE8F5E9);
  static const Color pastelBlue = Color(0xFFE8F5E9);
  static const Color pinkTint = Color(0xFFFFF8E7);
  static const Color softPurple = Color(0xFFC8E6C9);
  static const Color lilac = Color(0xFFE8F5E9);

  // Extended palette
  static const Color lightBlue = Color(0xFFE8F5E9);
  static const Color softPink = Color(0xFFFFF8E7);

  // UI colors
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5D6D5D);
  static const Color textLight = Color(0xFF8A9A8A);

  // Status colors
  static const Color positive = Color(0xFF4CAF50);
  static const Color negative = Color(0xFFE53935);
  static const Color accent = Color(0xFF2E7D32); // Changed to green
  static const Color accentBlue = Color(0xFF43A047);

  // Glass effect colors
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassWhiteLight = Color(0x66FFFFFF);
  static const Color glassWhiteMedium = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Card backgrounds
  static const Color cardBackground = Color(0xFFFFFBF5);
  static const Color cardBackgroundAlt = Color(0xFFF5FFF5);

  // Green and cream gradient
  static const List<Color> holographicGradient = [
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
    Color(0xFFFFF8E7),
    Color(0xFFA5D6A7),
    Color(0xFFE8F5E9),
  ];

  static const List<double> holographicStops = [0.0, 0.2, 0.45, 0.7, 1.0];

  // Tab colors
  static const Color tabActive = Color(0xFFE8F5E9);
  static const Color tabInactive = Colors.transparent;
}
