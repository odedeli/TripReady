import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls whether map geocoding and (in a future tile provider) map labels
/// use the app UI language or always English.
///
/// Tile-level language switching is deferred to v1.5 (requires tile provider
/// with language param support). This service already stores the preference
/// so the setting UI and geocoding can use it today.
class MapLanguageService extends ChangeNotifier {
  MapLanguageService._();
  static final instance = MapLanguageService._();

  static const _key = 'map_language_follow_ui';

  /// When true, geocoding requests use the current app locale language code.
  /// When false, geocoding always requests English ('en').
  bool _followUiLanguage = true;

  bool get followUiLanguage => _followUiLanguage;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _followUiLanguage = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> setFollowUiLanguage(bool value) async {
    if (_followUiLanguage == value) return;
    _followUiLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Returns the accept-language value to use for Nominatim requests.
  String acceptLanguage(String uiLanguageCode) {
    return _followUiLanguage ? uiLanguageCode : 'en';
  }
}
