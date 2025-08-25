import 'dart:convert';
import 'dart:math' as math;
import 'package:AstroAI/pages.dart';
import 'package:AstroAI/pages/signup_page.dart';
import 'package:AstroAI/services/api_service.dart';
import 'package:AstroAI/widgets/common/navigation_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F8),
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: SingleChildScrollView(
              child: const Column(
                children: [
                  HeroSection(),
                  TodaysEventsSection(),
                  ZodiacSection(),
                  PersonalisedSection(),
                  FeaturesSection(),
                  FooterSection(),
                ],
              ),
            ),
          ),
          // Fixed header on top
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

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 89, // Mac screen height minus header
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4097FF),
            Color(0xFFFF92A2),
            Color(0xFFA5E5F9),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: _buildHeroContent(context),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.8),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'EXPLORE YOUR\nJOURNEY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Text(
                  'Discover your zodiac, daily horoscope, and cosmic insights with just your birthday. Simple, beautiful, and powered by AI.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: -0.32,
                    height: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4097FF),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Text(
                    'About Us',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4097FF),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

}

class ZodiacSection extends StatelessWidget {
  const ZodiacSection({super.key});

  // Zodiac signs organized by elements
  static const List<List<Map<String, String>>> zodiacElements = [
    // Water signs
    [
      {'name': 'CANCER', 'symbol': '♋', 'dates': 'JUN 21 - JUL 22'},
      {'name': 'SCORPIO', 'symbol': '♏', 'dates': 'OCT 23 - NOV 21'},
      {'name': 'PISCES', 'symbol': '♓', 'dates': 'FEB 19 - MAR 20'},
    ],
    // Fire signs  
    [
      {'name': 'ARIES', 'symbol': '♈', 'dates': 'MAR 21 - APR 19'},
      {'name': 'LEO', 'symbol': '♌', 'dates': 'JUL 23 - AUG 22'},
      {'name': 'SAGITTARIUS', 'symbol': '♐', 'dates': 'NOV 22 - DEC 21'},
    ],
    // Air signs
    [
      {'name': 'GEMINI', 'symbol': '♊', 'dates': 'MAY 21 - JUN 20'},
      {'name': 'LIBRA', 'symbol': '♎', 'dates': 'SEP 23 - OCT 22'},
      {'name': 'AQUARIUS', 'symbol': '♒', 'dates': 'JAN 20 - FEB 18'},
    ],
    // Earth signs
    [
      {'name': 'TAURUS', 'symbol': '♉', 'dates': 'APR 20 - MAY 20'},
      {'name': 'VIRGO', 'symbol': '♍', 'dates': 'AUG 23 - SEP 22'},
      {'name': 'CAPRICORN', 'symbol': '♑', 'dates': 'DEC 22 - JAN 19'},
    ],
  ];

  static const List<Color> elementColors = [
    Color(0xFF4097FF), // Water - Blue
    Color(0xFFFF92A2), // Fire - Pink  
    Color(0xFFA5E5F9), // Air - Light Blue
    Color(0xFF8985CF), // Earth - Updated color as requested
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3F8),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF4097FF),
                            Color(0x80FF92A2),
                            Color(0x40A5E5F9),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Choose your zodiac sign',
                          style: GoogleFonts.cinzel(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
              ...zodiacElements.asMap().entries.map((entry) {
                final rowIndex = entry.key;
                final signs = entry.value;
                final isOddRow = rowIndex % 2 == 0;
                
                return Container(
                  margin: EdgeInsets.only(
                    bottom: 40,
                    left: isOddRow ? 0 : 100,
                    right: isOddRow ? 100 : 0,
                  ),
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1000 + (rowIndex * 200)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: signs.asMap().entries.map((signEntry) {
                              final cardIndex = signEntry.key;
                              final sign = signEntry.value;
                              final opacity = isOddRow 
                                  ? 1.0 - (cardIndex * 0.25) // Left to right: decrease opacity
                                  : 0.5 + (cardIndex * 0.25); // Left to right: increase opacity
                              
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  constraints: const BoxConstraints(maxWidth: 160), // Reduced card width
                                  child: ZodiacElementCard(
                                    zodiacData: sign,
                                    baseColor: elementColors[rowIndex],
                                    opacity: opacity,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ZodiacElementCard extends StatefulWidget {
  final Map<String, String> zodiacData;
  final Color baseColor;
  final double opacity;

  const ZodiacElementCard({
    super.key,
    required this.zodiacData,
    required this.baseColor,
    required this.opacity,
  });

  @override
  State<ZodiacElementCard> createState() => _ZodiacElementCardState();
}

class _ZodiacElementCardState extends State<ZodiacElementCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZodiacDetailPage(
              zodiacName: widget.zodiacData['name']!,
              zodiacSymbol: widget.zodiacData['symbol']!,
              dateRange: widget.zodiacData['dates']!,
              zodiacIndex: 0,
            ),
            settings: RouteSettings(name: '/zodiac/${widget.zodiacData['name']!.toLowerCase()}'),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
          _animationController.forward();
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
          _animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_animation.value * 3.14159),
              child: _animation.value < 0.5
                  ? _buildFrontCard()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildBackCard(),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      height: 160, // Reduced height for narrower cards
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: widget.baseColor.withOpacity(widget.opacity),
        boxShadow: [
          BoxShadow(
            color: widget.baseColor.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.zodiacData['symbol']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.zodiacData['name']!,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.zodiacData['dates']!,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      height: 160, // Reduced height for narrower cards
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: widget.baseColor.withOpacity(widget.opacity),
        boxShadow: [
          BoxShadow(
            color: widget.baseColor.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  widget.zodiacData['symbol']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.zodiacData['name']!,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ZodiacCard extends StatefulWidget {
  final int index;
  const ZodiacCard({super.key, required this.index});

  @override
  State<ZodiacCard> createState() => _ZodiacCardState();
}

class _ZodiacCardState extends State<ZodiacCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const List<Map<String, String>> zodiacSigns = [
    {'name': 'ARIES', 'symbol': '♈', 'dates': 'MAR 21 - APR 19'},
    {'name': 'TAURUS', 'symbol': '♉', 'dates': 'APR 20 - MAY 20'},
    {'name': 'GEMINI', 'symbol': '♊', 'dates': 'MAY 21 - JUN 20'},
    {'name': 'CANCER', 'symbol': '♋', 'dates': 'JUN 21 - JUL 22'},
    {'name': 'LEO', 'symbol': '♌', 'dates': 'JUL 23 - AUG 22'},
    {'name': 'VIRGO', 'symbol': '♍', 'dates': 'AUG 23 - SEP 22'},
    {'name': 'LIBRA', 'symbol': '♎', 'dates': 'SEP 23 - OCT 22'},
    {'name': 'SCORPIO', 'symbol': '♏', 'dates': 'OCT 23 - NOV 21'},
    {'name': 'SAGITTARIUS', 'symbol': '♐', 'dates': 'NOV 22 - DEC 21'},
    {'name': 'CAPRICORN', 'symbol': '♑', 'dates': 'DEC 22 - JAN 19'},
    {'name': 'AQUARIUS', 'symbol': '♒', 'dates': 'JAN 20 - FEB 18'},
    {'name': 'PISCES', 'symbol': '♓', 'dates': 'FEB 19 - MAR 20'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zodiac = zodiacSigns[widget.index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZodiacDetailPage(
              zodiacName: zodiac['name']!,
              zodiacSymbol: zodiac['symbol']!,
              dateRange: zodiac['dates']!,
              zodiacIndex: widget.index,
            ),
            settings: RouteSettings(name: '/zodiac/${zodiac['name']!.toLowerCase()}'),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
          _animationController.forward();
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
          _animationController.reverse();
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_animation.value * 3.14159),
              child: _animation.value < 0.5
                  ? _buildFrontCard(zodiac)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildBackCard(zodiac),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard(Map<String, String> zodiac) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4097FF),
            Color(0xFFA5E5F9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zodiac Symbol
            Text(
              zodiac['symbol']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Zodiac Name
            Text(
              zodiac['name']!,
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFF92A2),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            // Date Range
            Text(
              zodiac['dates']!,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(Map<String, String> zodiac) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4097FF),
            Color(0xFFA5E5F9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative border at top
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detailed artistic content
            Expanded(
              child: Stack(
                children: [
                  // Central circular design
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          zodiac['symbol']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Decorative waves and patterns
                  Positioned(
                    top: 20,
                    left: 10,
                    right: 10,
                    child: CustomPaint(
                      size: const Size(double.infinity, 30),
                      painter: WavePatternPainter(),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 10,
                    right: 10,
                    child: CustomPaint(
                      size: const Size(double.infinity, 30),
                      painter: WavePatternPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Name at bottom with decorative styling
            Text(
              zodiac['name']!,
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFF92A2),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Decorative border at bottom
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalisedSection extends StatefulWidget {
  const PersonalisedSection({super.key});

  @override
  State<PersonalisedSection> createState() => _PersonalisedSectionState();
}

class _PersonalisedSectionState extends State<PersonalisedSection> {
  final TextEditingController _birthdateController = TextEditingController();
  DateTime? _selectedDate;
  String? _zodiacSign;
  bool _isLoading = false;
  Map<String, String> _responses = {};
  Map<String, bool> _expandedStates = {
    'Daily Horoscope': false,
    'Love': false,
    'Career': false, 
    'Wealth': false,
    'Guidance': false,
    'Motivation': false,
  };
  String? _fullHoroscope;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Daily Horoscope',
      'icon': '🔮',
      'color': Color(0xFF9C27B0),
      'description': 'Your complete daily astrological forecast',
      'api_key': 'overall_horoscope',
    },
    {
      'title': 'Love',
      'icon': '💖',
      'color': Color(0xFFFF92A2),
      'description': 'Romantic relationships and connections',
      'api_key': 'love_advice',
    },
    {
      'title': 'Career',
      'icon': '🚀',
      'color': Color(0xFF000000),
      'description': 'Professional growth and opportunities',
      'api_key': 'career_advice',
    },
    {
      'title': 'Wealth',
      'icon': '💰',
      'color': Color(0xFFA5E5F9),
      'description': 'Financial prosperity and abundance',
      'api_key': 'wealth_advice',
    },
    {
      'title': 'Guidance',
      'icon': '💡',
      'color': Color(0xFF4CAF50),
      'description': 'Your personalized daily guidance',
      'api_key': 'daily_suggestion',
    },
    {
      'title': 'Motivation',
      'icon': '⭐',
      'color': Color(0xFF6B46C1),
      'description': 'Inspirational message for your day',
      'api_key': 'daily_encouragement_message',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF4097FF),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        'PERSONAL COSMIC INSIGHTS',
                        style: GoogleFonts.cinzel(
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFF3F8),
                          letterSpacing: -1,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
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
                        'Get detailed cosmic insights based on your birth date',
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFFFF3F8).withOpacity(0.9),
                          letterSpacing: -0.32,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              _buildBirthdateInput(),
              const SizedBox(height: 40),
              _buildCategoriesGrid(),
              if (_responses.isNotEmpty) ...[
                const SizedBox(height: 40),
                _buildHoroscopeContent(),
                const SizedBox(height: 40),
                _buildSignUpPrompt(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdateInput() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1995, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4097FF),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _birthdateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  _zodiacSign = _getZodiacSign(date);
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFF3F8).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: const Color(0xFF4097FF), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null 
                          ? 'Birth Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select your birth date',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: _selectedDate != null 
                            ? Colors.black 
                            : Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedDate != null && !_isLoading ? _generateInsights : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedDate != null 
                  ? const Color(0xFF4097FF) 
                  : const Color(0xFFE0E0E0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: _selectedDate != null ? 8 : 2,
              shadowColor: _selectedDate != null 
                  ? const Color(0xFF4097FF).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Generate Insights',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _selectedDate != null 
                          ? Colors.white 
                          : Colors.grey,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final hasResponse = _responses.containsKey(category['title']);
          final isExpanded = _expandedStates[category['title']] ?? false;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 150)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: category['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: category['color'].withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category['icon'],
                                style: const TextStyle(fontSize: 36),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['title'],
                                style: GoogleFonts.cinzel(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: category['color'],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                category['description'],
                                style: GoogleFonts.raleway(
                                  fontSize: 12,
                                  color: const Color(0xFFFFF3F8).withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (hasResponse) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedStates[category['title']] = !isExpanded;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isExpanded ? 'Hide' : 'Show Insight',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: category['color'],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: category['color'],
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: category['color'].withOpacity(0.1),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.all(8),
                            child: Text(
                              _responses[category['title']] ?? '',
                              style: GoogleFonts.raleway(
                                fontSize: 14,
                                color: Colors.black,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4097FF), Color(0xFFFF92A2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Want to keep your history and get more detailed analysis?',
            style: GoogleFonts.raleway(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4097FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  // Navigate to sign in
                },
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeContent() {
    if (_fullHoroscope == null && _responses.isEmpty) return const SizedBox.shrink();
    
    // Check if any response contains error messages
    bool hasErrors = _responses.values.any((response) => 
      response.contains('Unable to connect to the server'));
    
    if (hasErrors) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F4FF), Color(0xFFE8F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4097FF).withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4097FF), Color(0xFF8E2DE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Horoscope Reading',
                      style: GoogleFonts.cinzel(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4097FF),
                      ),
                    ),
                    Text(
                      'Powered by AI • Generated for ${_zodiacSign ?? 'your sign'}',
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Detailed Insights Grid
          if (_responses.isNotEmpty) ...[
            Text(
              'Detailed Cosmic Insights',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightCards(),
            const SizedBox(height: 24),
          ],
          
          // Full Horoscope Reading
          if (_fullHoroscope != null) ...[
            Text(
              'Complete Reading',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4097FF).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4097FF), Color(0xFF8E2DE2)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Your Cosmic Narrative',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4097FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _fullHoroscope!,
                    style: GoogleFonts.raleway(
                      fontSize: 15,
                      height: 1.7,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightCards() {
    final insights = [
      {'key': 'Daily Horoscope', 'icon': '🔮', 'color': Color(0xFF9C27B0)},
      {'key': 'Love', 'icon': '💖', 'color': Color(0xFFFF92A2)},
      {'key': 'Career', 'icon': '🚀', 'color': Color(0xFF4CAF50)},
      {'key': 'Wealth', 'icon': '💰', 'color': Color(0xFFA5E5F9)},
      {'key': 'Guidance', 'icon': '💡', 'color': Color(0xFF4CAF50)},
      {'key': 'Motivation', 'icon': '⭐', 'color': Color(0xFF6B46C1)},
    ];

    return Column(
      children: insights.map((insight) {
        final key = insight['key'] as String;
        final icon = insight['icon'] as String;
        final color = insight['color'] as Color;
        final response = _responses[key] ?? '';
        
        if (response.isEmpty) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      response,
                      style: GoogleFonts.raleway(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _generateInsights() async {
    if (_selectedDate == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the real horoscope API
      final response = await http.post(
        Uri.parse('http://localhost:8000/horoscope'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'birthdate': _birthdateController.text,
          'sign': _zodiacSign,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final horoscopeData = data['horoscope'] ?? {};
        
        setState(() {
          _fullHoroscope = _buildFullHoroscopeText(horoscopeData);
          _responses = {
            'Daily Horoscope': horoscopeData['overall_horoscope']?.toString() ?? 'Today holds unique cosmic energies that guide your path toward growth and fulfillment.',
            'Love': horoscopeData['love_advice']?.toString() ?? 'Open your heart to the possibilities that love brings into your life today.',
            'Career': horoscopeData['career_advice']?.toString() ?? 'Professional opportunities await those who remain focused and determined.',
            'Wealth': horoscopeData['wealth_advice']?.toString() ?? 'Financial wisdom comes from mindful decisions and patient planning.',
            'Guidance': horoscopeData['daily_suggestion']?.toString() ?? 'Embrace the day with confidence and stay true to your inner wisdom.',
            'Motivation': horoscopeData['daily_encouragement_message']?.toString() ?? 'You have the strength and wisdom to make today extraordinary.',
          };
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to generate horoscope');
      }
    } catch (e) {
      print('Error generating insights: $e');
      setState(() {
        _fullHoroscope = null;
        // Check if it's a quota exceeded error
        bool isQuotaError = e.toString().contains('429') || 
                           e.toString().contains('quota') || 
                           e.toString().contains('exceeded');
        
        if (isQuotaError) {
          _responses = {
            'Daily Horoscope': 'The stars align to bring you wisdom and clarity today. Trust in your intuition and embrace the opportunities that come your way.',
            'Love': 'Love surrounds you in many forms today. Open your heart to deeper connections and meaningful conversations with those who matter.',
            'Career': 'Your professional journey is guided by cosmic forces. Stay focused on your goals and trust that your hard work will be rewarded.',
            'Wealth': 'Financial opportunities may present themselves in unexpected ways. Practice mindful spending and consider long-term investments.',
            'Guidance': 'Take a moment to appreciate the beauty around you and reflect on your personal growth.',
            'Motivation': 'You are exactly where you need to be. Trust the process and believe in your incredible potential.',
          };
        } else {
          _responses = {
            'Daily Horoscope': 'Unable to connect to the server. Please check your connection and try again.',
            'Love': 'Unable to connect to the server. Please check your connection and try again.',
            'Career': 'Unable to connect to the server. Please check your connection and try again.',
            'Wealth': 'Unable to connect to the server. Please check your connection and try again.',
            'Guidance': 'Unable to connect to the server. Please check your connection and try again.',
            'Motivation': 'Unable to connect to the server. Please check your connection and try again.',
          };
        }
        _isLoading = false;
      });
    }
  }

  String? _extractSection(String horoscope, String sectionName) {
    try {
      final sections = horoscope.split('\n\n');
      for (final section in sections) {
        if (section.toLowerCase().contains(sectionName.toLowerCase())) {
          return section.replaceAll(RegExp(r'^[*#\s]*${sectionName}[*#\s]*:?\s*', caseSensitive: false), '').trim();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  String _buildFullHoroscopeText(Map<String, dynamic> horoscopeData) {
    final sections = <String>[];
    
    if (horoscopeData['overall_horoscope'] != null) {
      sections.add('Overall: ${horoscopeData['overall_horoscope']}');
    }
    
    if (horoscopeData['love_advice'] != null) {
      sections.add('Love: ${horoscopeData['love_advice']}');
    }
    
    if (horoscopeData['career_advice'] != null) {
      sections.add('Career: ${horoscopeData['career_advice']}');
    }
    
    if (horoscopeData['wealth_advice'] != null) {
      sections.add('Wealth: ${horoscopeData['wealth_advice']}');
    }
    
    if (horoscopeData['daily_suggestion'] != null) {
      sections.add('Guidance: ${horoscopeData['daily_suggestion']}');
    }
    
    if (horoscopeData['daily_encouragement_message'] != null) {
      sections.add('Motivation: ${horoscopeData['daily_encouragement_message']}');
    }
    
    return sections.join('\n\n');
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3F8),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
          children: [
            Text(
              'MORE FEATURES',
              style: GoogleFonts.cinzel(
                fontSize: 50,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -1,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ), 
            const SizedBox(height: 50), 
            _buildFeatureGrid(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {
        'title': 'MATCHING',
        'description': 'Discover your cosmic compatibility with others. Find your perfect match based on zodiac signs, birth charts, and astrological harmony.',
        'color': const Color(0xFF4097FF),
        'page': const MatchingPage(),
      },
      {
        'title': 'NATAL CHART',
        'description': 'Get your complete birth chart analysis. Explore planetary positions, houses, and aspects that shape your personality and life path.',
        'color': const Color(0xFFFF92A2),
        'page': const NatalChartPage(),
      },
      {
        'title': 'ASMR',
        'description': 'Relax with cosmic soundscapes and guided meditations. Soothing audio experiences designed for deep relaxation and spiritual connection.',
        'color': const Color(0xFFA5E5F9),
        'page': const ASMRPage(),
      },
      {
        'title': 'TAROT',
        'description': 'Unveil insights through mystical tarot readings. Get guidance on love, career, and life decisions with AI-powered card interpretations.',
        'color': const Color(0xFF8985CF),
        'page': const TarotPage(),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 800;
        final crossAxisCount = isSmallScreen ? 1 : 2;
        final childAspectRatio = isSmallScreen ? 1.2 : 1.3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _buildFeatureCard(context, features[index]);
          },
        );
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored circle icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: feature['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            feature['title'],
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            feature['description'],
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const Spacer(),
          
          // Learn more link
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => feature['page']),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'learn more',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Logo and description
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4097FF), Color(0xFFFF92A2)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('✨', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AstroAI',
                              style: GoogleFonts.cinzel(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your personal guide to the cosmos, blending ancient wisdom with modern technology.',
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side: Links
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLinkColumn('Features', ['Horoscope', 'Natal Chart', 'Compatibility', 'Tarot']),
                        _buildLinkColumn('Resources', ['Blog', 'Glossary', 'FAQ', 'Support']),
                        _buildLinkColumn('Company', ['About Us', 'Careers', 'Press', 'Contact']),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Divider(color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2024 AstroAI. All rights reserved.',
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Row(
                    children: [
                      _buildSocialIcon(Icons.facebook),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.transcribe),
                      const SizedBox(width: 16),
                      _buildSocialIcon(Icons.apple),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            link,
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(
      icon,
      color: Colors.white.withOpacity(0.7),
      size: 20,
    );
  }
}

class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, size.height / 2);
    path.quadraticBezierTo(size.width * 3 / 4, size.height, size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TodaysEventsSection extends StatefulWidget {
  const TodaysEventsSection({super.key});

  @override
  State<TodaysEventsSection> createState() => _TodaysEventsSectionState();
}

class _TodaysEventsSectionState extends State<TodaysEventsSection> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? _events;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodaysEvents();
  }

  Future<void> _loadTodaysEvents() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getTodaysEvents();
      
      setState(() {
        _isLoading = false;
        if (response != null && response['events'] != null) {
          _events = List<Map<String, dynamic>>.from(response['events']);
        } else {
          _events = [];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load cosmic events';
        _events = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        "TODAY'S COSMIC EVENTS",
                        style: GoogleFonts.cinzel(
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4097FF),
                          letterSpacing: -1,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
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
                        'Discover what the cosmos has in store for you today',
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.7),
                          letterSpacing: -0.32,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
              _buildEventsContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsContent() {
    if (_isLoading) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4097FF).withOpacity(0.1),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF4097FF),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading cosmic events...',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (_events == null || _events!.isEmpty) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F4FF),
                      Color(0xFFE8F7FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF4097FF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4097FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '⭐',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NO SPECIAL COSMIC EVENTS TODAY',
                      style: GoogleFonts.cinzel(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4097FF),
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage ?? 'The cosmos is in a peaceful state today',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              children: _events!.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1400 + (index * 200)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, animValue, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - animValue)),
                        child: Opacity(
                          opacity: animValue,
                          child: _buildEventCard(event),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final String eventType = event['event_type'] ?? '';
    final String description = event['description'] ?? '';
    final String eventDate = event['event_date'] ?? '';

    Color cardColor;
    String icon;
    
    switch (eventType.toLowerCase()) {
      case 'lunar':
        cardColor = const Color(0xFFA5E5F9);
        icon = '🌙';
        break;
      case 'retrograde':
        cardColor = const Color(0xFFFF92A2);
        icon = '🪐';
        break;
      case 'ingress':
        cardColor = const Color(0xFF8985CF);
        icon = '✨';
        break;
      default:
        cardColor = const Color(0xFF4097FF);
        icon = '⭐';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventType.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                if (eventDate.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Date: $eventDate',
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}