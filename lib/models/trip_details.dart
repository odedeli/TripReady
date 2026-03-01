// ── Task ─────────────────────────────────────────────────────

enum TaskStatus { pending, inProgress, done }

class TripTask {
  final String id;
  final String tripId;
  final String name;
  final DateTime? dueDate;
  final TaskStatus status;
  final String? notes;
  final DateTime createdAt;

  TripTask({
    required this.id,
    required this.tripId,
    required this.name,
    this.dueDate,
    this.status = TaskStatus.pending,
    this.notes,
    required this.createdAt,
  });

  bool get isDone => status == TaskStatus.done;

  String get statusLabel {
    switch (status) {
      case TaskStatus.pending: return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.done: return 'Done';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'trip_id': tripId,
    'name': name,
    'due_date': dueDate?.toIso8601String(),
    'status': status.name,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory TripTask.fromMap(Map<String, dynamic> map) => TripTask(
    id: map['id'],
    tripId: map['trip_id'],
    name: map['name'],
    dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    status: TaskStatus.values.firstWhere(
      (e) => e.name == map['status'],
      orElse: () => TaskStatus.pending,
    ),
    notes: map['notes'],
    createdAt: DateTime.parse(map['created_at']),
  );

  TripTask copyWith({
    String? id,
    String? tripId,
    String? name,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskStatus? status,
    String? notes,
    DateTime? createdAt,
  }) => TripTask(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    status: status ?? this.status,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
}

// ── Address ───────────────────────────────────────────────────

enum AddressCategory {
  hotel,
  airport,
  restaurant,
  landmark,
  office,
  hospital,
  transport,
  shopping,
  other,
}

class TripAddress {
  final String id;
  final String tripId;
  final String name;
  final String? address;
  final AddressCategory category;
  final String? mapLink;
  final String? website;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  TripAddress({
    required this.id,
    required this.tripId,
    required this.name,
    this.address,
    this.category = AddressCategory.other,
    this.mapLink,
    this.website,
    this.phone,
    this.notes,
    required this.createdAt,
  });

  String get categoryLabel {
    switch (category) {
      case AddressCategory.hotel: return 'Hotel';
      case AddressCategory.airport: return 'Airport';
      case AddressCategory.restaurant: return 'Restaurant';
      case AddressCategory.landmark: return 'Landmark';
      case AddressCategory.office: return 'Office';
      case AddressCategory.hospital: return 'Hospital';
      case AddressCategory.transport: return 'Transport';
      case AddressCategory.shopping: return 'Shopping';
      case AddressCategory.other: return 'Other';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'trip_id': tripId,
    'name': name,
    'address': address,
    'category': category.name,
    'map_link': mapLink,
    'website': website,
    'phone': phone,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory TripAddress.fromMap(Map<String, dynamic> map) => TripAddress(
    id: map['id'],
    tripId: map['trip_id'],
    name: map['name'],
    address: map['address'],
    category: AddressCategory.values.firstWhere(
      (e) => e.name == map['category'],
      orElse: () => AddressCategory.other,
    ),
    mapLink: map['map_link'],
    website: map['website'],
    phone: map['phone'],
    notes: map['notes'],
    createdAt: DateTime.parse(map['created_at']),
  );

  TripAddress copyWith({
    String? id,
    String? tripId,
    String? name,
    String? address,
    AddressCategory? category,
    String? mapLink,
    String? website,
    String? phone,
    String? notes,
    DateTime? createdAt,
  }) => TripAddress(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    address: address ?? this.address,
    category: category ?? this.category,
    mapLink: mapLink ?? this.mapLink,
    website: website ?? this.website,
    phone: phone ?? this.phone,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
}

// ── Document ──────────────────────────────────────────────────

enum DocumentType {
  ticket,
  voucher,
  letter,
  passport,
  visa,
  insurance,
  reservation,
  itinerary,
  other,
}

class TripDocument {
  final String id;
  final String tripId;
  final String name;
  final DocumentType type;
  final String? filePath;
  final String? notes;
  final DateTime createdAt;

  TripDocument({
    required this.id,
    required this.tripId,
    required this.name,
    this.type = DocumentType.other,
    this.filePath,
    this.notes,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case DocumentType.ticket: return 'Ticket';
      case DocumentType.voucher: return 'Voucher';
      case DocumentType.letter: return 'Letter';
      case DocumentType.passport: return 'Passport';
      case DocumentType.visa: return 'Visa';
      case DocumentType.insurance: return 'Insurance';
      case DocumentType.reservation: return 'Reservation';
      case DocumentType.itinerary: return 'Itinerary';
      case DocumentType.other: return 'Other';
    }
  }

  bool get hasFile => filePath != null && filePath!.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'id': id,
    'trip_id': tripId,
    'name': name,
    'type': type.name,
    'file_path': filePath,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory TripDocument.fromMap(Map<String, dynamic> map) => TripDocument(
    id: map['id'],
    tripId: map['trip_id'],
    name: map['name'],
    type: DocumentType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => DocumentType.other,
    ),
    filePath: map['file_path'],
    notes: map['notes'],
    createdAt: DateTime.parse(map['created_at']),
  );

  TripDocument copyWith({
    String? id,
    String? tripId,
    String? name,
    DocumentType? type,
    String? filePath,
    String? notes,
    DateTime? createdAt,
  }) => TripDocument(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    type: type ?? this.type,
    filePath: filePath ?? this.filePath,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
}
