import 'dart:convert';
import 'package:http/http.dart' as http;

/// Nominatim OSM geocoding — no API key required.
/// Rate limit: 1 request/second (we throttle via debounce in UI).
class GeocodingService {
  GeocodingService._();
  static final instance = GeocodingService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org';
  static const _headers = {'User-Agent': 'TripReady/1.4 (travel planner app)'};

  /// Reverse geocode lat/lng → address string.
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

  /// Forward geocode a query → first result's lat/lng.
  Future<({double lat, double lng, String display})?> forwardGeocode(String query) async {
    try {
      final encoded = Uri.encodeComponent(query);
      final uri = Uri.parse(
          '$_baseUrl/search?format=json&q=$encoded&limit=1&addressdetails=1');
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
}
