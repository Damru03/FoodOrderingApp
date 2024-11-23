import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> initDB() async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    _database = await openDatabase(
            path,
            version: 1,
            onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE food_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              cost REAL
      )
      ''');
      await db.execute('''
      CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              items TEXT
      )
      ''');
      _populateInitialData(db);
    },
    );
    return _database!;
  }

  static Future<void> _populateInitialData(Database db) async {
    List<Map<String, dynamic>> initialFoodItems = [
    {'name': 'Pizza', 'cost': 12.99},
    {'name': 'Burger', 'cost': 8.99},
    {'name': 'Pasta', 'cost': 10.99},
    {'name': 'Salad', 'cost': 7.99},
    {'name': 'Fries', 'cost': 4.99},
    {'name': 'Soup', 'cost': 5.99},
    ];

    for (var item in initialFoodItems) {
      await db.insert('food_items', item);
    }
  }

  // Save Order
  static Future<void> saveOrder(Map<String, int> cartItems, String date) async {
    final db = await initDB();
    String items = cartItems.entries.map((e) => '${e.key}:${e.value}').join(',');
    await db.insert('orders', {'date': date, 'items': items});
  }

  // Query Orders
  static Future<List<Map<String, dynamic>>> queryOrders(String date) async {
    final db = await initDB();
    return await db.query('orders', where: 'date = ?', whereArgs: [date]);
  }

  // Update Order
  static Future<void> updateOrder(int orderId, String updatedItems) async {
    final db = await initDB();
    await db.update(
            'orders',
            {'items': updatedItems},
    where: 'id = ?',
            whereArgs: [orderId],
    );
  }

  // Delete Order
  static Future<void> deleteOrder(int orderId) async {
    final db = await initDB();
    await db.delete(
            'orders',
            where: 'id = ?',
            whereArgs: [orderId],
    );
  }
}
