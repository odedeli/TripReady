import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Font helpers ──────────────────────────────────────────────
// Returns Poppins for English, DM Sans for Hebrew (Poppins has no Hebrew glyphs)
TextStyle _f(
  String languageCode, {
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) {
  final base = languageCode == 'he'
      ? GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color, height: height)
      : GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color, height: height);
  return base;
}

// Heading font: Poppins semibold for EN, DM Sans semibold for HE
// (removed Playfair Display — no serif fonts in v1.2.0)
TextStyle _h(
  String languageCode, {
  double size = 18,
  FontWeight weight = FontWeight.w600,
  Color? color,
}) {
  return languageCode == 'he'
      ? GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color)
      : GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
}

class TripReadyTheme {
  // ── Palette ───────────────────────────────────────────────
  static const Color navy      = Color(0xFF0D2B45);
  static const Color teal      = Color(0xFF1A6B72);
  static const Color tealLight = Color(0xFF2A9BA3);
  static const Color amber     = Color(0xFFE8A838);
  static const Color amberLight= Color(0xFFF5C96A);
  static const Color cream     = Color(0xFFF7F3EE);
  static const Color warmGrey  = Color(0xFFE8E2DA);
  static const Color textDark  = Color(0xFF1A1A2E);
  static const Color textMid   = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF8A9BB0);
  static const Color success   = Color(0xFF2D9E6B);
  static const Color warning   = Color(0xFFE8A838);
  static const Color danger    = Color(0xFFD64045);
  static const Color cardBg    = Color(0xFFFFFFFF);

  // ── Theme builder ─────────────────────────────────────────
  // languageCode drives font selection ('en' → Poppins, 'he' → DM Sans)
  static ThemeData theme({String languageCode = 'en'}) {
    final String lc = languageCode;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: teal,
        onPrimary: Colors.white,
        primaryContainer: tealLight.withOpacity(0.15),
        onPrimaryContainer: navy,
        secondary: amber,
        onSecondary: navy,
        secondaryContainer: amberLight.withOpacity(0.2),
        onSecondaryContainer: navy,
        surface: cream,
        onSurface: textDark,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: cream,

      // ── Text theme ────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  _h(lc, size: 36, weight: FontWeight.w700, color: navy),
        displayMedium: _h(lc, size: 28, weight: FontWeight.w700, color: navy),
        displaySmall:  _h(lc, size: 22, weight: FontWeight.w600, color: navy),
        headlineMedium:_h(lc, size: 20, weight: FontWeight.w600, color: navy),
        headlineSmall: _h(lc, size: 18, weight: FontWeight.w600, color: navy),
        titleLarge:    _f(lc, size: 17, weight: FontWeight.w600, color: textDark),
        titleMedium:   _f(lc, size: 15, weight: FontWeight.w600, color: textDark),
        titleSmall:    _f(lc, size: 13, weight: FontWeight.w600, color: textMid),
        bodyLarge:     _f(lc, size: 16, color: textDark),
        bodyMedium:    _f(lc, size: 14, color: textDark),
        bodySmall:     _f(lc, size: 12, color: textMid),
        labelLarge:    _f(lc, size: 14, weight: FontWeight.w600, color: teal),
      ),

      // ── AppBar ────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: _h(lc, size: 22, weight: FontWeight.w700, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── Cards ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shadowColor: navy.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Buttons ───────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: teal,
          side: const BorderSide(color: teal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: navy,
      ),

      // ── Inputs ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: warmGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: warmGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: teal, width: 2)),
        labelStyle: _f(lc, size: 14, color: textMid),
        hintStyle:  _f(lc, size: 14, color: textLight),
      ),

      // ── Chips ─────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: warmGrey,
        selectedColor: teal.withOpacity(0.15),
        labelStyle: _f(lc, size: 12, weight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dividerTheme: const DividerThemeData(color: warmGrey, thickness: 1, space: 1),

      // ── Navigation bar ────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navy,
        indicatorColor: teal,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white);
          return IconThemeData(color: Colors.white.withOpacity(0.5));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = _f(lc, size: 12, weight: FontWeight.w600);
          if (states.contains(WidgetState.selected)) return style.copyWith(color: Colors.white);
          return style.copyWith(color: Colors.white.withOpacity(0.5));
        }),
      ),
    );
  }
}
