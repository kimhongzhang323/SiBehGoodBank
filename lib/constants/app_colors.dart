import 'package:flutter/material.dart';

/// App color palette following the glassmorphism + holographic theme
class AppColors {
  // Primary gradient colors
  static const Color lavender = Color(0xFFE3D7FF);
  static const Color pastelBlue = Color(0xFFC9D7FF);
  static const Color pinkTint = Color(0xFFEDD9F5);
  static const Color softPurple = Color(0xFFCFD1FF);
  static const Color lilac = Color(0xFFE5C9FF);
  
  // Extended palette
  static const Color lightBlue = Color(0xFFD6F0FF);
  static const Color softPink = Color(0xFFFFE8F7);
  
  // UI colors
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8D);
  static const Color textLight = Color(0xFF9999B3);
  
  // Status colors
  static const Color positive = Color(0xFF4CAF50);
  static const Color negative = Color(0xFFE53935);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentBlue = Color(0xFF4A90E2);
  
  // Glass effect colors
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassWhiteLight = Color(0x66FFFFFF);
  static const Color glassWhiteMedium = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Card backgrounds
  static const Color cardBackground = Color(0xFFF8F6FF);
  static const Color cardBackgroundAlt = Color(0xFFF0F4FF);
  
  // Holographic gradient
  static const List<Color> holographicGradient = [
    Color(0xFFD7C8FF),
    Color(0xFFD6F0FF),
    Color(0xFFFFE8F7),
    Color(0xFFCFD1FF),
    Color(0xFFE5C9FF),
  ];
  
  static const List<double> holographicStops = [0.0, 0.2, 0.45, 0.7, 1.0];
  
  // Tab colors
  static const Color tabActive = Color(0xFFE8EFFF);
  static const Color tabInactive = Colors.transparent;
}
