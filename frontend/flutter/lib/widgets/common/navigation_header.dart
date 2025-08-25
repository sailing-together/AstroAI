
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:AstroAI/pages.dart';
import 'package:AstroAI/pages/daily_insights_page.dart';
import 'package:AstroAI/pages/signup_page.dart';
import 'package:AstroAI/pages/home_page.dart';


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
