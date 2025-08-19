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
      
      if (response != null && response['events'] != null) {
        _todaysEvents = (response['events'] as List)
            .map((event) => PlanetaryEvent.fromJson(event))
            .toList();
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
        return CompatibilityData.fromJson(response);
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
