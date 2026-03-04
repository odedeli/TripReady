import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppColorTheme {
  oceanDusk,
  oceanMidnight,
  amberSunset,
  cobaltStorm,
  grassForest,
  orchidDusk,
}

class ColorThemeService extends ChangeNotifier {
  static final ColorThemeService instance = ColorThemeService._();
  ColorThemeService._();

  static const _key = 'app_color_theme';

  AppColorTheme _colorTheme = AppColorTheme.oceanDusk;
  AppColorTheme get colorTheme => _colorTheme;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'oceanDusk';
    _colorTheme = _fromString(saved);
    notifyListeners();
  }

  Future<void> setColorTheme(AppColorTheme t) async {
    if (_colorTheme == t) return;
    _colorTheme = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(t));
    notifyListeners();
  }

  static AppColorTheme _fromString(String s) {
    switch (s) {
      case 'oceanMidnight': return AppColorTheme.oceanMidnight;
      case 'amberSunset':   return AppColorTheme.amberSunset;
      case 'cobaltStorm':   return AppColorTheme.cobaltStorm;
      case 'grassForest':   return AppColorTheme.grassForest;
      case 'orchidDusk':    return AppColorTheme.orchidDusk;
      default:              return AppColorTheme.oceanDusk;
    }
  }

  static String _toString(AppColorTheme t) {
    switch (t) {
      case AppColorTheme.oceanMidnight: return 'oceanMidnight';
      case AppColorTheme.amberSunset:   return 'amberSunset';
      case AppColorTheme.cobaltStorm:   return 'cobaltStorm';
      case AppColorTheme.grassForest:   return 'grassForest';
      case AppColorTheme.orchidDusk:    return 'orchidDusk';
      case AppColorTheme.oceanDusk:     return 'oceanDusk';
    }
  }
}
