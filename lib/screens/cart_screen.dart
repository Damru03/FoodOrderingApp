import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../db_helper.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DateTime? selectedDate;
  final TextEditingController targetCostController = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _showOrderSummary(BuildContext context, CartModel cart) async {
    final subtotal = await cart.getSubtotal();
    final taxes = subtotal * 0.13; // Assuming 13% tax
    final total = subtotal + taxes;
    final targetCost = double.tryParse(targetCostController.text) ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...cart.cartItems.entries.map((entry) {
                return Text('${entry.key}: Quantity: ${entry.value}');
              }).toList(),
              Divider(),
              Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
              Text('Taxes (13%): \$${taxes.toStringAsFixed(2)}'),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
              Text('Target Cost: \$${targetCost.toStringAsFixed(2)}'),
              Text(
                'Selected Date: ${selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'No date selected'}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (selectedDate != null && total <= targetCost) {
                  print('Save order called with date: $selectedDate');
                  await DBHelper.saveOrder(
                      cart.cartItems, selectedDate!.toIso8601String());
                  cart.clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order saved successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Order exceeds target cost or no date selected!'),
                    ),
                  );
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                final itemName = cart.cartItems.keys.elementAt(index);
                final quantity = cart.cartItems[itemName];

                return ListTile(
                  leading: Icon(Icons.fastfood),
                  title: Text(itemName),
                  subtitle: Text('Quantity: $quantity'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      cart.removeItem(itemName);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: targetCostController,
                  decoration: InputDecoration(
                    labelText: 'Enter Target Cost',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Text(
                  selectedDate == null
                      ? 'No Date Selected'
                      : 'Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: Text('Pick a Date'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showOrderSummary(context, cart),
                  child: Text('Save Order'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    cart.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cart cleared!')),
                    );
                  },
                  child: Text('Clear Cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
