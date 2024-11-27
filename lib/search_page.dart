import 'package:flutter/material.dart';
import 'db_helper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _foodItems = []; // Stores food item details
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await DBHelper.getItems(); // Fetch food items
    setState(() {
      _foodItems = items;
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final dateString = '${picked.year}-${picked.month}-${picked.day}';
      final orders = await DBHelper.getOrdersByDate(dateString);

      // Calculate total cost
      double totalCost = 0.0;
      for (final order in orders) {
        final foodItem = _foodItems.firstWhere(
          (item) => item['id'] == order['food_id'],
          orElse: () => {'name': 'Unknown', 'cost': 0.0},
        );
        totalCost += (foodItem['cost'] * order['quantity']);
      }

      setState(() {
        _selectedDate = picked;
        _orders = orders;
        _totalCost = totalCost;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Select a date to view orders'
                        : 'Orders for: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: _selectDate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _orders.isEmpty
                ? const Center(
                    child: Text('No orders found for the selected date.'),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final foodItem = _foodItems.firstWhere(
                          (item) => item['id'] == order['food_id'],
                          orElse: () => {'name': 'Unknown', 'cost': 0.0},
                        );
                        return ListTile(
                          title: Text(foodItem['name']),
                          subtitle: Text(
                              'Quantity: ${order['quantity']} | Cost: \$${(foodItem['cost'] * order['quantity']).toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 16),
            if (_orders.isNotEmpty)
              Text(
                'Total Cost: \$${_totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
