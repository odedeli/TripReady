import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._();
  ThemeService._();

  static const _key = 'app_theme_mode';

  AppThemeMode _mode = AppThemeMode.system;
  AppThemeMode get mode => _mode;

  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:  return ThemeMode.light;
      case AppThemeMode.dark:   return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }

  /// Call once at app startup
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'system';
    _mode = _fromString(saved);
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(mode));
    notifyListeners();
  }

  static AppThemeMode _fromString(String s) {
    switch (s) {
      case 'light':  return AppThemeMode.light;
      case 'dark':   return AppThemeMode.dark;
      default:       return AppThemeMode.system;
    }
  }

  static String _toString(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.light:  return 'light';
      case AppThemeMode.dark:   return 'dark';
      case AppThemeMode.system: return 'system';
    }
  }
}
