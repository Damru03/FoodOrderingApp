import 'package:flutter/foundation.dart';

import '../db_helper.dart';

class CartModel extends ChangeNotifier {
  final Map<String, int> _cartItems = {}; // Item name and quantity

  Map<String, int> get cartItems => _cartItems;

  void addItem(String itemName) {
    if (_cartItems.containsKey(itemName)) {
      _cartItems[itemName] = _cartItems[itemName]! + 1;
    } else {
      _cartItems[itemName] = 1;
    }
    notifyListeners();
  }

  void removeItem(String itemName) {
    if (_cartItems.containsKey(itemName)) {
      _cartItems[itemName] = _cartItems[itemName]! - 1;
      if (_cartItems[itemName]! <= 0) {
        _cartItems.remove(itemName);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Calculate the subtotal cost
  Future<double> getSubtotal() async {
    double subtotal = 0.0;
    final db = await DBHelper.initDB();
    for (final entry in _cartItems.entries) {
      final itemName = entry.key;
      final quantity = entry.value;

      // Fetch the price of the item from the database
      final result = await db.query(
        'food_items',
        where: 'name = ?',
        whereArgs: [itemName],
        limit: 1,
      );

      if (result.isNotEmpty) {
        subtotal += (result.first['cost'] as double) * quantity;
      }
    }
    return subtotal;
  }
}

