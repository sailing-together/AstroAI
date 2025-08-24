import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Compatibility Analysis
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
        return jsonDecode(response.body);
      } else {
        print('Compatibility API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Compatibility API exception: $e');
      return null;
    }
  }

  // Horoscope Generation
  Future<Map<String, dynamic>?> getHoroscope(String birthdate, {String? sign}) async {
    try {
      final body = {'birthdate': birthdate, 'sign': sign ?? ''};

      final response = await http.post(
        Uri.parse('$baseUrl/horoscope'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Horoscope API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Horoscope API exception: $e');
      return null;
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

  // Celebrity Compatibility
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
        return jsonDecode(response.body);
      } else {
        print('Celebrity Compatibility API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Celebrity Compatibility API exception: $e');
      return null;
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

  // Get Today's Events
  Future<Map<String, dynamic>?> getTodaysEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events-today'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Today\'s Events API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Today\'s Events API exception: $e');
      return null;
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
