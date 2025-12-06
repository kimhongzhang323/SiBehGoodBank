import 'package:flutter/material.dart';

/// App color palette - Premium Fintech Theme
class AppColors {
  // Primary dark green colors (header & accents)
  static const Color primaryNavy = Color(0xFF1A3D2E); // Deep forest green
  static const Color darkNavy = Color(0xFF0F2A1F); // Darker green
  static const Color softNavy = Color(0xFF234D3A); // Soft dark green for header
  static const Color mutedNavy = Color(0xFF2D5A45); // Muted green

  // Accent colors
  static const Color accentTeal = Color(0xFF00C9A7); // Fintech teal accent
  static const Color accentGold = Color(0xFFD4AF37); // Premium gold

  // Legacy green names mapped to dark green (for compatibility)
  static const Color primaryGreen = Color(0xFF1A3D2E);
  static const Color darkGreen = Color(0xFF0F2A1F);
  static const Color lightGreen = Color(0xFF3A6B52);
  static const Color softGreen = Color(0xFF234D3A); // Used for header
  static const Color mintGreen = Color(0xFFE8F2ED);

  // Cream/neutral colors
  static const Color cream = Color(0xFFFAFBFC);
  static const Color lightCream = Color(0xFFF5F7FA);
  static const Color warmCream = Color(0xFFF0F2F5);

  // Legacy colors (keeping for compatibility)
  static const Color lavender = Color(0xFFE8F2ED);
  static const Color pastelBlue = Color(0xFFE8F2ED);
  static const Color pinkTint = Color(0xFFF5F7FA);
  static const Color softPurple = Color(0xFFE8F2ED);
  static const Color lilac = Color(0xFFE8F2ED);

  // Extended palette
  static const Color lightBlue = Color(0xFFE8F2ED);
  static const Color softPink = Color(0xFFF5F7FA);

  // UI colors
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xB3FFFFFF); // 70% white

  // Status colors
  static const Color positive = Color(0xFF00C9A7);
  static const Color negative = Color(0xFFEF4444);
  static const Color accent = Color(0xFF00C9A7); // Teal accent
  static const Color accentBlue = Color(0xFF3B82F6);

  // Glass effect colors
  static const Color glassWhite = Color(0x14FFFFFF); // 8% white
  static const Color glassWhiteLight = Color(0x1FFFFFFF); // 12% white
  static const Color glassWhiteMedium = Color(0x29FFFFFF); // 16% white
  static const Color glassBorder = Color(0x1FFFFFFF);

  // Card backgrounds
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundAlt = Color(0xFFF5F7FA);

  // Gradient for header (dark green)
  static const List<Color> headerGradient = [
    Color(0xFF1A3D2E),
    Color(0xFF234D3A),
  ];

  // Legacy gradient (mapped to new colors)
  static const List<Color> holographicGradient = [
    Color(0xFFE8F2ED),
    Color(0xFFD1E6DB),
    Color(0xFFF5F7FA),
    Color(0xFFE0EFE7),
    Color(0xFFE8F2ED),
  ];

  static const List<double> holographicStops = [0.0, 0.2, 0.45, 0.7, 1.0];

  // Tab colors
  static const Color tabActive = Color(0xFFE8F2ED);
  static const Color tabInactive = Colors.transparent;
}
