import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'palette.dart';
import 'typography.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _fontPresetKey = 'font_preset';
  static const String _fontSizeKey = 'font_size';

  ThemeMode _themeMode = ThemeMode.system;
  AppTypography _lightTypography = AppTypography.poppinsInter();
  AppTypography _darkTypography = AppTypography.poppinsInter();
  AppPalette _lightPalette = AppPalette.light();
  AppPalette _darkPalette = AppPalette.dark();

  // Private constructor for singleton pattern
  ThemeController._();
  static final ThemeController _instance = ThemeController._();
  factory ThemeController() => _instance;

  // Getters
  ThemeMode get themeMode => _themeMode;
  AppTypography get lightTypography => _lightTypography;
  AppTypography get darkTypography => _darkTypography;
  AppPalette get lightPalette => _lightPalette;
  AppPalette get darkPalette => _darkPalette;

  // Get current typography based on brightness
  AppTypography getCurrentTypography(Brightness brightness) {
    return brightness == Brightness.light ? _lightTypography : _darkTypography;
  }

  // Get current palette based on brightness
  AppPalette getCurrentPalette(Brightness brightness) {
    return brightness == Brightness.light ? _lightPalette : _darkPalette;
  }

  // Generate theme data
  ThemeData get lightTheme => AppTheme.light(
        palette: _lightPalette,
        typography: _lightTypography,
      );

  ThemeData get darkTheme => AppTheme.dark(
        palette: _darkPalette,
        typography: _darkTypography,
      );

  // Initialize from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeModeString = prefs.getString(_themeModeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }

      // Load font preset
      final fontPresetString = prefs.getString(_fontPresetKey);
      final fontSize = prefs.getDouble(_fontSizeKey) ?? 14.0;
      
      if (fontPresetString != null) {
        final preset = FontFamilyPreset.values.firstWhere(
          (preset) => preset.toString() == fontPresetString,
          orElse: () => FontFamilyPreset.poppinsInter,
        );
        _setTypographyFromPreset(preset, fontSize);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme preferences: $e');
    }
  }

  // Toggle theme mode (system -> light -> dark -> system)
  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
    }
    await _saveThemeMode();
    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeMode();
      notifyListeners();
    }
  }

  // Set typography preset
  Future<void> setTypographyPreset(FontFamilyPreset preset, {double? baseSize}) async {
    final fontSize = baseSize ?? _lightTypography.baseSize;
    _setTypographyFromPreset(preset, fontSize);
    await _saveFontSettings(preset, fontSize);
    notifyListeners();
  }

  // Set font size
  Future<void> setFontSize(double baseSize) async {
    final currentPreset = _lightTypography.preset;
    _setTypographyFromPreset(currentPreset, baseSize);
    await _saveFontSettings(currentPreset, baseSize);
    notifyListeners();
  }

  // Set custom palette (for future use)
  void setPalette({AppPalette? lightPalette, AppPalette? darkPalette}) {
    if (lightPalette != null) {
      _lightPalette = lightPalette;
    }
    if (darkPalette != null) {
      _darkPalette = darkPalette;
    }
    notifyListeners();
  }

  // Private helper methods
  void _setTypographyFromPreset(FontFamilyPreset preset, double baseSize) {
    switch (preset) {
      case FontFamilyPreset.poppinsInter:
        _lightTypography = AppTypography.poppinsInter(baseSize: baseSize);
        _darkTypography = AppTypography.poppinsInter(baseSize: baseSize);
      case FontFamilyPreset.notoSans:
        _lightTypography = AppTypography.notoSans(baseSize: baseSize);
        _darkTypography = AppTypography.notoSans(baseSize: baseSize);
    }
  }

  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.toString());
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }

  Future<void> _saveFontSettings(FontFamilyPreset preset, double baseSize) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontPresetKey, preset.toString());
      await prefs.setDouble(_fontSizeKey, baseSize);
    } catch (e) {
      debugPrint('Failed to save font settings: $e');
    }
  }

  // Utility methods for UI
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_7;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }

  String get currentFontDisplayName => _lightTypography.displayName;

  double get currentFontSize => _lightTypography.baseSize;

  // Get available font presets
  List<FontFamilyPreset> get availableFontPresets => FontFamilyPreset.values;

  // Get display name for font preset
  String getPresetDisplayName(FontFamilyPreset preset) {
    switch (preset) {
      case FontFamilyPreset.poppinsInter:
        return 'Poppins + Inter';
      case FontFamilyPreset.notoSans:
        return 'Noto Sans';
    }
  }
}