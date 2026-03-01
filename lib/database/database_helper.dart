import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trip.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tripready.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        destination TEXT NOT NULL,
        country TEXT,
        departure_date TEXT NOT NULL,
        return_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'planned',
        type TEXT NOT NULL DEFAULT 'leisure',
        purpose TEXT NOT NULL DEFAULT 'holiday',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE packing_items (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        storage_place TEXT,
        status TEXT NOT NULL DEFAULT 'not_packed',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE packing_item_tasks (
        id TEXT PRIMARY KEY,
        packing_item_id TEXT NOT NULL,
        trip_id TEXT NOT NULL,
        description TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (packing_item_id) REFERENCES packing_items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE packing_templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE packing_template_items (
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        storage_place TEXT,
        FOREIGN KEY (template_id) REFERENCES packing_templates (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        due_date TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        category TEXT,
        map_link TEXT,
        website TEXT,
        phone TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE receipts (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        date TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'USD',
        exchange_rate REAL NOT NULL DEFAULT 1,
        notes TEXT,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        file_path TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== TRIPS ====================

  Future<String> insertTrip(Trip trip) async {
    final db = await database;
    // If new trip is set to active, deactivate all others first
    if (trip.status == TripStatus.active) {
      await db.update(
        'trips',
        {'status': 'planned'},
        where: 'status = ?',
        whereArgs: ['active'],
      );
    }
    await db.insert('trips', trip.toMap());
    return trip.id;
  }

  Future<List<Trip>> getAllTrips() async {
    final db = await database;
    final result = await db.query('trips', orderBy: 'departure_date ASC');
    return result.map((map) => Trip.fromMap(map)).toList();
  }

  Future<Trip?> getActiveTrip() async {
    final db = await database;
    final result = await db.query(
      'trips',
      where: 'status = ?',
      whereArgs: ['active'],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Trip.fromMap(result.first);
  }

  Future<Trip?> getTripById(String id) async {
    final db = await database;
    final result = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Trip.fromMap(result.first);
  }

  Future<void> updateTrip(Trip trip) async {
    final db = await database;
    if (trip.status == TripStatus.active) {
      await db.update(
        'trips',
        {'status': 'planned'},
        where: 'status = ? AND id != ?',
        whereArgs: ['active', trip.id],
      );
    }
    await db.update('trips', trip.toMap(), where: 'id = ?', whereArgs: [trip.id]);
  }

  Future<void> setTripActive(String tripId) async {
    final db = await database;
    await db.update('trips', {'status': 'planned'}, where: 'status = ?', whereArgs: ['active']);
    await db.update(
      'trips',
      {'status': 'active', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  /// Wipes every table and re-creates the schema — full factory reset.
  Future<void> resetAllData() async {
    final db = await database;
    const tables = [
      'packing_item_tasks',
      'packing_template_items',
      'packing_items',
      'packing_templates',
      'tasks',
      'addresses',
      'receipts',
      'documents',
      'trips',
    ];
    await db.transaction((txn) async {
      for (final table in tables) {
        await txn.delete(table);
      }
    });
  }

  Future<void> archiveTrip(String tripId) async {
    final db = await database;
    await db.update(
      'trips',
      {'status': 'archived', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  Future<void> deleteTrip(String tripId) async {
    final db = await database;
    await db.delete('trips', where: 'id = ?', whereArgs: [tripId]);
  }

  // ==================== TRIP STATS ====================

  Future<Map<String, int>> getTripStats(String tripId) async {
    final db = await database;

    final packingTotal = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM packing_items WHERE trip_id = ?', [tripId])) ?? 0;
    final packingPacked = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM packing_items WHERE trip_id = ? AND status = ?', [tripId, 'packed'])) ?? 0;

    final tasksTotal = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE trip_id = ?', [tripId])) ?? 0;
    final tasksDone = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE trip_id = ? AND status = ?', [tripId, 'done'])) ?? 0;

    final addressCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM addresses WHERE trip_id = ?', [tripId])) ?? 0;

    final receiptCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM receipts WHERE trip_id = ?', [tripId])) ?? 0;

    return {
      'packing_total': packingTotal,
      'packing_packed': packingPacked,
      'tasks_total': tasksTotal,
      'tasks_done': tasksDone,
      'address_count': addressCount,
      'receipt_count': receiptCount,
    };
  }

  Future<double> getTripTotalExpenses(String tripId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount * exchange_rate) as total FROM receipts WHERE trip_id = ?',
      [tripId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
