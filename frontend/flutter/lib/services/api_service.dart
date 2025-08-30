import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Cache for fallback data
  Map<String, dynamic>? _dailyHoroscopeData;
  Map<String, dynamic>? _signCompatibilityData;
  Map<String, dynamic>? _celebrityMatchesData;
  Map<String, dynamic>? _cosmicEventsData;

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Load daily horoscope fallback data from JSON asset
  Future<Map<String, dynamic>> _loadDailyHoroscopeData() async {
    if (_dailyHoroscopeData != null) {
      return _dailyHoroscopeData!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString('assets/daily_horoscopes.json');
      _dailyHoroscopeData = jsonDecode(jsonString);
      return _dailyHoroscopeData!;
    } catch (e) {
      print('Failed to load daily horoscope data: $e');
      return {};
    }
  }

  // Load sign compatibility fallback data from JSON asset
  Future<Map<String, dynamic>> _loadSignCompatibilityData() async {
    if (_signCompatibilityData != null) {
      return _signCompatibilityData!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString('assets/sign_compatibility.json');
      _signCompatibilityData = jsonDecode(jsonString);
      return _signCompatibilityData!;
    } catch (e) {
      print('Failed to load sign compatibility data: $e');
      return {};
    }
  }

  // Load celebrity matches fallback data from JSON asset
  Future<Map<String, dynamic>> _loadCelebrityMatchesData() async {
    if (_celebrityMatchesData != null) {
      return _celebrityMatchesData!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString('assets/celebrity_matches.json');
      _celebrityMatchesData = jsonDecode(jsonString);
      return _celebrityMatchesData!;
    } catch (e) {
      print('Failed to load celebrity matches data: $e');
      return {};
    }
  }

  // Load cosmic events fallback data from JSON asset
  Future<Map<String, dynamic>> _loadCosmicEventsData() async {
    if (_cosmicEventsData != null) {
      return _cosmicEventsData!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString('assets/cosmic_events_2025.json');
      _cosmicEventsData = jsonDecode(jsonString);
      return _cosmicEventsData!;
    } catch (e) {
      print('Failed to load cosmic events data: $e');
      return {};
    }
  }

  // Get zodiac sign from birthdate
  String _getZodiacSignFromBirthdate(String birthdate) {
    try {
      final date = DateTime.parse(birthdate);
      final month = date.month;
      final day = date.day;
      
      // Zodiac sign date ranges
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
      if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Pisces';
      
      return 'Aries'; // Default fallback
    } catch (e) {
      print('Error parsing birthdate: $e');
      return 'Aries'; // Default fallback
    }
  }

  // Compatibility Analysis with fallback
  Future<Map<String, dynamic>?> getCompatibility(String sign1, String sign2) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compatibility'),
        headers: _headers,
        body: jsonEncode({
          'sign_1': sign1,
          'sign_2': sign2,
        }),
      );

      if (response.statusCode == 200) {
        final apiResult = jsonDecode(response.body);
        apiResult['source'] = 'gemini_live';
        return apiResult;
      } else {
        print('Compatibility API error: ${response.statusCode}');
        return await _getFallbackCompatibility(sign1, sign2);
      }
    } catch (e) {
      print('Compatibility API exception: $e');
      return await _getFallbackCompatibility(sign1, sign2);
    }
  }

  // Get fallback compatibility from JSON data
  Future<Map<String, dynamic>> _getFallbackCompatibility(String sign1, String sign2) async {
    try {
      final compatibilityData = await _loadSignCompatibilityData();
      final compatibilityKey = '${sign1}_$sign2';
      final reverseKey = '${sign2}_$sign1';
      
      Map<String, dynamic>? matchData = compatibilityData[compatibilityKey] ?? compatibilityData[reverseKey];
      
      if (matchData != null) {
        return {
          'source': 'compatibility_fallback',
          'sign_1': sign1,
          'sign_2': sign2,
          'compatibility_score': matchData['compatibility_score'],
          'summary': matchData['summary'],
          'romantic_compatibility': matchData['romantic_compatibility'],
          'friendship_potential': matchData['friendship_potential'],
          'business_partnership': matchData['business_partnership'],
          'family_compatibility': matchData['family_compatibility'],
          'general_compatibility': matchData['general_compatibility'],
        };
      } else {
        // Generic fallback
        return {
          'source': 'generic_fallback',
          'sign_1': sign1,
          'sign_2': sign2,
          'compatibility_score': 7.0,
          'summary': '🌟 **Cosmic Connection** - Every zodiac pairing has unique potential for growth and understanding when both partners embrace their differences and appreciate each other\'s strengths.',
          'romantic_compatibility': 'Love can flourish between any two signs when there\'s mutual respect, open communication, and willingness to grow together.',
          'friendship_potential': 'Strong friendships can develop through shared experiences and genuine care for each other\'s wellbeing and growth.',
          'business_partnership': 'Professional success comes from combining different strengths and maintaining clear communication about goals and responsibilities.',
          'family_compatibility': 'Family harmony develops through patience, understanding, and appreciation for each member\'s unique contributions.',
          'general_compatibility': 'Overall compatibility depends on individual growth, mutual respect, and commitment to understanding each other\'s perspectives.',
        };
      }
    } catch (e) {
      print('Error in fallback compatibility: $e');
      return {
        'source': 'error_fallback',
        'sign_1': sign1,
        'sign_2': sign2,
        'compatibility_score': 7.0,
        'summary': '🌟 The cosmic energies suggest this pairing has potential for meaningful connection and mutual growth.',
        'message': 'Compatibility data temporarily unavailable',
      };
    }
  }

  // Horoscope Generation with fallback to demo data
  Future<Map<String, dynamic>?> getHoroscope(String birthdate, {String? sign}) async {
    try {
      final body = {'birthdate': birthdate, 'sign': sign ?? ''};

      final response = await http.post(
        Uri.parse('$baseUrl/horoscope'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final apiResult = jsonDecode(response.body);
        // Add source indicator for successful API calls
        apiResult['source'] = 'gemini_live';
        return apiResult;
      } else {
        print('Horoscope API error: ${response.statusCode}');
        return await _getFallbackHoroscope(birthdate, sign);
      }
    } catch (e) {
      print('Horoscope API exception: $e');
      return await _getFallbackHoroscope(birthdate, sign);
    }
  }

  // Get fallback horoscope from daily JSON data
  Future<Map<String, dynamic>> _getFallbackHoroscope(String birthdate, String? sign) async {
    try {
      final dailyData = await _loadDailyHoroscopeData();
      final zodiacSign = sign ?? _getZodiacSignFromBirthdate(birthdate);
      
      if (dailyData.containsKey(zodiacSign)) {
        final horoscopeData = Map<String, dynamic>.from(dailyData[zodiacSign]);
        // Format the response to match API structure and add source indicator
        return {
          'source': 'daily_fallback',
          'zodiac_sign': zodiacSign,
          'birthdate': birthdate,
          'horoscope': horoscopeData['overall_horoscope'],
          'love_advice': horoscopeData['love_advice'],
          'career_advice': horoscopeData['career_advice'],
          'wealth_advice': horoscopeData['wealth_advice'],
          'daily_suggestion': horoscopeData['daily_suggestion'],
          'daily_encouragement_message': horoscopeData['daily_encouragement_message'],
        };
      } else {
        // Ultimate fallback
        return {
          'source': 'fallback',
          'zodiac_sign': zodiacSign,
          'birthdate': birthdate,
          'horoscope': '🌟 The cosmic energies are aligning in your favor today. Trust your intuition and embrace the opportunities that come your way.',
          'love_advice': '💝 Open your heart to new connections and deeper understanding in your relationships.',
          'career_advice': '📈 Your professional abilities are being recognized. Stay focused on your goals.',
          'wealth_advice': '💰 Financial opportunities are present. Make thoughtful decisions about your resources.',
          'daily_suggestion': '✨ Take time for self-reflection and appreciate the beauty around you.',
          'daily_encouragement_message': '🌈 You have the strength and wisdom to handle whatever comes your way today.',
        };
      }
    } catch (e) {
      print('Error in fallback horoscope: $e');
      // Ultimate fallback
      return {
        'source': 'error_fallback',
        'zodiac_sign': sign ?? 'Unknown',
        'birthdate': birthdate,
        'horoscope': '🌟 The stars are working in mysterious ways today. Stay positive and trust the journey.',
        'message': 'Fallback data temporarily unavailable',
      };
    }
  }

  // Natal Chart Analysis
  Future<Map<String, dynamic>?> getNatalChart(
    String birthDate,
    String birthTime,
    String birthLocation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/natal_chart'),
        headers: _headers,
        body: jsonEncode({
          'birth_date': birthDate,
          'birth_time': birthTime,
          'birth_location': birthLocation,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Natal Chart API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Natal Chart API exception: $e');
      return null;
    }
  }

  // Event Review
  Future<Map<String, dynamic>?> reviewEvent(
    String event,
    String eventDate,
    String birthdate,
    String location, {
    String? outcome,
  }) async {
    try {
      final body = {
        'event': event,
        'event_date': eventDate,
        'birthdate': birthdate,
        'location': location,
      };
      if (outcome != null) body['outcome'] = outcome;

      final response = await http.post(
        Uri.parse('$baseUrl/review_event'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Event Review API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Event Review API exception: $e');
      return null;
    }
  }

  // Celebrity Compatibility with fallback
  Future<Map<String, dynamic>?> getCelebrityCompatibility(
    String birthdate, {
    String? sign,
    String? celebrityName,
  }) async {
    try {
      final body = {'birthdate': birthdate};
      if (sign != null) body['sign'] = sign;
      if (celebrityName != null) body['celebrity_name'] = celebrityName;

      final response = await http.post(
        Uri.parse('$baseUrl/with_celebrity'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final apiResult = jsonDecode(response.body);
        apiResult['source'] = 'gemini_live';
        return apiResult;
      } else {
        print('Celebrity Compatibility API error: ${response.statusCode}');
        return await _getFallbackCelebrityCompatibility(birthdate, sign, celebrityName);
      }
    } catch (e) {
      print('Celebrity Compatibility API exception: $e');
      return await _getFallbackCelebrityCompatibility(birthdate, sign, celebrityName);
    }
  }

  // Get fallback celebrity compatibility from JSON data
  Future<Map<String, dynamic>> _getFallbackCelebrityCompatibility(
    String birthdate, 
    String? sign, 
    String? celebrityName,
  ) async {
    try {
      final celebrityData = await _loadCelebrityMatchesData();
      final zodiacSign = sign ?? _getZodiacSignFromBirthdate(birthdate);
      
      if (celebrityData.containsKey(zodiacSign)) {
        final signCelebrities = celebrityData[zodiacSign] as Map<String, dynamic>;
        
        // If specific celebrity requested, try to find match
        if (celebrityName != null) {
          for (var entry in signCelebrities.entries) {
            final celebrityMatch = entry.value as String;
            if (celebrityMatch.toLowerCase().contains(celebrityName.toLowerCase())) {
              return {
                'source': 'celebrity_fallback',
                'user_sign': zodiacSign,
                'user_birthdate': birthdate,
                'requested_celebrity': celebrityName,
                'match_found': true,
                'celebrity_analysis': celebrityMatch,
              };
            }
          }
        }
        
        // Return all celebrities for the sign if no specific match or no specific celebrity requested
        return {
          'source': 'celebrity_fallback',
          'user_sign': zodiacSign,
          'user_birthdate': birthdate,
          'celebrity_matches': signCelebrities,
        };
      } else {
        // Generic fallback
        return {
          'source': 'generic_fallback',
          'user_sign': zodiacSign,
          'user_birthdate': birthdate,
          'message': '🌟 **Celebrity Compatibility** - Your $zodiacSign energy would create interesting dynamics with many celebrities. Look for those who share your values of growth, creativity, and authentic self-expression.',
          'general_advice': 'Celebrity compatibility often depends more on personal growth and shared values than just zodiac signs. Focus on developing your own unique qualities that would attract like-minded successful people.',
        };
      }
    } catch (e) {
      print('Error in fallback celebrity compatibility: $e');
      return {
        'source': 'error_fallback',
        'user_sign': sign ?? 'Unknown',
        'user_birthdate': birthdate,
        'message': '🌟 The stars suggest you have magnetic qualities that would appeal to many accomplished individuals.',
        'error': 'Celebrity data temporarily unavailable',
      };
    }
  }

  // Save User Data
  Future<bool> saveUserData(String birthday, String location) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save-data'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'birthday=$birthday&location=$location',
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Save User Data API exception: $e');
      return false;
    }
  }

  // Get Today's Events with fallback
  Future<Map<String, dynamic>?> getTodaysEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events-today'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final apiResult = jsonDecode(response.body);
        apiResult['source'] = 'gemini_live';
        return apiResult;
      } else {
        print('Today\'s Events API error: ${response.statusCode}');
        return await _getFallbackTodaysEvents();
      }
    } catch (e) {
      print('Today\'s Events API exception: $e');
      return await _getFallbackTodaysEvents();
    }
  }

  // Get fallback today's events from JSON data
  Future<Map<String, dynamic>> _getFallbackTodaysEvents() async {
    try {
      final cosmicData = await _loadCosmicEventsData();
      final now = DateTime.now();
      final todayKey = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final yearKey = now.year.toString();
      
      if (cosmicData.containsKey(yearKey) && cosmicData[yearKey].containsKey(todayKey)) {
        final todayData = cosmicData[yearKey][todayKey];
        
        return {
          'source': 'cosmic_events_fallback',
          'date': todayData['date'],
          'lunar_events': todayData['lunar_events'] ?? [],
          'retrogrades': todayData['retrogrades'] ?? [],
          'ingresses': todayData['ingresses'] ?? [],
          'celestial_highlights': todayData['celestial_highlights'] ?? '',
          'overall_interpretation': todayData['overall_interpretation'] ?? '',
          'total_events': (todayData['lunar_events']?.length ?? 0) + 
                         (todayData['retrogrades']?.length ?? 0) + 
                         (todayData['ingresses']?.length ?? 0),
        };
      } else {
        // Generic fallback for dates not in our data
        return {
          'source': 'generic_fallback',
          'date': now.toIso8601String().split('T')[0],
          'lunar_events': [],
          'retrogrades': [],
          'ingresses': [],
          'celestial_highlights': '🌟 **Daily Cosmic Flow** - The universe continues its eternal dance, bringing opportunities for growth, love, and spiritual development.',
          'overall_interpretation': 'Every day offers cosmic gifts and lessons. Stay open to synchronicities and trust that the universe is supporting your highest path.',
          'total_events': 0,
        };
      }
    } catch (e) {
      print('Error in fallback today\'s events: $e');
      return {
        'source': 'error_fallback',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'lunar_events': [],
        'retrogrades': [],
        'ingresses': [],
        'celestial_highlights': '🌟 The cosmic energies are flowing in mysterious ways today.',
        'overall_interpretation': 'Trust in the universe\'s plan and stay open to the magic around you.',
        'total_events': 0,
        'message': 'Cosmic events data temporarily unavailable',
      };
    }
  }

  // Update Database (Admin)
  Future<bool> updateDatabase() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-database/'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update Database API exception: $e');
      return false;
    }
  }

  // Clear Past Events (Admin)
  Future<bool> clearPastEvents() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/clear-past-events/'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Clear Past Events API exception: $e');
      return false;
    }
  }
}
