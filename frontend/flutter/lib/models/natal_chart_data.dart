import 'package:flutter/material.dart';

class NatalChartData {
  final double ascendantDegree;
  final List<House> houses;
  final List<Planet> planets;
  final List<Aspect> aspects;

  NatalChartData({
    required this.ascendantDegree,
    required this.houses,
    required this.planets,
    required this.aspects,
  });

  factory NatalChartData.fromJson(Map<String, dynamic> json) {
    return NatalChartData(
      ascendantDegree: json['ascendant_degree']?.toDouble() ?? 0.0,
      houses: (json['houses'] as List<dynamic>?)
              ?.map((e) => House.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      planets: (json['planets'] as List<dynamic>?)
              ?.map((e) => Planet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aspects: (json['aspects'] as List<dynamic>?)
              ?.map((e) => Aspect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'ascendant_degree': ascendantDegree,
        'houses': houses.map((e) => e.toJson()).toList(),
        'planets': planets.map((e) => e.toJson()).toList(),
        'aspects': aspects.map((e) => e.toJson()).toList(),
      };
}

class House {
  final int houseNumber;
  final double startDegree;

  House({
    required this.houseNumber,
    required this.startDegree,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      houseNumber: json['house_number'] as int? ?? 0,
      startDegree: json['start_degree']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'house_number': houseNumber,
        'start_degree': startDegree,
      };
}

class Planet {
  final String name;
  final String symbol;
  final double degree;
  final String zodiacSign;
  final int houseNumber;
  final String houseSign;
  final double houseDegree;

  Planet({
    required this.name,
    required this.symbol,
    required this.degree,
    required this.zodiacSign,
    required this.houseNumber,
    required this.houseSign,
    required this.houseDegree,
  });

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      degree: json['degree']?.toDouble() ?? 0.0,
      zodiacSign: json['zodiac_sign'] as String? ?? '',
      houseNumber: json['house_number'] as int? ?? 0,
      houseSign: json['house_sign'] as String? ?? '',
      houseDegree: json['house_degree']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'degree': degree,
        'zodiac_sign': zodiacSign,
        'house_number': houseNumber,
        'house_sign': houseSign,
        'house_degree': houseDegree,
      };
}

class Aspect {
  final String planet1;
  final String planet2;
  final double angle;
  final int aspectType;

  Aspect({
    required this.planet1,
    required this.planet2,
    required this.angle,
    required this.aspectType,
  });

  factory Aspect.fromJson(Map<String, dynamic> json) {
    return Aspect(
      planet1: json['planet1'] as String? ?? '',
      planet2: json['planet2'] as String? ?? '',
      angle: json['angle']?.toDouble() ?? 0.0,
      aspectType: json['aspect_type'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'planet1': planet1,
        'planet2': planet2,
        'angle': angle,
        'aspect_type': aspectType,
      };
}