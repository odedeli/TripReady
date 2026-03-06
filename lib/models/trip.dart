import 'dart:convert';
import '../data/countries.dart';
import '../services/language_service.dart';
import 'trip_stop.dart';

enum TripStatus { planned, active, archived }
enum TripType { leisure, business, family, adventure, medical, other }
enum TripPurpose { holiday, workTrip, familyVisit, conference, medical, other }

class Trip {
  final String id;
  final String name;
  // ── Route ──────────────────────────────────────────────────────────────────
  final String destination;          // departure city
  final String? country;             // departure country (ISO code)
  final String? returnDestination;   // return-from city (null = same as departure)
  final String? returnCountry;       // return-from country (ISO code)
  final List<TripStop> stops;        // intermediate stops, in order
  // ── Dates & metadata ───────────────────────────────────────────────────────
  final DateTime departureDate;
  final DateTime returnDate;
  final TripStatus status;
  final TripType type;
  final TripPurpose purpose;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    this.country,
    this.returnDestination,
    this.returnCountry,
    List<TripStop>? stops,
    required this.departureDate,
    required this.returnDate,
    this.status = TripStatus.planned,
    this.type = TripType.leisure,
    this.purpose = TripPurpose.holiday,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : stops = stops ?? [];

  // ── Display helpers ─────────────────────────────────────────────────────────

  bool get hasReturnDestination =>
      returnDestination != null && returnDestination!.isNotEmpty;
  bool get hasStops => stops.isNotEmpty;

  String? get countryDisplay => _resolveCountry(country);
  String? get returnCountryDisplay => _resolveCountry(returnCountry);

  static String? _resolveCountry(String? code) {
    if (code == null || code.isEmpty) return null;
    final resolved = countryByCode(code);
    if (resolved != null) {
      final lang = LanguageService.instance.locale.languageCode;
      return resolved.localizedDisplay(lang);
    }
    return code;
  }

  /// Short display for trip cards:
  /// • Simple:        "London, 🇬🇧 United Kingdom"
  /// • With return:   "London → Paris"
  /// • With stops:    "London → … → Paris"  (ellipsis if stops exist)
  String get routeDisplay {
    final dep = countryDisplay != null ? '$destination, $countryDisplay' : destination;
    if (!hasReturnDestination && !hasStops) return dep;
    final ret = hasReturnDestination
        ? (returnCountryDisplay != null
            ? '$returnDestination, $returnCountryDisplay'
            : returnDestination!)
        : dep;
    if (!hasStops) return '$dep → $ret';
    return '$dep → … → $ret';
  }

  /// Full route for trip detail header — all stops expanded.
  /// "London, UK → Amsterdam, NL → Frankfurt, DE → Paris, FR"
  String get routeFull {
    final parts = <String>[
      countryDisplay != null ? '$destination, $countryDisplay' : destination,
      ...stops.map((s) => s.label),
      if (hasReturnDestination)
        returnCountryDisplay != null
            ? '$returnDestination, $returnCountryDisplay'
            : returnDestination!,
    ];
    return parts.join(' → ');
  }

  bool get isActive   => status == TripStatus.active;
  bool get isArchived => status == TripStatus.archived;
  bool get isPlanned  => status == TripStatus.planned;

  int get durationDays => returnDate.difference(departureDate).inDays + 1;

  // ── Serialisation ───────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'destination': destination,
    'country': country,
    'return_destination': returnDestination,
    'return_country': returnCountry,
    'stops': TripStop.listToJson(stops),
    'departure_date': departureDate.toIso8601String(),
    'return_date': returnDate.toIso8601String(),
    'status': status.name,
    'type': type.name,
    'purpose': purpose.name,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
    id: map['id'] as String,
    name: map['name'] as String,
    destination: map['destination'] as String,
    country: map['country'] as String?,
    returnDestination: map['return_destination'] as String?,
    returnCountry: map['return_country'] as String?,
    stops: TripStop.listFromJson(map['stops'] as String?),
    departureDate: DateTime.parse(map['departure_date'] as String),
    returnDate: DateTime.parse(map['return_date'] as String),
    status: TripStatus.values.firstWhere((e) => e.name == map['status'],
        orElse: () => TripStatus.planned),
    type: TripType.values.firstWhere((e) => e.name == map['type'],
        orElse: () => TripType.leisure),
    purpose: TripPurpose.values.firstWhere((e) => e.name == map['purpose'],
        orElse: () => TripPurpose.holiday),
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  Trip copyWith({
    String? id,
    String? name,
    String? destination,
    String? country,
    String? returnDestination,
    String? returnCountry,
    List<TripStop>? stops,
    DateTime? departureDate,
    DateTime? returnDate,
    TripStatus? status,
    TripType? type,
    TripPurpose? purpose,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearReturnDestination = false,
    bool clearReturnCountry = false,
  }) => Trip(
    id: id ?? this.id,
    name: name ?? this.name,
    destination: destination ?? this.destination,
    country: country ?? this.country,
    returnDestination: clearReturnDestination ? null : (returnDestination ?? this.returnDestination),
    returnCountry: clearReturnCountry ? null : (returnCountry ?? this.returnCountry),
    stops: stops ?? this.stops,
    departureDate: departureDate ?? this.departureDate,
    returnDate: returnDate ?? this.returnDate,
    status: status ?? this.status,
    type: type ?? this.type,
    purpose: purpose ?? this.purpose,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  String get statusLabel {
    switch (status) {
      case TripStatus.planned:  return 'Planned';
      case TripStatus.active:   return 'Active';
      case TripStatus.archived: return 'Archived';
    }
  }

  String get typeLabel {
    switch (type) {
      case TripType.leisure:   return 'Leisure';
      case TripType.business:  return 'Business';
      case TripType.family:    return 'Family';
      case TripType.adventure: return 'Adventure';
      case TripType.medical:   return 'Medical';
      case TripType.other:     return 'Other';
    }
  }

  String get purposeLabel {
    switch (purpose) {
      case TripPurpose.holiday:      return 'Holiday';
      case TripPurpose.workTrip:     return 'Work Trip';
      case TripPurpose.familyVisit:  return 'Family Visit';
      case TripPurpose.conference:   return 'Conference';
      case TripPurpose.medical:      return 'Medical';
      case TripPurpose.other:        return 'Other';
    }
  }
}
