import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:AstroAI/providers/app_state.dart';
import 'pages.dart'; // This imports all pages from pages.dart
import 'pages/daily_insights_page.dart';
import 'pages/ai_assistant_page.dart';
import 'pages/home_page.dart'; // Import the new home_page.dart
import 'pages/signup_page.dart'; // Import the new signup_page.dart
import 'pages/natal_chart_page.dart'; // Import the new natal_chart_page.dart
import 'widgets/common/navigation_header.dart'; // Import the new navigation_header.dart

void main() {
  print('AstroAI App Started!');
  runApp(const AstroAiApp());
}

class AstroAiApp extends StatelessWidget {
  const AstroAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState()..initialize(),
      child: MaterialApp(
        title: 'AstroAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        home: const HomePage(),
        routes: {
          '/daily-insights': (context) => const DailyInsightsPage(),
          '/ai-assistant': (context) => const AiAssistantPage(),
          '/natal-chart': (context) => const NatalChartPage(),
          '/matching': (context) => const MatchingPage(),
          '/about': (context) => const AboutUsPage(), // Ensure AboutUsPage is routed
          '/asmr': (context) => const ASMRPage(), // Ensure ASMRPage is routed
          '/tarot': (context) => const TarotPage(), // Ensure TarotPage is routed
          '/signup': (context) => const SignUpPage(), // Ensure SignUpPage is routed
        },
      ),
    );
  }
}