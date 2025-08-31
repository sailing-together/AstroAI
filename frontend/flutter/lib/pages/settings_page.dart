import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_controller.dart';
import '../theme/typography.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).palette.lightBlue.withValues(alpha: 0.2),
              Theme.of(context).palette.lightPink.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildPreviewSection(context),
                  const SizedBox(height: 32),
                  _buildThemeSection(context),
                  const SizedBox(height: 24),
                  _buildFontSection(context),
                  const SizedBox(height: 24),
                  _buildFontSizeSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).palette.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Theme Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).palette.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: Theme.of(context).palette.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).palette.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Sample text
            Text(
              'This is a Headline Style',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This is body text style, showcasing the current font and size selection. AstroAI provides personalized astrological insights tailored to your unique cosmic profile.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Sample button
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sample Button'),
            ),
            const SizedBox(height: 16),
            
            // Sample card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).palette.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).palette.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).palette.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Title',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This is the card content description',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      themeController.themeModeIcon,
                      color: Theme.of(context).palette.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Theme Mode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildThemeButton(
                      context,
                      themeController,
                      ThemeMode.system,
                      Icons.brightness_auto,
                      'System',
                    ),
                    const SizedBox(width: 12),
                    _buildThemeButton(
                      context,
                      themeController,
                      ThemeMode.light,
                      Icons.brightness_7,
                      'Light',
                    ),
                    const SizedBox(width: 12),
                    _buildThemeButton(
                      context,
                      themeController,
                      ThemeMode.dark,
                      Icons.brightness_2,
                      'Dark',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    ThemeController controller,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = controller.themeMode == mode;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: OutlinedButton.icon(
          onPressed: () => controller.setThemeMode(mode),
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).palette.primary
                : Colors.transparent,
            foregroundColor: isSelected
                ? Theme.of(context).palette.textOnPrimary
                : Theme.of(context).palette.primary,
            side: BorderSide(
              color: Theme.of(context).palette.primary,
              width: isSelected ? 2 : 1,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFontSection(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.font_download,
                      color: Theme.of(context).palette.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Font Family',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFontButton(
                      context,
                      themeController,
                      FontFamilyPreset.poppinsInter,
                      'Poppins + Inter',
                    ),
                    const SizedBox(width: 12),
                    _buildFontButton(
                      context,
                      themeController,
                      FontFamilyPreset.notoSans,
                      'Noto Sans',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontButton(
    BuildContext context,
    ThemeController controller,
    FontFamilyPreset preset,
    String label,
  ) {
    final isSelected = controller.lightTypography.preset == preset;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: OutlinedButton(
          onPressed: () => controller.setTypographyPreset(preset),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).palette.secondary
                : Colors.transparent,
            foregroundColor: isSelected
                ? Theme.of(context).palette.textOnPrimary
                : Theme.of(context).palette.secondary,
            side: BorderSide(
              color: Theme.of(context).palette.secondary,
              width: isSelected ? 2 : 1,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildFontSizeSection(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_size,
                      color: Theme.of(context).palette.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Font Size',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).palette.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${themeController.currentFontSize.toInt()}px',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).palette.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Small',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: Slider(
                        value: themeController.currentFontSize,
                        min: 12.0,
                        max: 18.0,
                        divisions: 6,
                        onChanged: (value) => themeController.setFontSize(value),
                        activeColor: Theme.of(context).palette.accent,
                        inactiveColor: Theme.of(context).palette.divider,
                      ),
                    ),
                    Text(
                      'Large',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag the slider to adjust global font size',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}