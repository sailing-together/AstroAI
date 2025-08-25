import 'package:AstroAI/widgets/common/navigation_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user_data.dart';
import '../main.dart';

class DailyInsightsPage extends StatefulWidget {
  const DailyInsightsPage({super.key});

  @override
  State<DailyInsightsPage> createState() => _DailyInsightsPageState();
}

class _DailyInsightsPageState extends State<DailyInsightsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadTodaysHoroscope();
      context.read<AppState>().loadTodaysEvents();
    });
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Consumer<AppState>(
                      builder: (context, appState, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(appState),
                            const SizedBox(height: 40),
                            if (appState.currentHoroscope != null)
                              _buildHoroscopeSection(appState.currentHoroscope!),
                            const SizedBox(height: 40),
                            _buildTodaysEvents(appState.todaysEvents),
                            const SizedBox(height: 40),
                            _buildMoodTracker(appState),
                            const SizedBox(height: 40),
                            _buildQuickActions(context),
                          ],
                        );
                      },
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

  Widget _buildHeader(AppState appState) {
    final userData = appState.userData;
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : 
                    now.hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9398DF), Color(0xFF6953B9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting${userData?.name != null ? ', ${userData!.name}' : ''}! ✨',
            style: GoogleFonts.cinzel(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Daily Cosmic Insights',
            style: GoogleFonts.raleway(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                _formatDate(now),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              if (userData?.zodiacSign != null) ...[
                const SizedBox(width: 24),
                Icon(Icons.star, color: Colors.white.withOpacity(0.8), size: 16),
                const SizedBox(width: 8),
                Text(
                  userData!.zodiacSign!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeSection(HoroscopeData horoscope) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Horoscope',
          style: GoogleFonts.cinzel(
            fontSize: 28,
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
            _buildHoroscopeCard('Love & Relationships', '💕', horoscope.love, const Color(0xFFFF6B9D)),
            _buildHoroscopeCard('Career Path', '💼', horoscope.career, const Color(0xFF4ECDC4)),
            _buildHoroscopeCard('Financial Outlook', '💰', horoscope.finance, const Color(0xFFFFE66D)),
            _buildHoroscopeCard('Health & Wellness', '🌿', horoscope.health, const Color(0xFF95E1D3)),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'General Guidance',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                horoscope.general,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              if (horoscope.luckyNumbers.isNotEmpty || horoscope.luckyColors.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (horoscope.luckyNumbers.isNotEmpty) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lucky Numbers',
                              style: GoogleFonts.cinzel(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              horoscope.luckyNumbers.join(', '),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (horoscope.luckyColors.isNotEmpty) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lucky Colors',
                              style: GoogleFonts.cinzel(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              horoscope.luckyColors.join(', '),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoroscopeCard(String title, String emoji, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysEvents(List<PlanetaryEvent> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Cosmic Events',
          style: GoogleFonts.cinzel(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.white.withOpacity(0.6), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'No major cosmic events today. A perfect day for reflection and planning.',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...events.map((event) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getEventColor(event.type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.type.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                if (event.impact.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: const Color(0xFFFFD700), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.impact,
                            style: GoogleFonts.raleway(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildMoodTracker(AppState appState) {
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
                'Mood Tracker',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showMoodDialog(context, appState),
                child: Text(
                  'Add Entry',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9398DF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Track your daily emotions and see how they correlate with planetary movements.',
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (appState.moodHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appState.moodHistory.take(7).length,
                itemBuilder: (context, index) {
                  final entry = appState.moodHistory[index];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getMoodColor(entry.mood),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _getMoodEmoji(entry.mood),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${entry.date.day}/${entry.date.month}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.cinzel(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildActionCard('Ask AI Assistant', '🤖', () => _showAiChat(context)),
            _buildActionCard('Compatibility Check', '💕', () => _navigateToCompatibility(context)),
            _buildActionCard('Natal Chart', '🌌', () => _navigateToNatalChart(context)),
            _buildActionCard('ASMR Sounds', '🎵', () => _navigateToASMR(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'lunar': return const Color(0xFF9398DF);
      case 'retrograde': return const Color(0xFFFF6B6B);
      case 'ingress': return const Color(0xFF4ECDC4);
      default: return const Color(0xFF6953B9);
    }
  }

  Color _getMoodColor(int mood) {
    if (mood <= 3) return const Color(0xFFFF6B6B);
    if (mood <= 6) return const Color(0xFFFFE66D);
    return const Color(0xFF4ECDC4);
  }

  String _getMoodEmoji(int mood) {
    if (mood <= 2) return '😢';
    if (mood <= 4) return '😕';
    if (mood <= 6) return '😐';
    if (mood <= 8) return '😊';
    return '😄';
  }

  void _showMoodDialog(BuildContext context, AppState appState) {
    // Implementation for mood dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How are you feeling today?'),
        content: Text('Mood tracking dialog implementation'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAiChat(BuildContext context) {
    // Navigate to AI chat
  }

  void _navigateToCompatibility(BuildContext context) {
    // Navigate to compatibility page
  }

  void _navigateToNatalChart(BuildContext context) {
    // Navigate to natal chart page
  }

  void _navigateToASMR(BuildContext context) {
    // Navigate to ASMR page
  }
}
