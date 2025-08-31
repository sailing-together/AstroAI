import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:AstroAI/widgets/common/navigation_header.dart';
import 'package:AstroAI/services/api_service.dart';
import 'dart:convert';
import 'dart:math' as math;
export 'package:AstroAI/pages/natal_chart_page.dart';
import 'theme/app_theme.dart';

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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF3F8),
                    Color(0xFFF0F8FF),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
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
                        Text(
                          'Navigate your journey with celestial guidance and discover what the stars have in store for you today.',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
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
              color: Colors.black.withValues(alpha: 0.8),
              height: 1.4,
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
    return ContentPageWrapper(
      title: 'AstroAI',
      subtitle: 'Your Personal Cosmic Guide 🌌',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Vision', 'AstroAI combines traditional astrology with modern AI technology and immersive sound experiences to create a comprehensive personal cosmic guidance platform.'),
          _buildFeatureGrid(),
          _buildSection('AI Integration 🤖', 'Our AI Astrologer Assistant provides natural language interaction, personalized astrological guidance, and real-time question answering.'),
          _buildSection('Premium Features ✨', 'Experience our exclusive ASMR & Meditation Suite with 12 unique zodiac-themed sound experiences, emotion-based recommendations, and AI-powered personalization.'),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.raleway(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Core Features 🌟',
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                _buildFeatureCard('Compatibility Analysis', 'Relationship matching, friendship compatibility, and business partnership synergy.', Theme.of(context).palette.primary),
                _buildFeatureCard('Natal Chart Analysis', 'Personalized birth chart generation with detailed planet positions interpretation.', Theme.of(context).palette.secondary),
                _buildFeatureCard('Smart Notifications', 'Astrological event reminders and personalized cosmic advice.', Theme.of(context).palette.lightBlue),
                _buildFeatureCard('ASMR & Meditation', '12 unique zodiac-themed sound experiences with AI-powered personalization.', Theme.of(context).palette.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 8),
            blurRadius: 32,
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black.withValues(alpha: 0.7),
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
    return ContentPageWrapper(
      title: 'Get in Touch',
      subtitle: 'Connect with our cosmic guidance team for personalized support',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }

  Widget _buildContactCard(String title, String email, String description) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).palette.lightBlue.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 8),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).palette.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).palette.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Matching Page - Compatibility Analysis
class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    Color(0xFFFFF3F8),
                    Color(0xFFF0F8FF),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  padding: const EdgeInsets.all(32),
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
                        const SizedBox(height: 32),
                        
                        // Compatibility Types Instructions
                        _buildMatchingTypesInstruction(),
                        
                        const SizedBox(height: 32),
                        
                        // Tab Bar
                        Container(
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
                            children: [
                              TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: 'SIGN COMPATIBILITY'),
                                  Tab(text: 'CELEBRITY MATCH'),
                                ],
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.black.withOpacity(0.8),
                                labelStyle: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                unselectedLabelStyle: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                indicator: BoxDecoration(
                                  color: const Color(0xFF6953B9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                              ),
                              SizedBox(
                                height: 800,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    SingleChildScrollView(
                                      child: _buildCompatibilitySection(),
                                    ),
                                    SingleChildScrollView(
                                      child: _buildCelebritySection(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

  // Sign Compatibility Tab
  Widget _buildCompatibilitySection() {
    return _SignCompatibilityWidget();
  }

  // Celebrity Match Tab  
  Widget _buildCelebritySection() {
    return _CelebrityMatchWidget();
  }

  // Compact instruction version at the top
  Widget _buildMatchingTypesInstruction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9398DF).withOpacity(0.1),
            const Color(0xFF6953B9).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6953B9).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF6953B9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Compatibility Types We Analyze',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6953B9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactTypeChip('💕 Romantic Love', 'Find your soulmate through astrological compatibility'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTypeChip('🤝 Friendship', 'Discover lasting friendships with cosmic connections'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactTypeChip('💼 Business Partnership', 'Align with partners for professional success'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactTypeChip('👨‍👩‍👧‍👦 Family Harmony', 'Understand family dynamics and relationships'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactTypeChip(String text, String description) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6953B9).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6953B9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

}

// Sign Compatibility Widget
class _SignCompatibilityWidget extends StatefulWidget {
  @override
  State<_SignCompatibilityWidget> createState() => _SignCompatibilityWidgetState();
}

class _SignCompatibilityWidgetState extends State<_SignCompatibilityWidget> {
  String? _selectedSign1;
  String? _selectedSign2;
  String? _selectedRelationType;
  bool _isLoading = false;
  Map<String, dynamic>? _compatibilityResult;

  final List<String> _zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  final List<String> _relationshipTypes = [
    'lover', 'friend', 'business', 'family', 'all'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
                child: _buildInputCard('Your Sign', 'Select your zodiac sign', _selectedSign1, (value) {
                  setState(() => _selectedSign1 = value);
                }),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.favorite, color: Color(0xFF6953B9), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputCard('Partner\'s Sign', 'Select partner\'s sign', _selectedSign2, (value) {
                  setState(() => _selectedSign2 = value);
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRelationshipTypeCard(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: _selectedSign1 != null && _selectedSign2 != null && !_isLoading
                  ? _analyzeCompatibility
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6953B9),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Analyze Compatibility',
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
            _buildResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildInputCard(String title, String hint, String? selectedValue, Function(String?) onChanged) {
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
          DropdownButton<String>(
            value: selectedValue,
            hint: Text(
              hint,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            items: _zodiacSigns.map((sign) {
              return DropdownMenuItem(
                value: sign,
                child: Text(
                  sign,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipTypeCard() {
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
            'Relationship Type',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedRelationType,
            hint: Text(
              'Optional',
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            items: _relationshipTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type.toUpperCase(),
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRelationType = value;
                _compatibilityResult = null; // Clear previous results
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Compatibility Results',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (_compatibilityResult!['relationship_type'] != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6953B9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6953B9).withOpacity(0.3)),
                  ),
                  child: Text(
                    _compatibilityResult!['relationship_type'].toString(),
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6953B9),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (_compatibilityResult!['compatibility_score'] != null)
            Text(
              'Score: ${_compatibilityResult!['compatibility_score']}/10',
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6953B9),
              ),
            ),
          const SizedBox(height: 8),
          if (_compatibilityResult!['analysis'] != null)
            Text(
              _compatibilityResult!['analysis'].toString(),
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.8),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _analyzeCompatibility() async {
    setState(() => _isLoading = true);
    
    try {
      Map<String, dynamic>? result;
      
      // Always call the API first for the base compatibility analysis
      final apiService = ApiService();
      final apiResult = await apiService.getCompatibility(_selectedSign1!, _selectedSign2!);
      
      if (apiResult != null && apiResult['compatibility'] != null) {
        // Successfully got API response
        String compatibilityText = apiResult['compatibility'].toString();
        String score = _extractCompatibilityScore(compatibilityText);
        
        // If specific relationship type is selected, combine with API result
        if (_selectedRelationType != null && _selectedRelationType != 'other') {
          String relationshipSpecificInfo = _getRelationshipSpecificInfo(_selectedSign1!, _selectedSign2!, _selectedRelationType!);
          compatibilityText = '$relationshipSpecificInfo\n\n$compatibilityText';
        }
        
        result = {
          'analysis': compatibilityText,
          'compatibility_score': score,
          'relationship_type': _selectedRelationType?.toUpperCase()
        };
      } else {
        // API failed, use fallback with predefined information
        if (_selectedRelationType != null && _selectedRelationType != 'other') {
          result = _generateRelationshipTypeInfo(_selectedSign1!, _selectedSign2!, _selectedRelationType!);
        } else {
          // Use generic fallback
          result = {
            'analysis': _getGenericCompatibilityFallback(_selectedSign1!, _selectedSign2!),
            'compatibility_score': _getCompatibilityScore(_selectedSign1!, _selectedSign2!, 'general'),
            'relationship_type': null
          };
        }
      }
      
      setState(() {
        _compatibilityResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _compatibilityResult = {
          'analysis': 'Unable to analyze compatibility at this time. Please try again later.',
          'compatibility_score': 'N/A',
          'relationship_type': _selectedRelationType?.toUpperCase()
        };
      });
    }
  }

  Map<String, dynamic> _generateRelationshipTypeInfo(String sign1, String sign2, String relationType) {
    // Generate predefined compatibility information based on relationship type
    String analysis;
    String score;
    
    switch (relationType) {
      case 'lover':
        analysis = _getLoverCompatibility(sign1, sign2);
        score = _getCompatibilityScore(sign1, sign2, 'lover');
      case 'friend':
        analysis = _getFriendCompatibility(sign1, sign2);
        score = _getCompatibilityScore(sign1, sign2, 'friend');
      case 'business':
        analysis = _getBusinessCompatibility(sign1, sign2);
        score = _getCompatibilityScore(sign1, sign2, 'business');
      case 'family':
        analysis = _getFamilyCompatibility(sign1, sign2);
        score = _getCompatibilityScore(sign1, sign2, 'family');
      case 'all':
      default:
        analysis = _getAllTypesCompatibility(sign1, sign2);
        score = _getCompatibilityScore(sign1, sign2, 'all');
    }
    
    return {
      'analysis': analysis,
      'compatibility_score': score,
      'relationship_type': relationType.toUpperCase()
    };
  }

  String _getLoverCompatibility(String sign1, String sign2) {
    return '''💕 Romantic Compatibility: $sign1 & $sign2

As lovers, your connection brings together ${_getSignElement(sign1)} and ${_getSignElement(sign2)} energies. This creates a dynamic where passion meets understanding.

Key Relationship Dynamics:
• Emotional Connection: ${_getEmotionalConnection(sign1, sign2)}
• Communication Style: ${_getCommunicationStyle(sign1, sign2)}
• Intimacy Level: ${_getIntimacyLevel(sign1, sign2)}
• Long-term Potential: ${_getLongTermPotential(sign1, sign2)}

Remember that true love transcends astrological compatibility - nurture your connection with understanding, patience, and open communication.''';
  }

  String _getFriendCompatibility(String sign1, String sign2) {
    return '''🤝 Friendship Compatibility: $sign1 & $sign2

Your friendship combines the unique qualities of ${_getSignElement(sign1)} and ${_getSignElement(sign2)} signs, creating a bond built on mutual respect and shared experiences.

Friendship Highlights:
• Shared Activities: ${_getSharedActivities(sign1, sign2)}
• Support Style: ${_getSupportStyle(sign1, sign2)}
• Conflict Resolution: ${_getConflictResolution(sign1, sign2)}
• Growth Together: ${_getGrowthPotential(sign1, sign2)}

This friendship has the potential to be both meaningful and lasting when you embrace each other's differences and celebrate your unique strengths.''';
  }

  String _getBusinessCompatibility(String sign1, String sign2) {
    return '''💼 Business Partnership: $sign1 & $sign2

Your professional partnership brings together complementary skills and approaches. $sign1's ${_getBusinessStrength(sign1)} pairs well with $sign2's ${_getBusinessStrength(sign2)}.

Partnership Dynamics:
• Leadership Style: ${_getLeadershipDynamic(sign1, sign2)}
• Decision Making: ${_getDecisionMaking(sign1, sign2)}
• Risk Management: ${_getRiskManagement(sign1, sign2)}
• Innovation Approach: ${_getInnovationApproach(sign1, sign2)}

Success in business requires clear communication of goals, defined roles, and mutual respect for each other's working styles.''';
  }

  String _getFamilyCompatibility(String sign1, String sign2) {
    return '''👨‍👩‍👧‍👦 Family Harmony: $sign1 & $sign2

Your family relationship is enriched by the blend of ${_getSignElement(sign1)} and ${_getSignElement(sign2)} energies, creating a unique family dynamic.

Family Dynamics:
• Communication Pattern: ${_getFamilyCommunication(sign1, sign2)}
• Support System: ${_getFamilySupport(sign1, sign2)}
• Tradition & Values: ${_getFamilyValues(sign1, sign2)}
• Conflict Resolution: ${_getFamilyConflictResolution(sign1, sign2)}

Family bonds are strengthened through understanding, patience, and celebrating the unique gifts each person brings to the family unit.''';
  }

  String _getAllTypesCompatibility(String sign1, String sign2) {
    return '''🌟 Complete Compatibility Analysis: $sign1 & $sign2

Your cosmic connection spans across all relationship dimensions, blending ${_getSignElement(sign1)} and ${_getSignElement(sign2)} energies in a harmonious dance.

💕 ROMANTIC POTENTIAL
• Attraction Level: ${_getRomanticAttraction(sign1, sign2)}
• Emotional Connection: ${_getEmotionalConnection(sign1, sign2)}
• Long-term Compatibility: ${_getLongTermCompatibility(sign1, sign2)}

🤝 FRIENDSHIP DYNAMICS  
• Social Compatibility: ${_getSocialCompatibility(sign1, sign2)}
• Shared Interests: ${_getSharedInterests(sign1, sign2)}
• Loyalty Factor: ${_getLoyaltyFactor(sign1, sign2)}

💼 PROFESSIONAL SYNERGY
• Work Style Match: ${_getWorkStyleMatch(sign1, sign2)}
• Decision Making: ${_getDecisionMaking(sign1, sign2)}
• Innovation Potential: ${_getInnovationApproach(sign1, sign2)}

👨‍👩‍👧‍👦 FAMILY HARMONY
• Communication Style: ${_getFamilyCommunication(sign1, sign2)}
• Shared Values: ${_getFamilyValues(sign1, sign2)}
• Support System: ${_getFamilySupport(sign1, sign2)}

✨ OVERALL COSMIC INSIGHT
This multi-dimensional compatibility reveals the full spectrum of your potential connection. Whether as lovers, friends, colleagues, or family, your signs create a dynamic that encourages growth, understanding, and mutual support across all areas of life.''';
  }

  String _getCompatibilityScore(String sign1, String sign2, String relationType) {
    // Simple scoring logic based on element compatibility
    final elements1 = _getSignElement(sign1);
    final elements2 = _getSignElement(sign2);
    
    if (elements1 == elements2) return '9'; // Same element
    if (_areCompatibleElements(elements1, elements2)) return '8'; // Compatible elements
    return '7'; // Different but workable
  }

  String _getSignElement(String sign) {
    const elements = {
      'Aries': 'Fire', 'Leo': 'Fire', 'Sagittarius': 'Fire',
      'Taurus': 'Earth', 'Virgo': 'Earth', 'Capricorn': 'Earth',
      'Gemini': 'Air', 'Libra': 'Air', 'Aquarius': 'Air',
      'Cancer': 'Water', 'Scorpio': 'Water', 'Pisces': 'Water'
    };
    return elements[sign] ?? 'Unknown';
  }

  bool _areCompatibleElements(String element1, String element2) {
    const compatible = {
      'Fire': ['Air'],
      'Air': ['Fire'],
      'Earth': ['Water'],
      'Water': ['Earth']
    };
    return compatible[element1]?.contains(element2) ?? false;
  }

  // Extract compatibility score from API response text
  String _extractCompatibilityScore(String compatibilityText) {
    // Look for patterns like "6/10", "7 out of 10", "score of 8", etc.
    final scorePattern = RegExp(r'(\d+(?:\.\d+)?)[\/\s]*(?:out of |\/)?10|score.*?(\d+(?:\.\d+)?)|(\d+(?:\.\d+)?)\/10');
    final match = scorePattern.firstMatch(compatibilityText.toLowerCase());
    
    if (match != null) {
      String? score = match.group(1) ?? match.group(2) ?? match.group(3);
      if (score != null) {
        double scoreValue = double.tryParse(score) ?? 7.0;
        // Ensure score is between 1-10
        scoreValue = scoreValue.clamp(1.0, 10.0);
        return scoreValue.toStringAsFixed(1);
      }
    }
    
    // Default fallback score based on element compatibility
    return _getCompatibilityScore(_selectedSign1 ?? '', _selectedSign2 ?? '', 'general');
  }
  
  // Get relationship-specific intro for API response
  String _getRelationshipSpecificInfo(String sign1, String sign2, String relationType) {
    switch (relationType) {
      case 'lover':
        return '💕 ROMANTIC COMPATIBILITY: $sign1 & $sign2\nThis analysis focuses on your romantic potential together.';
      case 'friend':
        return '🤝 FRIENDSHIP COMPATIBILITY: $sign1 & $sign2\nThis analysis explores your friendship dynamics and shared interests.';
      case 'business':
        return '💼 BUSINESS PARTNERSHIP: $sign1 & $sign2\nThis analysis examines your professional collaboration potential.';
      case 'family':
        return '👨‍👩‍👧‍👦 FAMILY HARMONY: $sign1 & $sign2\nThis analysis looks at your family relationship dynamics.';
      case 'all':
        return '🌟 COMPLETE COMPATIBILITY ANALYSIS: $sign1 & $sign2\nThis comprehensive analysis covers all relationship dimensions - romantic, friendship, business, and family connections.';
      default:
        return '🌟 COMPLETE COMPATIBILITY ANALYSIS: $sign1 & $sign2\nThis comprehensive analysis covers all relationship dimensions - romantic, friendship, business, and family connections.';
    }
  }
  
  // Generic fallback when API fails and no relationship type is selected
  String _getGenericCompatibilityFallback(String sign1, String sign2) {
    final element1 = _getSignElement(sign1);
    final element2 = _getSignElement(sign2);
    
    String elementDescription = '';
    if (element1 == element2) {
      elementDescription = 'Both $sign1 and $sign2 are $element1 signs, sharing similar core energies and approaches to life.';
    } else if (_areCompatibleElements(element1, element2)) {
      elementDescription = '$sign1 ($element1) and $sign2 ($element2) represent complementary elemental energies.';
    } else {
      elementDescription = '$sign1 ($element1) and $sign2 ($element2) bring different elemental perspectives to their relationship.';
    }
    
    return '''$elementDescription

This pairing offers opportunities for mutual growth and understanding. While every relationship requires effort and communication, astrological compatibility can provide insights into natural strengths and potential challenges.

Key areas to focus on:
• Communication: Find common ground in your different communication styles
• Values: Respect each other's core values and motivations  
• Growth: Support each other's personal development and goals
• Balance: Appreciate both similarities and differences

Remember that successful relationships depend more on mutual respect, understanding, and commitment than purely on astrological compatibility.''';
  }

  // Helper methods for generating detailed compatibility text
  String _getEmotionalConnection(String sign1, String sign2) => 'Deep and intuitive understanding';
  String _getCommunicationStyle(String sign1, String sign2) => 'Open and honest dialogue';
  String _getIntimacyLevel(String sign1, String sign2) => 'Strong physical and emotional bond';
  String _getLongTermPotential(String sign1, String sign2) => 'Excellent with mutual growth';
  String _getSharedActivities(String sign1, String sign2) => 'Adventure and creative pursuits';
  String _getSupportStyle(String sign1, String sign2) => 'Encouraging and loyal';
  String _getConflictResolution(String sign1, String sign2) => 'Direct but respectful discussion';
  String _getGrowthPotential(String sign1, String sign2) => 'Inspiring each other to excel';
  String _getBusinessStrength(String sign) => 'strategic planning and execution';
  String _getLeadershipDynamic(String sign1, String sign2) => 'Collaborative leadership approach';
  String _getDecisionMaking(String sign1, String sign2) => 'Balanced analytical and intuitive choices';
  String _getRiskManagement(String sign1, String sign2) => 'Calculated risks with careful planning';
  String _getInnovationApproach(String sign1, String sign2) => 'Creative solutions with practical implementation';
  String _getFamilyCommunication(String sign1, String sign2) => 'Open and supportive dialogue';
  String _getFamilySupport(String sign1, String sign2) => 'Unconditional love and encouragement';
  String _getFamilyValues(String sign1, String sign2) => 'Shared core values with room for individual expression';
  String _getFamilyConflictResolution(String sign1, String sign2) => 'Patient discussion with focus on understanding';
  
  // Additional methods for ALL types compatibility
  String _getRomanticAttraction(String sign1, String sign2) => 'Strong magnetic pull with deep understanding';
  String _getLongTermCompatibility(String sign1, String sign2) => 'Promising potential for lasting partnership';
  String _getSocialCompatibility(String sign1, String sign2) => 'Natural ease in social settings together';
  String _getSharedInterests(String sign1, String sign2) => 'Common passions and complementary hobbies';
  String _getLoyaltyFactor(String sign1, String sign2) => 'High trust and mutual reliability';
  String _getWorkStyleMatch(String sign1, String sign2) => 'Complementary approaches to tasks and goals';
}

// Celebrity Match Widget
class _CelebrityMatchWidget extends StatefulWidget {
  @override
  State<_CelebrityMatchWidget> createState() => _CelebrityMatchWidgetState();
}

class _CelebrityMatchWidgetState extends State<_CelebrityMatchWidget> {
  DateTime? _selectedDate;
  String? _zodiacSign;
  String? _celebrityName;
  bool _isLoading = false;
  List<Map<String, String>> _celebrityResults = [];
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _celebrityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Celebrity Match',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          // Birth Date and Celebrity Name in one line
          Row(
            children: [
              // Birth Date Input (Left side)
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1995, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
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
                          'Your Birth Date',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDate != null 
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select your birth date',
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _selectedDate != null 
                                ? Colors.black 
                                : Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Celebrity Name Input (Right side)
              Expanded(
                child: Container(
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
                        'Celebrity Name (Optional)',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _celebrityController,
                        decoration: InputDecoration(
                          hintText: 'Enter celebrity name for specific match',
                          hintStyle: GoogleFonts.raleway(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _celebrityName = value.isNotEmpty ? value : null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: _selectedDate != null && !_isLoading
                  ? _findCelebrityMatch
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6953B9),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
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
          if (_celebrityResults.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildCelebrityResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildCelebrityResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Celebrity Match Results',
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        // Display multiple celebrity cards
        ..._celebrityResults.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> celebrity = entry.value;
          
          return Container(
            margin: EdgeInsets.only(bottom: index < _celebrityResults.length - 1 ? 16 : 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
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
                // Celebrity name and score header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        celebrity['name'] ?? 'Celebrity Match ${index + 1}',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6953B9),
                        ),
                      ),
                    ),
                    if (celebrity['score'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6953B9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF6953B9).withOpacity(0.3)),
                        ),
                        child: Text(
                          celebrity['score']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6953B9),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Birth date if available
                if (celebrity['birth_date'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Born: ${celebrity['birth_date']}',
                    style: GoogleFonts.raleway(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Analysis text
                if (celebrity['analysis'] != null)
                  Text(
                    celebrity['analysis']!,
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _findCelebrityMatch() async {
    setState(() => _isLoading = true);
    
    try {
      final apiService = ApiService();
      final result = await apiService.getCelebrityCompatibility(
        _birthdateController.text,
        sign: _zodiacSign,
        celebrityName: _celebrityName,
      );
      
      if (result != null) {
        // Parse API response with multiple celebrities
        List<Map<String, String>> celebrities = _parseApiResponse(result);
        
        setState(() {
          _celebrityResults = celebrities;
          _isLoading = false;
        });
      } else {
        // API failed, use fallback data
        await _loadFallbackData();
      }
    } catch (e) {
      print('Celebrity Match API error: $e');
      // API failed, use fallback data
      await _loadFallbackData();
    }
  }

  // Parse API response format
  List<Map<String, String>> _parseApiResponse(Map<String, dynamic> apiResult) {
    List<Map<String, String>> celebrities = [];
    
    // API returns celebrities as "Celebrity 1", "Celebrity 2", "Celebrity 3"
    for (int i = 1; i <= 3; i++) {
      String key = 'Celebrity $i';
      if (apiResult.containsKey(key)) {
        String celebrityText = apiResult[key].toString();
        Map<String, String> parsedCelebrity = _parseCelebrityText(celebrityText);
        if (parsedCelebrity.isNotEmpty) {
          celebrities.add(parsedCelebrity);
        }
      }
    }
    
    // If API returns only one celebrity (when celebrity name is specified)
    if (celebrities.isEmpty && apiResult.isNotEmpty) {
      // Check for single celebrity response format
      apiResult.forEach((key, value) {
        if (key.toLowerCase().contains('celebrity') || value.toString().contains('born')) {
          Map<String, String> parsedCelebrity = _parseCelebrityText(value.toString());
          if (parsedCelebrity.isNotEmpty) {
            celebrities.add(parsedCelebrity);
          }
        }
      });
    }
    
    return celebrities;
  }

  // Parse individual celebrity text to extract name, birth date, and analysis
  Map<String, String> _parseCelebrityText(String celebrityText) {
    Map<String, String> celebrity = {};
    
    try {
      // Extract celebrity name (before the first parenthesis)
      RegExp namePattern = RegExp(r'^([^(]+)\(');
      Match? nameMatch = namePattern.firstMatch(celebrityText);
      if (nameMatch != null) {
        celebrity['name'] = nameMatch.group(1)!.trim();
      }
      
      // Extract birth date (inside parentheses)
      RegExp datePattern = RegExp(r'\(born ([^)]+)\)');
      Match? dateMatch = datePattern.firstMatch(celebrityText);
      if (dateMatch != null) {
        celebrity['birth_date'] = dateMatch.group(1)!.trim();
      }
      
      // Extract compatibility score
      RegExp scorePattern = RegExp(r'Compatibility Score: ([\d.]+\/10|\d+\.\d+\/10|\d+\/10)');
      Match? scoreMatch = scorePattern.firstMatch(celebrityText);
      if (scoreMatch != null) {
        celebrity['score'] = scoreMatch.group(1)!.trim();
      }
      
      // The analysis is the full text
      celebrity['analysis'] = celebrityText;
      
      // If we couldn't extract a name, try a different approach
      if (!celebrity.containsKey('name')) {
        List<String> parts = celebrityText.split(':');
        if (parts.isNotEmpty) {
          celebrity['name'] = parts[0].trim().replaceAll(RegExp(r'\([^)]*\)'), '').trim();
        }
      }
      
    } catch (e) {
      print('Error parsing celebrity text: $e');
    }
    
    return celebrity;
  }

  // Load fallback data from JSON file
  Future<void> _loadFallbackData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/celebrity_matches.json');
      Map<String, dynamic> allMatches = json.decode(jsonString);
      
      if (_zodiacSign != null && allMatches.containsKey(_zodiacSign)) {
        Map<String, dynamic> signMatches = allMatches[_zodiacSign!];
        List<Map<String, String>> celebrities = [];
        
        for (int i = 1; i <= 3; i++) {
          String key = 'Celebrity $i';
          if (signMatches.containsKey(key)) {
            String celebrityText = signMatches[key].toString();
            Map<String, String> parsedCelebrity = _parseCelebrityText(celebrityText);
            if (parsedCelebrity.isNotEmpty) {
              celebrities.add(parsedCelebrity);
            }
          }
        }
        
        setState(() {
          _celebrityResults = celebrities;
          _isLoading = false;
        });
      } else {
        // Ultimate fallback
        setState(() {
          _celebrityResults = [
            {
              'name': 'Celebrity Match',
              'analysis': 'Celebrity compatibility data is currently unavailable. Please try again later.',
              'score': 'N/A'
            }
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading fallback data: $e');
      setState(() {
        _celebrityResults = [
          {
            'name': 'Error',
            'analysis': 'Unable to load celebrity matches at this time.',
            'score': 'N/A'
          }
        ];
        _isLoading = false;
      });
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
        )),
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