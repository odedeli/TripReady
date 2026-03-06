import 'dart:convert';
import 'package:http/http.dart' as http;
import 'language_service.dart';
import 'map_language_service.dart';

/// Nominatim OSM geocoding — no API key required.
/// Rate limit: 1 request/second (throttled via debounce in UI).
class GeocodingService {
  GeocodingService._();
  static final instance = GeocodingService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org';

  Map<String, String> get _headers => {
    'User-Agent': 'TripReady/1.4 (travel planner app)',
    'Accept-Language': _acceptLanguage,
  };

  String get _acceptLanguage {
    final uiLang = LanguageService.instance.locale.languageCode;
    return MapLanguageService.instance.acceptLanguage(uiLang);
  }

  /// Reverse geocode lat/lng → full address string.
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/reverse?format=json&lat=$lat&lon=$lng&zoom=17&addressdetails=1');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Reverse geocode at city zoom level → city name only.
  Future<String?> reverseGeocodeCity(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final addr = data['address'] as Map<String, dynamic>?;
      if (addr != null) {
        return (addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'])
            as String?;
      }
      return data['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Forward geocode a query → first result lat/lng.
  Future<({double lat, double lng, String display})?> forwardGeocode(
      String query, {String? countryCode}) async {
    try {
      final encoded = Uri.encodeComponent(query);
      final cc = countryCode != null
          ? '&countrycodes=${countryCode.toLowerCase()}' : '';
      final uri = Uri.parse(
          '$_baseUrl/search?format=json&q=$encoded$cc&limit=1&addressdetails=1');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final list = jsonDecode(res.body) as List;
      if (list.isEmpty) return null;
      final item = list.first as Map<String, dynamic>;
      return (
        lat: double.parse(item['lat'] as String),
        lng: double.parse(item['lon'] as String),
        display: item['display_name'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  /// Live autocomplete — returns up to [limit] city name suggestions.
  /// Callers must debounce to respect Nominatim 1 req/s rate limit.
  Future<List<String>> autocomplete(
    String query, {
    String? countryCode,
    int limit = 5,
  }) async {
    if (query.trim().length < 2) return [];
    try {
      final encoded = Uri.encodeComponent(query.trim());
      final cc = countryCode != null
          ? '&countrycodes=${countryCode.toLowerCase()}' : '';
      final uri = Uri.parse(
          '$_baseUrl/search?format=json&q=$encoded$cc'
          '&featuretype=city&limit=$limit&addressdetails=1');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
