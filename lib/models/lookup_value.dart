/// Categories of lookup lists that are user-customizable.
enum LookupCategory {
  tripType,
  tripPurpose,
  packingCategory,
  storageLocation,
  packingAction,
}

extension LookupCategoryX on LookupCategory {
  String get key {
    switch (this) {
      case LookupCategory.tripType:         return 'trip_type';
      case LookupCategory.tripPurpose:      return 'trip_purpose';
      case LookupCategory.packingCategory:  return 'packing_category';
      case LookupCategory.storageLocation:  return 'storage_location';
      case LookupCategory.packingAction:      return 'packing_action';
    }
  }

  static LookupCategory fromKey(String key) {
    switch (key) {
      case 'trip_type':         return LookupCategory.tripType;
      case 'trip_purpose':      return LookupCategory.tripPurpose;
      case 'packing_category':  return LookupCategory.packingCategory;
      case 'storage_location':  return LookupCategory.storageLocation;
      case 'packing_action':     return LookupCategory.packingAction;
      default: throw ArgumentError('Unknown LookupCategory key: $key');
    }
  }
}

/// A single value in a user-customizable dropdown list.
class LookupValue {
  final String id;
  final LookupCategory category;

  /// Stable machine key for default values (e.g. 'leisure').
  /// Null for user-added custom values.
  final String? valueKey;

  final String displayEn;
  final String displayHe;

  /// True for values seeded from the original hardcoded lists.
  /// Default values can be disabled but not deleted.
  final bool isDefault;

  /// Whether this value appears in dropdowns.
  bool isEnabled;

  int displayOrder;

  LookupValue({
    required this.id,
    required this.category,
    this.valueKey,
    required this.displayEn,
    required this.displayHe,
    this.isDefault = false,
    this.isEnabled = true,
    required this.displayOrder,
  });

  /// Localized display label.
  String label(String languageCode) {
    switch (languageCode) {
      case 'he': return displayHe.isNotEmpty ? displayHe : displayEn;
      default:   return displayEn;
    }
  }

  Map<String, dynamic> toMap() => {
    'id':            id,
    'category':      category.key,
    'value_key':     valueKey,
    'display_en':    displayEn,
    'display_he':    displayHe,
    'is_default':    isDefault ? 1 : 0,
    'is_enabled':    isEnabled ? 1 : 0,
    'display_order': displayOrder,
  };

  factory LookupValue.fromMap(Map<String, dynamic> map) => LookupValue(
    id:           map['id'] as String,
    category:     LookupCategoryX.fromKey(map['category'] as String),
    valueKey:     map['value_key'] as String?,
    displayEn:    map['display_en'] as String,
    displayHe:    map['display_he'] as String? ?? '',
    isDefault:    (map['is_default'] as int) == 1,
    isEnabled:    (map['is_enabled'] as int) == 1,
    displayOrder: map['display_order'] as int,
  );

  LookupValue copyWith({
    String? displayEn,
    String? displayHe,
    bool? isEnabled,
    int? displayOrder,
  }) => LookupValue(
    id:           id,
    category:     category,
    valueKey:     valueKey,
    displayEn:    displayEn ?? this.displayEn,
    displayHe:    displayHe ?? this.displayHe,
    isDefault:    isDefault,
    isEnabled:    isEnabled ?? this.isEnabled,
    displayOrder: displayOrder ?? this.displayOrder,
  );
}
