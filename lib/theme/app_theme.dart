import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Font helpers ──────────────────────────────────────────────
TextStyle _f(
  String languageCode, {
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double scale = 1.0,
}) {
  final s = (size * scale).roundToDouble();
  return languageCode == 'he'
      ? GoogleFonts.dmSans(fontSize: s, fontWeight: weight, color: color, height: height)
      : GoogleFonts.poppins(fontSize: s, fontWeight: weight, color: color, height: height);
}

TextStyle _h(
  String languageCode, {
  double size = 18,
  FontWeight weight = FontWeight.w600,
  Color? color,
  double scale = 1.0,
}) {
  final s = (size * scale).roundToDouble();
  return languageCode == 'he'
      ? GoogleFonts.dmSans(fontSize: s, fontWeight: weight, color: color)
      : GoogleFonts.poppins(fontSize: s, fontWeight: weight, color: color);
}

class TripReadyTheme {
  // ── Light palette ─────────────────────────────────────────
  static const Color navy       = Color(0xFF0D2B45);
  static const Color teal       = Color(0xFF1A6B72);
  static const Color tealLight  = Color(0xFF2A9BA3);
  static const Color amber      = Color(0xFFE8A838);
  static const Color amberLight = Color(0xFFF5C96A);
  static const Color cream      = Color(0xFFF7F3EE);
  static const Color warmGrey   = Color(0xFFE8E2DA);
  static const Color textDark   = Color(0xFF1A1A2E);
  static const Color textMid    = Color(0xFF4A5568);
  static const Color textLight  = Color(0xFF8A9BB0);
  static const Color success    = Color(0xFF2D9E6B);
  static const Color warning    = Color(0xFFE8A838);
  static const Color danger     = Color(0xFFD64045);
  static const Color cardBg     = Color(0xFFFFFFFF);

  // ── Dark palette ──────────────────────────────────────────
  static const Color darkBg         = Color(0xFF0F1923);
  static const Color darkSurface    = Color(0xFF1A2633);
  static const Color darkCard       = Color(0xFF1E2E3D);
  static const Color darkNavy       = Color(0xFF0D2B45);
  static const Color darkTeal       = Color(0xFF2A9BA3);
  static const Color darkTealLight  = Color(0xFF3DBBC4);
  static const Color darkAmber      = Color(0xFFE8A838);
  static const Color darkAmberLight = Color(0xFFF5C96A);
  static const Color darkTextDark   = Color(0xFFE8EDF2);
  static const Color darkTextMid    = Color(0xFF9AACBE);
  static const Color darkTextLight  = Color(0xFF5A7490);
  static const Color darkWarmGrey   = Color(0xFF2A3A4A);

  // ── Light theme ───────────────────────────────────────────
  static ThemeData theme({String languageCode = 'en', double fontScale = 1.0}) {
    final lc = languageCode;
    final fs = fontScale;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
      textTheme: _buildTextTheme(lc, isLight: true, scale: fs),
      appBarTheme: AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: _h(lc, size: 22, weight: FontWeight.w700, color: Colors.white, scale: fs),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shadowColor: navy.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: teal,
          side: const BorderSide(color: teal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: navy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: warmGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: warmGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: teal, width: 2)),
        labelStyle: _f(lc, size: 14, color: textMid, scale: fs),
        hintStyle:  _f(lc, size: 14, color: textLight, scale: fs),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmGrey,
        selectedColor: teal.withOpacity(0.15),
        labelStyle: _f(lc, size: 12, weight: FontWeight.w500, scale: fs),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: warmGrey, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navy,
        indicatorColor: teal,
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
  static ThemeData darkTheme({String languageCode = 'en', double fontScale = 1.0}) {
    final lc = languageCode;
    final fs = fontScale;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: darkTeal,
        onPrimary: darkBg,
        primaryContainer: darkTeal.withOpacity(0.2),
        onPrimaryContainer: darkTextDark,
        secondary: darkAmber,
        onSecondary: darkBg,
        secondaryContainer: darkAmber.withOpacity(0.2),
        onSecondaryContainer: darkTextDark,
        surface: darkSurface,
        onSurface: darkTextDark,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(lc, isLight: false, scale: fs),
      appBarTheme: AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: darkTextDark,
        elevation: 0,
        titleTextStyle: _h(lc, size: 22, weight: FontWeight.w700, color: darkTextDark, scale: fs),
        iconTheme: IconThemeData(color: darkTextDark),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTeal,
          foregroundColor: darkBg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTeal,
          side: BorderSide(color: darkTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _f(lc, size: 15, weight: FontWeight.w600, scale: fs),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkAmber,
        foregroundColor: darkBg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkWarmGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkWarmGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkTeal, width: 2)),
        labelStyle: _f(lc, size: 14, color: darkTextMid, scale: fs),
        hintStyle:  _f(lc, size: 14, color: darkTextLight, scale: fs),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkWarmGrey,
        selectedColor: darkTeal.withOpacity(0.25),
        labelStyle: _f(lc, size: 12, weight: FontWeight.w500, color: darkTextDark, scale: fs),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: darkWarmGrey, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkNavy,
        indicatorColor: darkTeal,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: darkBg);
          return IconThemeData(color: darkTextMid);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = _f(lc, size: 12, weight: FontWeight.w600, scale: fs);
          if (states.contains(WidgetState.selected)) return style.copyWith(color: darkTextDark);
          return style.copyWith(color: darkTextMid);
        }),
      ),
    );
  }

  // ── Text theme builder ────────────────────────────────────
  static TextTheme _buildTextTheme(String lc, {required bool isLight, double scale = 1.0}) {
    final heading = isLight ? navy : darkTextDark;
    final body    = isLight ? textDark : darkTextDark;
    final mid     = isLight ? textMid : darkTextMid;
    final accent  = isLight ? teal : darkTeal;
    return TextTheme(
      displayLarge:  _h(lc, size: 36, weight: FontWeight.w700, color: heading, scale: scale),
      displayMedium: _h(lc, size: 28, weight: FontWeight.w700, color: heading, scale: scale),
      displaySmall:  _h(lc, size: 22, weight: FontWeight.w600, color: heading, scale: scale),
      headlineMedium:_h(lc, size: 20, weight: FontWeight.w600, color: heading, scale: scale),
      headlineSmall: _h(lc, size: 18, weight: FontWeight.w600, color: heading, scale: scale),
      titleLarge:    _f(lc, size: 17, weight: FontWeight.w600, color: body, scale: scale),
      titleMedium:   _f(lc, size: 15, weight: FontWeight.w600, color: body, scale: scale),
      titleSmall:    _f(lc, size: 13, weight: FontWeight.w600, color: mid, scale: scale),
      bodyLarge:     _f(lc, size: 16, color: body, scale: scale),
      bodyMedium:    _f(lc, size: 14, color: body, scale: scale),
      bodySmall:     _f(lc, size: 12, color: mid, scale: scale),
      labelLarge:    _f(lc, size: 14, weight: FontWeight.w600, color: accent, scale: scale),
    );
  }
}
