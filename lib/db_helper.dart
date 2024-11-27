import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'sample_food_items.dart';

class DBHelper {
  static const String foodTable = 'food_items';
  static const String budgetTable = 'budgets';
  static const String orderTable = 'orders';

  // Part of the code dealing with the creation of the three database tables.

  static Future<Database> _getDatabase() async {
    final String dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $foodTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cost REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $budgetTable(
            date TEXT PRIMARY KEY,
            total_budget REAL NOT NULL,
            total_spent REAL DEFAULT 0.0
          )
        ''');
        await db.execute('''
          CREATE TABLE $orderTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            food_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (food_id) REFERENCES $foodTable (id),
            FOREIGN KEY (date) REFERENCES $budgetTable (date)
          )
        ''');
        await SampleFoodItems.insertSampleItems(db, foodTable);
      },
      version: 1,
    );
  }

  static Future<Database> getDatabase() async {
    return _getDatabase();
  }

  // Query to pull the items

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await _getDatabase();
    return db.query(foodTable);
  }

  //Updating a specific column in the database based on the ID

  static Future<void> updateItem(int id, String name, double cost) async {
    final db = await _getDatabase();
    await db.update(
      foodTable,
      {'name': name, 'cost': cost},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deleting an item from the database

  static Future<void> deleteItem(int id) async {
    final db = await _getDatabase();
    await db.delete(
      foodTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> insertItem(String name, double cost) async {
    final db = await _getDatabase();
    await db.insert(
      foodTable,
      {'name': name, 'cost': cost},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // creating the budget columns that gets used in the

  static Future<void> createBudget(String date, double totalBudget) async {
    final db = await _getDatabase();
    await db.insert(
      budgetTable,
      {'date': date, 'total_budget': totalBudget, 'total_spent': 0.0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Query to get the budget of a specific date

  static Future<Map<String, dynamic>?> getBudget(String date) async {
    final db = await _getDatabase();
    final result = await db.query(
      budgetTable,
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Updating the budget spend of a specific date

  static Future<void> updateBudgetSpent(String date, double totalSpent) async {
    final db = await _getDatabase();
    await db.update(
      budgetTable,
      {'total_spent': totalSpent},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

// Adding an order to the order table

  static Future<void> insertOrder(String date, int foodId, int quantity) async {
    final db = await _getDatabase();
    await db.insert(
      orderTable,
      {'date': date, 'food_id': foodId, 'quantity': quantity},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//getting the orders of a specific date

  static Future<List<Map<String, dynamic>>> getOrdersByDate(String date) async {
    final db = await _getDatabase();
    return db.query(
      orderTable,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

// deleting an order of a specific date.

  static Future<void> deleteOrdersByDate(String date) async {
    final db = await _getDatabase();
    await db.delete(
      orderTable,
      where: 'date = ?',
      whereArgs: [date],
    );
  }
}
