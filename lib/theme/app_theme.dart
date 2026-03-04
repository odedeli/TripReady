import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palettes.dart';

// ── Font helpers ──────────────────────────────────────────────
TextStyle _f(String lc, {double size=14, FontWeight weight=FontWeight.w400, Color? color, double? height, double scale=1.0}) {
  final s = (size * scale).roundToDouble();
  return lc == 'he'
      ? GoogleFonts.dmSans(fontSize: s, fontWeight: weight, color: color, height: height)
      : GoogleFonts.poppins(fontSize: s, fontWeight: weight, color: color, height: height);
}

TextStyle _h(String lc, {double size=18, FontWeight weight=FontWeight.w600, Color? color, double scale=1.0}) {
  final s = (size * scale).roundToDouble();
  return lc == 'he'
      ? GoogleFonts.dmSans(fontSize: s, fontWeight: weight, color: color)
      : GoogleFonts.poppins(fontSize: s, fontWeight: weight, color: color);
}

// ── TripReadyTheme ────────────────────────────────────────────
class TripReadyTheme {
  // Keep legacy color constants for widgets that reference them directly
  // (StatusBadge, EmptyState etc). They resolve to the active palette at runtime
  // via context — but for static const refs we fall back to Ocean·Dusk values.
  static const Color navy       = Color(0xFF0A2F40); // ocean-900
  static const Color teal       = Color(0xFF257599); // ocean-600
  static const Color tealLight  = Color(0xFF40B8EF); // ocean-400
  static const Color amber      = Color(0xFFF7B750); // amber-300
  static const Color amberLight = Color(0xFFFCE8CC); // amber-100
  static const Color cream      = Color(0xFFF2FAFE); // ocean-50
  static const Color warmGrey   = Color(0xFFB7E2FA); // ocean-200
  static const Color textDark   = Color(0xFF05202D); // ocean-950
  static const Color textMid    = Color(0xFF1B5976); // ocean-700
  static const Color textLight  = Color(0xFF40B8EF); // ocean-400
  static const Color success    = Color(0xFF34A466);
  static const Color warning    = Color(0xFFDB9E3A);
  static const Color danger     = Color(0xFFF23D61);
  static const Color cardBg     = Color(0xFFFFFFFF);
  // Dark equivalents
  static const Color darkBg      = Color(0xFF05202D);
  static const Color darkSurface = Color(0xFF0E3347);
  static const Color darkCard    = Color(0xFF124259);
  static const Color darkNavy    = Color(0xFF0A2F40);
  static const Color darkTeal    = Color(0xFF40B8EF);
  static const Color darkAmber   = Color(0xFFF7B750);
  static const Color darkTextDark  = Color(0xFFF2FAFE);
  static const Color darkTextMid   = Color(0xFF83CFF7);
  static const Color darkTextLight = Color(0xFF257599);
  static const Color darkWarmGrey  = Color(0xFF124259);

  // ── Theme builder ─────────────────────────────────────────
  static ThemeData theme({
    String languageCode = 'en',
    double fontScale = 1.0,
    AppColorPalette? palette,
  }) {
    final lc = languageCode;
    final fs = fontScale;
    final p = palette ?? AppPalettes.oceanDusk;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: p.primary,
        onPrimary: Colors.white,
        primaryContainer: p.primaryLight,
        onPrimaryContainer: p.textDark,
        secondary: p.accent,
        onSecondary: p.textDark,
        secondaryContainer: p.accentLight,
        onSecondaryContainer: p.textDark,
        surface: p.background,
        onSurface: p.textDark,
        error: p.danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: p.background,
      textTheme: _buildTextTheme(lc, isLight: true, p: p, scale: fs),
      appBarTheme: AppBarTheme(
        backgroundColor: p.navBg,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: _h(lc, size: 22, weight: FontWeight.w700, color: Colors.white, scale: fs),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 2,
        shadowColor: p.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.textDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.primary, width: 2)),
        labelStyle: _f(lc, size: 14, color: p.textMid, scale: fs),
        hintStyle:  _f(lc, size: 14, color: p.textLight, scale: fs),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.border,
        selectedColor: p.primary.withOpacity(0.15),
        labelStyle: _f(lc, size: 12, weight: FontWeight.w500, scale: fs),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.navBg,
        indicatorColor: p.navIndicator,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white);
          return IconThemeData(color: Colors.white.withOpacity(0.5));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = _f(lc, size: 12, weight: FontWeight.w600, scale: fs);
          if (states.contains(WidgetState.selected)) return style.copyWith(color: Colors.white);
          return style.copyWith(color: Colors.white.withOpacity(0.5));
        }),
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────
  static ThemeData darkTheme({
    String languageCode = 'en',
    double fontScale = 1.0,
    AppColorPalette? palette,
  }) {
    final lc = languageCode;
    final fs = fontScale;
    final p = palette ?? AppPalettes.oceanDusk;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: p.darkPrimary,
        onPrimary: p.darkBackground,
        primaryContainer: p.darkPrimaryLight,
        onPrimaryContainer: p.darkTextDark,
        secondary: p.darkAccent,
        onSecondary: p.darkBackground,
        secondaryContainer: p.darkPrimaryLight,
        onSecondaryContainer: p.darkTextDark,
        surface: p.darkSurface,
        onSurface: p.darkTextDark,
        error: p.danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: p.darkBackground,
      textTheme: _buildTextTheme(lc, isLight: false, p: p, scale: fs),
      appBarTheme: AppBarTheme(
        backgroundColor: p.navBg,
        foregroundColor: p.darkTextDark,
        elevation: 0,
        titleTextStyle: _h(lc, size: 22, weight: FontWeight.w700, color: p.darkTextDark, scale: fs),
        iconTheme: IconThemeData(color: p.darkTextDark),
      ),
      cardTheme: CardThemeData(
        color: p.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.darkPrimary,
          foregroundColor: p.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.darkPrimary,
          side: BorderSide(color: p.darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.darkAccent,
        foregroundColor: p.darkBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.darkPrimary, width: 2)),
        labelStyle: _f(lc, size: 14, color: p.darkTextMid, scale: fs),
        hintStyle:  _f(lc, size: 14, color: p.darkTextLight, scale: fs),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.darkBorder,
        selectedColor: p.darkPrimary.withOpacity(0.25),
        labelStyle: _f(lc, size: 12, weight: FontWeight.w500, color: p.darkTextDark, scale: fs),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: p.darkBorder, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.navBg,
        indicatorColor: p.navIndicator,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: p.darkBackground);
          return IconThemeData(color: p.darkTextMid);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = _f(lc, size: 12, weight: FontWeight.w600, scale: fs);
          if (states.contains(WidgetState.selected)) return style.copyWith(color: p.darkTextDark);
          return style.copyWith(color: p.darkTextMid);
        }),
      ),
    );
  }

  // ── Text theme ────────────────────────────────────────────
  static TextTheme _buildTextTheme(String lc, {required bool isLight, required AppColorPalette p, double scale = 1.0}) {
    final heading = isLight ? p.textDark   : p.darkTextDark;
    final body    = isLight ? p.textDark   : p.darkTextDark;
    final mid     = isLight ? p.textMid    : p.darkTextMid;
    final accent  = isLight ? p.primary    : p.darkPrimary;
    return TextTheme(
      displayLarge:  _h(lc, size: 36, weight: FontWeight.w700, color: heading, scale: scale),
      displayMedium: _h(lc, size: 28, weight: FontWeight.w700, color: heading, scale: scale),
      displaySmall:  _h(lc, size: 22, weight: FontWeight.w600, color: heading, scale: scale),
      headlineMedium:_h(lc, size: 20, weight: FontWeight.w600, color: heading, scale: scale),
      headlineSmall: _h(lc, size: 18, weight: FontWeight.w600, color: heading, scale: scale),
      titleLarge:    _f(lc, size: 17, weight: FontWeight.w600, color: body,    scale: scale),
      titleMedium:   _f(lc, size: 15, weight: FontWeight.w600, color: body,    scale: scale),
      titleSmall:    _f(lc, size: 13, weight: FontWeight.w600, color: mid,     scale: scale),
      bodyLarge:     _f(lc, size: 16, color: body,    scale: scale),
      bodyMedium:    _f(lc, size: 14, color: body,    scale: scale),
      bodySmall:     _f(lc, size: 12, color: mid,     scale: scale),
      labelLarge:    _f(lc, size: 14, weight: FontWeight.w600, color: accent,  scale: scale),
    );
  }
}
