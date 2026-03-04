import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/lookup_value.dart';
import '../database/database_helper.dart';

/// Singleton service for user-customizable dropdown lists.
///
/// Call [load()] once at app startup (after DatabaseHelper is ready).
/// Listen with [addListener] for rebuild notifications on any change.
///
/// Usage:
///   final values = LookupService.instance.enabled(LookupCategory.tripType);
class LookupService extends ChangeNotifier {
  static final LookupService instance = LookupService._();
  LookupService._();

  // In-memory cache per category
  final Map<LookupCategory, List<LookupValue>> _cache = {};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ── Bootstrap ──────────────────────────────────────────────────

  Future<void> load() async {
    for (final cat in LookupCategory.values) {
      _cache[cat] = await _fetchCategory(cat);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<List<LookupValue>> _fetchCategory(LookupCategory cat) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'lookup_values',
      where: 'category = ?',
      whereArgs: [cat.key],
      orderBy: 'display_order ASC, display_en ASC',
    );
    return rows.map(LookupValue.fromMap).toList();
  }

  // ── Read ───────────────────────────────────────────────────────

  /// All values for a category (enabled + disabled).
  List<LookupValue> all(LookupCategory cat) =>
      List.unmodifiable(_cache[cat] ?? []);

  /// Only enabled values — use this to populate dropdowns.
  List<LookupValue> enabled(LookupCategory cat) =>
      (_cache[cat] ?? []).where((v) => v.isEnabled).toList();

  /// Find a value by its stable [valueKey] (for resolving legacy enum strings).
  LookupValue? byKey(LookupCategory cat, String valueKey) {
    try {
      return (_cache[cat] ?? [])
          .firstWhere((v) => v.valueKey == valueKey);
    } catch (_) {
      return null;
    }
  }

  /// Find a value by its [id].
  LookupValue? byId(LookupCategory cat, String id) {
    try {
      return (_cache[cat] ?? []).firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Resolve a stored trip field (may be a valueKey like 'leisure' OR
  /// a legacy localized string like 'Leisure') to a [LookupValue].
  /// Falls back to the first enabled value if nothing matches.
  LookupValue? resolve(LookupCategory cat, String? stored) {
    if (stored == null) return null;
    final all_ = _cache[cat] ?? [];
    // Try valueKey match first (new storage format)
    try {
      return all_.firstWhere((v) => v.valueKey == stored);
    } catch (_) {}
    // Try display_en match (legacy storage)
    try {
      return all_.firstWhere(
          (v) => v.displayEn.toLowerCase() == stored.toLowerCase());
    } catch (_) {}
    return null;
  }

  // ── Write ──────────────────────────────────────────────────────

  /// Toggle a value's enabled state.
  /// Default values can be disabled but not deleted.
  Future<void> toggleEnabled(LookupValue value) async {
    final db = await DatabaseHelper.instance.database;
    final updated = value.copyWith(isEnabled: !value.isEnabled);
    await db.update(
      'lookup_values',
      {'is_enabled': updated.isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [value.id],
    );
    _updateCache(updated);
    notifyListeners();
  }

  /// Rename the display label(s) of a value.
  Future<void> rename(LookupValue value,
      {required String displayEn, required String displayHe}) async {
    final db = await DatabaseHelper.instance.database;
    final updated = value.copyWith(
        displayEn: displayEn.trim(), displayHe: displayHe.trim());
    await db.update(
      'lookup_values',
      {'display_en': updated.displayEn, 'display_he': updated.displayHe},
      where: 'id = ?',
      whereArgs: [value.id],
    );
    _updateCache(updated);
    notifyListeners();
  }

  /// Add a brand-new custom value to a category.
  Future<LookupValue> add(LookupCategory cat,
      {required String displayEn, required String displayHe}) async {
    final db = await DatabaseHelper.instance.database;
    final existing = _cache[cat] ?? [];
    final nextOrder = existing.isEmpty
        ? 100
        : existing.map((v) => v.displayOrder).reduce((a, b) => a > b ? a : b) + 1;

    final value = LookupValue(
      id:           const Uuid().v4(),
      category:     cat,
      valueKey:     null, // custom — no stable key
      displayEn:    displayEn.trim(),
      displayHe:    displayHe.trim(),
      isDefault:    false,
      isEnabled:    true,
      displayOrder: nextOrder,
    );
    await db.insert('lookup_values', value.toMap());
    _cache[cat] = [...existing, value];
    notifyListeners();
    return value;
  }

  /// Permanently delete a custom (non-default) value.
  Future<void> delete(LookupValue value) async {
    assert(!value.isDefault, 'Cannot delete default lookup values');
    final db = await DatabaseHelper.instance.database;
    await db.delete('lookup_values',
        where: 'id = ?', whereArgs: [value.id]);
    _cache[value.category] =
        (_cache[value.category] ?? []).where((v) => v.id != value.id).toList();
    notifyListeners();
  }

  /// Reorder values within a category.
  Future<void> reorder(LookupCategory cat, int oldIndex, int newIndex) async {
    final list = List<LookupValue>.from(_cache[cat] ?? []);
    if (oldIndex < newIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(displayOrder: i);
      batch.update('lookup_values', {'display_order': i},
          where: 'id = ?', whereArgs: [list[i].id]);
    }
    await batch.commit(noResult: true);
    _cache[cat] = list;
    notifyListeners();
  }

  void _updateCache(LookupValue updated) {
    final list = _cache[updated.category] ?? [];
    final idx = list.indexWhere((v) => v.id == updated.id);
    if (idx >= 0) {
      final newList = List<LookupValue>.from(list);
      newList[idx] = updated;
      _cache[updated.category] = newList;
    }
  }
}
