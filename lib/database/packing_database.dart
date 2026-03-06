import 'package:sqflite/sqflite.dart';
import '../services/app_notifier.dart';
import '../models/packing.dart';
import 'database_helper.dart';

extension PackingDatabase on DatabaseHelper {
  // ==================== PACKING ITEMS ====================

  Future<List<PackingItem>> getPackingItems(String tripId) async {
    final db = await database;
    final itemRows = await db.query(
      'packing_items',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'category ASC, name ASC',
    );

    final items = itemRows.map((r) => PackingItem.fromMap(r)).toList();

    // Load tasks for each item
    for (final item in items) {
      final taskRows = await db.query(
        'packing_item_tasks',
        where: 'packing_item_id = ?',
        whereArgs: [item.id],
        orderBy: 'created_at ASC',
      );
      item.tasks = taskRows.map((r) => PackingItemTask.fromMap(r)).toList();
    }

    return items;
  }

  Future<void> insertPackingItem(PackingItem item) async {
    final db = await database;
    await db.insert('packing_items', item.toMap());
     AppNotifier.instance.notify();
  }

  Future<void> updatePackingItem(PackingItem item) async {
    final db = await database;
    await db.update(
      'packing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
     AppNotifier.instance.notify();
  }

  Future<void> deletePackingItem(String itemId) async {
    final db = await database;
    await db.delete('packing_items', where: 'id = ?', whereArgs: [itemId]);
     AppNotifier.instance.notify();
  }

  Future<void> togglePackingItemStatus(PackingItem item) async {
    final db = await database;
    final newStatus = item.isPacked ? 'not_packed' : 'packed';
    await db.update(
      'packing_items',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [item.id],
    );
    AppNotifier.instance.notify();
  }

  // ==================== PACKING ITEM TASKS ====================

  Future<void> insertPackingItemTask(PackingItemTask task) async {
    final db = await database;
    await db.insert('packing_item_tasks', task.toMap());
     AppNotifier.instance.notify();
  }

  Future<void> updatePackingItemTask(PackingItemTask task) async {
    final db = await database;
    await db.update(
      'packing_item_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
     AppNotifier.instance.notify();
  }

  Future<void> togglePackingTaskDone(PackingItemTask task) async {
    final db = await database;
    await db.update(
      'packing_item_tasks',
      {'is_done': task.isDone ? 0 : 1},
      where: 'id = ?',
      whereArgs: [task.id],
    );
    AppNotifier.instance.notify();
  }

  Future<void> deletePackingItemTask(String taskId) async {
    final db = await database;
    await db.delete('packing_item_tasks', where: 'id = ?', whereArgs: [taskId]);
     AppNotifier.instance.notify();
  }

  // ==================== TEMPLATES ====================

  Future<List<PackingTemplate>> getPackingTemplates() async {
    final db = await database;
    final rows = await db.query('packing_templates', orderBy: 'name ASC');
    final templates = rows.map((r) => PackingTemplate.fromMap(r)).toList();

    for (final tmpl in templates) {
      final itemRows = await db.query(
        'packing_template_items',
        where: 'template_id = ?',
        whereArgs: [tmpl.id],
        orderBy: 'category ASC, name ASC',
      );
      tmpl.items = itemRows.map((r) => PackingTemplateItem.fromMap(r)).toList();
    }

    return templates;
  }

  Future<void> savePackingTemplate(PackingTemplate template) async {
    final db = await database;
    await db.insert('packing_templates', template.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (final item in template.items) {
      await db.insert('packing_template_items', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    AppNotifier.instance.notify();
  }

  Future<void> deletePackingTemplate(String templateId) async {
    final db = await database;
    await db.delete('packing_templates', where: 'id = ?', whereArgs: [templateId]);
     AppNotifier.instance.notify();
  }

  Future<void> loadTemplateIntoTrip(String templateId, String tripId) async {
    final db = await database;
    final itemRows = await db.query(
      'packing_template_items',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );

    final now = DateTime.now().toIso8601String();
    for (final row in itemRows) {
      final newId = '${tripId}_${row['name']}_${DateTime.now().microsecondsSinceEpoch}';
      await db.insert('packing_items', {
        'id': newId,
        'trip_id': tripId,
        'name': row['name'],
        'category': row['category'],
        'quantity': row['quantity'],
        'storage_place': row['storage_place'],
        'status': 'not_packed',
        'notes': null,
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
