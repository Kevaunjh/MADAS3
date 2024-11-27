import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'sample_food_items.dart';
import 'menu_page.dart';
import 'budget_page.dart';
import 'search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase(); // Initialize the database
  runApp(const MyApp());
}

Future<void> initializeDatabase() async {
  final db = await DBHelper.getDatabase(); // Use the public method
  await SampleFoodItems.insertSampleItems(db, DBHelper.foodTable);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tab Navigation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TabNavigation(),
    );
  }
}

class TabNavigation extends StatefulWidget {
  const TabNavigation({super.key});

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Menu';
      case 1:
        return 'Budget';
      case 2:
        return 'Search';
      default:
        return 'Tab Navigation';
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const MenuPage();
      case 1:
        return const BudgetPage();
      case 2:
        return const SearchPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}
