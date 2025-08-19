class UserData {
  final String? birthdate;
  final String? location;
  final String? zodiacSign;
  final String? name;

  const UserData({
    this.birthdate,
    this.location,
    this.zodiacSign,
    this.name,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      birthdate: json['birthdate'],
      location: json['location'],
      zodiacSign: json['zodiac_sign'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birthdate': birthdate,
      'location': location,
      'zodiac_sign': zodiacSign,
      'name': name,
    };
  }

  UserData copyWith({
    String? birthdate,
    String? location,
    String? zodiacSign,
    String? name,
  }) {
    return UserData(
      birthdate: birthdate ?? this.birthdate,
      location: location ?? this.location,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      name: name ?? this.name,
    );
  }
}

class HoroscopeData {
  final String sign;
  final String date;
  final String love;
  final String career;
  final String finance;
  final String health;
  final String general;
  final List<String> luckyNumbers;
  final List<String> luckyColors;

  const HoroscopeData({
    required this.sign,
    required this.date,
    required this.love,
    required this.career,
    required this.finance,
    required this.health,
    required this.general,
    required this.luckyNumbers,
    required this.luckyColors,
  });

  factory HoroscopeData.fromJson(Map<String, dynamic> json) {
    return HoroscopeData(
      sign: json['sign'] ?? '',
      date: json['date'] ?? '',
      love: json['love'] ?? '',
      career: json['career'] ?? '',
      finance: json['finance'] ?? '',
      health: json['health'] ?? '',
      general: json['general'] ?? '',
      luckyNumbers: List<String>.from(json['lucky_numbers'] ?? []),
      luckyColors: List<String>.from(json['lucky_colors'] ?? []),
    );
  }
}

class CompatibilityData {
  final String sign1;
  final String sign2;
  final int compatibilityScore;
  final String analysis;
  final String strengths;
  final String challenges;
  final String advice;

  const CompatibilityData({
    required this.sign1,
    required this.sign2,
    required this.compatibilityScore,
    required this.analysis,
    required this.strengths,
    required this.challenges,
    required this.advice,
  });

  factory CompatibilityData.fromJson(Map<String, dynamic> json) {
    return CompatibilityData(
      sign1: json['sign_1'] ?? '',
      sign2: json['sign_2'] ?? '',
      compatibilityScore: json['compatibility_score'] ?? 0,
      analysis: json['analysis'] ?? '',
      strengths: json['strengths'] ?? '',
      challenges: json['challenges'] ?? '',
      advice: json['advice'] ?? '',
    );
  }
}

class PlanetaryEvent {
  final String type;
  final String title;
  final String description;
  final DateTime date;
  final String impact;

  const PlanetaryEvent({
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.impact,
  });

  factory PlanetaryEvent.fromJson(Map<String, dynamic> json) {
    return PlanetaryEvent(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      impact: json['impact'] ?? '',
    );
  }
}

class MoodEntry {
  final DateTime date;
  final int mood; // 1-10 scale
  final List<String> emotions;
  final String? notes;
  final Map<String, dynamic>? planetaryCorrelation;

  const MoodEntry({
    required this.date,
    required this.mood,
    required this.emotions,
    this.notes,
    this.planetaryCorrelation,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'] ?? 5,
      emotions: List<String>.from(json['emotions'] ?? []),
      notes: json['notes'],
      planetaryCorrelation: json['planetary_correlation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'emotions': emotions,
      'notes': notes,
      'planetary_correlation': planetaryCorrelation,
    };
  }
}
