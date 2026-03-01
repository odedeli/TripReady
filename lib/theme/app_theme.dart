import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripReadyTheme {
  static const Color navy = Color(0xFF0D2B45);
  static const Color teal = Color(0xFF1A6B72);
  static const Color tealLight = Color(0xFF2A9BA3);
  static const Color amber = Color(0xFFE8A838);
  static const Color amberLight = Color(0xFFF5C96A);
  static const Color cream = Color(0xFFF7F3EE);
  static const Color warmGrey = Color(0xFFE8E2DA);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMid = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF8A9BB0);
  static const Color success = Color(0xFF2D9E6B);
  static const Color warning = Color(0xFFE8A838);
  static const Color danger = Color(0xFFD64045);
  static const Color cardBg = Color(0xFFFFFFFF);

  static ThemeData get theme {
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
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w700, color: navy),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: navy),
        displaySmall: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, color: navy),
        headlineMedium: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: navy),
        headlineSmall: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: navy),
        titleLarge: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: textDark),
        titleSmall: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: textMid),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: textDark),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: textMid),
        labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: teal),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
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
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: teal,
          side: const BorderSide(color: teal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: warmGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: warmGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: teal, width: 2)),
        labelStyle: GoogleFonts.dmSans(color: textMid, fontSize: 14),
        hintStyle: GoogleFonts.dmSans(color: textLight, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmGrey,
        selectedColor: teal.withOpacity(0.15),
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
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
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white);
          }
          return GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withOpacity(0.5));
        }),
      ),
    );
  }
}
