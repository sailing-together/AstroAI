import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'pages.dart';
import 'providers/app_state.dart';
import 'pages/daily_insights_page.dart';
import 'pages/ai_assistant_page.dart';
import 'models/user_data.dart';

void main() {
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
        },
      ),
    );
  }
}

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

class NavigationHeader extends StatefulWidget {
  const NavigationHeader({super.key});

  @override
  State<NavigationHeader> createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<NavigationHeader> {
  String _currentMenuItem = 'Home';  // Default selected menu item

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 89,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4097FF),
                          Color(0xFFFF92A2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4097FF).withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '✨',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF4097FF),
                        Color(0xFFFF92A2),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'AstroAI',
                      style: GoogleFonts.cinzel(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (MediaQuery.of(context).size.width < 800) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {},
                    );
                  }
                  return Row(
                    children: [
                      _buildMenuItem('Home', context),
                      _buildMenuItem('Horoscope', context),
                      _buildMenuItemWithDropdown('More Features', context),
                      _buildMenuItem('About Us', context),
                      _buildHighlightedMenuItem('Sign Up', context),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String text, BuildContext context) {
    final bool isSelected = text == _currentMenuItem;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMenuItem = text;
        });
        _navigateToPage(text, context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(String pageName, BuildContext context) {
    // Update current menu item in state
    setState(() {
      _currentMenuItem = pageName;
    });

    switch (pageName) {
      case 'Home':
        // Always navigate to home by popping to first route and pushing new HomePage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: const RouteSettings(name: '/'),
          ),
          (route) => false,
        );
        break;
      case 'Horoscope':
        // Check if we're already on the daily insights page
        if (ModalRoute.of(context)?.settings.name == '/daily-insights') return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DailyInsightsPage(),
            settings: const RouteSettings(name: '/daily-insights'),
          ),
        );
        break;
      case 'About Us':
        // Check if we're already on the about page
        if (ModalRoute.of(context)?.settings.name == '/about') return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AboutUsPage(),
            settings: const RouteSettings(name: '/about'),
          ),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildMenuItemWithDropdown(String text, [BuildContext? context]) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: text == _currentMenuItem ? FontWeight.w700 : FontWeight.w400,
                color: text == _currentMenuItem ? Colors.black : Colors.black.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black.withOpacity(0.5),
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Matching',
          child: Text(
            'Matching',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Natal chart',
          child: Text(
            'Natal chart',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
        PopupMenuItem<String>(
          value: 'ASMR',
          child: Text(
            'ASMR',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Tarot',
          child: Text(
            'Tarot',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
      ],
      onSelected: (String value) {
        if (context == null) return;
        
        setState(() {
          _currentMenuItem = 'More Features';
        });
        
        // Handle feature selection
        switch (value) {
          case 'Matching':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchingPage(),
                settings: const RouteSettings(name: '/matching'),
              ),
            );
            break;
          case 'Natal chart':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NatalChartPage(),
                settings: const RouteSettings(name: '/natal-chart'),
              ),
            );
            break;
          case 'ASMR':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ASMRPage(),
                settings: const RouteSettings(name: '/asmr'),
              ),
            );
            break;
          case 'Tarot':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TarotPage(),
                settings: const RouteSettings(name: '/tarot'),
              ),
            );
            break;
        }
      },
    );
  }

  Widget _buildHighlightedMenuItem(String text, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
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
              backgroundColor: const Color(0xFFFFF3F8),
              foregroundColor: const Color(0xFF4097FF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
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
                      color: Colors.white,
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
    if (_fullHoroscope == null) return const SizedBox.shrink();
    
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              _fullHoroscope!,
              style: GoogleFonts.raleway(
                fontSize: 15,
                height: 1.7,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
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
        
        setState(() {
          _fullHoroscope = data['horoscope'];
          _responses = {
            'Daily Horoscope': data['overall_horoscope'] ?? 'Today holds unique cosmic energies that guide your path toward growth and fulfillment.',
            'Love': data['love_advice'] ?? 'Open your heart to the possibilities that love brings into your life today.',
            'Career': data['career_advice'] ?? 'Professional opportunities await those who remain focused and determined.',
            'Wealth': data['wealth_advice'] ?? 'Financial wisdom comes from mindful decisions and patient planning.',
            'Guidance': data['daily_suggestion'] ?? 'Embrace the day with confidence and stay true to your inner wisdom.',
            'Motivation': data['daily_encouragement_message'] ?? 'You have the strength and wisdom to make today extraordinary.',
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
              'more features',
              style: GoogleFonts.cinzel(
                fontSize: 50,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -1,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildStaggeredFeatureLayout(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStaggeredFeatureLayout(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'title': 'Matching', 'color': const Color(0xFF4097FF), 'delay': 0},
      {'title': 'Natal chart', 'color': const Color(0xFFFF92A2), 'delay': 200},
      {'title': 'ASMR', 'color': const Color(0xFFA5E5F9), 'delay': 400},
      {'title': 'Tarot', 'color': const Color(0xFF8985CF), 'delay': 600},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile: Stack vertically with alternating alignment
          return Column(
            children: features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;
              final isEven = index % 2 == 0;
              
              return Container(
                margin: EdgeInsets.only(
                  bottom: 30,
                  left: isEven ? 0 : 40,
                  right: isEven ? 40 : 0,
                ),
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 800 + (feature['delay'] as int)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        isEven ? -50 * (1 - value) : 50 * (1 - value),
                        20 * (1 - value),
                      ),
                      child: Opacity(
                        opacity: value,
                        child: _buildFloatingFeatureCard(
                          context, 
                          feature['title'], 
                          feature['color'],
                          index,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        }
        
        // Desktop: 2x2 staggered grid
        return Column(
          children: [
            // First row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20, bottom: 30),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(-30 * (1 - value), 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildFloatingFeatureCard(
                              context, 
                              'Matching', 
                              const Color(0xFF4097FF),
                              0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, top: 40, bottom: 30),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 15 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildFloatingFeatureCard(
                              context, 
                              'Natal chart', 
                              const Color(0xFFFF92A2),
                              1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Second row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20, top: 20),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(-25 * (1 - value), 25 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildFloatingFeatureCard(
                              context, 
                              'ASMR', 
                              const Color(0xFFA5E5F9),
                              2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, bottom: 20),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1400),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(35 * (1 - value), 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildFloatingFeatureCard(
                              context, 
                              'Tarot', 
                              const Color(0xFF8985CF),
                              3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingFeatureCard(BuildContext context, String title, Color iconColor, int index) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 3),
        tween: Tween(begin: -5.0, end: 5.0),
        builder: (context, value, child) {
          return AnimatedBuilder(
            animation: AlwaysStoppedAnimation<double>(DateTime.now().millisecondsSinceEpoch / 2000),
            builder: (context, child) {
              final floatOffset = 3 * math.sin((DateTime.now().millisecondsSinceEpoch / 1500) + (index * 0.5));
              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: _buildFeatureCard(context, title, iconColor),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, Color iconColor) {
    // Get description based on feature title
    String getFeatureDescription(String title) {
      switch (title) {
        case 'Matching':
          return 'Discover your cosmic compatibility with others. Find your perfect match based on zodiac signs, birth charts, and astrological harmony.';
        case 'Natal chart':
          return 'Get your complete birth chart analysis. Explore planetary positions, houses, and aspects that shape your personality and life path.';
        case 'ASMR':
          return 'Relax with cosmic soundscapes and guided meditations. Soothing audio experiences designed for deep relaxation and spiritual connection.';
        case 'Tarot':
          return 'Unveil insights through mystical tarot readings. Get guidance on love, career, and life decisions with AI-powered card interpretations.';
        default:
          return 'Explore the mysteries of the cosmos with our advanced astrological features and personalized insights.';
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            offset: const Offset(0, 16),
            blurRadius: 40,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor,
                      iconColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.48,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            getFeatureDescription(title),
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.4),
              letterSpacing: -0.32,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InstructionPage(),
                  settings: const RouteSettings(name: '/instructions'),
                ),
              );
            },
            child: Text(
              'learn more',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveHeight = size.height * 0.3;
    final waveLength = size.width / 4;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength / 4, size.height / 2 - waveHeight,
        x + waveLength / 2, size.height / 2,
      );
      path.quadraticBezierTo(
        x + 3 * waveLength / 4, size.height / 2 + waveHeight,
        x + waveLength, size.height / 2,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC04747)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Heart shape based on Figma SVG path
    path.moveTo(size.width, size.height * 0.335);
    path.cubicTo(size.width, size.height * 0.4, size.width * 0.973, size.height * 0.463, size.width * 0.926, size.height * 0.509);
    path.lineTo(size.width * 0.535, size.height * 0.891);
    path.cubicTo(size.width * 0.521, size.height * 0.904, size.width * 0.498, size.height * 0.904, size.width * 0.485, size.height * 0.891);
    path.lineTo(size.width * 0.093, size.height * 0.509);
    path.cubicTo(size.width * 0.048, size.height * 0.375, size.width * 0.066, size.height * 0.148, size.width * 0.207, size.height * 0.099);
    path.cubicTo(size.width * 0.295, size.height * 0.077, size.width * 0.388, size.height * 0.101, size.width * 0.452, size.height * 0.163);
    path.lineTo(size.width * 0.510, size.height * 0.214);
    path.lineTo(size.width * 0.567, size.height * 0.162);
    path.cubicTo(size.width * 0.705, size.height * 0.030, size.width * 0.942, size.height * 0.091, size.width * 0.993, size.height * 0.273);
    path.cubicTo(size.width, size.height * 0.294, size.width, size.height * 0.315, size.width, size.height * 0.335);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ToolboxIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD600), Color(0xFFFF007A)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Simplified toolbox shape
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.8, size.height * 0.4),
      const Radius.circular(8),
    ));

    // Handle
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.1, size.width * 0.2, size.height * 0.25),
      const Radius.circular(4),
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FlaskIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF51E3), Color(0xFF1B4DFF)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Flask shape
    path.moveTo(size.width * 0.4, size.height * 0.1);
    path.lineTo(size.width * 0.6, size.height * 0.1);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    path.cubicTo(size.width * 0.95, size.height * 0.85, size.width * 0.95, size.height * 0.95, size.width * 0.85, size.height * 0.95);
    path.lineTo(size.width * 0.15, size.height * 0.95);
    path.cubicTo(size.width * 0.05, size.height * 0.95, size.width * 0.05, size.height * 0.85, size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.4);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DollarIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD600), Color(0xFF00D078)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw bulb base
    final bulbPath = Path();
    bulbPath.addOval(Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.8, size.height * 0.7));
    canvas.drawPath(bulbPath, paint);

    // Draw screw threads at bottom
    final threadPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.25, size.height * 0.85 + i * 5),
        Offset(size.width * 0.75, size.height * 0.85 + i * 5),
        threadPaint,
      );
    }

    // Draw dollar sign
    final dollarPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // S curve for dollar sign
    final dollarPath = Path();
    dollarPath.moveTo(size.width * 0.65, size.height * 0.25);
    dollarPath.cubicTo(size.width * 0.65, size.height * 0.2, size.width * 0.55, size.height * 0.2, size.width * 0.45, size.height * 0.25);
    dollarPath.cubicTo(size.width * 0.35, size.height * 0.3, size.width * 0.35, size.height * 0.4, size.width * 0.45, size.height * 0.45);
    dollarPath.cubicTo(size.width * 0.55, size.height * 0.5, size.width * 0.55, size.height * 0.6, size.width * 0.45, size.height * 0.65);
    dollarPath.cubicTo(size.width * 0.35, size.height * 0.7, size.width * 0.35, size.height * 0.75, size.width * 0.45, size.height * 0.75);

    canvas.drawPath(dollarPath, dollarPaint);

    // Vertical line through dollar sign
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.85),
      dollarPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// User Data Collection Dialog
void _showUserDataDialog(BuildContext context) {
  final nameController = TextEditingController();
  final birthdateController = TextEditingController();
  final locationController = TextEditingController();
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF4097FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Welcome to AstroAI! ✨',
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s personalize your cosmic journey. Please share some basic information:',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDialogTextField(
                    controller: nameController,
                    label: 'Name (Optional)',
                    hint: 'What should we call you?',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1990, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFFF92A2),
                                onPrimary: Colors.white,
                                surface: Color(0xFF4097FF),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          birthdateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate != null 
                                  ? 'Birth Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                  : 'Select your birth date',
                              style: GoogleFonts.raleway(
                                fontSize: 14,
                                color: selectedDate != null 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: locationController,
                    label: 'Birth Location',
                    hint: 'City, Country (e.g., London, UK)',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: selectedDate != null && locationController.text.isNotEmpty
                    ? () {
                        final appState = Provider.of<AppState>(context, listen: false);
                        final userData = UserData(
                          name: nameController.text.isNotEmpty ? nameController.text : null,
                          birthdate: birthdateController.text,
                          location: locationController.text,
                          zodiacSign: _getZodiacSign(selectedDate!),
                        );
                        appState.updateUserData(userData);
                        Navigator.pop(context);
                        
                        // Navigate to daily insights
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DailyInsightsPage(),
                            settings: const RouteSettings(name: '/daily-insights'),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF92A2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start My Journey',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildDialogTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: TextField(
      controller: controller,
      style: GoogleFonts.raleway(
        fontSize: 14,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.raleway(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
        ),
        hintStyle: GoogleFonts.raleway(
          fontSize: 14,
          color: Colors.white.withOpacity(0.5),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );
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

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4097FF),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              // Main Footer Content
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        _buildBrandSection(),
                        const SizedBox(height: 40),
                        _buildLinksSection(),
                        const SizedBox(height: 40),
                        _buildSocialSection(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildBrandSection()),
                      const SizedBox(width: 60),
                      Expanded(flex: 1, child: _buildLinksSection()),
                      const SizedBox(width: 40),
                      Expanded(flex: 1, child: _buildSocialSection()),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 50),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Copyright
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2024 AstroAI. All rights reserved.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Privacy Policy',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Terms of Service',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF92A2),
                    Color(0xFFA5E5F9),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '✨',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
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
        const SizedBox(height: 20),
        Text(
          'Your personal cosmic guide powered by AI. Discover your zodiac, get daily horoscopes, and unlock the mysteries of the universe.',
          style: GoogleFonts.raleway(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF92A2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            'Get Started Free',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildFooterLink('Daily Horoscope'),
        _buildFooterLink('Zodiac Matching'),
        _buildFooterLink('Natal Charts'),
        _buildFooterLink('ASMR & Meditation'),
        _buildFooterLink('Tarot Reading'),
        const SizedBox(height: 30),
        Text(
          'Company',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildFooterLink('About Us'),
        _buildFooterLink('Contact'),
        _buildFooterLink('Blog'),
        _buildFooterLink('Careers'),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect With Us',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Join our community for daily cosmic insights and updates.',
          style: GoogleFonts.raleway(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildSocialIcon('🌟'),
            const SizedBox(width: 15),
            _buildSocialIcon('📱'),
            const SizedBox(width: 15),
            _buildSocialIcon('💫'),
            const SizedBox(width: 15),
            _buildSocialIcon('🔮'),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stay Updated',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF92A2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          text,
          style: GoogleFonts.raleway(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String emoji) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Placeholder pages
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFF4097FF),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Sign Up Page - Coming Soon!'),
      ),
    );
  }
}

class TodaysEventsSection extends StatefulWidget {
  const TodaysEventsSection({super.key});

  @override
  State<TodaysEventsSection> createState() => _TodaysEventsSectionState();
}

class _TodaysEventsSectionState extends State<TodaysEventsSection> {
  List<dynamic> _todaysEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodaysEvents();
  }

  Future<void> _fetchTodaysEvents() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/events-today'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _todaysEvents = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Error fetching today\'s events: $e');
      setState(() {
        _todaysEvents = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
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
                        'Today\'s Cosmic Events',
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
              const SizedBox(height: 40),
              _isLoading 
                ? const CircularProgressIndicator(color: Color(0xFF4097FF))
                : _buildEventsDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsDisplay() {
    if (_todaysEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4097FF).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.star_outline,
              size: 48,
              color: Color(0xFF4097FF),
            ),
            const SizedBox(height: 16),
            Text(
              'No special cosmic events today',
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The cosmos is in a peaceful state today',
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: _todaysEvents.length,
      itemBuilder: (context, index) {
        final event = _todaysEvents[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4097FF),
                        Color(0xFFFF92A2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4097FF).withOpacity(0.3),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getEventIcon(event['type'] ?? 'unknown'),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event['type'] ?? 'Cosmic Event',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          event['description'] ?? 'A special cosmic event is occurring today',
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'lunar':
        return '🌙';
      case 'retrograde':
        return '↩️';
      case 'ingress':
        return '✨';
      case 'eclipse':
        return '🌑';
      case 'conjunction':
        return '💫';
      default:
        return '🔮';
    }
  }
}

class NatalChartPage extends StatefulWidget {
  const NatalChartPage({super.key});

  @override
  State<NatalChartPage> createState() => _NatalChartPageState();
}

class _NatalChartPageState extends State<NatalChartPage> {
  final _formKey = GlobalKey<FormState>();
  final _birthdateController = TextEditingController();
  final _birthtimeController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  Map<String, dynamic>? _natalChartData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F8),
      appBar: AppBar(
        title: Text(
          'Natal Chart',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF4097FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _natalChartData == null ? _buildForm() : _buildResults(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4097FF).withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Birth Details',
              style: GoogleFonts.cinzel(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your exact birth information for accurate natal chart calculation',
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            // Birth Date
            _buildDateField(),
            const SizedBox(height: 20),
            
            // Birth Time
            _buildTimeField(),
            const SizedBox(height: 20),
            
            // Birth Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Birth Location *',
                hintText: 'e.g., London, UK',
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF4097FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFF4097FF).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4097FF), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your birth location';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateNatalChart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4097FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
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
                        'Generate Natal Chart',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4097FF).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF4097FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? 'Birth Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Select Birth Date *',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: _selectedDate != null
                      ? Colors.black
                      : Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4097FF).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF4097FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? 'Birth Time: ${_selectedTime!.format(context)}'
                    : 'Select Birth Time *',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: _selectedTime != null
                      ? Colors.black
                      : Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Natal Chart',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4097FF),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _natalChartData = null;
                  });
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF4097FF)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Display natal chart data
          if (_natalChartData != null) ...[
            // Ascendant Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4097FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ascendant: ${(_natalChartData!['ascendant_degree'] as double).toStringAsFixed(2)}°',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4097FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your rising sign represents how others perceive you and your approach to life.',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Planets Section
            Text(
              'Planetary Positions',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 12),
            ...((_natalChartData!['planets'] as List).map<Widget>((planet) => 
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${planet['symbol']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${planet['name']} in ${planet['zodiac_sign']}',
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(planet['degree'] as double).toStringAsFixed(2)}° - House ${planet['house_number']}',
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
              )
            ).toList()),
            
            const SizedBox(height: 20),

            // Houses Section
            Text(
              'House System',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_natalChartData!['houses'] as List).map<Widget>((house) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4097FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'House ${house['house_number']}: ${(house['start_degree'] as double).toStringAsFixed(1)}°',
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).toList(),
            ),
            
            const SizedBox(height: 20),

            // Aspects Summary
            Text(
              'Major Aspects',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4097FF),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found ${(_natalChartData!['aspects'] as List).where((aspect) => aspect['aspect_type'] != -1).length} significant planetary aspects in your chart.',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aspects show how planets interact and influence each other in your personality and life experiences.',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: const Color(0xFF4097FF).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generate your natal chart to see detailed planetary positions, houses, and aspects.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4097FF),
              onPrimary: Colors.white,
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
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _birthtimeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _generateNatalChart() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/natal_chart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'birth_date': _birthdateController.text,
          'birth_time': _birthtimeController.text,
          'birth_location': _locationController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _natalChartData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to generate natal chart');
      }
    } catch (e) {
      print('Error generating natal chart: $e');
      setState(() {
        _natalChartData = {
          'analysis': 'Unable to connect to the server. Please check your connection and try again.'
        };
        _isLoading = false;
      });
    }
  }
}

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> with TickerProviderStateMixin {
  TabController? _tabController;
  final _birthdateController = TextEditingController();
  final _celebrityController = TextEditingController();
  final _sign2Controller = TextEditingController();
  DateTime? _selectedDate;
  String? _userSign;
  bool _isLoadingCompatibility = false;
  bool _isLoadingCelebrity = false;
  Map<String, dynamic>? _compatibilityResult;
  Map<String, dynamic>? _celebrityResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F8),
      appBar: AppBar(
        title: Text(
          'Zodiac Matching',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF4097FF),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Text(
                'Sign Compatibility',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Tab(
              child: Text(
                'Celebrity Match',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompatibilityTab(),
          _buildCelebrityTab(),
        ],
      ),
    );
  }

  Widget _buildCompatibilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
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
              children: [
                Text(
                  'Zodiac Compatibility',
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4097FF),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Your sign input
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Your Zodiac Sign',
                    prefixIcon: const Icon(Icons.star, color: Color(0xFF4097FF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _zodiacSigns.map((sign) {
                    return DropdownMenuItem(value: sign, child: Text(sign));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _userSign = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Partner's sign input
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Partner\'s Zodiac Sign',
                    prefixIcon: const Icon(Icons.favorite, color: Color(0xFFFF92A2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _zodiacSigns.map((sign) {
                    return DropdownMenuItem(value: sign, child: Text(sign));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sign2Controller.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingCompatibility ? null : _checkCompatibility,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4097FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoadingCompatibility
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Check Compatibility',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                if (_compatibilityResult != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Compatibility Result',
                          style: GoogleFonts.cinzel(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4097FF),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _compatibilityResult!['compatibility'] ?? 'Analysis unavailable',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
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
              children: [
                Text(
                  'Celebrity Match',
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4097FF),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Birth date input
                GestureDetector(
                  onTap: _selectDateForCelebrity,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4097FF).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF4097FF)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? 'Birth Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select Your Birth Date',
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              color: _selectedDate != null
                                  ? Colors.black
                                  : Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Your zodiac sign (optional)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Your Zodiac Sign (Optional)',
                    hintText: 'Auto-determined from birth date if empty',
                    prefixIcon: const Icon(Icons.star, color: Color(0xFF4097FF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [null, ..._zodiacSigns].map((sign) {
                    return DropdownMenuItem(
                      value: sign, 
                      child: Text(sign ?? 'Auto-determine from birth date'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _userSign = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Celebrity name (optional)
                TextField(
                  controller: _celebrityController,
                  decoration: InputDecoration(
                    labelText: 'Celebrity Name (Optional)',
                    hintText: 'Leave empty for top 3 compatible matches',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF4097FF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingCelebrity ? null : _findCelebrityMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF92A2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoadingCelebrity
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Find Celebrity Match',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                if (_celebrityResult != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Celebrity Match Result',
                          style: GoogleFonts.cinzel(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4097FF),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _celebrityResult!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4097FF),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.value.toString(),
                                    style: GoogleFonts.raleway(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateForCelebrity() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4097FF),
              onPrimary: Colors.white,
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
      });
    }
  }

  Future<void> _checkCompatibility() async {
    if (_userSign == null || _sign2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both zodiac signs')),
      );
      return;
    }

    setState(() {
      _isLoadingCompatibility = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/compatibility'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sign_1': _userSign,
          'sign_2': _sign2Controller.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _compatibilityResult = data;
          _isLoadingCompatibility = false;
        });
      } else {
        throw Exception('Failed to check compatibility');
      }
    } catch (e) {
      print('Error checking compatibility: $e');
      setState(() {
        _compatibilityResult = {
          'compatibility': 'Unable to connect to the server. Please check your connection and try again.'
        };
        _isLoadingCompatibility = false;
      });
    }
  }

  Future<void> _findCelebrityMatch() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birth date')),
      );
      return;
    }

    setState(() {
      _isLoadingCelebrity = true;
    });

    try {
      final body = {
        'birthdate': _birthdateController.text,
      };
      
      // Add optional sign parameter if selected
      if (_userSign != null && _userSign!.isNotEmpty) {
        body['sign'] = _userSign!;
      }
      
      // Add optional celebrity name if provided
      if (_celebrityController.text.isNotEmpty) {
        body['celebrity_name'] = _celebrityController.text;
      }

      final response = await http.post(
        Uri.parse('http://localhost:8000/with_celebrity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _celebrityResult = data;
          _isLoadingCelebrity = false;
        });
      } else {
        throw Exception('Failed to find celebrity match');
      }
    } catch (e) {
      print('Error finding celebrity match: $e');
      setState(() {
        _celebrityResult = {
          'Error': 'Unable to connect to the server. Please check your connection and try again.'
        };
        _isLoadingCelebrity = false;
      });
    }
  }

  static const List<String> _zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];
}

