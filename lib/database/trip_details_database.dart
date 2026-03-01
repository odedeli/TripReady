import '../models/trip_details.dart';
import 'database_helper.dart';

extension TripDetailsDatabase on DatabaseHelper {

  // ==================== TASKS ====================

  Future<List<TripTask>> getTasks(String tripId) async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'due_date ASC, created_at ASC',
    );
    return rows.map((r) => TripTask.fromMap(r)).toList();
  }

  Future<void> insertTask(TripTask task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(TripTask task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<void> setTaskStatus(String taskId, TaskStatus status) async {
    final db = await database;
    await db.update(
      'tasks',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ==================== ADDRESSES ====================

  Future<List<TripAddress>> getAddresses(String tripId) async {
    final db = await database;
    final rows = await db.query(
      'addresses',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'category ASC, name ASC',
    );
    return rows.map((r) => TripAddress.fromMap(r)).toList();
  }

  Future<void> insertAddress(TripAddress address) async {
    final db = await database;
    await db.insert('addresses', address.toMap());
  }

  Future<void> updateAddress(TripAddress address) async {
    final db = await database;
    await db.update('addresses', address.toMap(),
        where: 'id = ?', whereArgs: [address.id]);
  }

  Future<void> deleteAddress(String addressId) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [addressId]);
  }

  // ==================== DOCUMENTS ====================

  Future<List<TripDocument>> getDocuments(String tripId) async {
    final db = await database;
    final rows = await db.query(
      'documents',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'type ASC, name ASC',
    );
    return rows.map((r) => TripDocument.fromMap(r)).toList();
  }

  Future<void> insertDocument(TripDocument doc) async {
    final db = await database;
    await db.insert('documents', doc.toMap());
  }

  Future<void> updateDocument(TripDocument doc) async {
    final db = await database;
    await db.update('documents', doc.toMap(),
        where: 'id = ?', whereArgs: [doc.id]);
  }

  Future<void> deleteDocument(String docId) async {
    final db = await database;
    await db.delete('documents', where: 'id = ?', whereArgs: [docId]);
  }
}
