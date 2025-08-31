import 'package:flutter/material.dart';
import '../widgets/common/navigation_header.dart';
import 'app_theme.dart';

/// Standardized page wrapper that provides consistent scrolling pattern,
/// background, and navigation across all pages in the app
class PageWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final bool showHeader;
  final Color? backgroundColor;
  final bool useCosmicGradient;

  const PageWrapper({
    super.key,
    required this.child,
    this.padding,
    this.constraints,
    this.showHeader = true,
    this.backgroundColor,
    this.useCosmicGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).palette.lightPink,
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: EdgeInsets.only(top: showHeader ? 89 : 0), // Header height
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - (showHeader ? 89 : 0),
                ),
                decoration: useCosmicGradient
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).palette.primary,
                            Theme.of(context).palette.accent,
                            Theme.of(context).palette.lightBlue,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      )
                    : null,
                child: Center(
                  child: Container(
                    constraints: constraints ?? const BoxConstraints(maxWidth: 1440),
                    padding: padding ?? const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          // Fixed header on top
          if (showHeader)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: NavigationHeader(),
            ),
        ],
      ),
    );
  }
}

/// Specialized wrapper for form pages (like sign up, settings)
class FormPageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsets? contentPadding;

  const FormPageWrapper({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 8),
              blurRadius: 32,
            ),
          ],
        ),
        padding: contentPadding ?? const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).palette.primary,
                    Theme.of(context).palette.secondary,
                  ],
                ).createShader(bounds),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).palette.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Specialized wrapper for content pages (like features, info pages)
class ContentPageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsets? contentPadding;
  final bool showGradientBackground;

  const ContentPageWrapper({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.contentPadding,
    this.showGradientBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      useCosmicGradient: showGradientBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.8),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 60),
          ],
          Padding(
            padding: contentPadding ?? EdgeInsets.zero,
            child: child,
          ),
        ],
      ),
    );
  }
}