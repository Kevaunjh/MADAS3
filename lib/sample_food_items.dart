import 'package:sqflite/sqflite.dart';

// Page to create the sameple values of the table.

class SampleFoodItems {
  static final List<Map<String, dynamic>> items = [
    {'name': 'Pizza', 'cost': 10.0},
    {'name': 'Burger', 'cost': 8.0},
    {'name': 'Pasta', 'cost': 12.0},
    {'name': 'Salad', 'cost': 7.0},
    {'name': 'Sushi', 'cost': 15.0},
    {'name': 'Fries', 'cost': 5.0},
    {'name': 'Steak', 'cost': 20.0},
    {'name': 'Tacos', 'cost': 9.0},
    {'name': 'Sandwich', 'cost': 6.0},
    {'name': 'Soup', 'cost': 4.0},
    {'name': 'Nachos', 'cost': 8.0},
    {'name': 'Chicken Wings', 'cost': 10.0},
    {'name': 'Hot Dog', 'cost': 6.0},
    {'name': 'Ramen', 'cost': 11.0},
    {'name': 'Fried Rice', 'cost': 8.0},
    {'name': 'Spring Rolls', 'cost': 5.0},
    {'name': 'Ice Cream', 'cost': 4.0},
    {'name': 'Brownie', 'cost': 6.0},
    {'name': 'Cheesecake', 'cost': 7.0},
    {'name': 'Smoothie', 'cost': 5.0},
  ];

  // insert it into the database

  static Future<void> insertSampleItems(Database db, String tableName) async {
    final existingItems = await db.query(tableName);
    if (existingItems.isEmpty) {
      print('Inserting sample food items...');
      for (var item in items) {
        await db.insert(tableName, item);
      }
    } else {
      print('Sample food items already exist in the database.');
    }
  }
}
