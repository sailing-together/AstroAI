import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pages.dart';
import 'providers/app_state.dart';
import 'pages/daily_insights_page.dart';
import 'pages/ai_assistant_page.dart';
import 'models/user_data.dart';
import 'dart:math' as math;

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
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        home: const HomePage(),
        routes: {
          '/daily-insights': (context) => const DailyInsightsPage(),
          '/ai-assistant': (context) => const AiAssistantPage(),
        },
      ),
    );
  }
}

// Zodiac-themed color palette
class ZodiacColors {
  static const Color primaryPurple = Color(0xFF8B5CF6); // Mystical purple
  static const Color deepPurple = Color(0xFF6D28D9); // Deep mystical
  static const Color cosmicPink = Color(0xFFEC4899); // Cosmic pink
  static const Color starGold = Color(0xFFFBBF24); // Star gold
  static const Color cosmicBlue = Color(0xFF3B82F6); // Cosmic blue
  static const Color darkSpace = Color(0xFF1E1B4B); // Dark space
  static const Color lightSpace = Color(0xFFF8FAFC); // Light space
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZodiacColors.darkSpace,
      body: Stack(
        children: [
          // Twinkling stars background
          const TwinklingStarsBackground(),
          
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: SingleChildScrollView(
              child: const Column(
                children: [
                  HeroSection(),
                  ZodiacSection(),
                  CosmicDestinySection(),
                  FeaturesSection(),
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

// Twinkling stars background effect
class TwinklingStarsBackground extends StatefulWidget {
  const TwinklingStarsBackground({super.key});

  @override
  State<TwinklingStarsBackground> createState() => _TwinklingStarsBackgroundState();
}

class _TwinklingStarsBackgroundState extends State<TwinklingStarsBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starAnimations;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _generateStars();
    _initializeAnimations();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        delay: random.nextDouble() * 2,
      ));
    }
  }

  void _initializeAnimations() {
    _starControllers = List.generate(
      _stars.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: (1000 + _stars[index].delay * 1000).round()),
        vsync: this,
      ),
    );

    _starAnimations = _starControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (var controller in _starControllers) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: StarsPainter(_stars, _starAnimations),
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double delay;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final List<Animation<double>> animations;

  StarsPainter(this.stars, this.animations);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZodiacColors.starGold
      ..style = PaintingStyle.fill;

    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];
      final animation = animations[i];
      
      final opacity = (0.3 + animation.value * 0.7);
      paint.color = ZodiacColors.starGold.withOpacity(opacity);
      
      final x = star.x * size.width;
      final y = star.y * size.height;
      final radius = star.size * (0.5 + animation.value * 0.5);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NavigationHeader extends StatefulWidget {
  const NavigationHeader({super.key});

  @override
  State<NavigationHeader> createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<NavigationHeader> {
  String _currentMenuItem = 'Home';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 89,
      decoration: BoxDecoration(
        color: ZodiacColors.darkSpace.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: ZodiacColors.primaryPurple.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 20,
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
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: ZodiacColors.cosmicPink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ZodiacColors.cosmicPink.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AstroAI',
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ZodiacColors.starGold,
                    ),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (MediaQuery.of(context).size.width < 800) {
                    return IconButton(
                      icon: Icon(Icons.menu, color: ZodiacColors.starGold),
                      onPressed: () {},
                    );
                  }
                  return Row(
                    children: [
                      _buildMenuItem('Home', context),
                      _buildMenuItem('Horoscope', context),
                      _buildMenuItemWithDropdown('More Features', context),
                      _buildMenuItem('About Us', context),
                      _buildHighlightedMenuItem('Reach out to us', context),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? ZodiacColors.primaryPurple.withOpacity(0.2) : Colors.transparent,
        ),
        child: Text(
          text,
          style: GoogleFonts.raleway(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? ZodiacColors.starGold : ZodiacColors.starGold.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedMenuItem(String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ZodiacColors.cosmicPink, ZodiacColors.primaryPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ZodiacColors.cosmicPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateToPage(String pageName, BuildContext context) {
    setState(() {
      _currentMenuItem = pageName;
    });

    switch (pageName) {
      case 'Home':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: const RouteSettings(name: '/'),
          ),
          (route) => false,
        );
        break;
      case 'Horoscope':
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
        borderRadius: BorderRadius.circular(12),
      ),
      color: ZodiacColors.darkSpace,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              text,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: text == _currentMenuItem ? FontWeight.w700 : FontWeight.w400,
                color: text == _currentMenuItem ? ZodiacColors.starGold : ZodiacColors.starGold.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: ZodiacColors.starGold.withOpacity(0.7),
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Matching',
          child: Text(
            'Matching',
            style: GoogleFonts.raleway(fontSize: 14, color: ZodiacColors.starGold),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Natal chart',
          child: Text(
            'Natal chart',
            style: GoogleFonts.raleway(fontSize: 14, color: ZodiacColors.starGold),
          ),
        ),
        PopupMenuItem<String>(
          value: 'ASMR',
          child: Text(
            'ASMR',
            style: GoogleFonts.raleway(fontSize: 14, color: ZodiacColors.starGold),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Tarot',
          child: Text(
            'Tarot',
            style: GoogleFonts.raleway(fontSize: 14, color: ZodiacColors.starGold),
          ),
        ),
      ],
      onSelected: (String value) {
        if (context == null) return;
        
        setState(() {
          _currentMenuItem = 'More Features';
        });
        
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
                builder: (context) => const AsmrPage(),
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
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 600,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/MainSpace.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ZodiacColors.darkSpace.withOpacity(0.3),
              ZodiacColors.darkSpace.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1152),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeroContent(context),
                      const SizedBox(height: 40),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: _buildHeroContent(context)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPLORE YOUR\nCOSMIC JOURNEY',
          style: GoogleFonts.cinzel(
            fontSize: 60,
            fontWeight: FontWeight.w700,
            color: ZodiacColors.starGold,
            letterSpacing: -1,
            height: 1.2,
            shadows: [
              Shadow(
                color: ZodiacColors.primaryPurple.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Discover your zodiac, daily horoscope, and cosmic insights with just your birthday. Simple, beautiful, and powered by AI.',
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: -0.32,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            _scrollToZodiacSection(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ZodiacColors.cosmicPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            shadowColor: ZodiacColors.cosmicPink.withOpacity(0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Started',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_downward, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _scrollToZodiacSection(BuildContext context) {
    Scrollable.ensureVisible(
      context.findAncestorStateOfType<_ZodiacSectionState>()?.context ?? context,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }
}

class ZodiacSection extends StatefulWidget {
  const ZodiacSection({super.key});

  @override
  State<ZodiacSection> createState() => _ZodiacSectionState();
}

class _ZodiacSectionState extends State<ZodiacSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: Column(
            children: [
              Text(
                'Choose your zodiac',
                style: GoogleFonts.cinzel(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: ZodiacColors.starGold,
                  letterSpacing: -1,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Tap to reveal your cosmic destiny',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 :
                                 MediaQuery.of(context).size.width < 900 ? 3 : 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return ZodiacCard(index: index);
                },
              ),
            ],
          ),
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
  bool isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const List<Map<String, dynamic>> zodiacSigns = [
    {'name': 'ARIES', 'symbol': '♈', 'dates': 'MAR 21 - APR 19', 'element': 'Fire', 'planet': 'Mars'},
    {'name': 'TAURUS', 'symbol': '♉', 'dates': 'APR 20 - MAY 20', 'element': 'Earth', 'planet': 'Venus'},
    {'name': 'GEMINI', 'symbol': '♊', 'dates': 'MAY 21 - JUN 20', 'element': 'Air', 'planet': 'Mercury'},
    {'name': 'CANCER', 'symbol': '♋', 'dates': 'JUN 21 - JUL 22', 'element': 'Water', 'planet': 'Moon'},
    {'name': 'LEO', 'symbol': '♌', 'dates': 'JUL 23 - AUG 22', 'element': 'Fire', 'planet': 'Sun'},
    {'name': 'VIRGO', 'symbol': '♍', 'dates': 'AUG 23 - SEP 22', 'element': 'Earth', 'planet': 'Mercury'},
    {'name': 'LIBRA', 'symbol': '♎', 'dates': 'SEP 23 - OCT 22', 'element': 'Air', 'planet': 'Venus'},
    {'name': 'SCORPIO', 'symbol': '♏', 'dates': 'OCT 23 - NOV 21', 'element': 'Water', 'planet': 'Pluto'},
    {'name': 'SAGITTARIUS', 'symbol': '♐', 'dates': 'NOV 22 - DEC 21', 'element': 'Fire', 'planet': 'Jupiter'},
    {'name': 'CAPRICORN', 'symbol': '♑', 'dates': 'DEC 22 - JAN 19', 'element': 'Earth', 'planet': 'Saturn'},
    {'name': 'AQUARIUS', 'symbol': '♒', 'dates': 'JAN 20 - FEB 18', 'element': 'Air', 'planet': 'Uranus'},
    {'name': 'PISCES', 'symbol': '♓', 'dates': 'FEB 19 - MAR 20', 'element': 'Water', 'planet': 'Neptune'},
  ];

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
    final zodiac = zodiacSigns[widget.index];

    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipped = !isFlipped;
        });
        if (isFlipped) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final flipValue = isFlipped ? _animation.value : (1.0 - _animation.value);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(flipValue * 3.14159),
            child: flipValue < 0.5
                ? _buildFrontCard(zodiac)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildBackCard(zodiac),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> zodiac) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZodiacColors.primaryPurple,
            ZodiacColors.deepPurple,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ZodiacColors.primaryPurple.withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zodiac Symbol
            Text(
              zodiac['symbol']!,
              style: TextStyle(
                color: ZodiacColors.starGold,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: ZodiacColors.starGold.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Zodiac Name
            Text(
              zodiac['name']!,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Date Range
            Text(
              zodiac['dates']!,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Element
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ZodiacColors.cosmicPink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ZodiacColors.cosmicPink.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                zodiac['element']!,
                style: GoogleFonts.raleway(
                  color: ZodiacColors.cosmicPink,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(Map<String, dynamic> zodiac) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZodiacColors.deepPurple,
            ZodiacColors.darkSpace,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ZodiacColors.primaryPurple.withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mystical border
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ZodiacColors.starGold.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Central mystical design
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
                          color: ZodiacColors.starGold.withOpacity(0.4),
                          width: 2,
                        ),
                        gradient: RadialGradient(
                          colors: [
                            ZodiacColors.starGold.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          zodiac['symbol']!,
                          style: TextStyle(
                            color: ZodiacColors.starGold,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Decorative cosmic patterns
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: CustomPaint(
                      size: const Size(double.infinity, 20),
                      painter: CosmicPatternPainter(),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 10,
                    right: 10,
                    child: CustomPaint(
                      size: const Size(double.infinity, 20),
                      painter: CosmicPatternPainter(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Planet information
            Text(
              'Ruled by ${zodiac['planet']!}',
              style: GoogleFonts.raleway(
                color: ZodiacColors.cosmicPink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Name at bottom
            Text(
              zodiac['name']!,
              style: GoogleFonts.cinzel(
                color: ZodiacColors.starGold,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Bottom mystical border
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ZodiacColors.starGold.withOpacity(0.6),
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

class CosmicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZodiacColors.starGold.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    
    // Create mystical wave pattern
    for (double x = 0; x < size.width; x += 20) {
      final y = size.height / 2 + math.sin(x * 0.1) * 5;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CosmicDestinySection extends StatelessWidget {
  const CosmicDestinySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZodiacColors.darkSpace,
            ZodiacColors.deepPurple.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    _buildIconGrid(),
                    const SizedBox(height: 44),
                    _buildCosmicContent(),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 1, child: _buildIconGrid()),
                  const SizedBox(width: 100),
                  Expanded(flex: 1, child: _buildCosmicContent()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        _buildIconCard(ZodiacColors.cosmicPink, 'heart'),
        _buildIconCard(ZodiacColors.cosmicBlue, 'toolbox'),
        _buildIconCard(ZodiacColors.starGold, 'flask'),
        _buildIconCard(ZodiacColors.primaryPurple, 'dollar'),
      ],
    );
  }

  Widget _buildIconCard(Color color, String iconType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: _buildSvgIcon(iconType, color),
        ),
      ),
    );
  }

  Widget _buildSvgIcon(String iconType, Color color) {
    switch (iconType) {
      case 'heart':
        return _buildHeartIcon(color);
      case 'toolbox':
        return _buildToolboxIcon(color);
      case 'flask':
        return _buildFlaskIcon(color);
      case 'dollar':
        return _buildDollarIcon(color);
      default:
        return Container();
    }
  }

  Widget _buildHeartIcon(Color color) {
    return Icon(
      Icons.favorite,
      size: 40,
      color: color,
    );
  }

  Widget _buildToolboxIcon(Color color) {
    return Icon(
      Icons.psychology,
      size: 40,
      color: color,
    );
  }

  Widget _buildFlaskIcon(Color color) {
    return Icon(
      Icons.auto_awesome,
      size: 40,
      color: color,
    );
  }

  Widget _buildDollarIcon(Color color) {
    return Icon(
      Icons.star,
      size: 40,
      color: color,
    );
  }

  Widget _buildCosmicContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unlock your cosmic destiny!',
          style: GoogleFonts.cinzel(
            fontSize: 50,
            fontWeight: FontWeight.w700,
            color: ZodiacColors.starGold,
            letterSpacing: -1,
            height: 1.3,
            shadows: [
              Shadow(
                color: ZodiacColors.primaryPurple.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Our AI analyses your zodiac sign to deliver tailored predictions about romance, success, and fortune. Discover what the universe has in store!',
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: -0.32,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            _showUserDataDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ZodiacColors.cosmicPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
            shadowColor: ZodiacColors.cosmicPink.withOpacity(0.5),
          ),
          child: Text(
            'Enter your birthday',
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZodiacColors.deepPurple.withOpacity(0.8),
            ZodiacColors.darkSpace,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: Column(
            children: [
              Text(
                'Cosmic Features',
                style: GoogleFonts.cinzel(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: ZodiacColors.starGold,
                  letterSpacing: -1,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Discover the mystical tools that await you',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _buildFeatureCard(context, 'Matching', ZodiacColors.cosmicPink),
                        const SizedBox(height: 24),
                        _buildFeatureCard(context, 'Natal chart', ZodiacColors.cosmicBlue),
                        const SizedBox(height: 24),
                        _buildFeatureCard(context, 'ASMR', ZodiacColors.starGold),
                        const SizedBox(height: 24),
                        _buildFeatureCard(context, 'Tarot', ZodiacColors.primaryPurple),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: _buildFeatureCard(context, 'Matching', ZodiacColors.cosmicPink)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildFeatureCard(context, 'Natal chart', ZodiacColors.cosmicBlue)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildFeatureCard(context, 'ASMR', ZodiacColors.starGold)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildFeatureCard(context, 'Tarot', ZodiacColors.primaryPurple)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  _showUserDataDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZodiacColors.cosmicPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  shadowColor: ZodiacColors.cosmicPink.withOpacity(0.5),
                ),
                child: Text(
                  'Start Your Journey',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.1),
            accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
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
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getFeatureIcon(title),
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.48,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getFeatureDescription(title),
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
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
              'Learn more',
              style: GoogleFonts.raleway(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accentColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String title) {
    switch (title) {
      case 'Matching':
        return Icons.favorite;
      case 'Natal chart':
        return Icons.psychology;
      case 'ASMR':
        return Icons.headphones;
      case 'Tarot':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }

  String _getFeatureDescription(String title) {
    switch (title) {
      case 'Matching':
        return 'Find your perfect cosmic match based on zodiac compatibility and astrological insights.';
      case 'Natal chart':
        return 'Discover your unique birth chart and understand your cosmic blueprint with detailed planetary analysis.';
      case 'ASMR':
        return 'Immerse yourself in soothing cosmic sounds and guided meditation for spiritual relaxation.';
      case 'Tarot':
        return 'Explore mystical tarot readings and divine guidance for your life\'s journey.';
      default:
        return 'Discover the mystical tools that await you on your cosmic journey.';
    }
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
            backgroundColor: ZodiacColors.darkSpace,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Welcome to AstroAI! ✨',
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ZodiacColors.starGold,
              ),
              textAlign: TextAlign.center,
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
                                primary: Color(0xFF9398DF),
                                onPrimary: Colors.white,
                                surface: Color(0xFF1A1A2E),
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
                  backgroundColor: ZodiacColors.cosmicPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                  shadowColor: ZodiacColors.cosmicPink.withOpacity(0.5),
                ),
                                  child: Text(
                    'Start My Journey',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
