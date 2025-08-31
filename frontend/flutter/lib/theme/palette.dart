import 'package:flutter/material.dart';

class AppPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;
  final Color error;
  final Color success;
  final Color warning;
  final Color divider;

  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.error,
    required this.success,
    required this.warning,
    required this.divider,
  });

  // Light theme using existing demo colors
  factory AppPalette.light() {
    return const AppPalette(
      primary: Color(0xFF4097FF),        // Primary Blue
      secondary: Color(0xFF8985CF),      // Purple
      accent: Color(0xFFFF92A2),         // Pink
      background: Color(0xFFFAFAFA),     // Light background
      surface: Color(0xFFFFFFFF),        // White surface
      textPrimary: Color(0xFF1A1A1A),    // Dark text
      textSecondary: Color(0xFF666666),  // Gray text
      textOnPrimary: Color(0xFFFFFFFF),  // White text on primary
      error: Color(0xFFE53E3E),          // Red
      success: Color(0xFF2E8B57),        // Sea Green
      warning: Color(0xFFFF8C00),        // Orange
      divider: Color(0xFFE0E0E0),        // Light gray divider
    );
  }

  // Dark theme
  factory AppPalette.dark() {
    return const AppPalette(
      primary: Color(0xFF4097FF),        // Primary Blue (same)
      secondary: Color(0xFF8985CF),      // Purple (same)
      accent: Color(0xFFFF92A2),         // Pink (same)
      background: Color(0xFF121212),     // Dark background
      surface: Color(0xFF1E1E1E),        // Dark surface
      textPrimary: Color(0xFFFFFFFF),    // White text
      textSecondary: Color(0xFFB3B3B3),  // Light gray text
      textOnPrimary: Color(0xFFFFFFFF),  // White text on primary
      error: Color(0xFFFF6B6B),          // Light red
      success: Color(0xFF48BB78),        // Light green
      warning: Color(0xFFFFA726),        // Light orange
      divider: Color(0xFF333333),        // Dark gray divider
    );
  }

  // Additional color variations for specific UI elements
  Color get lightBlue => const Color(0xFFA5E5F9);
  Color get lightPink => const Color(0xFFFFF3F8);
  Color get gradientStart => primary.withValues(alpha: 0.8);
  Color get gradientEnd => secondary.withValues(alpha: 0.6);
}

extension AppPaletteExtension on ThemeData {
  AppPalette get appPalette {
    return brightness == Brightness.light
        ? AppPalette.light()
        : AppPalette.dark();
  }
}