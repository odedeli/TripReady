import 'package:flutter/material.dart';
import '../services/color_theme_service.dart';

// ─────────────────────────────────────────────────────────────
// Ambersky V4.0 palette — all colors used across themes
// ─────────────────────────────────────────────────────────────
class _Ocean {
  static const c50  = Color(0xFFF2FAFE);
  static const c100 = Color(0xFFD8EFFC);
  static const c200 = Color(0xFFB7E2FA);
  static const c300 = Color(0xFF83CFF7);
  static const c400 = Color(0xFF40B8EF);
  static const c500 = Color(0xFF3397C5);
  static const c600 = Color(0xFF257599);
  static const c700 = Color(0xFF1B5976);
  static const c800 = Color(0xFF124259);
  static const c900 = Color(0xFF0A2F40);
  static const c950 = Color(0xFF05202D);
}

class _Amber {
  static const c50  = Color(0xFFFEF7EE);
  static const c100 = Color(0xFFFCE8CC);
  static const c200 = Color(0xFFFAD49E);
  static const c300 = Color(0xFFF7B750);
  static const c400 = Color(0xFFDB9E3A);
  static const c500 = Color(0xFFB4812E);
  static const c600 = Color(0xFF8B6321);
  static const c700 = Color(0xFF6B4C17);
  static const c800 = Color(0xFF50380F);
  static const c900 = Color(0xFF3A2708);
  static const c950 = Color(0xFF281A04);
}

class _Coral {
  static const c300 = Color(0xFFF7B09A);
  static const c400 = Color(0xFFF58968);
  static const c500 = Color(0xFFE35A2D);
  static const c600 = Color(0xFFB04421);
  static const c50  = Color(0xFFFEF7F4);
  static const c100 = Color(0xFFFCE6DF);
  static const c800 = Color(0xFF67250F);
  static const c900 = Color(0xFF4C1908);
  static const c950 = Color(0xFF350F04);
}

class _Cobalt {
  static const c50  = Color(0xFFF6F8FE);
  static const c100 = Color(0xFFE4EBFC);
  static const c200 = Color(0xFFCEDAFA);
  static const c300 = Color(0xFFAFC3F7);
  static const c400 = Color(0xFF8CA8F4);
  static const c500 = Color(0xFF6184EF);
  static const c600 = Color(0xFF3757EB);
  static const c700 = Color(0xFF222BDA);
  static const c800 = Color(0xFF171FA7);
  static const c900 = Color(0xFF0E147C);
  static const c950 = Color(0xFF070C59);
}

class _Lavender {
  static const c200 = Color(0xFFD6D7FA);
  static const c300 = Color(0xFFBDBEF7);
  static const c400 = Color(0xFFA2A0F4);
}

class _Grass {
  static const c50  = Color(0xFFEBFEF1);
  static const c100 = Color(0xFFBFFCD3);
  static const c400 = Color(0xFF42C77E);
  static const c500 = Color(0xFF34A466);
  static const c600 = Color(0xFF277E4E);
  static const c700 = Color(0xFF1C613B);
  static const c800 = Color(0xFF12492B);
  static const c900 = Color(0xFF0B341D);
  static const c950 = Color(0xFF052312);
}

class _Gold {
  static const c200 = Color(0xFFF3DD4D);
  static const c300 = Color(0xFFDAC644);
  static const c400 = Color(0xFFBEAC3A);
}

class _Orchid {
  static const c50  = Color(0xFFFAF7FE);
  static const c100 = Color(0xFFF1E6FC);
  static const c300 = Color(0xFFD7B2F7);
  static const c400 = Color(0xFFC68EF4);
  static const c500 = Color(0xFFB25AF0);
  static const c600 = Color(0xFF922DCF);
  static const c700 = Color(0xFF7121A1);
  static const c800 = Color(0xFF55177A);
  static const c900 = Color(0xFF3D0E5A);
  static const c950 = Color(0xFF2A0740);
}

class _Rose {
  static const c200 = Color(0xFFFAC9EE);
  static const c300 = Color(0xFFF8A4E4);
  static const c400 = Color(0xFFF571DB);
}

class _Gray {
  static const c50  = Color(0xFFF8F8FA);
  static const c100 = Color(0xFFEAEBEE);
  static const c200 = Color(0xFFD8DBE0);
  static const c300 = Color(0xFFC0C4CD);
  static const c400 = Color(0xFFA6ABB7);
  static const c500 = Color(0xFF868C9C);
  static const c600 = Color(0xFF656C7B);
  static const c700 = Color(0xFF4B5263);
  static const c800 = Color(0xFF393D46);
  static const c900 = Color(0xFF282B34);
  static const c950 = Color(0xFF1A1D24);
}

// ─────────────────────────────────────────────────────────────
// AppColorPalette — all the semantic color slots consumed by
// app_theme.dart to build light & dark ThemeData.
// ─────────────────────────────────────────────────────────────
class AppColorPalette {
  // Display name shown in Settings
  final String name;

  // Light mode
  final Color primary;        // buttons, icons, active states
  final Color primaryLight;   // hover / container tint
  final Color accent;         // FAB, badges, highlights
  final Color accentLight;    // accent tint
  final Color background;     // scaffold
  final Color surface;        // cards
  final Color border;         // dividers, input borders
  final Color textDark;
  final Color textMid;
  final Color textLight;

  // Dark mode overrides
  final Color darkPrimary;
  final Color darkPrimaryLight;
  final Color darkAccent;
  final Color darkBackground;
  final Color darkSurface;
  final Color darkCard;
  final Color darkBorder;
  final Color darkTextDark;
  final Color darkTextMid;
  final Color darkTextLight;

  // Semantic — shared across light/dark
  final Color success;
  final Color warning;
  final Color danger;

  // Nav bar background (usually deep/dark regardless of light/dark mode)
  final Color navBg;
  final Color navIndicator;

  const AppColorPalette({
    required this.name,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.accentLight,
    required this.background,
    required this.surface,
    required this.border,
    required this.textDark,
    required this.textMid,
    required this.textLight,
    required this.darkPrimary,
    required this.darkPrimaryLight,
    required this.darkAccent,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkCard,
    required this.darkBorder,
    required this.darkTextDark,
    required this.darkTextMid,
    required this.darkTextLight,
    required this.success,
    required this.warning,
    required this.danger,
    required this.navBg,
    required this.navIndicator,
  });
}

// ─────────────────────────────────────────────────────────────
// The 6 palettes
// ─────────────────────────────────────────────────────────────
class AppPalettes {

  // 1. Ocean · Dusk — warm ocean + amber glow (DEFAULT)
  static const oceanDusk = AppColorPalette(
    name: 'Ocean · Dusk',
    primary:       _Ocean.c600,
    primaryLight:  _Ocean.c200,
    accent:        _Amber.c300,
    accentLight:   _Amber.c100,
    background:    Color(0xFFF2FAFE),  // ocean-50 tint
    surface:       Color(0xFFFFFFFF),
    border:        _Ocean.c200,
    textDark:      _Ocean.c950,
    textMid:       _Ocean.c700,
    textLight:     _Ocean.c400,
    darkPrimary:       _Ocean.c400,
    darkPrimaryLight:  _Ocean.c800,
    darkAccent:        _Amber.c300,
    darkBackground:    _Ocean.c950,
    darkSurface:       Color(0xFF0E3347),
    darkCard:          Color(0xFF124259),
    darkBorder:        _Ocean.c800,
    darkTextDark:      _Ocean.c50,
    darkTextMid:       _Ocean.c300,
    darkTextLight:     _Ocean.c600,
    success: Color(0xFF34A466),
    warning: _Amber.c400,
    danger:  Color(0xFFF23D61),
    navBg:         _Ocean.c900,
    navIndicator:  _Ocean.c500,
  );

  // 2. Ocean · Midnight — deep dramatic ocean
  static const oceanMidnight = AppColorPalette(
    name: 'Ocean · Midnight',
    primary:       _Ocean.c800,
    primaryLight:  _Ocean.c100,
    accent:        _Ocean.c400,
    accentLight:   _Ocean.c100,
    background:    _Gray.c50,
    surface:       Color(0xFFFFFFFF),
    border:        _Gray.c200,
    textDark:      _Ocean.c950,
    textMid:       _Gray.c700,
    textLight:     _Gray.c400,
    darkPrimary:       _Ocean.c300,
    darkPrimaryLight:  _Ocean.c900,
    darkAccent:        _Ocean.c400,
    darkBackground:    Color(0xFF05202D),
    darkSurface:       Color(0xFF0A2F40),
    darkCard:          Color(0xFF0E3850),
    darkBorder:        _Ocean.c900,
    darkTextDark:      _Gray.c50,
    darkTextMid:       _Gray.c300,
    darkTextLight:     _Gray.c600,
    success: Color(0xFF34A466),
    warning: _Amber.c400,
    danger:  Color(0xFFF23D61),
    navBg:         _Ocean.c950,
    navIndicator:  _Ocean.c600,
  );

  // 3. Amber · Sunset — warm, energetic, amber + coral
  static const amberSunset = AppColorPalette(
    name: 'Amber · Sunset',
    primary:       _Amber.c600,
    primaryLight:  _Amber.c100,
    accent:        _Coral.c400,
    accentLight:   _Coral.c100,
    background:    _Amber.c50,
    surface:       Color(0xFFFFFFFF),
    border:        _Amber.c200,
    textDark:      _Amber.c950,
    textMid:       _Amber.c700,
    textLight:     _Amber.c400,
    darkPrimary:       _Amber.c300,
    darkPrimaryLight:  _Amber.c800,
    darkAccent:        _Coral.c300,
    darkBackground:    Color(0xFF1A0E04),
    darkSurface:       Color(0xFF281A04),
    darkCard:          Color(0xFF3A2708),
    darkBorder:        _Amber.c800,
    darkTextDark:      _Amber.c50,
    darkTextMid:       _Amber.c200,
    darkTextLight:     _Amber.c500,
    success: Color(0xFF34A466),
    warning: _Amber.c400,
    danger:  Color(0xFFF23D61),
    navBg:         _Amber.c900,
    navIndicator:  _Amber.c500,
  );

  // 4. Cobalt · Storm — bold electric blue + lavender
  static const cobaltStorm = AppColorPalette(
    name: 'Cobalt · Storm',
    primary:       _Cobalt.c600,
    primaryLight:  _Cobalt.c100,
    accent:        _Lavender.c300,
    accentLight:   _Cobalt.c100,
    background:    _Cobalt.c50,
    surface:       Color(0xFFFFFFFF),
    border:        _Cobalt.c200,
    textDark:      _Cobalt.c950,
    textMid:       _Cobalt.c700,
    textLight:     _Cobalt.c400,
    darkPrimary:       _Cobalt.c400,
    darkPrimaryLight:  _Cobalt.c900,
    darkAccent:        _Lavender.c300,
    darkBackground:    Color(0xFF07091A),
    darkSurface:       Color(0xFF0E1430),
    darkCard:          Color(0xFF141B42),
    darkBorder:        _Cobalt.c900,
    darkTextDark:      _Gray.c50,
    darkTextMid:       _Cobalt.c300,
    darkTextLight:     _Cobalt.c600,
    success: Color(0xFF34A466),
    warning: _Amber.c400,
    danger:  Color(0xFFF23D61),
    navBg:         _Cobalt.c950,
    navIndicator:  _Cobalt.c600,
  );

  // 5. Grass · Forest — natural, fresh green + gold
  static const grassForest = AppColorPalette(
    name: 'Grass · Forest',
    primary:       _Grass.c600,
    primaryLight:  _Grass.c100,
    accent:        _Gold.c300,
    accentLight:   Color(0xFFFEFADB),
    background:    _Grass.c50,
    surface:       Color(0xFFFFFFFF),
    border:        Color(0xFFBFFCD3),
    textDark:      _Grass.c950,
    textMid:       _Grass.c700,
    textLight:     _Grass.c400,
    darkPrimary:       _Grass.c400,
    darkPrimaryLight:  _Grass.c900,
    darkAccent:        _Gold.c300,
    darkBackground:    Color(0xFF021A09),
    darkSurface:       Color(0xFF052312),
    darkCard:          Color(0xFF0B341D),
    darkBorder:        _Grass.c900,
    darkTextDark:      _Gray.c50,
    darkTextMid:       _Grass.c100,
    darkTextLight:     _Grass.c500,
    success: Color(0xFF34A466),
    warning: _Amber.c400,
    danger:  Color(0xFFF23D61),
    navBg:         _Grass.c950,
    navIndicator:  _Grass.c600,
  );

  // 6. Orchid · Dusk — rich creative purple + rose
  static const orchidDusk = AppColorPalette(
    name: 'Orchid · Dusk',
    primary:       _Orchid.c600,
    primaryLight:  _Orchid.c100,
    accent:        _Rose.c300,
    accentLight:   Color(0xFFFEF6FC),
    background:    _Orchid.c50,
    surface:       Color(0xFFFFFFFF),
    border:        Color(0xFFE6D1FA),
    textDark:      _Orchid.c950,
    textMid:       _Orchid.c700,
    textLight:     _Orchid.c400,
    darkPrimary:       _Orchid.c400,
    darkPrimaryLight:  _Orchid.c900,
    darkAccent:        _Rose.c300,
    darkBackground:    Color(0xFF120720),
    darkSurface:       Color(0xFF1E0B32),
    darkCard:          Color(0xFF2A0F45),
    darkBorder:        _Orchid.c900,
    darkTextDark:      _Gray.c50,
    darkTextMid:       _Orchid.c300,
    darkTextLight:     _Orchid.c600,
    success: Color(0xFF34A466),
    warning: _Amber.c400,
    danger:  Color(0xFFF23D61),
    navBg:         _Orchid.c950,
    navIndicator:  _Orchid.c600,
  );

  static AppColorPalette fromTheme(AppColorTheme t) {
    switch (t) {
      case AppColorTheme.oceanMidnight: return oceanMidnight;
      case AppColorTheme.amberSunset:   return amberSunset;
      case AppColorTheme.cobaltStorm:   return cobaltStorm;
      case AppColorTheme.grassForest:   return grassForest;
      case AppColorTheme.orchidDusk:    return orchidDusk;
      case AppColorTheme.oceanDusk:     return oceanDusk;
    }
  }
}
