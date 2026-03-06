import 'dart:convert';
import '../data/countries.dart';
import '../services/language_service.dart';

/// A single stop/visit between the departure and return points of a trip.
class TripStop {
  final String city;
  final String? countryCode;

  const TripStop({required this.city, this.countryCode});

  String? get countryDisplay {
    if (countryCode == null || countryCode!.isEmpty) return null;
    final resolved = countryByCode(countryCode);
    if (resolved != null) {
      final lang = LanguageService.instance.locale.languageCode;
      return resolved.localizedDisplay(lang);
    }
    return countryCode;
  }

  /// e.g. "Amsterdam, 🇳🇱 Netherlands"
  String get label {
    final cd = countryDisplay;
    return cd != null ? '$city, $cd' : city;
  }

  Map<String, dynamic> toJson() => {'city': city, 'countryCode': countryCode};

  factory TripStop.fromJson(Map<String, dynamic> j) =>
      TripStop(city: j['city'] as String, countryCode: j['countryCode'] as String?);

  static List<TripStop> listFromJson(String? json) {
    if (json == null || json.isEmpty) return [];
    final raw = jsonDecode(json) as List;
    return raw.map((e) => TripStop.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<TripStop> stops) =>
      jsonEncode(stops.map((s) => s.toJson()).toList());

  TripStop copyWith({String? city, String? countryCode}) =>
      TripStop(city: city ?? this.city, countryCode: countryCode ?? this.countryCode);
}
