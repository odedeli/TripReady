import 'package:flutter/material.dart';
import '../data/countries.dart';
import '../models/trip.dart';
import '../services/language_service.dart';
import 'flag_widget.dart';

/// Renders a trip's destination as: [city] [FlagWidget] [country name]
/// For multi-stop trips: city [flag] → … → city [flag]
///
/// Replaces plain `Text(trip.routeDisplay)` wherever a flag widget is needed.
class TripRouteDisplay extends StatelessWidget {
  final Trip trip;
  final TextStyle? style;
  final Color? color;

  const TripRouteDisplay({
    super.key,
    required this.trip,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance.locale.languageCode;
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    final textStyle = base?.copyWith(color: color) ?? TextStyle(color: color);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 2,
      children: _buildParts(lang, textStyle),
    );
  }

  List<Widget> _buildParts(String lang, TextStyle textStyle) {
    final parts = <Widget>[];

    void addDestination(String city, String? countryCode, {bool arrow = false}) {
      if (arrow) {
        parts.add(Text(' → ', style: textStyle));
      }
      final country = countryCode != null ? countryByCode(countryCode) : null;
      final countryName = country?.localizedName(lang);

      parts.add(Text(city, style: textStyle));
      if (countryCode != null && FlagWidget.isValid(countryCode)) {
        parts.add(const SizedBox(width: 4));
        parts.add(FlagWidget(code: countryCode, size: (textStyle.fontSize ?? 14) * 0.95));
      }
      if (countryName != null) {
        parts.add(Text(' $countryName', style: textStyle));
      }
    }

    addDestination(trip.destination, trip.country);

    if (trip.hasStops || trip.hasReturnDestination) {
      if (trip.hasStops) {
        parts.add(Text(' → … ', style: textStyle));
      }
      if (trip.hasReturnDestination) {
        addDestination(trip.returnDestination!, trip.returnCountry, arrow: !trip.hasStops);
      }
    }

    return parts;
  }
}

/// Single-destination variant: "City [flag] Country Name"
/// Used for the trip detail header simple case.
class TripDestinationDisplay extends StatelessWidget {
  final String city;
  final String? countryCode;
  final TextStyle? style;
  final Color? color;

  const TripDestinationDisplay({
    super.key,
    required this.city,
    this.countryCode,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance.locale.languageCode;
    final country = countryCode != null ? countryByCode(countryCode!) : null;
    final countryName = country?.localizedName(lang);
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    final textStyle = base?.copyWith(color: color) ?? TextStyle(color: color);
    final flagSize = (textStyle.fontSize ?? 14) * 0.95;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 2,
      children: [
        Text(city, style: textStyle),
        if (FlagWidget.isValid(countryCode)) ...[
          const SizedBox(width: 4),
          FlagWidget(code: countryCode, size: flagSize),
        ],
        if (countryName != null)
          Text(' $countryName', style: textStyle),
      ],
    );
  }
}
