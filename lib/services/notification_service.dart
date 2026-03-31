import '../database/database_helper.dart';
import '../models/app_notification.dart';
import '../models/reminder.dart';
import 'reminder_service.dart';

/// Manages the in-app Notification Center (EP02).
/// EP04 trigger engine will call [create] when reminders fire.
/// Until EP04: use [seedFromReminders] via Settings → Developer Tools.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  Future<AppNotification> create({
    required ReminderRefType refType,
    required String refId,
    required String title,
    required String body,
  }) async {
    final n = AppNotification(
      id:        AppNotification.newId(),
      refType:   refType,
      refId:     refId,
      title:     title,
      body:      body,
      isRead:    false,
      createdAt: DateTime.now(),
    );
    final db = await DatabaseHelper.instance.database;
    await db.insert('notifications', n.toMap());
    return n;
  }

  Future<List<AppNotification>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('notifications', orderBy: 'created_at DESC');
    return rows.map(AppNotification.fromMap).toList();
  }

  Future<int> unreadCount() async {
    final db = await DatabaseHelper.instance.database;
    final r = await db.rawQuery(
        'SELECT COUNT(*) as c FROM notifications WHERE is_read = 0');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<void> markRead(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('notifications', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllRead() async {
    final db = await DatabaseHelper.instance.database;
    await db.update('notifications', {'is_read': 1}, where: 'is_read = 0');
  }

  Future<void> dismiss(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('notifications');
  }

  /// Dev helper: seeds one notification per active reminder.
  /// Remove / gate with kDebugMode once EP04 trigger engine is complete.
  Future<int> seedFromReminders() async {
    final reminders = await ReminderService.instance.getAllActive();
    int count = 0;
    for (final r in reminders) {
      await create(
        refType: r.refType,
        refId:   r.refId,
        title:   '${_label(r.refType)} reminder',
        body:    '${r.leadDays} day${r.leadDays == 1 ? '' : 's'} before · at ${r.timeOfDay}',
      );
      count++;
    }
    return count;
  }

  String _label(ReminderRefType t) {
    switch (t) {
      case ReminderRefType.trip:     return 'Trip';
      case ReminderRefType.tripStop: return 'Leg';
      case ReminderRefType.task:     return 'Task';
      case ReminderRefType.document: return 'Document';
      case ReminderRefType.packing:  return 'Packing';
    }
  }
}
