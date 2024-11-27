import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'item_dialog.dart'; // Import the ItemDialog widget

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    final data = await DBHelper.getItems();
    setState(() => _items = data);
  }

  void _addItem() async {
    await showDialog(
      context: context,
      builder: (context) => ItemDialog(
        onSubmit: (name, cost) async {
          await DBHelper.insertItem(name, double.parse(cost));
          _refreshItems();
        },
      ),
    );
  }

  void _editItem(int id, String name, double cost) async {
    await showDialog(
      context: context,
      builder: (context) => ItemDialog(
        initialName: name,
        initialCost: cost.toString(),
        onSubmit: (newName, newCost) async {
          await DBHelper.updateItem(id, newName, double.parse(newCost));
          _refreshItems();
        },
      ),
    );
  }

  void _deleteItem(int id) async {
    await DBHelper.deleteItem(id);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return InkWell(
              onTap: _addItem,
              child: Container(
                height: 50,
                color: Colors.deepPurpleAccent,
                alignment: Alignment.center,
                child: const Text(
                  '+ Add Item',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            );
          }
          final item = _items[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Cost: \$${item['cost']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _editItem(item['id'], item['name'], item['cost']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(item['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
