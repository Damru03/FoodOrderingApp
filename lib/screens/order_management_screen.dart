import 'package:flutter/material.dart';
import '../db_helper.dart';

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // Fetch all orders from the database
  Future<void> fetchOrders() async {
    try {
      final results = await DBHelper.getAllOrders();

      // Debugging: Log fetched orders
      print('Fetched Orders: $results');

      setState(() {
        orders = results;
        print('Orders updated in UI: $orders');
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper method to parse items string (e.g., "Pizza:2,Burger:1")
  String parseItems(String items) {
    final parsed = items.split(',');
    return parsed.map((e) {
      final parts = e.split(':');
      return '${parts[0]} x ${parts[1]}';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Orders'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(
        child: Text(
          'No orders found.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              title: Text('Date: ${order['date']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items: ${parseItems(order['items'])}'),
                  Text('Total Cost: \$${order['total_cost'] ?? 0.0}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
