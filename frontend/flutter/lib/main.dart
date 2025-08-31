import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AstroAI/providers/app_state.dart';
import 'pages.dart'; // This imports all pages from pages.dart
import 'pages/daily_insights_page.dart';
import 'pages/ai_assistant_page.dart';
import 'pages/home_page.dart'; // Import the new home_page.dart
import 'pages/signup_page.dart'; // Import the new signup_page.dart
import 'pages/settings_page.dart';
import 'theme/theme_controller.dart';
// Import the new natal_chart_page.dart
// Import the new navigation_header.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize theme controller
  final themeController = ThemeController();
  await themeController.initialize();
  
  print('AstroAI App Started!');
  runApp(AstroAiApp(themeController: themeController));
}

class AstroAiApp extends StatelessWidget {
  final ThemeController themeController;
  
  const AstroAiApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()..initialize()),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'AstroAI',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.themeMode,
            theme: themeController.lightTheme,
            darkTheme: themeController.darkTheme,
            home: const HomePage(),
            routes: {
              '/daily-insights': (context) => const DailyInsightsPage(),
              '/ai-assistant': (context) => const AiAssistantPage(),
              '/natal-chart': (context) => const NatalChartPage(),
              '/matching': (context) => const MatchingPage(),
              '/about': (context) => const AboutUsPage(),
              '/asmr': (context) => const ASMRPage(),
              '/tarot': (context) => const TarotPage(),
              '/signup': (context) => const SignUpPage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}