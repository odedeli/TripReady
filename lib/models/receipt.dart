enum ReceiptType {
  food,
  transport,
  accommodation,
  entertainment,
  shopping,
  health,
  communication,
  fees,
  other,
}

class Receipt {
  final String id;
  final String tripId;
  final String name;
  final ReceiptType type;
  final DateTime date;
  final double amount;
  final String currency;
  final double exchangeRate;
  final String? notes;
  final String? photoPath;
  final DateTime createdAt;

  Receipt({
    required this.id,
    required this.tripId,
    required this.name,
    this.type = ReceiptType.other,
    required this.date,
    required this.amount,
    this.currency = 'USD',
    this.exchangeRate = 1.0,
    this.notes,
    this.photoPath,
    required this.createdAt,
  });

  /// Amount converted to base currency using exchange rate
  double get convertedAmount => amount * exchangeRate;

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  String get typeLabel {
    switch (type) {
      case ReceiptType.food: return 'Food & Drink';
      case ReceiptType.transport: return 'Transport';
      case ReceiptType.accommodation: return 'Accommodation';
      case ReceiptType.entertainment: return 'Entertainment';
      case ReceiptType.shopping: return 'Shopping';
      case ReceiptType.health: return 'Health';
      case ReceiptType.communication: return 'Communication';
      case ReceiptType.fees: return 'Fees & Charges';
      case ReceiptType.other: return 'Other';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'trip_id': tripId,
    'name': name,
    'type': type.name,
    'date': date.toIso8601String(),
    'amount': amount,
    'currency': currency,
    'exchange_rate': exchangeRate,
    'notes': notes,
    'photo_path': photoPath,
    'created_at': createdAt.toIso8601String(),
  };

  factory Receipt.fromMap(Map<String, dynamic> map) => Receipt(
    id: map['id'],
    tripId: map['trip_id'],
    name: map['name'],
    type: ReceiptType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => ReceiptType.other,
    ),
    date: DateTime.parse(map['date']),
    amount: (map['amount'] as num).toDouble(),
    currency: map['currency'] ?? 'USD',
    exchangeRate: (map['exchange_rate'] as num?)?.toDouble() ?? 1.0,
    notes: map['notes'],
    photoPath: map['photo_path'],
    createdAt: DateTime.parse(map['created_at']),
  );

  Receipt copyWith({
    String? id,
    String? tripId,
    String? name,
    ReceiptType? type,
    DateTime? date,
    double? amount,
    String? currency,
    double? exchangeRate,
    String? notes,
    String? photoPath,
    bool clearPhoto = false,
    DateTime? createdAt,
  }) => Receipt(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    type: type ?? this.type,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    exchangeRate: exchangeRate ?? this.exchangeRate,
    notes: notes ?? this.notes,
    photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    createdAt: createdAt ?? this.createdAt,
  );
}
