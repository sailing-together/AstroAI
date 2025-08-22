import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: const Color(0xFFDADADA),
      body: Stack(
        children: [
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
                    width: 17,
                    height: 17,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logo',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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
          MaterialPageRoute(builder: (context) => const ContactPage()),
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    _buildHeroContent(context),
                    const SizedBox(height: 40),
                    _buildHeroImage(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: _buildHeroContent(context)),
                  const SizedBox(width: 168),
                  Expanded(flex: 7, child: _buildHeroImage()),
                ],
              );
            },
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
          'EXPLORE YOUR\nJOURNEY',
          style: GoogleFonts.cinzel(
            fontSize: 50,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -1,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Discover your zodiac, daily horoscope, and cosmic insights with just your birthday. Simple, beautiful, and powered by AI.',
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: -0.32,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            _showUserDataDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            'Get Started',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: 623,
      height: 401,
      decoration: ShapeDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/MainSpace.png'),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 30,
            offset: Offset(30, 60),
            spreadRadius: -30,
          )
        ],
      ),
    );
  }
}

class ZodiacSection extends StatelessWidget {
  const ZodiacSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F3F3),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
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
                color: Colors.black,
                letterSpacing: -1,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 :
                               MediaQuery.of(context).size.width < 900 ? 4 : 6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
            Color(0xFF605688),
            Color(0xFF4A4070),
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
                color: const Color(0xFFFBF7BA),
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
            Color(0xFF605688),
            Color(0xFF4A4070),
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
                color: const Color(0xFFFBF7BA),
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

class CosmicDestinySection extends StatelessWidget {
  const CosmicDestinySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildIconCard(const Color(0xFFF9C3C3), 'heart'),
        _buildIconCard(const Color(0xFFBAE9AB), 'toolbox'),
        _buildIconCard(const Color(0xFFEAF1B2), 'flask'),
        _buildIconCard(const Color(0xFF3E5F8D), 'dollar'),
      ],
    );
  }

  Widget _buildIconCard(Color color, String iconType) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 109,
          height: 110,
          child: _buildSvgIcon(iconType),
        ),
      ),
    );
  }

  Widget _buildSvgIcon(String iconType) {
    switch (iconType) {
      case 'heart':
        return _buildHeartIcon();
      case 'toolbox':
        return _buildToolboxIcon();
      case 'flask':
        return _buildFlaskIcon();
      case 'dollar':
        return _buildDollarIcon();
      default:
        return Container();
    }
  }

  Widget _buildHeartIcon() {
    return CustomPaint(
      size: const Size(109, 110),
      painter: HeartIconPainter(),
    );
  }

  Widget _buildToolboxIcon() {
    return CustomPaint(
      size: const Size(92, 92),
      painter: ToolboxIconPainter(),
    );
  }

  Widget _buildFlaskIcon() {
    return CustomPaint(
      size: const Size(116, 110),
      painter: FlaskIconPainter(),
    );
  }

  Widget _buildDollarIcon() {
    return CustomPaint(
      size: const Size(91, 110),
      painter: DollarIconPainter(),
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
            color: Colors.black,
            letterSpacing: -1,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Our AI analyses your zodiac sign to deliver tailored predictions about romance, success, and fortune. Discover what the universe has in store!',
          style: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: -0.32,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Enter your birthday',
            style: GoogleFonts.inter(
              fontSize: 12,
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
      color: const Color(0xFFEFEEED),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: Column(
          children: [
            Text(
              'features',
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildFeatureCard(context, 'Matching', const Color(0xFF4A4A4A)),
                      const SizedBox(height: 24),
                      _buildFeatureCard(context, 'Natal chart', const Color(0xFF9398DF)),
                      const SizedBox(height: 24),
                      _buildFeatureCard(context, 'ASMR', const Color(0xFFBB8075)),
                      const SizedBox(height: 24),
                      _buildFeatureCard(context, 'Tarot', const Color(0xFF6953B9)),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _buildFeatureCard(context, 'Matching', const Color(0xFF4A4A4A))),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFeatureCard(context, 'Natal chart', const Color(0xFF9398DF))),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFeatureCard(context, 'ASMR', const Color(0xFFBB8075))),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFeatureCard(context, 'Tarot', const Color(0xFF6953B9))),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Button Text',
                style: GoogleFonts.inter(
                  fontSize: 12,
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

  Widget _buildFeatureCard(BuildContext context, String title, Color iconColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
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
                  color: iconColor,
                  borderRadius: BorderRadius.circular(32),
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
            'This is the description of the first feature of our app. We are going yo briefly outline what this feature does',
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
            backgroundColor: const Color(0xFF1A1A2E),
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
                  backgroundColor: const Color(0xFF9398DF),
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
