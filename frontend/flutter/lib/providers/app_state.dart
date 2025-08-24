import 'package:flutter/foundation.dart';
import '../models/user_data.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // User data
  UserData? _userData;
  UserData? get userData => _userData;

  // Current horoscope
  HoroscopeData? _currentHoroscope;
  HoroscopeData? get currentHoroscope => _currentHoroscope;

  // Today's events
  List<PlanetaryEvent> _todaysEvents = [];
  List<PlanetaryEvent> get todaysEvents => _todaysEvents;

  // Mood tracking
  List<MoodEntry> _moodHistory = [];
  List<MoodEntry> get moodHistory => _moodHistory;

  // Loading states
  bool _isLoadingHoroscope = false;
  bool get isLoadingHoroscope => _isLoadingHoroscope;

  bool _isLoadingEvents = false;
  bool get isLoadingEvents => _isLoadingEvents;

  // Premium status
  bool _isPremiumUser = false;
  bool get isPremiumUser => _isPremiumUser;

  // AI Assistant state
  List<ChatMessage> _chatHistory = [];
  List<ChatMessage> get chatHistory => _chatHistory;

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;

  // Update user data
  void updateUserData(UserData userData) {
    _userData = userData;
    notifyListeners();
    
    // Save to backend
    if (userData.birthdate != null && userData.location != null) {
      _apiService.saveUserData(userData.birthdate!, userData.location!);
    }
  }

  // Load today's horoscope
  Future<void> loadTodaysHoroscope() async {
    if (_userData?.birthdate == null) return;

    _isLoadingHoroscope = true;
    notifyListeners();

    try {
      final response = await _apiService.getHoroscope(
        _userData!.birthdate!,
        sign: _userData!.zodiacSign,
      );

      if (response != null) {
        _currentHoroscope = HoroscopeData.fromJson(response);
      }
    } catch (e) {
      print('Error loading horoscope: $e');
    }

    _isLoadingHoroscope = false;
    notifyListeners();
  }

  // Load today's planetary events
  Future<void> loadTodaysEvents() async {
    _isLoadingEvents = true;
    notifyListeners();

    try {
      final response = await _apiService.getTodaysEvents();
      // Backend shape: { date, lunar_events: [...], retrogrades: [...], ingresses: [...] }
      if (response != null) {
        final List<PlanetaryEvent> aggregated = [];

        void addEvents(List<dynamic>? raw, String type, Map<String, String> mapping) {
          if (raw == null) return;
          for (final item in raw) {
            final map = item as Map<String, dynamic>;
            final title = mapping['title'] != null ? (map[mapping['title']]?.toString() ?? '') : '';
            final desc = mapping['description'] != null ? (map[mapping['description']]?.toString() ?? '') : '';
            final dateStr = mapping['date'] != null ? (map[mapping['date']]?.toString() ?? DateTime.now().toIso8601String()) : DateTime.now().toIso8601String();
            aggregated.add(PlanetaryEvent(
              type: type,
              title: title.isNotEmpty ? title : '$type event',
              description: desc,
              date: DateTime.tryParse(dateStr) ?? DateTime.now(),
              impact: '',
            ));
          }
        }

        addEvents(response['lunar_events'] as List<dynamic>?, 'lunar', {
          'title': 'event',
          'description': 'event',
          'date': 'start',
        });
        addEvents(response['retrogrades'] as List<dynamic>?, 'retrograde', {
          'title': 'planet',
          'description': 'planet',
          'date': 'start',
        });
        addEvents(response['ingresses'] as List<dynamic>?, 'ingress', {
          'title': 'planet',
          'description': 'sign',
          'date': 'time',
        });

        _todaysEvents = aggregated;
      }
    } catch (e) {
      print('Error loading events: $e');
    }

    _isLoadingEvents = false;
    notifyListeners();
  }

  // Add mood entry
  void addMoodEntry(MoodEntry entry) {
    _moodHistory.add(entry);
    _moodHistory.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Get compatibility analysis
  Future<CompatibilityData?> getCompatibility(String sign1, String sign2) async {
    try {
      final response = await _apiService.getCompatibility(sign1, sign2);
      if (response != null) {
        // Backend returns { compatibility: "..." }. Wrap to expected model fields.
        final String text = (response['compatibility'] ?? '').toString();
        return CompatibilityData(
          sign1: sign1,
          sign2: sign2,
          compatibilityScore: 0,
          analysis: text,
          strengths: '',
          challenges: '',
          advice: '',
        );
      }
    } catch (e) {
      print('Error getting compatibility: $e');
    }
    return null;
  }

  // Get natal chart
  Future<Map<String, dynamic>?> getNatalChart(
    String birthDate,
    String birthTime,
    String birthLocation,
  ) async {
    try {
      return await _apiService.getNatalChart(birthDate, birthTime, birthLocation);
    } catch (e) {
      print('Error getting natal chart: $e');
      return null;
    }
  }

  // AI Chat functionality
  void addChatMessage(ChatMessage message) {
    _chatHistory.add(message);
    notifyListeners();
  }

  void setAiTyping(bool typing) {
    _isAiTyping = typing;
    notifyListeners();
  }

  // Ask AI using backend horoscope endpoint as a demo
  Future<void> askAi(String userMessage) async {
    setAiTyping(true);
    try {
      if (_userData?.birthdate == null) {
        addChatMessage(ChatMessage(
          content: 'Please enter your birth date and location to get personalized guidance.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        return;
      }

      final response = await _apiService.getHoroscope(
        _userData!.birthdate!,
        sign: _userData!.zodiacSign,
      );

      if (response != null) {
        final data = HoroscopeData.fromJson(response);
        final buffer = StringBuffer();
        if (data.general.isNotEmpty) {
          buffer.writeln('General Guidance:\n${data.general}\n');
        }
        if (data.love.isNotEmpty) {
          buffer.writeln('Love & Relationships:\n${data.love}\n');
        }
        if (data.career.isNotEmpty) {
          buffer.writeln('Career:\n${data.career}\n');
        }
        if (data.finance.isNotEmpty) {
          buffer.writeln('Finance:\n${data.finance}\n');
        }
        if (data.health.isNotEmpty) {
          buffer.writeln('Health & Wellness:\n${data.health}\n');
        }

        final content = buffer.isEmpty
            ? 'I could not generate guidance right now. Please try again.'
            : buffer.toString().trim();

        addChatMessage(ChatMessage(
          content: content,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        addChatMessage(ChatMessage(
          content: 'Request failed. Please try again later.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      addChatMessage(ChatMessage(
        content: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      setAiTyping(false);
    }
  }

  // Premium features
  void setPremiumStatus(bool isPremium) {
    _isPremiumUser = isPremium;
    notifyListeners();
  }

  // Initialize app state
  Future<void> initialize() async {
    await loadTodaysEvents();
    if (_userData?.birthdate != null) {
      await loadTodaysHoroscope();
    }
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
