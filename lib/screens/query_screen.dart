import 'package:flutter/material.dart';
import '../db_helper.dart';

class QueryScreen extends StatefulWidget {
  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final TextEditingController dateController = TextEditingController();
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> displayedOrders = [];
  String sortCriteria = 'Date Ascending';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    try {
      final results = await DBHelper.getAllOrders();
      setState(() {
        orders = results.toList();
        displayedOrders = results.toList();
      });
      sortOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    }
  }

  void sortOrders() {
    setState(() {
      if (sortCriteria == 'Date Ascending') {
        displayedOrders.sort((a, b) => a['date'].compareTo(b['date']));
      } else if (sortCriteria == 'Date Descending') {
        displayedOrders.sort((a, b) => b['date'].compareTo(a['date']));
      } else if (sortCriteria == 'Total Cost Ascending') {
        displayedOrders.sort((a, b) {
          final costA = a['total_cost'] ?? 0.0;
          final costB = b['total_cost'] ?? 0.0;
          return costA.compareTo(costB);
        });
      } else if (sortCriteria == 'Total Cost Descending') {
        displayedOrders.sort((a, b) {
          final costA = a['total_cost'] ?? 0.0;
          final costB = b['total_cost'] ?? 0.0;
          return costB.compareTo(costA);
        });
      }
    });
  }

  Future<void> pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        filterOrders();
      });
    }
  }

  void filterOrders() {
    if (startDate == null || endDate == null) return;

    setState(() {
      displayedOrders = orders.where((order) {
        final orderDate = DateTime.parse(order['date']);
        return orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
            orderDate.isBefore(endDate!.add(Duration(days: 1)));
      }).toList();
      sortOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: sortCriteria,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        sortCriteria = newValue;
                        sortOrders();
                      });
                    }
                  },
                  items: [
                    'Date Ascending',
                    'Date Descending',
                    'Total Cost Ascending',
                    'Total Cost Descending',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => pickDateRange(context),
                  child: Text(
                    startDate == null || endDate == null
                        ? 'Select Date Range'
                        : 'Selected: ${startDate!.toLocal().toString().split(' ')[0]} - ${endDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedOrders.length,
              itemBuilder: (context, index) {
                final order = displayedOrders[index];
                return Card(
                  child: ListTile(
                    title: Text('Date: ${order['date']}'),
                    subtitle: Text('Total Cost: \$${order['total_cost'] ?? 'N/A'}'),
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
