import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

// Page classes for navigation
class HoroscopePage extends StatelessWidget {
  const HoroscopePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Cosmic Insights',
                        style: GoogleFonts.cinzel(
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -1,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildHoroscopeSection('Love & Relationships', 'Discover insights about your romantic life and connections.'),
                      _buildHoroscopeSection('Career Path', 'Navigate your professional journey with cosmic guidance.'),
                      _buildHoroscopeSection('Financial Outlook', 'Understand your financial potential and opportunities.'),
                      _buildHoroscopeSection('Health & Wellness', 'Align your wellbeing with celestial energies.'),
                    ],
                  ),
                ),
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

  Widget _buildHoroscopeSection(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AstroAI - Your Personal Cosmic Guide 🌌',
                          style: GoogleFonts.cinzel(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: -1,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSection('Vision', 'AstroAI combines traditional astrology with modern AI technology and immersive sound experiences to create a comprehensive personal cosmic guidance platform.'),
                        _buildFeatureGrid(),
                        _buildSection('AI Integration 🤖', 'Our AI Astrologer Assistant provides natural language interaction, personalized astrological guidance, and real-time question answering.'),
                        _buildSection('Premium Features ✨', 'Experience our exclusive ASMR & Meditation Suite with 12 unique zodiac-themed sound experiences, emotion-based recommendations, and AI-powered personalization.'),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Core Features 🌟',
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5,
            children: [
              _buildFeatureCard('Compatibility Analysis', 'Relationship matching, friendship compatibility, and business partnership synergy.', const Color(0xFF9398DF)),
              _buildFeatureCard('Natal Chart Analysis', 'Personalized birth chart generation with detailed planet positions interpretation.', const Color(0xFFBB8075)),
              _buildFeatureCard('Smart Notifications', 'Astrological event reminders and personalized cosmic advice.', const Color(0xFF6953B9)),
              _buildFeatureCard('ASMR & Meditation', '12 unique zodiac-themed sound experiences with AI-powered personalization.', const Color(0xFF4A4A4A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              color: Colors.white,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get in Touch',
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
                        'Connect with our cosmic guidance team for personalized support, technical assistance, or partnership opportunities.',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: _buildContactCard('Email Support', 'support@astroai.com', 'Get technical help and account assistance'),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildContactCard('Partnerships', 'partners@astroai.com', 'Explore collaboration opportunities'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  Widget _buildContactCard(String title, String email, String description) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6953B9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Matching Page - Compatibility Analysis
class MatchingPage extends StatelessWidget {
  const MatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              color: const Color(0xFFF3F3F3),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compatibility Analysis',
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
                          'Discover your cosmic connections through advanced astrological compatibility analysis. Find your perfect match based on zodiac signs, birth charts, and celestial alignments.',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildCompatibilitySection(),
                        const SizedBox(height: 40),
                        _buildMatchingTypes(),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildCompatibilitySection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Perfect Match',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInputCard('Your Sign', 'Select your zodiac sign'),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.favorite, color: Color(0xFF6953B9), size: 32),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInputCard('Partner\'s Sign', 'Select partner\'s sign'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6953B9),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Analyze Compatibility',
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
    );
  }

  Widget _buildInputCard(String title, String hint) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compatibility Types',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.2,
          children: [
            _buildTypeCard('Romantic Love', '💕', 'Find your soulmate through astrological compatibility'),
            _buildTypeCard('Friendship', '🤝', 'Discover lasting friendships with cosmic connections'),
            _buildTypeCard('Business Partnership', '💼', 'Align with partners for professional success'),
            _buildTypeCard('Family Harmony', '👨‍👩‍👧‍👦', 'Understand family dynamics and relationships'),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard(String title, String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
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
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Natal Chart Page
class NatalChartPage extends StatelessWidget {
  const NatalChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              color: const Color(0xFF1A1A2E),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Natal Chart Analysis',
                          style: GoogleFonts.cinzel(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Unlock the secrets of your birth chart. Discover your planetary positions, houses, and aspects that shape your personality and destiny.',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildChartInputSection(),
                        const SizedBox(height: 40),
                        _buildChartFeatures(),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildChartInputSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0F3460)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate Your Birth Chart',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildNatalInputCard('Birth Date', 'MM/DD/YYYY'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNatalInputCard('Birth Time', 'HH:MM AM/PM'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNatalInputCard('Birth Place', 'City, Country'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9398DF),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Create Natal Chart',
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
    );
  }

  Widget _buildNatalInputCard(String title, String hint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9398DF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: GoogleFonts.raleway(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chart Analysis Features',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1,
          children: [
            _buildNatalFeatureCard('Planetary Positions', '🪐', 'Sun, Moon, Mercury, Venus, Mars positions'),
            _buildNatalFeatureCard('Houses Analysis', '🏠', '12 astrological houses interpretation'),
            _buildNatalFeatureCard('Aspects & Angles', '📐', 'Conjunctions, trines, squares analysis'),
            _buildNatalFeatureCard('Rising Sign', '🌅', 'Your ascendant and first impressions'),
            _buildNatalFeatureCard('Moon Phase', '🌙', 'Lunar influence on your personality'),
            _buildNatalFeatureCard('Elements Balance', '🔥💧🌍💨', 'Fire, Water, Earth, Air distribution'),
          ],
        ),
      ],
    );
  }

  Widget _buildNatalFeatureCard(String title, String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9398DF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ASMR Page
class ASMRPage extends StatelessWidget {
  const ASMRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2C1810),
                    Color(0xFF8B4513),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASMR & Meditation',
                          style: GoogleFonts.cinzel(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Immerse yourself in cosmic soundscapes designed for your zodiac sign. Experience personalized ASMR and meditation sessions that align with your astrological energy.',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildZodiacSounds(),
                        const SizedBox(height: 40),
                        _buildMeditationTypes(),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildZodiacSounds() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zodiac Sound Library',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            _buildSoundCard('Aries', '♈', 'Energetic Fire Sounds', const Color(0xFFFF6B6B)),
            _buildSoundCard('Taurus', '♉', 'Earthy Nature Sounds', const Color(0xFF4ECDC4)),
            _buildSoundCard('Gemini', '♊', 'Whispering Winds', const Color(0xFFFFE66D)),
            _buildSoundCard('Cancer', '♋', 'Ocean Wave Therapy', const Color(0xFF95E1D3)),
            _buildSoundCard('Leo', '♌', 'Warm Sun Meditation', const Color(0xFFFF8B94)),
            _buildSoundCard('Virgo', '♍', 'Forest Tranquility', const Color(0xFFA8E6CF)),
            _buildSoundCard('Libra', '♎', 'Harmonic Balance', const Color(0xFFFFAAB0)),
            _buildSoundCard('Scorpio', '♏', 'Deep Water Mysteries', const Color(0xFF88D8B0)),
            _buildSoundCard('Sagittarius', '♐', 'Adventure Sounds', const Color(0xFFFFC8A2)),
            _buildSoundCard('Capricorn', '♑', 'Mountain Echoes', const Color(0xFFD4A5A5)),
            _buildSoundCard('Aquarius', '♒', 'Cosmic Frequencies', const Color(0xFFA2D2FF)),
            _buildSoundCard('Pisces', '♓', 'Dreamy Underwater', const Color(0xFFBDB2FF)),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundCard(String sign, String symbol, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            sign,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
                      Text(
              description,
              style: GoogleFonts.raleway(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
          Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meditation Categories',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildMeditationCard('Sleep Stories', '🌙', 'Cosmic bedtime stories for peaceful sleep'),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMeditationCard('Focus Sessions', '🧘‍♀️', 'Concentration enhancement through sound'),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMeditationCard('Stress Relief', '🕯️', 'Calming sounds for anxiety reduction'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeditationCard(String title, String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Tarot Page
// Instruction Page
class InstructionPage extends StatelessWidget {
  const InstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AstroAI - Your Personal Cosmic Guide 🌌',
                          style: GoogleFonts.cinzel(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to AstroAI, where traditional astrology meets modern AI technology to provide you with personalized cosmic guidance and insights.',
                          style: GoogleFonts.raleway(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildVisionSection(),
                        const SizedBox(height: 40),
                        _buildCoreFeatures(),
                        const SizedBox(height: 40),
                        _buildHowToUse(),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildVisionSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Vision',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AstroAI combines traditional astrology with modern AI technology and immersive sound experiences to create a comprehensive personal cosmic guidance platform.',
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Features 🌟',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.2,
          children: [
            _buildInstructionCard('Daily Cosmic Insights', '🌙', 'Get personalized daily, weekly, and monthly horoscopes covering love, career, finance, and health.'),
            _buildInstructionCard('Compatibility Analysis', '💕', 'Discover relationship compatibility, friendship synergy, and business partnership potential.'),
            _buildInstructionCard('Natal Chart Analysis', '🌌', 'Generate detailed birth charts with planetary positions and astrological interpretations.'),
            _buildInstructionCard('ASMR & Meditation', '🎵', 'Enjoy zodiac-themed soundscapes and guided meditations tailored to your astrological profile.'),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionCard(String title, String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToUse() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF9398DF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9398DF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Get Started',
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildStep('1', 'Choose Your Zodiac', 'Click on your zodiac sign to get personalized insights'),
          _buildStep('2', 'Explore Features', 'Try our compatibility analysis, natal charts, and ASMR experiences'),
          _buildStep('3', 'Get Daily Insights', 'Visit the horoscope section for daily cosmic guidance'),
          _buildStep('4', 'Discover More', 'Explore advanced features like tarot readings and meditation'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF9398DF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Individual Zodiac Detail Page
class ZodiacDetailPage extends StatelessWidget {
  final String zodiacName;
  final String zodiacSymbol;
  final String dateRange;
  final int zodiacIndex;

  const ZodiacDetailPage({
    super.key,
    required this.zodiacName,
    required this.zodiacSymbol,
    required this.dateRange,
    required this.zodiacIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _getZodiacColors(zodiacIndex),
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildZodiacHeader(),
                        const SizedBox(height: 40),
                        _buildHoroscopeGrid(),
                        const SizedBox(height: 40),
                        _buildZodiacTraits(),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildZodiacHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
            ),
            child: Center(
              child: Text(
                zodiacSymbol,
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zodiacName.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateRange,
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getZodiacDescription(zodiacName),
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Horoscope Insights',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1,
          children: [
            _buildHoroscopeCard('Love & Relationships', '💕', _getLoveHoroscope(zodiacName)),
            _buildHoroscopeCard('Career Path', '💼', _getCareerHoroscope(zodiacName)),
            _buildHoroscopeCard('Financial Outlook', '💰', _getFinancialHoroscope(zodiacName)),
            _buildHoroscopeCard('Health & Wellness', '🌿', _getHealthHoroscope(zodiacName)),
          ],
        ),
      ],
    );
  }

  Widget _buildHoroscopeCard(String title, String emoji, String content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacTraits() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$zodiacName Personality Traits',
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTraitColumn('Strengths', _getStrengths(zodiacName)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTraitColumn('Areas for Growth', _getGrowthAreas(zodiacName)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTraitColumn(String title, List<String> traits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 12),
        ...traits.map((trait) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Expanded(
                child: Text(
                  trait,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  List<Color> _getZodiacColors(int index) {
    final colors = [
      [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)], // Aries - Fire
      [const Color(0xFF4ECDC4), const Color(0xFF44A08D)], // Taurus - Earth
      [const Color(0xFFFFE66D), const Color(0xFFFF6B6B)], // Gemini - Air
      [const Color(0xFF95E1D3), const Color(0xFF3BB2B8)], // Cancer - Water
      [const Color(0xFFFF8B94), const Color(0xFFFFAB91)], // Leo - Fire
      [const Color(0xFFA8E6CF), const Color(0xFF7FCDCD)], // Virgo - Earth
      [const Color(0xFFFFAAB0), const Color(0xFFFF8A80)], // Libra - Air
      [const Color(0xFF88D8B0), const Color(0xFF006064)], // Scorpio - Water
      [const Color(0xFFFFC8A2), const Color(0xFFFF7043)], // Sagittarius - Fire
      [const Color(0xFFD4A5A5), const Color(0xFF8D6E63)], // Capricorn - Earth
      [const Color(0xFFA2D2FF), const Color(0xFF1976D2)], // Aquarius - Air
      [const Color(0xFFBDB2FF), const Color(0xFF7986CB)], // Pisces - Water
    ];
    return colors[index % colors.length];
  }

  String _getZodiacDescription(String zodiac) {
    final descriptions = {
      'ARIES': 'Bold, ambitious, and energetic. Aries are natural leaders who embrace challenges with courage and determination.',
      'TAURUS': 'Reliable, patient, and practical. Taurus values stability, comfort, and the finer things in life.',
      'GEMINI': 'Curious, adaptable, and communicative. Gemini thrives on variety, learning, and social connections.',
      'CANCER': 'Intuitive, protective, and nurturing. Cancer is deeply emotional and values family and home above all.',
      'LEO': 'Confident, generous, and dramatic. Leo loves to shine and inspire others with their natural charisma.',
      'VIRGO': 'Analytical, helpful, and perfectionist. Virgo seeks order and improvement in everything they do.',
      'LIBRA': 'Diplomatic, charming, and balanced. Libra values harmony, beauty, and fair partnerships.',
      'SCORPIO': 'Intense, mysterious, and transformative. Scorpio seeks deep connections and profound truths.',
      'SAGITTARIUS': 'Adventurous, optimistic, and philosophical. Sagittarius loves freedom, travel, and expanding horizons.',
      'CAPRICORN': 'Ambitious, disciplined, and responsible. Capricorn is focused on achieving long-term success and recognition.',
      'AQUARIUS': 'Independent, innovative, and humanitarian. Aquarius values originality and making the world a better place.',
      'PISCES': 'Compassionate, artistic, and intuitive. Pisces is deeply empathetic and connected to the spiritual realm.',
    };
    return descriptions[zodiac] ?? 'A unique and special zodiac sign with many wonderful qualities.';
  }

  String _getLoveHoroscope(String zodiac) {
    final love = {
      'ARIES': 'Passionate and direct in love. You seek excitement and adventure in relationships. Your ideal partner matches your energy and enthusiasm.',
      'TAURUS': 'Loyal and sensual in relationships. You value stability and commitment. Physical affection and quality time are important to you.',
      'GEMINI': 'Playful and communicative in love. You need intellectual stimulation and variety. Good conversation is key to your heart.',
      'CANCER': 'Nurturing and protective in relationships. You seek emotional security and deep connections. Home and family are central to your love life.',
      'LEO': 'Generous and romantic in love. You enjoy grand gestures and being admired. Your partner should appreciate your need to shine.',
      'VIRGO': 'Thoughtful and devoted in relationships. You show love through acts of service. You seek a partner who shares your values and goals.',
      'LIBRA': 'Harmonious and romantic in love. You seek balance and partnership. Beauty, charm, and intellectual connection attract you.',
      'SCORPIO': 'Intense and transformative in love. You seek deep, soul-level connections. Loyalty and emotional honesty are non-negotiable.',
      'SAGITTARIUS': 'Free-spirited and adventurous in love. You need space to grow and explore. Your ideal partner shares your love of adventure.',
      'CAPRICORN': 'Committed and practical in love. You seek long-term stability and shared goals. You show love through reliability and support.',
      'AQUARIUS': 'Independent and unconventional in love. You value friendship and intellectual connection. You need space to be yourself.',
      'PISCES': 'Romantic and intuitive in love. You seek spiritual and emotional connection. Compassion and creativity draw you to partners.',
    };
    return love[zodiac] ?? 'Love brings unique opportunities for growth and connection.';
  }

  String _getCareerHoroscope(String zodiac) {
    final career = {
      'ARIES': 'Natural leadership roles suit you. Entrepreneurship, sales, sports, or military careers align with your pioneering spirit.',
      'TAURUS': 'Steady careers in finance, real estate, agriculture, or luxury goods appeal to your practical nature and love of stability.',
      'GEMINI': 'Communication-based careers thrive for you. Writing, teaching, media, or technology fields match your versatile mind.',
      'CANCER': 'Nurturing professions call to you. Healthcare, education, hospitality, or real estate align with your caring nature.',
      'LEO': 'Creative and leadership roles suit you. Entertainment, management, teaching, or politics allow you to shine and inspire.',
      'VIRGO': 'Detail-oriented careers appeal to you. Healthcare, research, editing, or service industries match your perfectionist nature.',
      'LIBRA': 'Harmonious careers attract you. Law, diplomacy, design, or counseling align with your need for balance and beauty.',
      'SCORPIO': 'Transformative careers call to you. Psychology, investigation, research, or healing professions suit your depth.',
      'SAGITTARIUS': 'Expansive careers excite you. Education, travel, publishing, or international business match your adventurous spirit.',
      'CAPRICORN': 'Traditional careers with growth potential appeal to you. Business, government, or established industries suit your ambition.',
      'AQUARIUS': 'Innovative careers attract you. Technology, humanitarian work, or scientific research align with your progressive nature.',
      'PISCES': 'Creative and healing careers call to you. Arts, music, therapy, or spiritual work match your compassionate soul.',
    };
    return career[zodiac] ?? 'Your career path offers unique opportunities for success and fulfillment.';
  }

  String _getFinancialHoroscope(String zodiac) {
    final finance = {
      'ARIES': 'You tend to spend impulsively but earn through bold ventures. Focus on emergency funds and avoid get-rich-quick schemes.',
      'TAURUS': 'You have natural financial wisdom and prefer secure investments. Real estate and stable assets appeal to you.',
      'GEMINI': 'Your finances may fluctuate with your varied interests. Diversify investments and avoid spreading money too thin.',
      'CANCER': 'You\'re naturally cautious with money and save for security. Property and family-focused investments suit you well.',
      'LEO': 'You enjoy spending on luxury and entertainment. Balance generous giving with smart saving for long-term security.',
      'VIRGO': 'You\'re excellent at budgeting and finding deals. Your careful approach to money leads to steady financial growth.',
      'LIBRA': 'You may overspend on beauty and social activities. Partner with someone financially savvy to balance your spending.',
      'SCORPIO': 'You\'re strategic with money and can sense good investments. Joint finances and transformative investments appeal to you.',
      'SAGITTARIUS': 'You prefer spending on experiences over things. Budget for travel and education while building long-term wealth.',
      'CAPRICORN': 'You\'re naturally good with money and long-term planning. Traditional investments and steady growth suit your style.',
      'AQUARIUS': 'You may have unconventional approaches to money. Technology investments and humanitarian causes attract you.',
      'PISCES': 'You may be generous to a fault with money. Set clear boundaries and automate savings to build financial security.',
    };
    return finance[zodiac] ?? 'Your financial journey offers opportunities for growth and stability.';
  }

  String _getHealthHoroscope(String zodiac) {
    final health = {
      'ARIES': 'You have high energy but may be prone to headaches and stress. Regular exercise and managing anger are important.',
      'TAURUS': 'You generally have good stamina but watch your throat and neck. Maintain a balanced diet and avoid overindulgence.',
      'GEMINI': 'You may experience nervous tension and respiratory issues. Deep breathing exercises and mental relaxation help.',
      'CANCER': 'Your emotions affect your digestive system. Stress management and comfort foods in moderation are key.',
      'LEO': 'Your heart and back need attention. Regular cardiovascular exercise and good posture support your vitality.',
      'VIRGO': 'You may worry about health and have digestive sensitivities. A clean diet and stress reduction are beneficial.',
      'LIBRA': 'Your kidneys and lower back need care. Balance in diet and exercise, plus adequate hydration, support wellness.',
      'SCORPIO': 'You have strong regenerative powers but may hold stress in reproductive areas. Emotional release is healing.',
      'SAGITTARIUS': 'Your hips and thighs need attention from active lifestyle. Stretching and avoiding overexertion prevent injury.',
      'CAPRICORN': 'Your bones and joints may need extra care. Weight-bearing exercise and calcium support skeletal health.',
      'AQUARIUS': 'Your circulatory system and ankles need attention. Regular movement and avoiding prolonged sitting help.',
      'PISCES': 'Your feet and immune system need care. Good shoes, rest, and avoiding negative environments support health.',
    };
    return health[zodiac] ?? 'Your health journey offers opportunities for vitality and well-being.';
  }

  List<String> _getStrengths(String zodiac) {
    final strengths = {
      'ARIES': ['Natural leadership', 'Courage and bravery', 'High energy and enthusiasm', 'Pioneering spirit'],
      'TAURUS': ['Reliability and loyalty', 'Practical wisdom', 'Patience and persistence', 'Appreciation for beauty'],
      'GEMINI': ['Excellent communication', 'Adaptability', 'Quick learning ability', 'Social charm'],
      'CANCER': ['Deep empathy', 'Protective instincts', 'Intuitive wisdom', 'Nurturing nature'],
      'LEO': ['Natural charisma', 'Generous heart', 'Creative expression', 'Inspiring leadership'],
      'VIRGO': ['Attention to detail', 'Analytical mind', 'Helpful nature', 'Organizational skills'],
      'LIBRA': ['Diplomatic skills', 'Sense of fairness', 'Aesthetic appreciation', 'Harmonious nature'],
      'SCORPIO': ['Emotional depth', 'Transformative power', 'Intuitive insights', 'Unwavering loyalty'],
      'SAGITTARIUS': ['Optimistic outlook', 'Adventurous spirit', 'Philosophical wisdom', 'Freedom-loving'],
      'CAPRICORN': ['Strong ambition', 'Disciplined approach', 'Practical wisdom', 'Leadership abilities'],
      'AQUARIUS': ['Innovative thinking', 'Humanitarian spirit', 'Independent nature', 'Progressive ideals'],
      'PISCES': ['Deep compassion', 'Artistic sensitivity', 'Spiritual connection', 'Intuitive wisdom'],
    };
    return strengths[zodiac] ?? ['Unique talents', 'Special gifts', 'Natural abilities'];
  }

  List<String> _getGrowthAreas(String zodiac) {
    final growth = {
      'ARIES': ['Patience and consideration', 'Managing impulsiveness', 'Listening to others', 'Following through on projects'],
      'TAURUS': ['Embracing change', 'Avoiding stubbornness', 'Being more flexible', 'Taking calculated risks'],
      'GEMINI': ['Focusing on depth', 'Completing projects', 'Managing restlessness', 'Consistent communication'],
      'CANCER': ['Managing moodiness', 'Setting boundaries', 'Avoiding over-protection', 'Trusting others'],
      'LEO': ['Sharing the spotlight', 'Managing ego', 'Accepting criticism', 'Being more humble'],
      'VIRGO': ['Accepting imperfection', 'Reducing criticism', 'Taking breaks', 'Trusting intuition'],
      'LIBRA': ['Making decisions', 'Avoiding people-pleasing', 'Addressing conflict', 'Being more assertive'],
      'SCORPIO': ['Managing intensity', 'Forgiving others', 'Trusting openly', 'Letting go of control'],
      'SAGITTARIUS': ['Commitment and focus', 'Considering others\' feelings', 'Planning ahead', 'Being more tactful'],
      'CAPRICORN': ['Showing emotions', 'Work-life balance', 'Being spontaneous', 'Accepting help'],
      'AQUARIUS': ['Emotional connection', 'Following through', 'Being more practical', 'Accepting traditions'],
      'PISCES': ['Setting boundaries', 'Being more practical', 'Making decisions', 'Avoiding escapism'],
    };
    return growth[zodiac] ?? ['Personal development', 'Growth opportunities', 'Areas for improvement'];
  }
}

class TarotPage extends StatelessWidget {
  const TarotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with top padding to account for fixed header
          Padding(
            padding: const EdgeInsets.only(top: 89), // Header height
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D1B69),
                    Color(0xFF11001C),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarot Card Reading',
                          style: GoogleFonts.cinzel(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Unveil the mysteries of your future through ancient tarot wisdom combined with AI insights. Draw cards and receive personalized interpretations.',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildCardDrawSection(),
                        const SizedBox(height: 40),
                        _buildReadingTypes(),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildCardDrawSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6953B9).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Draw Your Cards',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTarotCard('Card Back', true),
              _buildTarotCard('Card Back', true),
              _buildTarotCard('Card Back', true),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6953B9),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Shuffle & Draw Cards',
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

  Widget _buildTarotCard(String cardName, bool isBack) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        color: isBack ? const Color(0xFF6953B9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: isBack
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  '✨',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            )
          : Center(
              child: Text(
                cardName,
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Widget _buildReadingTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Types',
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.3,
          children: [
            _buildReadingCard('Past, Present, Future', '🔮', 'Three-card spread revealing your timeline'),
            _buildReadingCard('Love Reading', '💖', 'Insights into your romantic relationships'),
            _buildReadingCard('Career Guidance', '🎯', 'Professional path and opportunities'),
            _buildReadingCard('Celtic Cross', '✨', 'Comprehensive 10-card detailed reading'),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingCard(String title, String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6953B9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
