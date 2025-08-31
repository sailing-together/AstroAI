import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'palette.dart';
import 'typography.dart';

// Export page wrapper components
export 'page_wrapper.dart';

class AppTheme {
  static ThemeData light({
    AppPalette? palette,
    AppTypography? typography,
  }) {
    final appPalette = palette ?? AppPalette.light();
    final appTypography = typography ?? AppTypography.poppinsInter();

    return _buildTheme(
      brightness: Brightness.light,
      palette: appPalette,
      typography: appTypography,
    );
  }

  static ThemeData dark({
    AppPalette? palette,
    AppTypography? typography,
  }) {
    final appPalette = palette ?? AppPalette.dark();
    final appTypography = typography ?? AppTypography.poppinsInter();

    return _buildTheme(
      brightness: Brightness.dark,
      palette: appPalette,
      typography: appTypography,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppPalette palette,
    required AppTypography typography,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.textOnPrimary,
      secondary: palette.secondary,
      onSecondary: palette.textOnPrimary,
      tertiary: palette.accent,
      onTertiary: palette.textOnPrimary,
      error: palette.error,
      onError: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.divider,
      outlineVariant: palette.divider.withValues(alpha: 0.5),
      surfaceTint: palette.primary,
    );

    final textTheme = typography.generateTextTheme(
      palette.textPrimary,
      palette.textSecondary,
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      dividerColor: palette.divider,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
        toolbarTextStyle: textTheme.bodyMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: palette.surface,
        shadowColor: palette.textPrimary.withValues(alpha: 0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.textOnPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: palette.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.error),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textSecondary,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.textSecondary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.primary,
        inactiveTrackColor: palette.divider,
        thumbColor: palette.primary,
        overlayColor: palette.primary.withValues(alpha: 0.2),
        valueIndicatorColor: palette.primary,
        valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(
          color: palette.textOnPrimary,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return palette.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary.withValues(alpha: 0.5);
          }
          return palette.divider;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.divider,
        circularTrackColor: palette.divider,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.textOnPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // Use Material 3
      useMaterial3: true,
    );
  }
}

// Extensions for easy access to custom theme properties
extension ThemeExtensions on ThemeData {
  AppPalette get palette => appPalette;
  
  // Common gradient combinations
  LinearGradient get primaryGradient => LinearGradient(
    colors: [palette.primary, palette.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get accentGradient => LinearGradient(
    colors: [palette.accent, palette.lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get backgroundGradient => LinearGradient(
    colors: [
      palette.lightBlue.withValues(alpha: 0.3),
      palette.lightPink.withValues(alpha: 0.3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}