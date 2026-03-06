import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

/// Renders a country flag using the [country_flags] package.
///
/// Uses bundled SVG vector assets — works identically on Windows, Linux,
/// Android, iOS and macOS with no OS emoji font dependency.
class FlagWidget extends StatelessWidget {
  /// ISO 3166-1 alpha-2 country code (e.g. 'IL', 'FR').
  final String? code;

  /// Rendered height of the flag. Width is auto (approx 4:3 ratio).
  final double size;

  const FlagWidget({
    super.key,
    required this.code,
    this.size = 20,
  });

  /// Returns true if [code] is a valid 2-letter ISO code.
  static bool isValid(String? code) {
    if (code == null || code.length != 2) return false;
    return code.toUpperCase().codeUnits.every((c) => c >= 0x41 && c <= 0x5A);
  }

  @override
  Widget build(BuildContext context) {
    if (!isValid(code)) return const SizedBox.shrink();
    return CountryFlag.fromCountryCode(
      code!.toUpperCase(),
      height: size,
      width: size * 1.33,
      borderRadius: 2,
    );
  }
}

/// Inline helper — returns [SizedBox(width:4), FlagWidget] for Row children,
/// or empty list if code is null/invalid.
List<Widget> flagInline(String? code, {double size = 16}) {
  if (!FlagWidget.isValid(code)) return [];
  return [
    const SizedBox(width: 4),
    FlagWidget(code: code, size: size),
  ];
}
