import 'package:flutter/material.dart';

// This page is for managing the insertions and editing of data making sure that everything sindie is valid and everything is filled out.

class ItemDialog extends StatefulWidget {
  final String? initialName;
  final String? initialCost;
  final Function(String name, String cost) onSubmit;

  const ItemDialog({
    super.key,
    this.initialName,
    this.initialCost,
    required this.onSubmit,
  });

  @override
  State<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _costController = TextEditingController(text: widget.initialCost ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

// check if the picked state is add item or edit item.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // have the user input the name of the item
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            // have the user input the cost of the item
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a cost';
                }
                final parsedValue = double.tryParse(value);
                if (parsedValue == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      // cancel and submit buttons for the form
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_nameController.text, _costController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
