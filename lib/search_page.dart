import 'package:flutter/material.dart';
import 'db_helper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Initialize all of the variables and extra componenets

  DateTime? _selectedDate;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _foodItems = [];
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  // query the good items

  Future<void> _loadFoodItems() async {
    final items = await DBHelper.getItems();
    setState(() {
      _foodItems = items;
    });
  }

// get the selected date

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

// determine what day is picked

    if (picked != null) {
      final dateString = '${picked.year}-${picked.month}-${picked.day}';
      final orders = await DBHelper.getOrdersByDate(dateString);

// calculate total cost
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

// build the app componenet
  @override
  Widget build(BuildContext context) {
// build the applications top ba rwith the text for seracging and the date picker button.
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
                ), // cover the calendar controls
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
                    // if an order is found display all of the corresponding items
                    child: ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final foodItem = _foodItems.firstWhere(
                          (item) => item['id'] == order['food_id'],
                          // if the food item is no longer in the DB
                          orElse: () => {
                            'name': 'We no longer have this item.',
                            'cost': 0.0
                          },
                        );
                        return ListTile(
                          title: Text(foodItem['name']),
                          subtitle: Text(
                              // find the number of items in the db for the speicifc item
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
