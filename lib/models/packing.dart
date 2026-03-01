enum PackingStatus { notPacked, packed }

class PackingItem {
  final String id;
  final String tripId;
  final String name;
  final String? category;
  final int quantity;
  final String? storagePlace;
  final PackingStatus status;
  final String? notes;
  final DateTime createdAt;
  List<PackingItemTask> tasks;

  PackingItem({
    required this.id,
    required this.tripId,
    required this.name,
    this.category,
    this.quantity = 1,
    this.storagePlace,
    this.status = PackingStatus.notPacked,
    this.notes,
    required this.createdAt,
    this.tasks = const [],
  });

  bool get isPacked => status == PackingStatus.packed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'storage_place': storagePlace,
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PackingItem.fromMap(Map<String, dynamic> map) {
    return PackingItem(
      id: map['id'],
      tripId: map['trip_id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'] ?? 1,
      storagePlace: map['storage_place'],
      status: PackingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PackingStatus.notPacked,
      ),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  PackingItem copyWith({
    String? id,
    String? tripId,
    String? name,
    String? category,
    int? quantity,
    String? storagePlace,
    PackingStatus? status,
    String? notes,
    DateTime? createdAt,
    List<PackingItemTask>? tasks,
  }) {
    return PackingItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      storagePlace: storagePlace ?? this.storagePlace,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
    );
  }
}

class PackingItemTask {
  final String id;
  final String packingItemId;
  final String tripId;
  final String description;
  final bool isDone;
  final DateTime createdAt;

  PackingItemTask({
    required this.id,
    required this.packingItemId,
    required this.tripId,
    required this.description,
    this.isDone = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packing_item_id': packingItemId,
      'trip_id': tripId,
      'description': description,
      'is_done': isDone ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PackingItemTask.fromMap(Map<String, dynamic> map) {
    return PackingItemTask(
      id: map['id'],
      packingItemId: map['packing_item_id'],
      tripId: map['trip_id'],
      description: map['description'],
      isDone: map['is_done'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  PackingItemTask copyWith({
    String? id,
    String? packingItemId,
    String? tripId,
    String? description,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return PackingItemTask(
      id: id ?? this.id,
      packingItemId: packingItemId ?? this.packingItemId,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PackingTemplate {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  List<PackingTemplateItem> items;

  PackingTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PackingTemplate.fromMap(Map<String, dynamic> map) {
    return PackingTemplate(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class PackingTemplateItem {
  final String id;
  final String templateId;
  final String name;
  final String? category;
  final int quantity;
  final String? storagePlace;

  PackingTemplateItem({
    required this.id,
    required this.templateId,
    required this.name,
    this.category,
    this.quantity = 1,
    this.storagePlace,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'storage_place': storagePlace,
    };
  }

  factory PackingTemplateItem.fromMap(Map<String, dynamic> map) {
    return PackingTemplateItem(
      id: map['id'],
      templateId: map['template_id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'] ?? 1,
      storagePlace: map['storage_place'],
    );
  }
}
