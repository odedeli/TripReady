import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontSize { small, normal, large }

class FontSizeService extends ChangeNotifier {
  static final FontSizeService instance = FontSizeService._();
  FontSizeService._();

  static const _key = 'app_font_size';

  AppFontSize _size = AppFontSize.normal;
  AppFontSize get size => _size;

  /// Scale multiplier applied to all font sizes in the theme.
  /// small=0.88, normal=1.0, large=1.14
  /// Chosen so large never breaks common layouts (< 2 lines in most labels).
  double get scale {
    switch (_size) {
      case AppFontSize.small:  return 0.88;
      case AppFontSize.normal: return 1.0;
      case AppFontSize.large:  return 1.14;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'normal';
    _size = _fromString(saved);
    notifyListeners();
  }

  Future<void> setSize(AppFontSize size) async {
    if (_size == size) return;
    _size = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(size));
    notifyListeners();
  }

  static AppFontSize _fromString(String s) {
    switch (s) {
      case 'small': return AppFontSize.small;
      case 'large': return AppFontSize.large;
      default:      return AppFontSize.normal;
    }
  }

  static String _toString(AppFontSize s) {
    switch (s) {
      case AppFontSize.small:  return 'small';
      case AppFontSize.large:  return 'large';
      case AppFontSize.normal: return 'normal';
    }
  }
}
