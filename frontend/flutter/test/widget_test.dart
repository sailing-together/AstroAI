import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:AstroAI/main.dart';

void main() {
  testWidgets('App builds and displays the main menu and initial page', (WidgetTester tester) async {
    // Set a larger screen size to avoid overflow errors during the test.
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const AstroAiApp());

    // Verify that the main title 'AstroAI' is present within the NavigationHeader.
    expect(
      find.descendant(
        of: find.byType(NavigationHeader),
        matching: find.text('AstroAI'),
      ),
      findsOneWidget,
    );

    // Verify that the main menu buttons are present.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Horoscope'), findsOneWidget);

    // Verify that the initial page (HeroSection) is being shown.
    expect(find.text('EXPLORE YOUR\nJOURNEY'), findsOneWidget);
  });
}
