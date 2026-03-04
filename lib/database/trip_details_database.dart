import 'package:uuid/uuid.dart';
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

  /// Find the task linked to a packing item (source == packing).
  Future<TripTask?> getTaskForPackingItem(String packingItemId) async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'source = ? AND source_id = ?',
      whereArgs: ['packing', packingItemId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TripTask.fromMap(rows.first);
  }

  /// Find all packing-sourced tasks for a trip.
  Future<List<TripTask>> getPackingTasks(String tripId) async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'trip_id = ? AND source = ?',
      whereArgs: [tripId, 'packing'],
      orderBy: 'created_at ASC',
    );
    return rows.map((r) => TripTask.fromMap(r)).toList();
  }

  /// Create a task linked to a packing item, or update it if one already exists.
  Future<TripTask> upsertPackingTask({
    required String tripId,
    required String packingItemId,
    required String itemName,
  }) async {
    final existing = await getTaskForPackingItem(packingItemId);
    if (existing != null) {
      // Update name in case it was renamed
      final updated = existing.copyWith(name: itemName);
      await updateTask(updated);
      return updated;
    }
    final task = TripTask(
      id: const Uuid().v4(),
      tripId: tripId,
      name: itemName,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      source: TaskSource.packing,
      sourceId: packingItemId,
    );
    await insertTask(task);
    return task;
  }

  /// Sync packing item packed status → linked task status.
  /// packed = true  →  task done
  /// packed = false →  task pending
  Future<void> syncTaskFromPacking(String packingItemId, bool isPacked) async {
    final task = await getTaskForPackingItem(packingItemId);
    if (task == null) return;
    final newStatus = isPacked ? TaskStatus.done : TaskStatus.pending;
    await setTaskStatus(task.id, newStatus);
  }

  /// Sync task done status → linked packing item packed status.
  Future<void> syncPackingFromTask(String packingItemId, bool isDone) async {
    final db = await database;
    await db.update(
      'packing_items',
      {'status': isDone ? 'packed' : 'notPacked'},
      where: 'id = ?',
      whereArgs: [packingItemId],
    );
  }

  /// Delete the task linked to a packing item (called when packing item is deleted).
  Future<void> deleteTaskForPackingItem(String packingItemId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'source = ? AND source_id = ?',
      whereArgs: ['packing', packingItemId],
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
