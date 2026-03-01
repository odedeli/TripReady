import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._();
  LanguageService._();

  static const _key = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isRTL => _locale.languageCode == 'he';

  /// Call once at app startup
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('he'),
  ];
}
