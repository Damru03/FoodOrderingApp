import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../db_helper.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> foodItems = [];
  String sortCriteria = 'Name Ascending'; // Default sort option

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    try {
      // Fetch food items and convert to mutable list
      final items = (await DBHelper.getFoodItems()).toList();
      setState(() {
        foodItems = items;
      });
      sortItems(); // Apply default sorting
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching food items: $e')),
      );
    }
  }

  void sortItems() {
    setState(() {
      if (sortCriteria == 'Name Ascending') {
        foodItems.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (sortCriteria == 'Name Descending') {
        foodItems.sort((a, b) => b['name'].compareTo(a['name']));
      } else if (sortCriteria == 'Price Ascending') {
        foodItems.sort((a, b) {
          final costA = a['cost'] ?? 0.0;
          final costB = b['cost'] ?? 0.0;
          return costA.compareTo(costB);
        });
      } else if (sortCriteria == 'Price Descending') {
        foodItems.sort((a, b) {
          final costA = a['cost'] ?? 0.0;
          final costB = b['cost'] ?? 0.0;
          return costB.compareTo(costA);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cart.cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.cartItems.length}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cart'); // Navigate to CartScreen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort By:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: sortCriteria,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        sortCriteria = newValue;
                        sortItems();
                      });
                    }
                  },
                  items: [
                    'Name Ascending',
                    'Name Descending',
                    'Price Ascending',
                    'Price Descending',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.fastfood),
                    title: Text(item['name']),
                    subtitle: Text('Price: \$${item['cost']}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        cart.addItem(item['name']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} added to cart!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text('Add to Cart'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
