import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'item_dialog.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _items = [];

//make sure that the items reset on reentry

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

//repull the items from the db
  Future<void> _refreshItems() async {
    final data = await DBHelper.getItems();
    setState(() => _items = data);
  }

// add a new item based on the items in the dialog class
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

// edit item based on the items in the dialog class

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

//remove an item based on its ID

  void _deleteItem(int id) async {
    await DBHelper.deleteItem(id);
    _refreshItems();
  }

//build the application

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        // hold the add item at the bottom of the list.
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
          } // hold the items name and cost with the edit and delete button.
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
