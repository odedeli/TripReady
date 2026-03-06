import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A recently-selected destination entry.
class RecentDestination {
  final String city;
  final String? countryCode;
  final String? countryName;
  final DateTime usedAt;

  const RecentDestination({
    required this.city,
    this.countryCode,
    this.countryName,
    required this.usedAt,
  });

  Map<String, dynamic> toJson() => {
    'city': city,
    'countryCode': countryCode,
    'countryName': countryName,
    'usedAt': usedAt.toIso8601String(),
  };

  factory RecentDestination.fromJson(Map<String, dynamic> j) => RecentDestination(
    city: j['city'] as String,
    countryCode: j['countryCode'] as String?,
    countryName: j['countryName'] as String?,
    usedAt: DateTime.parse(j['usedAt'] as String),
  );

  @override
  bool operator ==(Object other) =>
      other is RecentDestination &&
      city == other.city &&
      countryCode == other.countryCode;

  @override
  int get hashCode => Object.hash(city, countryCode);
}

/// Persists up to [maxEntries] recently-selected destinations in shared_preferences.
/// Most-recent first. Duplicates (same city + country) are bumped to the top.
class RecentDestinationsService {
  RecentDestinationsService._();
  static final instance = RecentDestinationsService._();

  static const _key = 'recent_destinations';
  static const maxEntries = 20;

  List<RecentDestination> _cache = [];
  bool _loaded = false;

  Future<List<RecentDestination>> getAll() async {
    if (!_loaded) await _load();
    return List.unmodifiable(_cache);
  }

  /// Returns only entries matching [countryCode], or all if null.
  Future<List<RecentDestination>> getForCountry(String? countryCode) async {
    final all = await getAll();
    if (countryCode == null) return all;
    return all.where((r) => r.countryCode == countryCode).toList();
  }

  Future<void> add(String city, {String? countryCode, String? countryName}) async {
    if (!_loaded) await _load();
    // Remove existing duplicate
    _cache.removeWhere((r) =>
        r.city.toLowerCase() == city.toLowerCase() &&
        r.countryCode == countryCode);
    // Insert at front
    _cache.insert(
      0,
      RecentDestination(
        city: city,
        countryCode: countryCode,
        countryName: countryName,
        usedAt: DateTime.now(),
      ),
    );
    // Trim to max
    if (_cache.length > maxEntries) _cache = _cache.sublist(0, maxEntries);
    await _save();
  }

  Future<void> remove(RecentDestination entry) async {
    if (!_loaded) await _load();
    _cache.remove(entry);
    await _save();
  }

  Future<void> clearAll() async {
    _cache = [];
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _cache = list
            .map((e) => RecentDestination.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _cache = [];
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_cache.map((r) => r.toJson()).toList()));
  }
}
