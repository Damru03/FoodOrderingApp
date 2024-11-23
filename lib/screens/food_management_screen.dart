import 'package:flutter/material.dart';
import '../db_helper.dart';

class FoodManagementScreen extends StatefulWidget {
  @override
  _FoodManagementScreenState createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> {
  List<Map<String, dynamic>> foodItems = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    final items = await DBHelper.getFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  Future<void> addFoodItem() async {
    final name = nameController.text.trim();
    final cost = double.tryParse(costController.text.trim());
    if (name.isEmpty || cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid name and cost')),
      );
      return;
    }

    await DBHelper.addFoodItem(name, cost);
    fetchFoodItems();
    nameController.clear();
    costController.clear();
  }

  Future<void> updateFoodItem(int id) async {
    final name = nameController.text.trim();
    final cost = double.tryParse(costController.text.trim());
    if (name.isEmpty || cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid name and cost')),
      );
      return;
    }

    await DBHelper.updateFoodItem(id, name, cost);
    fetchFoodItems();
    nameController.clear();
    costController.clear();
  }

  Future<void> deleteFoodItem(int id) async {
    await DBHelper.deleteFoodItem(id);
    fetchFoodItems();
  }

  void showEditDialog(Map<String, dynamic> foodItem) {
    nameController.text = foodItem['name'];
    costController.text = foodItem['cost'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Food Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: costController,
              decoration: InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await updateFoodItem(foodItem['id']);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Food Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: costController,
                  decoration: InputDecoration(labelText: 'Cost'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addFoodItem,
                  child: Text('Add Food Item'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final foodItem = foodItems[index];
                return ListTile(
                  title: Text(foodItem['name']),
                  subtitle: Text('Cost: \$${foodItem['cost']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showEditDialog(foodItem),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFoodItem(foodItem['id']),
                      ),
                    ],
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
