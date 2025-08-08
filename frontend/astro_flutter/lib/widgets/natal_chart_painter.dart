import 'dart:math';
import 'package:flutter/material.dart';
import 'package:AstroAI/models/natal_chart_data.dart';

class NatalChartPainter extends CustomPainter {
  final NatalChartData chartData;

  NatalChartPainter(this.chartData);

  // Define zodiac signs and their symbols
  static const List<String> zodiacSigns = [
    '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'
  ];

  // Planet symbols (Unicode)
  static const Map<String, String> planetSymbols = {
    'Sun': '☉', 'Moon': '☽', 'Mercury': '☿', 'Venus': '♀',
    'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄',
    'Uranus': '♅', 'Neptune': '♆', 'Pluto': '♇',
  };

  // Aspect colors based on angle
  static const Map<int, Color> aspectColors = {
    0: Colors.red, // Conjunction
    60: Colors.green, // Sextile
    90: Colors.orange, // Square
    120: Colors.blue, // Trine
    180: Colors.purple, // Opposition
    // Add more as needed, e.g., for quincunx (150), semi-sextile (30), etc.
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20; // Adjust for padding

    final outerCircleRadius = radius;
    final innerCircleRadius = radius * 0.6; // Inner circle for planets/houses

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw outer circle (zodiac wheel)
    canvas.drawCircle(center, outerCircleRadius, paint);

    // Draw inner circle (for planets/houses)
    canvas.drawCircle(center, innerCircleRadius, paint);

    // Draw zodiac signs and their divisions
    // Draw zodiac signs and their divisions
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 12; i++) {
      // Astrological degrees: 0 Aries at 12 o'clock, increasing counter-clockwise
      // Canvas degrees: 0 at 3 o'clock, increasing clockwise
      // Conversion: (270 - astrological_degree) * (pi / 180)
      final astrologicalDegree = i * 30.0; // 0, 30, 60, ... for each sign start
      final centerOfSignAstrologicalDegree = astrologicalDegree + 15; // Center of the 30-degree segment
      final angleForSymbol = (270 - centerOfSignAstrologicalDegree) * (pi / 180); // Angle for symbol placement

      final textRadius = outerCircleRadius + 15; // Position text outside the circle

      // Draw zodiac sign symbol
      textPainter.text = TextSpan(
        text: zodiacSigns[i],
        style: const TextStyle(fontSize: 20, color: Colors.black),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(center.dx + textRadius * cos(angleForSymbol), center.dy + textRadius * sin(angleForSymbol));
      canvas.rotate(angleForSymbol + pi / 2); // Rotate text to be upright
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      // Draw zodiac division lines
      final linePaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 0.5;
      final lineAngle = (270 - astrologicalDegree) * (pi / 180); // Angle for the start of the sign
      final startPoint = Offset(
        center.dx + innerCircleRadius * cos(lineAngle),
        center.dy + innerCircleRadius * sin(lineAngle),
      );
      final endPoint = Offset(
        center.dx + outerCircleRadius * cos(lineAngle),
        center.dy + outerCircleRadius * sin(lineAngle),
      );
      canvas.drawLine(startPoint, endPoint, linePaint);
    }

    

    // Draw planets
    final planetPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0;
    for (var planet in chartData.planets) {
      final angle = (270 - planet.degree) * (pi / 180); // Adjust to Flutter's coordinate system
      final planetRadius = innerCircleRadius * 0.85; // Position planets inside the inner circle, moved further out
      final planetX = center.dx + planetRadius * cos(angle);
      final planetY = center.dy + planetRadius * sin(angle);

      // Draw planet symbol
      textPainter.text = TextSpan(
        text: planetSymbols[planet.name] ?? planet.name, // Use symbol or name if not found
        style: const TextStyle(fontSize: 18, color: Colors.red),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(planetX, planetY);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      
    }

    // Draw aspects
    for (var aspect in chartData.aspects) {
      // Only draw aspects with a valid type (not -1)
      if (aspect.aspectType != -1) {
        final aspectPaint = Paint()
          ..color = aspectColors[aspect.aspectType] ?? Colors.grey // Use defined colors or grey fallback
          ..strokeWidth = 0.7 // Reduced stroke width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        
        final planet1 = chartData.planets.firstWhere((p) => p.name == aspect.planet1);
        final planet2 = chartData.planets.firstWhere((p) => p.name == aspect.planet2);

        final angle1 = (270 - planet1.degree) * (pi / 180);
        final angle2 = (270 - planet2.degree) * (pi / 180);

        final radiusForAspect = innerCircleRadius * 0.7; // Same radius as planets

        final p1X = center.dx + radiusForAspect * cos(angle1);
        final p1Y = center.dy + radiusForAspect * sin(angle1);
        final p2X = center.dx + radiusForAspect * cos(angle2);
        final p2Y = center.dy + radiusForAspect * sin(angle2);

        canvas.drawLine(Offset(p1X, p1Y), Offset(p2X, p2Y), aspectPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // For simplicity, always repaint for now
  }
}
