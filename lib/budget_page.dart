import 'package:flutter/material.dart';
import 'db_helper.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with WidgetsBindingObserver {
  final TextEditingController _targetCostController = TextEditingController();
  DateTime? _selectedDate;
  double _totalBudget = 0.0;
  List<Map<String, dynamic>> _foodItems = [];
  Map<int, int> _selectedQuantities = {}; // Track quantities by food item ID.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for app lifecycle
    _loadFoodItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFoodItems();
    }
  }

  Future<void> _loadFoodItems() async {
    try {
      final data = await DBHelper.getItems();
      print('Loaded Food Items: $data'); // Debug log to check data.
      setState(() {
        _foodItems = data.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'cost': (item['cost'] is double)
                ? item['cost']
                : double.tryParse(item['cost'].toString()) ?? 0.0,
          };
        }).toList();
      });
    } catch (error) {
      print('Error loading food items: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load food items.')),
      );
    }
  }

  double get _totalSelectedCost {
    return _selectedQuantities.entries.fold(0, (sum, entry) {
      final item = _foodItems.firstWhere((food) => food['id'] == entry.key);
      return sum + (item['cost'] * entry.value);
    });
  }

  void _incrementQuantity(int itemId) {
    setState(() {
      _selectedQuantities[itemId] = (_selectedQuantities[itemId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(int itemId) {
    setState(() {
      if ((_selectedQuantities[itemId] ?? 0) > 0) {
        _selectedQuantities[itemId] = _selectedQuantities[itemId]! - 1;
      }
      if (_selectedQuantities[itemId] == 0) {
        _selectedQuantities.remove(itemId);
      }
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
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _createBudget() async {
    if (_selectedDate == null || _totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a valid date and budget.')),
      );
      return;
    }

    final dateString =
        '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}';
    final existingBudget = await DBHelper.getBudget(dateString);

    if (existingBudget != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A budget already exists for this date.')),
      );
      return;
    }

    await DBHelper.createBudget(dateString, _totalBudget);
    for (var entry in _selectedQuantities.entries) {
      await DBHelper.insertOrder(dateString, entry.key, entry.value);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget and orders saved successfully!')),
    );
    _resetPage();
  }

  void _resetPage() {
    setState(() {
      _selectedQuantities.clear();
      _targetCostController.clear();
      _totalBudget = 0.0;
      _selectedDate = null;
      _loadFoodItems();
    });
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
                  child: TextField(
                    controller: _targetCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Set Your Total Budget',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _totalBudget = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: _selectDate,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Food Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _foodItems.isEmpty
                  ? const Center(
                      child: Text('No food items available.'),
                    )
                  : ListView.builder(
                      itemCount: _foodItems.length,
                      itemBuilder: (context, index) {
                        final item = _foodItems[index];
                        final quantity = _selectedQuantities[item['id']] ?? 0;
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text('Cost: \$${item['cost']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.remove, color: Colors.red),
                                onPressed: quantity > 0
                                    ? () => _decrementQuantity(item['id'])
                                    : null,
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.green),
                                onPressed: _totalSelectedCost + item['cost'] <=
                                        _totalBudget
                                    ? () => _incrementQuantity(item['id'])
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Selected Cost: \$${_totalSelectedCost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _totalSelectedCost > _totalBudget
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            Text(
              'Total Budget: \$${_totalBudget.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetPage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _createBudget,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
