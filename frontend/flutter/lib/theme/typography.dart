import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FontFamilyPreset {
  poppinsInter,
  notoSans,
}

class AppTypography {
  final String headingFamily;
  final String bodyFamily;
  final double baseSize;
  final FontFamilyPreset preset;

  const AppTypography({
    required this.headingFamily,
    required this.bodyFamily,
    required this.baseSize,
    required this.preset,
  });

  // Poppins + Inter preset (Modern, geometric)
  factory AppTypography.poppinsInter({double baseSize = 14.0}) {
    return AppTypography(
      headingFamily: 'Poppins',
      bodyFamily: 'Inter',
      baseSize: baseSize,
      preset: FontFamilyPreset.poppinsInter,
    );
  }

  // Noto Sans preset (Clean, readable)
  factory AppTypography.notoSans({double baseSize = 14.0}) {
    return AppTypography(
      headingFamily: 'Noto Sans',
      bodyFamily: 'Noto Sans',
      baseSize: baseSize,
      preset: FontFamilyPreset.notoSans,
    );
  }

  // Generate TextTheme based on the current typography settings
  TextTheme generateTextTheme(Color textColor, Color textSecondary) {
    final headingTextStyle = _getHeadingTextStyle();
    final bodyTextStyle = _getBodyTextStyle();

    return TextTheme(
      // Display styles (largest)
      displayLarge: headingTextStyle.copyWith(
        fontSize: baseSize * 4.0, // 56px at base 14
        fontWeight: FontWeight.w300,
        letterSpacing: -0.25,
        color: textColor,
      ),
      displayMedium: headingTextStyle.copyWith(
        fontSize: baseSize * 3.2, // 45px at base 14
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        color: textColor,
      ),
      displaySmall: headingTextStyle.copyWith(
        fontSize: baseSize * 2.6, // 36px at base 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
      ),

      // Headline styles
      headlineLarge: headingTextStyle.copyWith(
        fontSize: baseSize * 2.3, // 32px at base 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
      ),
      headlineMedium: headingTextStyle.copyWith(
        fontSize: baseSize * 2.0, // 28px at base 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
      ),
      headlineSmall: headingTextStyle.copyWith(
        fontSize: baseSize * 1.7, // 24px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textColor,
      ),

      // Title styles
      titleLarge: headingTextStyle.copyWith(
        fontSize: baseSize * 1.6, // 22px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textColor,
      ),
      titleMedium: headingTextStyle.copyWith(
        fontSize: baseSize * 1.1, // 16px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
      titleSmall: headingTextStyle.copyWith(
        fontSize: baseSize * 1.0, // 14px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),

      // Body styles
      bodyLarge: bodyTextStyle.copyWith(
        fontSize: baseSize * 1.1, // 16px at base 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textColor,
      ),
      bodyMedium: bodyTextStyle.copyWith(
        fontSize: baseSize * 1.0, // 14px at base 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      bodySmall: bodyTextStyle.copyWith(
        fontSize: baseSize * 0.86, // 12px at base 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textSecondary,
      ),

      // Label styles
      labelLarge: bodyTextStyle.copyWith(
        fontSize: baseSize * 1.0, // 14px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: bodyTextStyle.copyWith(
        fontSize: baseSize * 0.86, // 12px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
      ),
      labelSmall: bodyTextStyle.copyWith(
        fontSize: baseSize * 0.79, // 11px at base 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );
  }

  // Get heading text style based on current preset
  TextStyle _getHeadingTextStyle() {
    switch (preset) {
      case FontFamilyPreset.poppinsInter:
        return GoogleFonts.poppins();
      case FontFamilyPreset.notoSans:
        return GoogleFonts.notoSans();
    }
  }

  // Get body text style based on current preset
  TextStyle _getBodyTextStyle() {
    switch (preset) {
      case FontFamilyPreset.poppinsInter:
        return GoogleFonts.inter();
      case FontFamilyPreset.notoSans:
        return GoogleFonts.notoSans();
    }
  }

  // Create a copy with different parameters
  AppTypography copyWith({
    String? headingFamily,
    String? bodyFamily,
    double? baseSize,
    FontFamilyPreset? preset,
  }) {
    return AppTypography(
      headingFamily: headingFamily ?? this.headingFamily,
      bodyFamily: bodyFamily ?? this.bodyFamily,
      baseSize: baseSize ?? this.baseSize,
      preset: preset ?? this.preset,
    );
  }

  // Get display name for UI
  String get displayName {
    switch (preset) {
      case FontFamilyPreset.poppinsInter:
        return 'Poppins + Inter';
      case FontFamilyPreset.notoSans:
        return 'Noto Sans';
    }
  }
}

extension AppTypographyExtension on ThemeData {
  AppTypography get appTypography {
    // This will be managed by ThemeController
    return AppTypography.poppinsInter(baseSize: 14.0);
  }
}