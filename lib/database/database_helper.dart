import 'package:sqflite/sqflite.dart';
import '../services/app_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';
import '../models/trip.dart';
import '../models/lookup_value.dart';

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
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        destination TEXT NOT NULL,
        country TEXT,
        return_destination TEXT,
        return_country TEXT,
        stops TEXT,
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
        source TEXT NOT NULL DEFAULT 'task',
        source_id TEXT,
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
        expiry_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await _createLookupTable(db);
    await _seedLookupValues(db);
    await _createRemindersTable(db);
    await _createNotificationsTable(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createLookupTable(db);
      await _seedLookupValues(db);
    }
    if (oldVersion < 3) {
      // Add source tracking to tasks for packing ↔ task integration
      await db.execute(
          "ALTER TABLE tasks ADD COLUMN source TEXT NOT NULL DEFAULT 'task'");
      await db.execute(
          'ALTER TABLE tasks ADD COLUMN source_id TEXT');
    }
    if (oldVersion < 4) {
      // Seed the new packingAction lookup category
      await _seedPackingActions(db);
    }
    if (oldVersion < 5) {
      // Add destinations column (superseded by v6 stops model — kept for safety)
      await db.execute('ALTER TABLE trips ADD COLUMN destinations TEXT');
    }
    if (oldVersion < 6) {
      // Route model: stops + return destination
      await db.execute('ALTER TABLE trips ADD COLUMN return_destination TEXT');
      await db.execute('ALTER TABLE trips ADD COLUMN return_country TEXT');
      await db.execute('ALTER TABLE trips ADD COLUMN stops TEXT');
    }
    if (oldVersion < 7) {
      // Maps: lat/lng on addresses
      await db.execute('ALTER TABLE addresses ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE addresses ADD COLUMN longitude REAL');
    }
    if (oldVersion < 8) {
      await _createRemindersTable(db);
    }
    if (oldVersion < 9) {
      await _createNotificationsTable(db);
      await db.execute('ALTER TABLE documents ADD COLUMN expiry_date TEXT');
    }
  }

  Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id          TEXT PRIMARY KEY,
        ref_type    TEXT NOT NULL,
        ref_id      TEXT NOT NULL,
        stop_index  INTEGER,
        lead_days   INTEGER NOT NULL DEFAULT 1,
        time_of_day TEXT NOT NULL DEFAULT '08:00',
        is_enabled  INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_ref ON reminders (ref_type, ref_id)'
    );
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id          TEXT PRIMARY KEY,
        ref_type    TEXT NOT NULL,
        ref_id      TEXT NOT NULL,
        title       TEXT NOT NULL,
        body        TEXT NOT NULL,
        is_read     INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications (is_read)'
    );
  }


  Future<void> _createLookupTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lookup_values (
        id            TEXT PRIMARY KEY,
        category      TEXT NOT NULL,
        value_key     TEXT,
        display_en    TEXT NOT NULL,
        display_he    TEXT NOT NULL DEFAULT '',
        is_default    INTEGER NOT NULL DEFAULT 1,
        is_enabled    INTEGER NOT NULL DEFAULT 1,
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _seedLookupValues(Database db) async {
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM lookup_values')) ?? 0;
    if (count > 0) return;

    const seeds = [
      // Trip Type
      ('trip_type', 'leisure',   'Leisure',   'פנאי',           0),
      ('trip_type', 'business',  'Business',  'עסקים',          1),
      ('trip_type', 'family',    'Family',    'משפחה',          2),
      ('trip_type', 'adventure', 'Adventure', 'הרפתקה',         3),
      ('trip_type', 'medical',   'Medical',   'רפואי',          4),
      ('trip_type', 'other',     'Other',     'אחר',            5),
      // Trip Purpose
      ('trip_purpose', 'holiday',      'Holiday',       'חופשה',          0),
      ('trip_purpose', 'work_trip',    'Work Trip',     'נסיעת עבודה',    1),
      ('trip_purpose', 'family_visit', 'Family Visit',  'ביקור משפחה',    2),
      ('trip_purpose', 'conference',   'Conference',    'כנס',            3),
      ('trip_purpose', 'medical',      'Medical',       'מסיבות רפואיות', 4),
      ('trip_purpose', 'other',        'Other',         'אחר',            5),
      // Packing Category
      ('packing_category', 'clothing',      'Clothing',        'ביגוד',         0),
      ('packing_category', 'toiletries',    'Toiletries',      'טיפוח',         1),
      ('packing_category', 'electronics',   'Electronics',     'אלקטרוניקה',    2),
      ('packing_category', 'documents',     'Documents',       'מסמכים',        3),
      ('packing_category', 'medication',    'Medication',      'תרופות',        4),
      ('packing_category', 'food_snacks',   'Food & Snacks',   'אוכל וחטיפים',  5),
      ('packing_category', 'accessories',   'Accessories',     'אביזרים',       6),
      ('packing_category', 'sport_outdoor', 'Sport & Outdoor', 'ספורט וטבע',    7),
      ('packing_category', 'baby_kids',     'Baby & Kids',     'תינוק וילדים',  8),
      ('packing_category', 'work_office',   'Work & Office',   'עבודה ומשרד',   9),
      ('packing_category', 'other',         'Other',           'אחר',           10),
      // Storage Location
      ('storage_location', 'checkin',      'Check-in Luggage', 'מזוודה לטעינה', 0),
      ('storage_location', 'hand_luggage', 'Hand Luggage',     'כבודת יד',      1),
      ('storage_location', 'backpack',     'Backpack',         'תיק גב',        2),
      ('storage_location', 'toiletry_bag', 'Toiletry Bag',     'תיק טיפוח',     3),
      ('storage_location', 'laptop_bag',   'Laptop Bag',       'תיק מחשב',      4),
      ('storage_location', 'handbag',      'Handbag / Purse',  'תיק יד',        5),
      ('storage_location', 'wallet',       'Wallet',           'ארנק',          6),
      ('storage_location', 'money_belt',   'Money Belt',       'חגורת כסף',     7),
      ('storage_location', 'car_boot',     'Car Boot',         'תא מטען',       8),
      ('storage_location', 'shipping_box', 'Shipping Box',     'קופסת משלוח',   9),
      ('storage_location', 'other',        'Other',            'אחר',           10),
      // Packing Action
      ('packing_action', 'buy',       'Buy',       'לקנות',    0),
      ('packing_action', 'clean',     'Clean',     'לנקות',    1),
      ('packing_action', 'retrieve',  'Retrieve',  'להביא',    2),
      ('packing_action', 'print',     'Print',     'להדפיס',   3),
      ('packing_action', 'charge',    'Charge',    'לטעון',    4),
      ('packing_action', 'repair',    'Repair',    'לתקן',     5),
      ('packing_action', 'pack',      'Pack',      'לארוז',    6),
      ('packing_action', 'iron',      'Iron',      'לגהץ',     7),
      ('packing_action', 'borrow',    'Borrow',    'לשאול',    8),
      ('packing_action', 'other',     'Other',     'אחר',      9),
    ];

    const uuid = Uuid();
    final batch = db.batch();
    for (final (cat, key, en, he, order) in seeds) {
      batch.insert('lookup_values', {
        'id':            uuid.v4(),
        'category':      cat,
        'value_key':     key,
        'display_en':    en,
        'display_he':    he,
        'is_default':    1,
        'is_enabled':    1,
        'display_order': order,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedPackingActions(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM lookup_values WHERE category = 'packing_action'")) ?? 0;
    if (count > 0) return;
    const actions = [
      ('buy',      'Buy',      'לקנות',   0),
      ('clean',    'Clean',    'לנקות',   1),
      ('retrieve', 'Retrieve', 'להביא',   2),
      ('print',    'Print',    'להדפיס',  3),
      ('charge',   'Charge',   'לטעון',   4),
      ('repair',   'Repair',   'לתקן',    5),
      ('pack',     'Pack',     'לארוז',   6),
      ('iron',     'Iron',     'לגהץ',    7),
      ('borrow',   'Borrow',   'לשאול',   8),
      ('other',    'Other',    'אחר',     9),
    ];
    const uuid = Uuid();
    final batch = db.batch();
    for (final (key, en, he, order) in actions) {
      batch.insert('lookup_values', {
        'id':            uuid.v4(),
        'category':      'packing_action',
        'value_key':     key,
        'display_en':    en,
        'display_he':    he,
        'is_default':    1,
        'is_enabled':    1,
        'display_order': order,
      });
    }
    await batch.commit(noResult: true);
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
     AppNotifier.instance.notify();
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
     AppNotifier.instance.notify();
  }

  Future<void> setTripPlanned(String tripId) async {
    final db = await database;
    await db.update(
      'trips',
      {'status': 'planned', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [tripId],
    );
    AppNotifier.instance.notify();
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
     AppNotifier.instance.notify();
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
      'reminders',
      'notifications',
      'trips',
      'lookup_values',
      'reminders',
      'notifications',
    ];
    await db.transaction((txn) async {
      for (final table in tables) {
        await txn.delete(table);
      }
    });
     AppNotifier.instance.notify();
  }

  Future<void> archiveTrip(String tripId) async {
    final db = await database;
    await db.update(
      'trips',
      {'status': 'archived', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [tripId],
    );
     AppNotifier.instance.notify();
  }

  Future<void> deleteTrip(String tripId) async {
    final db = await database;
    await db.delete('trips', where: 'id = ?', whereArgs: [tripId]);
     AppNotifier.instance.notify();
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

    final documentCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM documents WHERE trip_id = ?', [tripId])) ?? 0;

    return {
      'packing_total': packingTotal,
      'packing_packed': packingPacked,
      'tasks_total': tasksTotal,
      'tasks_done': tasksDone,
      'address_count': addressCount,
      'receipt_count': receiptCount,
      'document_count': documentCount,
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
