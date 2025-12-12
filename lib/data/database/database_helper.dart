import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restaurant_billing/core/constants/db_constants.dart';

// Database version 3: Added tax_enabled to restaurants table

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create restaurants table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableRestaurants} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnRestaurantName} TEXT NOT NULL,
        ${DbConstants.columnRestaurantCode} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnRestaurantEmail} TEXT,
        ${DbConstants.columnRestaurantPhone} TEXT,
        ${DbConstants.columnRestaurantAddress} TEXT,
        ${DbConstants.columnRestaurantLogoPath} TEXT,
        ${DbConstants.columnRestaurantTaxPercentage} REAL DEFAULT 10.0,
        ${DbConstants.columnRestaurantTaxEnabled} INTEGER DEFAULT 1,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL
      )
    ''');

    // Create tables table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableTables} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnTableNumber} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnTableName} TEXT,
        ${DbConstants.columnTableSeats} INTEGER DEFAULT 4,
        ${DbConstants.columnTableStatus} TEXT NOT NULL DEFAULT 'available',
        ${DbConstants.columnCreatedAt} TEXT NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableCategories} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnCategoryName} TEXT NOT NULL,
        ${DbConstants.columnCategoryDisplayOrder} INTEGER DEFAULT 0,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL
      )
    ''');

    // Create menu_items table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableMenuItems} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnMenuItemCategoryId} INTEGER NOT NULL,
        ${DbConstants.columnMenuItemName} TEXT NOT NULL,
        ${DbConstants.columnMenuItemDescription} TEXT,
        ${DbConstants.columnMenuItemPrice} REAL NOT NULL,
        ${DbConstants.columnMenuItemTaxPercentage} REAL DEFAULT 10.0,
        ${DbConstants.columnMenuItemAllowDiscount} INTEGER DEFAULT 1,
        ${DbConstants.columnMenuItemImagePath} TEXT,
        ${DbConstants.columnMenuItemIsAvailable} INTEGER DEFAULT 1,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.columnMenuItemCategoryId}) 
          REFERENCES ${DbConstants.tableCategories} (${DbConstants.columnId})
          ON DELETE CASCADE
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableOrders} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnOrderNumber} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnOrderTableId} INTEGER,
        ${DbConstants.columnOrderType} TEXT NOT NULL,
        ${DbConstants.columnOrderStatus} TEXT NOT NULL DEFAULT 'open',
        ${DbConstants.columnOrderSubtotal} REAL NOT NULL DEFAULT 0.0,
        ${DbConstants.columnOrderDiscountAmount} REAL DEFAULT 0.0,
        ${DbConstants.columnOrderTaxAmount} REAL DEFAULT 0.0,
        ${DbConstants.columnOrderTotalAmount} REAL NOT NULL DEFAULT 0.0,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL,
        ${DbConstants.columnOrderCompletedAt} TEXT,
        FOREIGN KEY (${DbConstants.columnOrderTableId}) 
          REFERENCES ${DbConstants.tableTables} (${DbConstants.columnId})
          ON DELETE SET NULL
      )
    ''');

    // Create order_items table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableOrderItems} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnOrderItemOrderId} INTEGER NOT NULL,
        ${DbConstants.columnOrderItemMenuItemId} INTEGER NOT NULL,
        ${DbConstants.columnOrderItemQuantity} INTEGER NOT NULL,
        ${DbConstants.columnOrderItemUnitPrice} REAL NOT NULL,
        ${DbConstants.columnOrderItemTotalPrice} REAL NOT NULL,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.columnOrderItemOrderId}) 
          REFERENCES ${DbConstants.tableOrders} (${DbConstants.columnId})
          ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.columnOrderItemMenuItemId}) 
          REFERENCES ${DbConstants.tableMenuItems} (${DbConstants.columnId})
          ON DELETE RESTRICT
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE ${DbConstants.tablePayments} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnPaymentOrderId} INTEGER NOT NULL,
        ${DbConstants.columnPaymentMethod} TEXT NOT NULL,
        ${DbConstants.columnPaymentAmount} REAL NOT NULL,
        ${DbConstants.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.columnPaymentOrderId}) 
          REFERENCES ${DbConstants.tableOrders} (${DbConstants.columnId})
          ON DELETE CASCADE
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableSettings} (
        ${DbConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.columnSettingsKey} TEXT NOT NULL UNIQUE,
        ${DbConstants.columnSettingsValue} TEXT,
        ${DbConstants.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      {'name': 'Starters', 'display_order': 1},
      {'name': 'Main Course', 'display_order': 2},
      {'name': 'Desserts', 'display_order': 3},
      {'name': 'Drinks', 'display_order': 4},
    ];

    for (var category in categories) {
      await db.insert(
        DbConstants.tableCategories,
        {
          DbConstants.columnCategoryName: category['name'],
          DbConstants.columnCategoryDisplayOrder: category['display_order'],
          DbConstants.columnCreatedAt: DateTime.now().toIso8601String(),
        },
      );
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2 && newVersion >= 2) {
      // Migration from version 1 to 2: Add logo_path column to restaurants table
      await db.execute('''
        ALTER TABLE ${DbConstants.tableRestaurants}
        ADD COLUMN ${DbConstants.columnRestaurantLogoPath} TEXT
      ''');
    }
    
    if (oldVersion < 3 && newVersion >= 3) {
      // Migration from version 2 to 3: Add tax_enabled column to restaurants table
      await db.execute('''
        ALTER TABLE ${DbConstants.tableRestaurants}
        ADD COLUMN ${DbConstants.columnRestaurantTaxEnabled} INTEGER DEFAULT 1
      ''');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}
