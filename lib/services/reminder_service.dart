import '../database/database_helper.dart';
import '../models/reminder.dart';

class ReminderService {
  static final ReminderService instance = ReminderService._();
  ReminderService._();

  Future<Reminder> create({
    required ReminderRefType refType,
    required String refId,
    int? stopIndex,
    required int leadDays,
    required String timeOfDay,
    bool isEnabled = true,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final r = Reminder(
      id:        Reminder.newId(),
      refType:   refType,
      refId:     refId,
      stopIndex: stopIndex,
      leadDays:  leadDays,
      timeOfDay: timeOfDay,
      isEnabled: isEnabled,
      createdAt: DateTime.now(),
    );
    await db.insert('reminders', r.toMap());
    return r;
  }

  Future<List<Reminder>> getForRef(ReminderRefType refType, String refId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('reminders',
        where: 'ref_type = ? AND ref_id = ?',
        whereArgs: [refType.value, refId],
        orderBy: 'created_at ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  Future<Reminder?> getForStop(String tripId, int stopIndex) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('reminders',
        where: 'ref_type = ? AND ref_id = ? AND stop_index = ?',
        whereArgs: [ReminderRefType.tripStop.value, tripId, stopIndex],
        limit: 1);
    return rows.isEmpty ? null : Reminder.fromMap(rows.first);
  }

  Future<bool> hasActiveReminder(ReminderRefType refType, String refId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('reminders',
        where: 'ref_type = ? AND ref_id = ? AND is_enabled = 1',
        whereArgs: [refType.value, refId],
        limit: 1);
    return rows.isNotEmpty;
  }

  Future<Reminder?> getById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('reminders', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Reminder.fromMap(rows.first);
  }

  Future<void> update(Reminder reminder) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('reminders', reminder.toMap(),
        where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> setEnabled(String id, {required bool enabled}) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('reminders', {'is_enabled': enabled ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllForRef(ReminderRefType refType, String refId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('reminders',
        where: 'ref_type = ? AND ref_id = ?',
        whereArgs: [refType.value, refId]);
  }

  /// Quick-toggle from card bell.
  /// No reminder → create one with defaults (ON).
  /// Existing → flip isEnabled on all.
  Future<bool> toggleBell({
    required ReminderRefType refType,
    required String refId,
    int defaultLeadDays  = 1,
    String defaultTimeOfDay = '08:00',
  }) async {
    final existing = await getForRef(refType, refId);
    if (existing.isEmpty) {
      await create(refType: refType, refId: refId,
          leadDays: defaultLeadDays, timeOfDay: defaultTimeOfDay, isEnabled: true);
      return true;
    }
    final anyEnabled = existing.any((r) => r.isEnabled);
    for (final r in existing) {
      await setEnabled(r.id, enabled: !anyEnabled);
    }
    return !anyEnabled;
  }

  /// All active reminders — used by NotificationService seed helper.
  Future<List<Reminder>> getAllActive() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('reminders',
        where: 'is_enabled = 1', orderBy: 'created_at ASC');
    return rows.map(Reminder.fromMap).toList();
  }
}
