enum TripStatus { planned, active, archived }
enum TripType { leisure, business, family, adventure, medical, other }
enum TripPurpose { holiday, workTrip, familyVisit, conference, medical, other }

class Trip {
  final String id;
  final String name;
  final String destination;
  final String? country;
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
    required this.departureDate,
    required this.returnDate,
    this.status = TripStatus.planned,
    this.type = TripType.leisure,
    this.purpose = TripPurpose.holiday,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  int get durationDays => returnDate.difference(departureDate).inDays + 1;

  bool get isActive => status == TripStatus.active;
  bool get isArchived => status == TripStatus.archived;
  bool get isPlanned => status == TripStatus.planned;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'country': country,
      'departure_date': departureDate.toIso8601String(),
      'return_date': returnDate.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'purpose': purpose.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      name: map['name'],
      destination: map['destination'],
      country: map['country'],
      departureDate: DateTime.parse(map['departure_date']),
      returnDate: DateTime.parse(map['return_date']),
      status: TripStatus.values.firstWhere((e) => e.name == map['status'],
          orElse: () => TripStatus.planned),
      type: TripType.values.firstWhere((e) => e.name == map['type'],
          orElse: () => TripType.leisure),
      purpose: TripPurpose.values.firstWhere((e) => e.name == map['purpose'],
          orElse: () => TripPurpose.holiday),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Trip copyWith({
    String? id,
    String? name,
    String? destination,
    String? country,
    DateTime? departureDate,
    DateTime? returnDate,
    TripStatus? status,
    TripType? type,
    TripPurpose? purpose,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case TripStatus.planned: return 'Planned';
      case TripStatus.active: return 'Active';
      case TripStatus.archived: return 'Archived';
    }
  }

  String get typeLabel {
    switch (type) {
      case TripType.leisure: return 'Leisure';
      case TripType.business: return 'Business';
      case TripType.family: return 'Family';
      case TripType.adventure: return 'Adventure';
      case TripType.medical: return 'Medical';
      case TripType.other: return 'Other';
    }
  }

  String get purposeLabel {
    switch (purpose) {
      case TripPurpose.holiday: return 'Holiday';
      case TripPurpose.workTrip: return 'Work Trip';
      case TripPurpose.familyVisit: return 'Family Visit';
      case TripPurpose.conference: return 'Conference';
      case TripPurpose.medical: return 'Medical';
      case TripPurpose.other: return 'Other';
    }
  }
}
