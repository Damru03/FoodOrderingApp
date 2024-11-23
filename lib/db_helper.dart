import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Initialize the database
  static Future<Database> initDB() async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    print('Database Path: $path');

    _database = await openDatabase(
      path,
      version: 3, // Increment version to recreate the schema
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS orders');
          await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            items TEXT,
            total_cost REAL DEFAULT 0.0
          )
        ''');
          print('Orders table recreated.');
        }
      },
    );
    return _database!;
  }


  // Populate initial food items into the database
  static Future<void> _populateInitialData(Database db) async {
    List<Map<String, dynamic>> initialFoodItems = [
      {'name': 'Pizza', 'cost': 12.99},
      {'name': 'Burger', 'cost': 8.99},
      {'name': 'Pasta', 'cost': 10.99},
    ];

    for (var item in initialFoodItems) {
      await db.insert('food_items', item);
    }
  }

  // Fetch all food items
  static Future<List<Map<String, dynamic>>> getFoodItems() async {
    final db = await initDB();
    final results = await db.query('food_items');
    print('Fetched Food Items: $results'); // Debugging fetched food items
    return results;
  }

  // Add a new food item
  static Future<void> addFoodItem(String name, double cost) async {
    final db = await initDB();
    await db.insert('food_items', {'name': name, 'cost': cost});
    print('Food item added: $name at \$${cost}');
  }

  // Update an existing food item
  static Future<void> updateFoodItem(int id, String name, double cost) async {
    final db = await initDB();
    await db.update(
      'food_items',
      {'name': name, 'cost': cost},
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Food item updated: $name at \$${cost}');
  }

  // Delete a food item
  static Future<void> deleteFoodItem(int id) async {
    final db = await initDB();
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
    print('Food item with ID $id deleted');
  }

  // Save an order with selected food items, date, and total cost
  static Future<void> saveOrder(Map<String, int> cartItems, String date) async {
    final db = await initDB();
    double totalCost = 0.0;

    // Debugging cartItems
    print('Cart items being saved: $cartItems');

    for (var entry in cartItems.entries) {
      final item = await db.query(
        'food_items',
        where: 'name = ?',
        whereArgs: [entry.key],
        limit: 1,
      );

      // Debugging fetched item
      print('Fetched item for ${entry.key}: $item');

      if (item.isNotEmpty) {
        totalCost += (item.first['cost'] as double) * entry.value;
      }
    }

    String items = cartItems.entries.map((e) => '${e.key}:${e.value}').join(',');

    // Debugging total cost
    print('Total Cost: $totalCost');

    final result = await db.insert('orders', {
      'date': date,
      'items': items,
      'total_cost': totalCost,
    });

    if (result > 0) {
      print('Order saved successfully with ID: $result');
    } else {
      print('Order failed to save.');
    }

    // Debugging: Fetch all orders after save
    final orders = await db.query('orders');
    print('Orders in DB after save: $orders');
  }


  // Fetch all orders
  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await initDB();
    final results = await db.query('orders');
    print('getAllOrders results: $results'); // Debugging fetched orders
    return results;
  }

  // Query orders by a specific date
  static Future<List<Map<String, dynamic>>> queryOrders(String date) async {
    final db = await initDB();
    final results = await db.query(
      'orders',
      where: 'date = ?',
      whereArgs: [date],
    );
    print('Queried orders for date $date: $results');
    return results;
  }

  // Update an existing order
  static Future<void> updateOrder(int orderId, String updatedItems) async {
    final db = await initDB();
    await db.update(
      'orders',
      {'items': updatedItems},
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('Order $orderId updated with items: $updatedItems');
  }

  // Delete an order by its ID
  static Future<void> deleteOrder(int orderId) async {
    final db = await initDB();
    await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    print('Order with ID $orderId deleted');
  }
}
