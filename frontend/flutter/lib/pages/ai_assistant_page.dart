import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../main.dart';
import '../models/user_data.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickQuestions = [
    "What does my zodiac sign say about my love life?",
    "How will the current planetary transits affect me?",
    "What career path suits my astrological profile?",
    "When is the best time for me to make important decisions?",
    "How can I improve my relationships based on astrology?",
    "What should I focus on this month?",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessage();
    });
  }

  void _addWelcomeMessage() {
    final appState = context.read<AppState>();
    final userData = appState.userData;
    final greeting = userData?.name != null 
        ? "Hello ${userData!.name}! 👋" 
        : "Hello there! 👋";
    
    appState.addChatMessage(ChatMessage(
      content: "$greeting I'm your AI Astrologer Assistant. I'm here to provide personalized cosmic guidance based on your astrological profile. What would you like to know about your stars today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
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
                    Color(0xFF2D1B69),
                    Color(0xFF11001C),
                    Color(0xFF0F0F23),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1152),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Expanded(child: _buildChatArea()),
                          _buildInputArea(),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9398DF), Color(0xFF6953B9)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Astrologer Assistant',
                          style: GoogleFonts.cinzel(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Powered by advanced AI and traditional astrology',
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: appState.isAiTyping 
                              ? const Color(0xFF4ECDC4) 
                              : const Color(0xFF2ECC71),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appState.isAiTyping ? 'Typing...' : 'Online',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            if (appState.chatHistory.isEmpty)
              Expanded(child: _buildQuickStartArea())
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.chatHistory.length,
                  itemBuilder: (context, index) {
                    final message = appState.chatHistory[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
            if (appState.isAiTyping) _buildTypingIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildQuickStartArea() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '✨ Quick Start Questions ✨',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
                      Text(
              'Tap any question below to get started, or type your own question',
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _quickQuestions.map((question) => 
              _buildQuickQuestionChip(question)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionChip(String question) {
    return GestureDetector(
      onTap: () => _sendMessage(question),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          question,
          style: GoogleFonts.raleway(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9398DF), Color(0xFF6953B9)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFF6953B9) 
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUser ? 16 : 4),
                  topRight: Radius.circular(message.isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: message.isUser 
                    ? null 
                    : Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Consumer<AppState>(
              builder: (context, appState, child) {
                final userData = appState.userData;
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      userData?.name?.isNotEmpty == true 
                          ? userData!.name![0].toUpperCase() 
                          : '👤',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9398DF), Color(0xFF6953B9)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (0.5 - (value - index * 0.2).abs().clamp(0.0, 0.5))),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about astrology...',
                  hintStyle: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _sendMessage(text.trim());
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<AppState>(
            builder: (context, appState, child) {
              return GestureDetector(
                onTap: appState.isAiTyping ? null : () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    _sendMessage(text);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: appState.isAiTyping 
                        ? null 
                        : const LinearGradient(
                            colors: [Color(0xFF9398DF), Color(0xFF6953B9)],
                          ),
                    color: appState.isAiTyping 
                        ? Colors.white.withOpacity(0.2) 
                        : null,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.send,
                    color: Colors.white.withOpacity(appState.isAiTyping ? 0.5 : 1.0),
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    final appState = context.read<AppState>();
    
    // Add user message
    appState.addChatMessage(ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate AI response (replace with actual API call)
    _simulateAiResponse(message, appState);
  }

  void _simulateAiResponse(String userMessage, AppState appState) {
    appState.setAiTyping(true);

    // Simulate thinking time
    Future.delayed(const Duration(seconds: 2), () {
      final response = _generateAiResponse(userMessage, appState.userData);
      
      appState.addChatMessage(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
      appState.setAiTyping(false);

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  String _generateAiResponse(String userMessage, UserData? userData) {
    // This is a simplified response generator
    // In a real implementation, this would call your backend AI service
    
    final lowerMessage = userMessage.toLowerCase();
    final sign = userData?.zodiacSign ?? "your sign";
    
    if (lowerMessage.contains('love') || lowerMessage.contains('relationship')) {
      return "Based on $sign's astrological profile, you tend to approach love with unique characteristics. Your sign influences how you express affection and what you seek in partnerships. Would you like me to analyze your compatibility with a specific sign or provide more detailed relationship guidance?";
    } else if (lowerMessage.contains('career') || lowerMessage.contains('job')) {
      return "Your astrological profile suggests certain career paths that align with $sign's natural talents and inclinations. The current planetary transits may also be influencing your professional opportunities. What specific career question can I help you with?";
    } else if (lowerMessage.contains('money') || lowerMessage.contains('financial')) {
      return "From an astrological perspective, $sign has particular approaches to money and financial decisions. The current planetary positions may be affecting your financial energy. Would you like specific guidance on investments, spending, or financial planning?";
    } else if (lowerMessage.contains('health')) {
      return "Astrologically, $sign is associated with certain areas of physical and emotional health. The current cosmic energies may be influencing your well-being. Remember, astrology complements but doesn't replace medical advice. What health aspect would you like to explore?";
    } else {
      return "That's an interesting question! As your AI Astrologer Assistant, I can provide insights based on your astrological profile and current planetary influences. Could you tell me more specifically what aspect of astrology or your cosmic journey you'd like to explore?";
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
